import 'package:flutter/material.dart';
import '../../services/video_service.dart';

class VideoAdminScreen extends StatefulWidget {
  const VideoAdminScreen({super.key});

  @override
  State<VideoAdminScreen> createState() => _VideoAdminScreenState();
}

class _VideoAdminScreenState extends State<VideoAdminScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _url = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _url.text.trim().isEmpty) return;

    await VideoService().addVideo(
      title: _title.text.trim(),
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      videoUrl: _url.text.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم إضافة فيديو هذا الأسبوع ✓')),
    );
    _title.clear();
    _desc.clear();
    _url.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الفيديو الأسبوعي')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'عنوان الفيديو'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            decoration: const InputDecoration(labelText: 'الوصف'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _url,
            decoration: const InputDecoration(labelText: 'رابط الفيديو'),
          ),
          const SizedBox(height: 25),
          FilledButton(
            onPressed: _save,
            child: const Text('إضافة الفيديو للأسبوع الحالي'),
          ),
        ],
      ),
    );
  }
}