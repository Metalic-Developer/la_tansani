import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../models/ayah.dart';

class AyahCard extends StatelessWidget {
  final Ayah ayah;
  final bool hasMistake;
  final VoidCallback onMistake;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.hasMistake,
    required this.onMistake,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: hasMistake ? AppColors.red.withValues(alpha: .08) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ayah.ayaText,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 25, height: 2),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.gold,
                  child: Text(
                    '${ayah.ayaNo}',
                    style: const TextStyle(fontSize: 11, color: AppColors.text),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onMistake,
                  icon: Icon(
                    Icons.warning_amber_rounded,
                    color: hasMistake ? AppColors.red : AppColors.muted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}