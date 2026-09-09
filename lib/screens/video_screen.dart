import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/supabase_service.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  Map<String, dynamic>? video;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final result = await SupabaseService.instance.client
        .from('weekly_videos')
        .select()
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (!mounted) return;
    setState(() {
      video = result;
    });
  }

  Future<void> open() async {
    if (video == null) return;
    final uri = Uri.parse(video!['video_url']);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فيديو الأسبوع')),
      body: video == null
          ? const Center(child: Text('لا يوجد فيديو هذا الأسبوع'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        video!['title'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(video!['description'] ?? ''),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: open,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('مشاهدة الفيديو'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
