class AudioMessage {
  final String id;
  final String? title;
  final String audioUrl;
  final String? speakerName;
  final String? speakerImageUrl;
  final String dayKey;

  const AudioMessage({
    required this.id,
    this.title,
    required this.audioUrl,
    this.speakerName,
    this.speakerImageUrl,
    required this.dayKey,
  });

  factory AudioMessage.fromMap(Map<String, dynamic> m) => AudioMessage(
    id: m['id'].toString(),
    title: m['title'] as String?,
    audioUrl: m['audio_url'].toString(),
    speakerName: m['speaker_name'] as String?,
    speakerImageUrl: m['speaker_image_url'] as String?,
    dayKey: m['day_key'].toString(),
  );
}