import '../core/app_day.dart';
import '../models/video.dart';
import 'supabase_service.dart';

class VideoService {
  final _db = SupabaseService.instance.client;

  Future<WeeklyVideo?> getCurrentWeekVideo() async {
    final weekKey = AppDay.weekKey();
    final result = await _db
        .from('weekly_videos')
        .select()
        .eq('week_key', weekKey)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (result == null) return null;
    return WeeklyVideo.fromMap(Map<String, dynamic>.from(result));
  }

  Future<void> addVideo({
    required String title,
    String? description,
    required String videoUrl,
    String? thumbnailUrl,
  }) async {
    await _db.from('weekly_videos').insert({
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'week_key': AppDay.weekKey(),
    });
  }
}