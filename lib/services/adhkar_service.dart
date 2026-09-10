import 'package:uuid/uuid.dart';
import '../core/app_day.dart';
import '../models/adhkar.dart';
import 'completion_engine.dart';
import 'supabase_service.dart';

class AdhkarService {
  AdhkarService({CompletionEngine? completionEngine})
      : _completionEngine = completionEngine ?? CompletionEngine();

  final _db = SupabaseService.instance.client;
  final _uuid = const Uuid();
  final CompletionEngine _completionEngine;

  Future<List<Dhikr>> getAdhkar({required String type, required int level}) async {
    final result = await _db
        .from('adhkar')
        .select()
        .eq('type', type)
        .eq('level', level)
        .eq('active', true)
        .order('sort_order');
    return (result as List)
        .map((e) => Dhikr.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<bool> isCompleted({required String studentId, required String type}) async {
    final day = AppDay.dateKey();
    final result = await _db
        .from('adhkar_completions')
        .select('id')
        .eq('student_id', studentId)
        .eq('day_key', day)
        .eq('type', type)
        .maybeSingle();
    return result != null;
  }

  Future<int> getLevel({required String studentId, required String type}) async {
    final result = await _db
        .from('adhkar_progress')
        .select()
        .eq('student_id', studentId)
        .eq('type', type)
        .maybeSingle();
    if (result == null) return 1;
    return (result['current_level'] as num).toInt();
  }

  Future<int> estimatedDurationSeconds({
    required String type,
    required int level,
  }) async {
    final items = await getAdhkar(type: type, level: level);
    return items.fold<int>(0, (sum, i) => sum + i.repetitions * 5);
  }

  Future<void> complete({required String studentId, required String type}) async {
    final day = AppDay.dateKey();
    if (await isCompleted(studentId: studentId, type: type)) return;

    await _db.from('adhkar_completions').upsert(
      {
        'id': _uuid.v4(),
        'student_id': studentId,
        'day_key': day,
        'type': type,
        'completed_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'student_id,day_key,type',
    );

    await _updateProgress(studentId: studentId, type: type, today: day);
    await _completionEngine.refreshForStudent(studentId);
  }

  Future<void> _updateProgress({
    required String studentId,
    required String type,
    required String today,
  }) async {
    final existing = await _db
        .from('adhkar_progress')
        .select()
        .eq('student_id', studentId)
        .eq('type', type)
        .maybeSingle();

    if (existing == null) {
      await _db.from('adhkar_progress').insert({
        'id': _uuid.v4(),
        'student_id': studentId,
        'type': type,
        'current_level': 1,
        'consecutive_days': 1,
        'last_completed_date': today,
      });
      return;
    }

    final currentLevel = (existing['current_level'] as num).toInt();
    final days = (existing['consecutive_days'] as num).toInt();
    final lastDate = existing['last_completed_date']?.toString();

    if (lastDate == today) return;

    final yesterday = AppDay.dateKey(
      DateTime.parse(today).subtract(const Duration(days: 1)),
    );

    final newDays = (lastDate == yesterday) ? days + 1 : 1;
    int newLevel = currentLevel;
    if (newDays >= 7 && currentLevel < 4) newLevel = currentLevel + 1;

    await _db.from('adhkar_progress').update({
      'current_level': newLevel,
      'consecutive_days': newDays,
      'last_completed_date': today,
    }).eq('id', existing['id']);
  }
}