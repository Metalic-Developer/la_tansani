import 'package:flutter/material.dart';

import '../models/assignment.dart';
import '../models/ayah.dart';
import '../repositories/mistake_repository.dart';
import '../repositories/quran_repository.dart';
import '../services/assignment_service.dart';
import '../services/audio_player_service.dart';
import '../widgets/ayah_card.dart';

class QuranAssignmentScreen extends StatefulWidget {
  final Assignment? assignment;

  const QuranAssignmentScreen({super.key, this.assignment});

  @override
  State<QuranAssignmentScreen> createState() => _QuranAssignmentScreenState();
}

class _QuranAssignmentScreenState extends State<QuranAssignmentScreen> {
  final QuranRepository _quran = QuranRepository();
  final MistakeRepository _mistakes = MistakeRepository();

  List<Ayah> ayat = [];
  final Set<int> mistakeAyat = {};
  bool loading = true;
  int? lastAyahId;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final assignment = widget.assignment;
    if (assignment == null) {
      setState(() => loading = false);
      return;
    }

    final result = await _quran.getAyatRange(
      surah: assignment.surah,
      startAyah: assignment.startAyah,
      endAyah: assignment.endAyah,
    );

    if (!mounted) return;
    setState(() {
      ayat = result;
      loading = false;
    });
  }

  Future<void> markMistake(Ayah ayah) async {
    await _mistakes.addRecitationMistake(ayah.id);
    if (!mounted) return;
    setState(() {
      mistakeAyat.add(ayah.id);
    });
  }

  Future<void> complete() async {
    if (ayat.isEmpty || widget.assignment == null) return;
    final last = lastAyahId ?? ayat.last.id;

    await AssignmentService().completeAssignment(
      assignmentId: widget.assignment!.id,
      lastAyahId: last,
    );

    if (!mounted) return;

    await AudioPlayerService().playTodayMessage();

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.assignment == null) {
      return const Scaffold(body: Center(child: Text('لا يوجد ورد قرآن اليوم')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.assignment!.surahName} ${widget.assignment!.startAyah}-${widget.assignment!.endAyah}',
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: ayat.length,
        itemBuilder: (context, index) {
          final ayah = ayat[index];
          return AyahCard(
            ayah: ayah,
            hasMistake: mistakeAyat.contains(ayah.id),
            onMistake: () {
              lastAyahId = ayah.id;
              markMistake(ayah);
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: FilledButton(
            onPressed: complete,
            child: const Text('إنهاء ورد القرآن'),
          ),
        ),
      ),
    );
  }
}
