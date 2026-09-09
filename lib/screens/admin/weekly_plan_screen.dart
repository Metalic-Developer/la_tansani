import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../repositories/quran_repository.dart';
import '../../services/supabase_service.dart';

class WeeklyPlanScreen extends StatefulWidget {
  final AppUser student;

  const WeeklyPlanScreen({super.key, required this.student});

  @override
  State<WeeklyPlanScreen> createState() => _WeeklyPlanScreenState();
}

class _WeeklyPlanScreenState extends State<WeeklyPlanScreen> {
  final List<String> days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
  final List<Map<String, dynamic>> surahs = [];

  final Map<int, int?> quranSurah = {};
  final Map<int, String?> quranSurahName = {};
  final Map<int, int?> quranStart = {};
  final Map<int, int?> quranEnd = {};

  final Map<int, int?> qiyamSurah = {};
  final Map<int, String?> qiyamSurahName = {};
  final Map<int, int?> qiyamStart = {};
  final Map<int, int?> qiyamEnd = {};

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final quranRepo = QuranRepository();
    final surahList = await quranRepo.getAllSurahs();

    final result = await SupabaseService.instance.client
        .from('weekly_plan_days')
        .select()
        .eq('student_id', widget.student.id);

    if (!mounted) return;

    setState(() {
      surahs.addAll(surahList.map((e) => {'id': e['sora'], 'name': e['sora_name']}));

      for (final item in result) {
        final day = item['weekday'] as int;
        quranSurah[day] = item['quran_surah'] as int?;
        quranSurahName[day] = item['quran_surah_name'] as String?;
        quranStart[day] = item['quran_start_ayah'] as int?;
        quranEnd[day] = item['quran_end_ayah'] as int?;

        qiyamSurah[day] = item['qiyam_surah'] as int?;
        qiyamSurahName[day] = item['qiyam_surah_name'] as String?;
        qiyamStart[day] = item['qiyam_start_ayah'] as int?;
        qiyamEnd[day] = item['qiyam_end_ayah'] as int?;
      }

      loading = false;
    });
  }

  Future<void> save() async {
    setState(() => saving = true);

    for (int day = 0; day < 7; day++) {
      await SupabaseService.instance.client.from('weekly_plan_days').upsert(
        {
          'student_id': widget.student.id,
          'weekday': day,
          'quran_surah': quranSurah[day],
          'quran_surah_name': quranSurahName[day],
          'quran_start_ayah': quranStart[day],
          'quran_end_ayah': quranEnd[day],
          'qiyam_surah': qiyamSurah[day],
          'qiyam_surah_name': qiyamSurahName[day],
          'qiyam_start_ayah': qiyamStart[day],
          'qiyam_end_ayah': qiyamEnd[day],
        },
        onConflict: 'student_id,weekday',
      );
    }

    if (!mounted) return;
    setState(() => saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ خطة الأسبوع')),
    );
  }

  Widget dayCard(int day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(days[day], style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('ورد القرآن', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<int>(
              initialValue: quranSurah[day],
              decoration: const InputDecoration(labelText: 'السورة'),
              items: surahs
                  .map((s) => DropdownMenuItem<int>(value: s['id'] as int, child: Text(s['name'] as String)))
                  .toList(),
              onChanged: (value) {
                final item = surahs.firstWhere((e) => e['id'] == value);
                setState(() {
                  quranSurah[day] = value;
                  quranSurahName[day] = item['name'];
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'من آية'),
                    onChanged: (value) => quranStart[day] = int.tryParse(value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'إلى آية'),
                    onChanged: (value) => quranEnd[day] = int.tryParse(value),
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            const Text('قيام الليل', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<int>(
              initialValue: qiyamSurah[day],
              decoration: const InputDecoration(labelText: 'السورة'),
              items: surahs
                  .map((s) => DropdownMenuItem<int>(value: s['id'] as int, child: Text(s['name'] as String)))
                  .toList(),
              onChanged: (value) {
                final item = surahs.firstWhere((e) => e['id'] == value);
                setState(() {
                  qiyamSurah[day] = value;
                  qiyamSurahName[day] = item['name'];
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'من آية'),
                    onChanged: (value) => qiyamStart[day] = int.tryParse(value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'إلى آية'),
                    onChanged: (value) => qiyamEnd[day] = int.tryParse(value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('خطة ${widget.student.username}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                for (int i = 0; i < 7; i++) dayCard(i),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: saving ? null : save,
                  child: saving ? const CircularProgressIndicator() : const Text('حفظ الخطة'),
                ),
              ],
            ),
    );
  }
}