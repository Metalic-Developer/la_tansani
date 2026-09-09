import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../models/assignment.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onTap;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isQiyam = assignment.type == AssignmentType.qiyam;
    final completed = assignment.status == AssignmentStatus.completed;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.gold.withValues(alpha: .2),
                child: Icon(
                  isQiyam ? Icons.nightlight_round : Icons.menu_book_rounded,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isQiyam ? 'قيام الليل' : 'ورد القرآن',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text('${assignment.surahName} • ${assignment.startAyah} - ${assignment.endAyah}'),
                    if (assignment.carriedFromDate != null)
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Text(
                          'ورد مرحّل من اليوم السابق',
                          style: TextStyle(color: AppColors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                completed ? Icons.check_circle : Icons.arrow_forward_ios,
                color: completed ? AppColors.green : AppColors.text,
              ),
            ],
          ),
        ),
      ),
    );
  }
}