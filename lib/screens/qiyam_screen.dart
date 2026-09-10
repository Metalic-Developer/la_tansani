import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../models/ayah.dart';
import '../repositories/quran_repository.dart';
import '../services/assignment_service.dart';
import '../services/auth_service.dart';
import '../services/recitation_engine.dart';
import '../widgets/ayah_card.dart';

class QiyamScreen extends StatefulWidget {
  final Assignment assignment;
  const QiyamScreen({super.key, required this.assignment});

  @override
  State<QiyamScreen> createState() => _QiyamScreenState();
}

class _QiyamScreenState extends State<QiyamScreen> {
  final _quran = QuranRepository();
  final _engine = RecitationEngine();
  final _assignments = AssignmentService();

  List<Ayah> ayat = [];
  bool loading = true;
  bool finishing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await _quran.getAyatRange(
      surah: widget.assignment.surah,
      startAyah: widget.assignment.startAyah,
      endAyah: widget.assignment.endAyah,
    );
    if (result.isEmpty) {
      if (mounted) setState(() => loading = false);
      return;
    }
    final user = await AuthService().getCurrentUser();
    if (user == null) {
      if (mounted) setState(() => loading = false);
      return;
    }
    await _engine.start(
        assignmentId: widget.assignment.id, studentId: user.id, ayat: result);
    await _assignments.startAssignment(widget.assignment.id);
    if (!mounted) return;
    setState(() {
      ayat = result;
      loading = false;
    });
  }

  Future<void> _recordMistake(Ayah a) async {
    await _engine.recordMistake(ayahId: a.id, mistakeType: 'qiyam_recitation');
    if (mounted) setState(() {});
  }

  Future<void> _complete() async {
    if (finishing || ayat.isEmpty) return;
    final c = _engine.currentAyah;
    if (c == null) return;
    setState(() => finishing = true);
    try {
      await _engine.confirmCurrentAyah();
      await _engine.finish();
      await _assignments.completeAssignment(
        assignmentId: widget.assignment.id,
        lastAyahId: c.id,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => finishing = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('تعذر إنهاء القيام: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (ayat.isEmpty) {
      return const Scaffold(body: Center(child: Text('لا يوجد ورد قيام اليوم')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('قيام الليل')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
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
                final a = ayat[i];
                return GestureDetector(
                  onTap: () async {
                    await _engine.goToIndex(i);
                    if (mounted) setState(() {});
                  },
                  child: AyahCard(
                    ayah: a,
                    hasMistake: _engine.mistakeAyat.contains(a.id),
                    onMistake: () => _recordMistake(a),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton(
              onPressed: finishing ? null : _complete,
              child: finishing
                  ? const CircularProgressIndicator()
                  : const Text('تم إتمام قيام الليل'),
            ),
          ),
        ),
      ),
    );
  }
}