import 'package:uuid/uuid.dart';
import '../core/app_day.dart';
import '../models/assignment.dart';
import 'completion_engine.dart';
import 'supabase_service.dart';

class AssignmentService {
  AssignmentService({CompletionEngine? completionEngine})
      : _completionEngine = completionEngine ?? CompletionEngine();

  final _db = SupabaseService.instance.client;
  final _uuid = const Uuid();
  final CompletionEngine _completionEngine;

  Future<List<Assignment>> getTodayAssignments(String studentId) async {
    await ensureDailyAssignments(studentId);
    final day = AppDay.dateKey();
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

  /// Backlog Model: أي ورد غير مكتمل يُرحّل (carry) لليوم التالي
  Future<void> ensureDailyAssignments(String studentId) async {
    final todayKey = AppDay.dateKey();

    final existing = await _db
        .from('daily_assignments')
        .select('type')
        .eq('student_id', studentId)
        .eq('planned_date', todayKey);

    final existingTypes = {
      for (final raw in existing)
        Map<String, dynamic>.from(raw)['type'].toString()
    };

    // جلب كل الأوراد السابقة غير المكتملة
    final previous = await _db
        .from('daily_assignments')
        .select()
        .eq('student_id', studentId)
        .lt('planned_date', todayKey)
        .neq('status', 'completed')
        .order('planned_date', ascending: true);

    // جلب خطة الأسبوع
    final weekday = AppDay.weekdayNumber();
    final plan = await _db
        .from('weekly_plan_days')
        .select()
        .eq('student_id', studentId)
        .eq('weekday', weekday)
        .maybeSingle();

    final rows = <Map<String, dynamic>>[];

    for (final type in ['quran', 'qiyam']) {
      if (existingTypes.contains(type)) continue;

      // هل فيه ورد قديم غير مكتمل من نفس النوع؟
      Map<String, dynamic>? previousForType;
      for (final raw in previous) {
        final item = Map<String, dynamic>.from(raw);
        if (item['type'] == type && item['status'] != 'completed') {
          previousForType = item;
          break;
        }
      }

      if (previousForType != null) {
        // رحّل الورد القديم
        final previousDepth =
            (previousForType['carry_depth'] as num?)?.toInt() ?? 0;

        rows.add({
          'id': _uuid.v4(),
          'student_id': studentId,
          'type': type,
          'planned_date': todayKey,
          'surah': previousForType['surah'],
          'surah_name': previousForType['surah_name'],
          'start_ayah': previousForType['start_ayah'],
          'end_ayah': previousForType['end_ayah'],
          'status': 'carried',
          'carried_from_date': previousForType['planned_date'],
          'original_plan_date': previousForType['original_plan_date'] ??
              previousForType['planned_date'],
          'carry_depth': previousDepth + 1,
          'created_at': DateTime.now().toIso8601String(),
        });
        continue;
      }

      // مفيش ورد قديم — استخدم خطة اليوم من الأسبوع
      if (plan == null) continue;

      final prefix = type == 'quran' ? 'quran' : 'qiyam';
      final surah = plan['${prefix}_surah'];
      final surahName = plan['${prefix}_surah_name'];
      final start = plan['${prefix}_start_ayah'];
      final end = plan['${prefix}_end_ayah'];

      if (surah == null || surahName == null || start == null || end == null) {
        continue;
      }

      rows.add({
        'id': _uuid.v4(),
        'student_id': studentId,
        'type': type,
        'planned_date': todayKey,
        'surah': surah,
        'surah_name': surahName,
        'start_ayah': start,
        'end_ayah': end,
        'status': 'pending',
        'carried_from_date': null,
        'original_plan_date': todayKey,
        'carry_depth': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    if (rows.isEmpty) return;

    await _db.from('daily_assignments').upsert(
      rows,
      onConflict: 'student_id,planned_date,type',
    );
  }

  Future<void> startAssignment(String assignmentId) async {
    await _db
        .from('daily_assignments')
        .update({'status': 'in_progress'})
        .eq('id', assignmentId)
        .neq('status', 'completed');
  }

  Future<void> completeAssignment({
    required String assignmentId,
    required int lastAyahId,
  }) async {
    final result = await _db
        .from('daily_assignments')
        .update({
          'status': 'completed',
          'completed_at': DateTime.now().toIso8601String(),
          'last_ayah_id': lastAyahId,
        })
        .eq('id', assignmentId)
        .neq('status', 'completed')
        .select('student_id')
        .maybeSingle();

    if (result == null) return;
    await _completionEngine.refreshForStudent(result['student_id'].toString());
  }

  Future<void> setLastAyah({
    required String assignmentId,
    required int lastAyahId,
  }) async {
    await _db
        .from('daily_assignments')
        .update({'last_ayah_id': lastAyahId})
        .eq('id', assignmentId);
  }
}