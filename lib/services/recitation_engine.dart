import '../models/ayah.dart';
import '../repositories/mistake_repository.dart';
import '../repositories/session_repository.dart';

class RecitationEngine {
  RecitationEngine({SessionRepository? sessions, MistakeRepository? mistakes})
      : _sessions = sessions ?? SessionRepository(),
        _mistakes = mistakes ?? MistakeRepository();

  final SessionRepository _sessions;
  final MistakeRepository _mistakes;

  int? _sessionId;
  List<Ayah> _ayat = [];
  int _currentIndex = 0;
  final Set<int> _mistakeAyat = {};
  bool _finished = false;

  int? get sessionId => _sessionId;
  int get currentIndex => _currentIndex;
  int get totalAyat => _ayat.length;
  bool get hasNext => _ayat.isNotEmpty && _currentIndex < _ayat.length - 1;
  bool get hasPrevious => _currentIndex > 0;
  bool get finished => _finished;
  Set<int> get mistakeAyat => Set.unmodifiable(_mistakeAyat);
  int get mistakeCount => _mistakeAyat.length;

  Ayah? get currentAyah {
    if (_ayat.isEmpty) return null;
    if (_currentIndex < 0 || _currentIndex >= _ayat.length) return null;
    return _ayat[_currentIndex];
  }

  int? get currentAyahId => currentAyah?.id;
  int? get lastConfirmedAyahId =>
      (_currentIndex < 0 || _ayat.isEmpty) ? null : _ayat[_currentIndex].id;

  Future<void> start({
    required String assignmentId,
    required String studentId,
    required List<Ayah> ayat,
  }) async {
    if (ayat.isEmpty) throw StateError('لا يمكن بدء جلسة بدون آيات.');
    _ayat = List.from(ayat);
    _currentIndex = 0;
    _finished = false;
    _mistakeAyat.clear();
    _sessionId = await _sessions.createSession(
      assignmentId: assignmentId,
      studentId: studentId,
      currentAyahId: _ayat.first.id,
    );
  }

  Future<void> restore({
    required int sessionId,
    required List<Ayah> ayat,
    int? currentAyahId,
  }) async {
    if (ayat.isEmpty) throw StateError('لا يمكن استعادة جلسة بدون آيات.');
    _ayat = List.from(ayat);
    _sessionId = sessionId;
    _finished = false;
    _mistakeAyat.clear();
    if (currentAyahId == null) {
      _currentIndex = 0;
      return;
    }
    final index = _ayat.indexWhere((a) => a.id == currentAyahId);
    _currentIndex = index >= 0 ? index : 0;
  }

  Future<void> goToIndex(int index) async {
    if (_ayat.isEmpty) return;
    _currentIndex = index.clamp(0, _ayat.length - 1);
    final s = _sessionId;
    if (s == null || currentAyah == null) return;
    await _sessions.updateCurrentAyah(sessionId: s, ayahId: currentAyah!.id);
  }

  Future<void> goToAyah(int ayahId) async {
    final index = _ayat.indexWhere((a) => a.id == ayahId);
    if (index < 0) return;
    await goToIndex(index);
  }

  Future<void> next() async {
    if (!hasNext) return;
    _currentIndex++;
    await goToIndex(_currentIndex);
  }

  Future<void> previous() async {
    if (!hasPrevious) return;
    _currentIndex--;
    await goToIndex(_currentIndex);
  }

  Future<void> recordMistake({
    required int ayahId,
    String? mistakeType,
    String? note,
  }) async {
    if (_sessionId == null) throw StateError('يجب بدء جلسة التسميع أولًا.');
    if (!_ayat.any((a) => a.id == ayahId)) {
      throw ArgumentError('الآية ليست ضمن نطاق الجلسة.');
    }
    _mistakeAyat.add(ayahId);
    await _mistakes.addRecitationMistake(ayahId);
    await _sessions.addMistakeToSession(
      sessionId: _sessionId!,
      ayahId: ayahId,
      mistakeType: mistakeType,
      note: note,
    );
  }

  Future<void> confirmCurrentAyah() async {
    if (_sessionId == null || currentAyah == null) return;
    await _sessions.confirmAyah(sessionId: _sessionId!, ayahId: currentAyah!.id);
  }

  Future<void> finish() async {
    if (_sessionId == null || currentAyah == null || _finished) return;
    final count = await _sessions.getSessionMistakesCount(_sessionId!);
    await _sessions.endSession(
      sessionId: _sessionId!,
      lastAyahId: currentAyah!.id,
      mistakesCount: count,
    );
    _finished = true;
  }
}