import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../models/audio_message.dart';
import '../services/audio_player_service.dart';

class AudioMessageSheet extends StatelessWidget {
  final AudioMessage message;

  const AudioMessageSheet({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('أحسنت 🌟', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (message.title != null)
            Text(message.title!, style: const TextStyle(color: AppColors.muted)),
          const SizedBox(height: 24),
          if (message.speakerImageUrl != null)
            CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(message.speakerImageUrl!),
            )
          else
            const CircleAvatar(radius: 48, child: Icon(Icons.person, size: 40)),
          const SizedBox(height: 16),
          if (message.speakerName != null)
            Text(message.speakerName!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: FilledButton.icon(
              onPressed: () => AudioPlayerService.instance.play(message),
              icon: const Icon(Icons.play_arrow),
              label: const Text('تشغيل الرسالة'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              AudioPlayerService.instance.stop();
              Navigator.pop(context);
            },
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}