import 'package:just_audio/just_audio.dart';
import '../core/app_day.dart';
import 'supabase_service.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playTodayMessage() async {
    final result = await SupabaseService.instance.client
        .from('audio_messages')
        .select('audio_url')
        .eq('day_key', AppDay.dateKey())
        .maybeSingle();

    if (result == null) return;
    final url = result['audio_url'] as String;
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
