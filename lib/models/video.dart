class WeeklyVideo {
  final String id;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final String weekKey;

  const WeeklyVideo({
    required this.id,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.weekKey,
  });

  factory WeeklyVideo.fromMap(Map<String, dynamic> m) => WeeklyVideo(
    id: m['id'].toString(),
    title: m['title'].toString(),
    description: m['description'] as String?,
    videoUrl: m['video_url'].toString(),
    thumbnailUrl: m['thumbnail_url'] as String?,
    weekKey: m['week_key']?.toString() ?? '',
  );
}