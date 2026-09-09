class WeeklyPlanDay {
  final String id;
  final String studentId;
  final int weekday;
  final int? quranSurah;
  final String? quranSurahName;
  final int? quranStartAyah;
  final int? quranEndAyah;
  final int? qiyamSurah;
  final String? qiyamSurahName;
  final int? qiyamStartAyah;
  final int? qiyamEndAyah;

  const WeeklyPlanDay({
    required this.id,
    required this.studentId,
    required this.weekday,
    this.quranSurah,
    this.quranSurahName,
    this.quranStartAyah,
    this.quranEndAyah,
    this.qiyamSurah,
    this.qiyamSurahName,
    this.qiyamStartAyah,
    this.qiyamEndAyah,
  });

  factory WeeklyPlanDay.fromMap(Map<String, dynamic> map) {
    return WeeklyPlanDay(
      id: map['id'].toString(),
      studentId: map['student_id'].toString(),
      weekday: map['weekday'] as int,
      quranSurah: map['quran_surah'] as int?,
      quranSurahName: map['quran_surah_name'] as String?,
      quranStartAyah: map['quran_start_ayah'] as int?,
      quranEndAyah: map['quran_end_ayah'] as int?,
      qiyamSurah: map['qiyam_surah'] as int?,
      qiyamSurahName: map['qiyam_surah_name'] as String?,
      qiyamStartAyah: map['qiyam_start_ayah'] as int?,
      qiyamEndAyah: map['qiyam_end_ayah'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student_id': studentId,
      'weekday': weekday,
      'quran_surah': quranSurah,
      'quran_surah_name': quranSurahName,
      'quran_start_ayah': quranStartAyah,
      'quran_end_ayah': quranEndAyah,
      'qiyam_surah': qiyamSurah,
      'qiyam_surah_name': qiyamSurahName,
      'qiyam_start_ayah': qiyamStartAyah,
      'qiyam_end_ayah': qiyamEndAyah,
    };
  }
}
