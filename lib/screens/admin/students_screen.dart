import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/supabase_service.dart';
import 'weekly_plan_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  List<AppUser> students = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final result = await SupabaseService.instance.client
        .from('users')
        .select()
        .eq('role', 'student')
        .order('username');

    if (!mounted) return;

    setState(() {
      students = (result as List).map((e) => AppUser.fromMap(Map<String, dynamic>.from(e))).toList();
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الطلاب')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (_, index) {
                final student = students[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: student.avatarUrl == null ? null : NetworkImage(student.avatarUrl!),
                      child: student.avatarUrl == null ? const Icon(Icons.person) : null,
                    ),
                    title: Text(student.username),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WeeklyPlanScreen(student: student),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
