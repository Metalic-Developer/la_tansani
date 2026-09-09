import 'package:flutter/material.dart';

import 'adhkar_admin_screen.dart';
import 'reports_screen.dart';
import 'students_screen.dart';
import 'video_admin_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة الشيخ')),
      body: GridView.count(
        padding: const EdgeInsets.all(18),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _item(context, Icons.people, 'الطلاب', const StudentsScreen()),
          _item(context, Icons.menu_book, 'خطط القرآن', const StudentsScreen()),
          _item(context, Icons.favorite, 'الأذكار', const AdhkarAdminScreen()),
          _item(context, Icons.video_library, 'الفيديو', const VideoAdminScreen()),
          _item(context, Icons.bar_chart, 'التقارير', const ReportsScreen()),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String title, Widget page) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
