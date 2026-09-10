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
  final _days = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
  final List<Map<String, dynamic>> _surahs = [];
  final Map<int, int> _surahAyahCount = {};

  final _qSurah = <int, int?>{};
  final _qSurahName = <int, String?>{};
  final _qStart = <int, int?>{};
  final _qEnd = <int, int?>{};
  final _ySurah = <int, int?>{};
  final _ySurahName = <int, String?>{};
  final _yStart = <int, int?>{};
  final _yEnd = <int, int?>{};

  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final quranRepo = QuranRepository();
    final surahList = await quranRepo.getAllSurahs();

    for (final s in surahList) {
      final count = await quranRepo.getAyatOfSora(s['sora'] as int);
      _surahAyahCount[s['sora'] as int] = count.length;
    }

    final result = await SupabaseService.instance.client
        .from('weekly_plan_days')
        .select()
        .eq('student_id', widget.student.id);

    if (!mounted) return;

    setState(() {
      _surahs.addAll(surahList.map((e) => {'id': e['sora'], 'name': e['sora_name']}));

      for (final raw in result) {
        final item = Map<String, dynamic>.from(raw);
        final d = item['weekday'] as int;
        _qSurah[d] = item['quran_surah'] as int?;
        _qSurahName[d] = item['quran_surah_name'] as String?;
        _qStart[d] = item['quran_start_ayah'] as int?;
        _qEnd[d] = item['quran_end_ayah'] as int?;
        _ySurah[d] = item['qiyam_surah'] as int?;
        _ySurahName[d] = item['qiyam_surah_name'] as String?;
        _yStart[d] = item['qiyam_start_ayah'] as int?;
        _yEnd[d] = item['qiyam_end_ayah'] as int?;
      }
      loading = false;
    });
  }

  Future<void> _save() async {
    for (int d = 0; d < 7; d++) {
      if (_qStart[d] != null && _qEnd[d] != null && _qStart[d]! > _qEnd[d]!) {
        _snack('خطأ في ورد القرآن يوم ${_days[d]}: من > إلى');
        return;
      }
      if (_yStart[d] != null && _yEnd[d] != null && _yStart[d]! > _yEnd[d]!) {
        _snack('خطأ في قيام الليل يوم ${_days[d]}: من > إلى');
        return;
      }
    }

    setState(() => saving = true);

    try {
      final payload = List.generate(7, (d) => {
        'weekday': d,
        'quran_surah': _qSurah[d],
        'quran_surah_name': _qSurahName[d],
        'quran_start_ayah': _qStart[d],
        'quran_end_ayah': _qEnd[d],
        'qiyam_surah': _ySurah[d],
        'qiyam_surah_name': _ySurahName[d],
        'qiyam_start_ayah': _yStart[d],
        'qiyam_end_ayah': _yEnd[d],
      });

      await SupabaseService.instance.client.rpc(
        'save_weekly_plan',
        params: {
          'p_student_id': widget.student.id,
          'p_days': payload,
        },
      );

      if (!mounted) return;
      _snack('تم حفظ الخطة بالكامل ✓');
    } catch (e) {
      if (!mounted) return;
      _snack('فشل الحفظ: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _snack(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Widget _dayCard(int day) {
    final qMax = _surahAyahCount[_qSurah[day]] ?? 286;
    final yMax = _surahAyahCount[_ySurah[day]] ?? 286;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(_days[day],
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('ورد القرآن', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<int>(
              initialValue: _qSurah[day],
              decoration: const InputDecoration(labelText: 'السورة'),
              items: _surahs
                  .map((s) => DropdownMenuItem<int>(
                        value: s['id'] as int,
                        child: Text(s['name'] as String),
                      ))
                  .toList(),
              onChanged: (v) {
                final item = _surahs.firstWhere((e) => e['id'] == v);
                setState(() {
                  _qSurah[day] = v;
                  _qSurahName[day] = item['name'];
                  _qStart[day] = null;
                  _qEnd[day] = null;
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('qs-$day-$qMax'),
                    keyboardType: TextInputType.number,
                    initialValue: _qStart[day]?.toString(),
                    decoration: const InputDecoration(labelText: 'من آية'),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      _qStart[day] = (n != null && n >= 1 && n <= qMax) ? n : null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('qe-$day-$qMax'),
                    keyboardType: TextInputType.number,
                    initialValue: _qEnd[day]?.toString(),
                    decoration: InputDecoration(
                      labelText: 'إلى آية',
                      helperText: 'الحد الأقصى $qMax',
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      _qEnd[day] = (n != null && n >= 1 && n <= qMax) ? n : null;
                    },
                  ),
                ),
              ],
            ),
            const Divider(height: 30),
            const Text('قيام الليل', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButtonFormField<int>(
              initialValue: _ySurah[day],
              decoration: const InputDecoration(labelText: 'السورة'),
              items: _surahs
                  .map((s) => DropdownMenuItem<int>(
                        value: s['id'] as int,
                        child: Text(s['name'] as String),
                      ))
                  .toList(),
              onChanged: (v) {
                final item = _surahs.firstWhere((e) => e['id'] == v);
                setState(() {
                  _ySurah[day] = v;
                  _ySurahName[day] = item['name'];
                  _yStart[day] = null;
                  _yEnd[day] = null;
                });
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: ValueKey('ys-$day-$yMax'),
                    keyboardType: TextInputType.number,
                    initialValue: _yStart[day]?.toString(),
                    decoration: const InputDecoration(labelText: 'من آية'),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      _yStart[day] = (n != null && n >= 1 && n <= yMax) ? n : null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    key: ValueKey('ye-$day-$yMax'),
                    keyboardType: TextInputType.number,
                    initialValue: _yEnd[day]?.toString(),
                    decoration: InputDecoration(
                      labelText: 'إلى آية',
                      helperText: 'الحد الأقصى $yMax',
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      _yEnd[day] = (n != null && n >= 1 && n <= yMax) ? n : null;
                    },
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
                for (int i = 0; i < 7; i++) _dayCard(i),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: saving ? null : _save,
                  child: saving
                      ? const CircularProgressIndicator()
                      : const Text('حفظ الخطة بالكامل'),
                ),
              ],
            ),
    );
  }
}