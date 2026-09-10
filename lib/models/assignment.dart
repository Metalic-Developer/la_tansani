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
  final int carryDepth;
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
    this.carryDepth = 0,
    required this.createdAt,
    this.completedAt,
    this.lastAyahId,
  });

  bool get isQuran => type == AssignmentType.quran;
  bool get isQiyam => type == AssignmentType.qiyam;
  bool get isCompleted => status == AssignmentStatus.completed;
  bool get isCarried => status == AssignmentStatus.carried;

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'].toString(),
      studentId: map['student_id'].toString(),
      type: map['type'] == 'qiyam' ? AssignmentType.qiyam : AssignmentType.quran,
      plannedDate: map['planned_date'].toString(),
      surah: (map['surah'] as num).toInt(),
      surahName: map['surah_name'].toString(),
      startAyah: (map['start_ayah'] as num).toInt(),
      endAyah: (map['end_ayah'] as num).toInt(),
      status: _statusFromString(map['status']),
      carriedFromDate: map['carried_from_date']?.toString(),
      originalPlanDate: map['original_plan_date']?.toString(),
      carryDepth: (map['carry_depth'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(map['created_at'].toString()),
      completedAt: map['completed_at'] == null ? null : DateTime.parse(map['completed_at'].toString()),
      lastAyahId: (map['last_ayah_id'] as num?)?.toInt(),
    );
  }

  static AssignmentStatus _statusFromString(Object? v) {
    switch (v) {
      case 'in_progress': return AssignmentStatus.inProgress;
      case 'completed': return AssignmentStatus.completed;
      case 'carried': return AssignmentStatus.carried;
      default: return AssignmentStatus.pending;
    }
  }
}