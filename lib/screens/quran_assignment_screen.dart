import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../models/ayah.dart';
import '../repositories/quran_repository.dart';
import '../services/assignment_service.dart';
import '../services/audio_player_service.dart';
import '../services/auth_service.dart';
import '../services/recitation_engine.dart';
import '../widgets/audio_message_sheet.dart';
import '../widgets/ayah_card.dart';

class QuranAssignmentScreen extends StatefulWidget {
  final Assignment? assignment;
  const QuranAssignmentScreen({super.key, this.assignment});

  @override
  State<QuranAssignmentScreen> createState() => _QuranAssignmentScreenState();
}

class _QuranAssignmentScreenState extends State<QuranAssignmentScreen> {
  final _quran = QuranRepository();
  final _engine = RecitationEngine();
  final _assignments = AssignmentService();

  List<Ayah> ayat = [];
  bool loading = true;
  bool finishing = false;
  bool showAppBar = true;

  @override
  void initState() {
    super.initState();
    showAppBar = widget.assignment != null;
    _load();
  }

  Future<void> _load() async {
    final a = widget.assignment;
    if (a == null) {
      if (mounted) setState(() => loading = false);
      return;
    }

    final result = await _quran.getAyatRange(
      surah: a.surah, startAyah: a.startAyah, endAyah: a.endAyah);
    if (result.isEmpty) {
      if (mounted) setState(() => loading = false);
      return;
    }

    final user = await AuthService().getCurrentUser();
    if (user == null) {
      if (mounted) setState(() => loading = false);
      return;
    }

    await _engine.start(assignmentId: a.id, studentId: user.id, ayat: result);
    await _assignments.startAssignment(a.id);

    if (!mounted) return;
    setState(() {
      ayat = result;
      loading = false;
    });
  }

  Future<void> _recordMistake(Ayah ayah) async {
    try {
      await _engine.recordMistake(ayahId: ayah.id, mistakeType: 'recitation');
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر تسجيل الخطأ: $e')));
    }
  }

  Future<void> _complete() async {
    if (finishing || ayat.isEmpty || widget.assignment == null) return;
    final current = _engine.currentAyah;
    if (current == null) return;

    setState(() => finishing = true);
    try {
      await _engine.confirmCurrentAyah();
      await _engine.finish();
      await _assignments.completeAssignment(
        assignmentId: widget.assignment!.id,
        lastAyahId: current.id,
      );

      final message = await AudioPlayerService.instance.getTodayMessage();
      if (!mounted) return;

      if (message != null) {
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AudioMessageSheet(message: message),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => finishing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذر إنهاء الورد: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (widget.assignment == null || ayat.isEmpty) {
      return const Scaffold(body: Center(child: Text('لا يوجد ورد قرآن اليوم')));
    }

    final body = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
          child: Row(
            children: [
              Text('الآية ${_engine.currentIndex + 1} من ${ayat.length}'),
              const Spacer(),
              Text('الأخطاء: ${_engine.mistakeCount}'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: ayat.length,
            itemBuilder: (context, i) {
              final ayah = ayat[i];
              return GestureDetector(
                onTap: () async {
                  await _engine.goToIndex(i);
                  if (mounted) setState(() {});
                },
                child: AyahCard(
                  ayah: ayah,
                  hasMistake: _engine.mistakeAyat.contains(ayah.id),
                  onMistake: () => _recordMistake(ayah),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    await _engine.confirmCurrentAyah();
                    final c = _engine.currentAyah;
                    if (c != null) {
                      await _assignments.setLastAyah(
                        assignmentId: widget.assignment!.id,
                        lastAyahId: c.id,
                      );
                    }
                    if (mounted) setState(() {});
                  },
                  child: const Text('تأكيد الوقوف عند هذه الآية'),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed: finishing ? null : _complete,
                    child: finishing
                        ? const CircularProgressIndicator()
                        : const Text('أنهيت ورد القرآن'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (showAppBar) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.assignment!.surahName} ${widget.assignment!.startAyah}-${widget.assignment!.endAyah}',
          ),
        ),
        body: body,
      );
    }
    return Scaffold(body: body);
  }
}