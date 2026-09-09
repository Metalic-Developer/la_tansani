import 'package:uuid/uuid.dart';
import '../core/app_day.dart';
import 'supabase_service.dart';

class ReportService {
  final _db = SupabaseService.instance.client;
  final _uuid = const Uuid();

  Future<void> refreshReport(String studentId) async {
    final day = AppDay.dateKey();

    final assignments = await _db
        .from('daily_assignments')
        .select()
        .eq('student_id', studentId)
        .eq('planned_date', day);

    bool quran = false, qiyam = false;
    for (final item in assignments) {
      if (item['type'] == 'quran' && item['status'] == 'completed') quran = true;
      if (item['type'] == 'qiyam' && item['status'] == 'completed') qiyam = true;
    }

    final morning = await _db
        .from('adhkar_completions')
        .select()
        .eq('student_id', studentId)
        .eq('day_key', day)
        .eq('type', 'morning')
        .maybeSingle();
    final evening = await _db
        .from('adhkar_completions')
        .select()
        .eq('student_id', studentId)
        .eq('day_key', day)
        .eq('type', 'evening')
        .maybeSingle();

    await _db.from('daily_reports').upsert(
      {
        'id': _uuid.v4(),
        'student_id': studentId,
        'day_key': day,
        'quran_completed': quran,
        'qiyam_completed': qiyam,
        'morning_completed': morning != null,
        'evening_completed': evening != null,
      },
      onConflict: 'student_id,day_key',
    );
  }
}
