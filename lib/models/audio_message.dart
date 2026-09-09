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

  factory AudioMessage.fromMap(Map<String, dynamic> map) {
    return AudioMessage(
      id: map['id'].toString(),
      title: map['title'] as String?,
      audioUrl: map['audio_url'].toString(),
      speakerName: map['speaker_name'] as String?,
      speakerImageUrl: map['speaker_image_url'] as String?,
      dayKey: map['day_key'].toString(),
    );
  }
}
