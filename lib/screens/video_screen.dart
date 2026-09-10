import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/video_service.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  String? title;
  String? description;
  String? url;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await VideoService().getCurrentWeekVideo();
    if (!mounted) return;
    setState(() {
      title = v?.title;
      description = v?.description;
      url = v?.videoUrl;
      loading = false;
    });
  }

  Future<void> _open() async {
    if (url == null) return;
    await launchUrl(Uri.parse(url!), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('فيديو الأسبوع')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : title == null
              ? const Center(child: Text('لا يوجد فيديو هذا الأسبوع'))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(title!,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          if (description != null) ...[
                            const SizedBox(height: 12),
                            Text(description!),
                          ],
                          const Spacer(),
                          FilledButton.icon(
                            onPressed: _open,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('مشاهدة'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}