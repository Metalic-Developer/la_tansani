enum AssignmentType { quran, qiyam }

enum AssignmentStatus { pending, inProgress, completed, carried }

class Assignment {
  final String id;
  final String studentId;
  final AssignmentType type;
  final String plannedDate;
  final int surah;
  final String surahName;
  final int startAyah;
  final int endAyah;
  final AssignmentStatus status;
  final String? carriedFromDate;
  final String? originalPlanDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int? lastAyahId;

  const Assignment({
    required this.id,
    required this.studentId,
    required this.type,
    required this.plannedDate,
    required this.surah,
    required this.surahName,
    required this.startAyah,
    required this.endAyah,
    required this.status,
    this.carriedFromDate,
    this.originalPlanDate,
    required this.createdAt,
    this.completedAt,
    this.lastAyahId,
  });

  bool get isQiyam => type == AssignmentType.qiyam;
  bool get isCompleted => status == AssignmentStatus.completed;

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'].toString(),
      studentId: map['student_id'].toString(),
      type: map['type'] == 'qiyam' ? AssignmentType.qiyam : AssignmentType.quran,
      plannedDate: map['planned_date'].toString(),
      surah: map['surah'] as int,
      surahName: map['surah_name'] as String,
      startAyah: map['start_ayah'] as int,
      endAyah: map['end_ayah'] as int,
      status: _statusFromString(map['status']),
      carriedFromDate: map['carried_from_date'] as String?,
      originalPlanDate: map['original_plan_date'] as String?,
      createdAt: DateTime.parse(map['created_at'].toString()),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at'].toString()) : null,
      lastAyahId: map['last_ayah_id'] as int?,
    );
  }

  static AssignmentStatus _statusFromString(Object? value) {
    switch (value) {
      case 'in_progress': return AssignmentStatus.inProgress;
      case 'completed': return AssignmentStatus.completed;
      case 'carried': return AssignmentStatus.carried;
      default: return AssignmentStatus.pending;
    }
  }
}
