import 'package:flutter/material.dart';
import '../main_shell.dart';
import 'students_screen.dart';
import 'adhkar_admin_screen.dart';
import 'video_admin_screen.dart';
import 'reports_screen.dart';
import '../../services/auth_service.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الشيخ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainShell()),
              );
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(18),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _tile(context, Icons.people, 'الطلاب', const StudentsScreen()),
          _tile(context, Icons.bar_chart, 'التقارير', const ReportsScreen()),
          _tile(context, Icons.favorite, 'الأذكار', const AdhkarAdminScreen()),
          _tile(context, Icons.video_library, 'الفيديو', const VideoAdminScreen()),
        ],
      ),
    );
  }

  Widget _tile(BuildContext c, IconData i, String t, Widget page) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(i, size: 42),
            const SizedBox(height: 12),
            Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}