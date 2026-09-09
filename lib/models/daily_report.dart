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

  double get percentage {
    int count = 0;
    if (quranCompleted) count++;
    if (qiyamCompleted) count++;
    if (morningCompleted) count++;
    if (eveningCompleted) count++;
    return (count / 4) * 100;
  }
}
