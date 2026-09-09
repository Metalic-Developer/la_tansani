import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';

class VideoAdminScreen extends StatefulWidget {
  const VideoAdminScreen({super.key});

  @override
  State<VideoAdminScreen> createState() => _VideoAdminScreenState();
}

class _VideoAdminScreenState extends State<VideoAdminScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final urlController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    urlController.dispose();
    super.dispose();
  }

  Future<void> save() async {
    await SupabaseService.instance.client.from('weekly_videos').insert({
      'title': titleController.text.trim(),
      'description': descriptionController.text.trim(),
      'video_url': urlController.text.trim(),
      'week_start': DateTime.now().toIso8601String().substring(0, 10),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إضافة فيديو الأسبوع')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الفيديو الأسبوعي')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'عنوان الفيديو'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'الوصف'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: urlController,
            decoration: const InputDecoration(labelText: 'رابط الفيديو'),
          ),
          const SizedBox(height: 25),
          FilledButton(
            onPressed: save,
            child: const Text('إضافة الفيديو'),
          ),
        ],
      ),
    );
  }
}
