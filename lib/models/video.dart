class WeeklyVideo {
  final String id;
  final String title;
  final String? description;
  final String videoUrl;
  final String weekStart;
  final String? thumbnailUrl;

  const WeeklyVideo({
    required this.id,
    required this.title,
    this.description,
    required this.videoUrl,
    required this.weekStart,
    this.thumbnailUrl,
  });

  factory WeeklyVideo.fromMap(Map<String, dynamic> map) {
    return WeeklyVideo(
      id: map['id'].toString(),
      title: map['title'].toString(),
      description: map['description'] as String?,
      videoUrl: map['video_url'].toString(),
      weekStart: map['week_start'].toString(),
      thumbnailUrl: map['thumbnail_url'] as String?,
    );
  }
}
