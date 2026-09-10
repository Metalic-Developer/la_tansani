import 'package:uuid/uuid.dart';
import '../core/app_day.dart';
import '../models/daily_report.dart';
import 'supabase_service.dart';

class ReportService {
  final _db = SupabaseService.instance.client;
  final _uuid = const Uuid();

  Future<DailyReport?> getTodayReport(String studentId) async {
    final day = AppDay.dateKey();
    final result = await _db
        .from('daily_reports')
        .select()
        .eq('student_id', studentId)
        .eq('day_key', day)
        .maybeSingle();
    if (result == null) return null;
    return DailyReport.fromMap(Map<String, dynamic>.from(result));
  }

  Future<DailyReport> refreshReport(String studentId) async {
    final day = AppDay.dateKey();

    final assignments = await _db
        .from('daily_assignments')
        .select('id,type,status')
        .eq('student_id', studentId)
        .eq('planned_date', day);

    bool quran = false, qiyam = false;
    for (final raw in assignments) {
      final item = Map<String, dynamic>.from(raw);
      if (item['status'] != 'completed') continue;
      if (item['type'] == 'quran') quran = true;
      if (item['type'] == 'qiyam') qiyam = true;
    }

    final morning = await _db
        .from('adhkar_completions')
        .select('id')
        .eq('student_id', studentId)
        .eq('day_key', day)
        .eq('type', 'morning')
        .maybeSingle();

    final evening = await _db
        .from('adhkar_completions')
        .select('id')
        .eq('student_id', studentId)
        .eq('day_key', day)
        .eq('type', 'evening')
        .maybeSingle();

    final existing = await _db
        .from('daily_reports')
        .select('id')
        .eq('student_id', studentId)
        .eq('day_key', day)
        .maybeSingle();

    final payload = <String, dynamic>{
      'student_id': studentId,
      'day_key': day,
      'quran_completed': quran,
      'qiyam_completed': qiyam,
      'morning_completed': morning != null,
      'evening_completed': evening != null,
    };

    if (existing == null) payload['id'] = _uuid.v4();

    final result = await _db
        .from('daily_reports')
        .upsert(payload, onConflict: 'student_id,day_key')
        .select()
        .single();

    return DailyReport.fromMap(Map<String, dynamic>.from(result));
  }
}