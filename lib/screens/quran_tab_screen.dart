import 'package:flutter/material.dart';
import '../models/assignment.dart';
import '../services/assignment_service.dart';
import '../services/auth_service.dart';
import 'quran_assignment_screen.dart';

class QuranTabScreen extends StatefulWidget {
  const QuranTabScreen({super.key});

  @override
  State<QuranTabScreen> createState() => _QuranTabScreenState();
}

class _QuranTabScreenState extends State<QuranTabScreen> {
  Assignment? assignment;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) return;
    final items = await AssignmentService().getTodayAssignments(user.id);
    Assignment? q;
    for (final a in items) {
      if (a.type == AssignmentType.quran) q = a;
    }
    if (!mounted) return;
    setState(() {
      assignment = q;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (assignment == null) {
      return const Scaffold(
        body: Center(child: Text('لا يوجد ورد قرآن اليوم')),
      );
    }
    return QuranAssignmentScreen(assignment: assignment);
  }
}