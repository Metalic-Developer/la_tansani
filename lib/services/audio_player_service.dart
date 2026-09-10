import 'package:just_audio/just_audio.dart';
import '../core/app_day.dart';
import '../models/audio_message.dart';
import 'supabase_service.dart';

class AudioPlayerService {
  AudioPlayerService._();
  static final AudioPlayerService instance = AudioPlayerService._();

  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  Future<AudioMessage?> getTodayMessage() async {
    final result = await SupabaseService.instance.client
        .from('audio_messages')
        .select()
        .eq('day_key', AppDay.dateKey())
        .maybeSingle();
    if (result == null) return null;
    return AudioMessage.fromMap(Map<String, dynamic>.from(result));
  }

  Future<void> play(AudioMessage message) async {
    await _player.setUrl(message.audioUrl);
    await _player.play();
  }

  Future<void> stop() async => _player.stop();
}