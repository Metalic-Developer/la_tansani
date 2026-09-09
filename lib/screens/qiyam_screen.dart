import 'package:flutter/material.dart';

import '../models/assignment.dart';
import '../models/ayah.dart';
import '../repositories/quran_repository.dart';
import '../services/assignment_service.dart';
import '../widgets/ayah_card.dart';

class QiyamScreen extends StatefulWidget {
  final Assignment assignment;

  const QiyamScreen({super.key, required this.assignment});

  @override
  State<QiyamScreen> createState() => _QiyamScreenState();
}

class _QiyamScreenState extends State<QiyamScreen> {
  final QuranRepository repository = QuranRepository();
  List<Ayah> ayat = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final result = await repository.getAyatRange(
      surah: widget.assignment.surah,
      startAyah: widget.assignment.startAyah,
      endAyah: widget.assignment.endAyah,
    );
    if (!mounted) return;
    setState(() {
      ayat = result;
      loading = false;
    });
  }

  Future<void> complete() async {
    if (ayat.isEmpty) return;
    await AssignmentService().completeAssignment(
      assignmentId: widget.assignment.id,
      lastAyahId: ayat.last.id,
    );
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('قيام الليل')),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: ayat.length,
        itemBuilder: (_, index) {
          return AyahCard(
            ayah: ayat[index],
            hasMistake: false,
            onMistake: () {},
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: FilledButton(
            onPressed: complete,
            child: const Text('تم إتمام قيام الليل'),
          ),
        ),
      ),
    );
  }
}
