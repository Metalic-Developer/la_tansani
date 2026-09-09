import 'package:uuid/uuid.dart';
import '../core/app_day.dart';
import '../models/assignment.dart';
import 'supabase_service.dart';

class AssignmentService {
  final _db = SupabaseService.instance.client;
  final _uuid = const Uuid();

  Future<List<Assignment>> getTodayAssignments(String studentId) async {
    final day = AppDay.dateKey();
    await ensureDailyAssignments(studentId);

    final result = await _db
        .from('daily_assignments')
        .select()
        .eq('student_id', studentId)
        .eq('planned_date', day)
        .order('type');

    return (result as List)
        .map((e) => Assignment.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> ensureDailyAssignments(String studentId) async {
    final today = AppDay.current();
    final todayKey = AppDay.dateKey(today);

    final existing = await _db
        .from('daily_assignments')
        .select('id')
        .eq('student_id', studentId)
        .eq('planned_date', todayKey);

    if ((existing as List).isNotEmpty) return;

    final weekday = AppDay.weekdayNumber(today);
    final plan = await _db
        .from('weekly_plan_days')
        .select()
        .eq('student_id', studentId)
        .eq('weekday', weekday)
        .maybeSingle();

    final previousAssignments = await _db
        .from('daily_assignments')
        .select()
        .eq('student_id', studentId)
        .lt('planned_date', todayKey)
        .neq('status', 'completed')
        .order('planned_date');

    final rows = <Map<String, dynamic>>[];

    final prevQuran = _findFirstUncompleted(previousAssignments, 'quran');
    if (prevQuran != null) {
      rows.add(_carriedRow(
        studentId: studentId,
        type: 'quran',
        plannedDate: todayKey,
        previous: prevQuran,
      ));
    } else if (plan != null && plan['quran_start_ayah'] != null && plan['quran_end_ayah'] != null) {
      rows.add(_plannedRow(
        studentId: studentId,
        type: 'quran',
        plannedDate: todayKey,
        plan: plan,
        start: plan['quran_start_ayah'],
        end: plan['quran_end_ayah'],
      ));
    }

    final prevQiyam = _findFirstUncompleted(previousAssignments, 'qiyam');
    if (prevQiyam != null) {
      rows.add(_carriedRow(
        studentId: studentId,
        type: 'qiyam',
        plannedDate: todayKey,
        previous: prevQiyam,
      ));
    } else if (plan != null && plan['qiyam_start_ayah'] != null && plan['qiyam_end_ayah'] != null) {
      rows.add(_plannedRow(
        studentId: studentId,
        type: 'qiyam',
        plannedDate: todayKey,
        plan: plan,
        start: plan['qiyam_start_ayah'],
        end: plan['qiyam_end_ayah'],
      ));
    }

    if (rows.isNotEmpty) {
      await _db.from('daily_assignments').insert(rows);
    }
  }

  Future<void> startAssignment(String assignmentId) async {
    await _db
        .from('daily_assignments')
        .update({'status': 'in_progress'})
        .eq('id', assignmentId);
  }

  Future<void> completeAssignment({
    required String assignmentId,
    required int lastAyahId,
  }) async {
    await _db
        .from('daily_assignments')
        .update({
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
          'last_ayah_id': lastAyahId,
        })
        .eq('id', assignmentId);
  }

  Map<String, dynamic>? _findFirstUncompleted(List<dynamic> assignments, String type) {
    for (final item in assignments) {
      final map = Map<String, dynamic>.from(item);
      if (map['type'] == type && map['status'] != 'completed') {
        return map;
      }
    }
    return null;
  }

  Map<String, dynamic> _plannedRow({
    required String studentId,
    required String type,
    required String plannedDate,
    required Map<String, dynamic> plan,
    required int start,
    required int end,
  }) {
    final surah = type == 'quran' ? plan['quran_surah'] : plan['qiyam_surah'];
    final surahName = type == 'quran' ? plan['quran_surah_name'] : plan['qiyam_surah_name'];

    return {
      'id': _uuid.v4(),
      'student_id': studentId,
      'type': type,
      'planned_date': plannedDate,
      'surah': surah,
      'surah_name': surahName,
      'start_ayah': start,
      'end_ayah': end,
      'status': 'pending',
      'original_plan_date': plannedDate,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _carriedRow({
    required String studentId,
    required String type,
    required String plannedDate,
    required Map<String, dynamic> previous,
  }) {
    return {
      'id': _uuid.v4(),
      'student_id': studentId,
      'type': type,
      'planned_date': plannedDate,
      'surah': previous['surah'],
      'surah_name': previous['surah_name'],
      'start_ayah': previous['start_ayah'],
      'end_ayah': previous['end_ayah'],
      'status': 'carried',
      'carried_from_date': previous['planned_date'],
      'original_plan_date': previous['original_plan_date'],
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}
