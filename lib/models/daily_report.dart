class DailyReport {
  final String id;
  final String studentId;
  final String dayKey;
  final bool quranCompleted;
  final bool qiyamCompleted;
  final bool morningCompleted;
  final bool eveningCompleted;

  const DailyReport({
    required this.id,
    required this.studentId,
    required this.dayKey,
    required this.quranCompleted,
    required this.qiyamCompleted,
    required this.morningCompleted,
    required this.eveningCompleted,
  });

  int get completedCount => [
    quranCompleted, qiyamCompleted, morningCompleted, eveningCompleted,
  ].where((e) => e).length;

  double get percentage => completedCount / 4 * 100;

  factory DailyReport.fromMap(Map<String, dynamic> m) => DailyReport(
    id: m['id'].toString(),
    studentId: m['student_id'].toString(),
    dayKey: m['day_key'].toString(),
    quranCompleted: m['quran_completed'] == true,
    qiyamCompleted: m['qiyam_completed'] == true,
    morningCompleted: m['morning_completed'] == true,
    eveningCompleted: m['evening_completed'] == true,
  );
}