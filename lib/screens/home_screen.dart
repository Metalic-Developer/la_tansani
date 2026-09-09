import 'package:flutter/material.dart';

import '../core/app_day.dart';
import '../core/colors.dart';
import '../models/assignment.dart';
import '../models/user.dart';
import '../services/assignment_service.dart';
import '../services/auth_service.dart';
import '../services/adhkar_service.dart';
import '../widgets/assignment_card.dart';
import 'adhkar_screen.dart';
import 'quran_assignment_screen.dart';
import 'qiyam_screen.dart';
import 'video_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AppUser? user;
  List<Assignment> assignments = [];
  bool loading = true;
  bool morningCompleted = false;
  bool eveningCompleted = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final current = await AuthService().getCurrentUser();
    if (current == null) return;

    final assignmentService = AssignmentService();
    final items = await assignmentService.getTodayAssignments(current.id);

    final adhkar = AdhkarService();
    final morning = await adhkar.isCompleted(studentId: current.id, type: 'morning');
    final evening = await adhkar.isCompleted(studentId: current.id, type: 'evening');

    if (!mounted) return;

    setState(() {
      user = current;
      assignments = items;
      morningCompleted = morning;
      eveningCompleted = evening;
      loading = false;
    });
  }

  Assignment? find(AssignmentType type) {
    for (final item in assignments) {
      if (item.type == type) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (loading || user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final quran = find(AssignmentType.quran);
    final qiyam = find(AssignmentType.qiyam);

    return Scaffold(
      appBar: AppBar(title: const Text('لا تنساني')),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuranAssignmentScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdhkarScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'القرآن',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'الأذكار',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: load,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Text(
              'اليوم ${AppDay.arabicName()}',
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'أهلًا بك يا ${user!.username}',
              style: const TextStyle(fontSize: 18, color: AppColors.muted),
            ),
            const SizedBox(height: 25),
            const Text(
              'ورد اليوم',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (quran != null)
              AssignmentCard(
                assignment: quran,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranAssignmentScreen(assignment: quran),
                    ),
                  );
                },
              ),
            if (qiyam != null)
              AssignmentCard(
                assignment: qiyam,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QiyamScreen(assignment: qiyam),
                    ),
                  );
                },
              ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.wb_sunny_outlined),
                title: const Text('أذكار الصباح'),
                subtitle: Text(morningCompleted ? 'تم الإتمام ✓' : 'لم تُنجز بعد'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdhkarScreen(initialType: 'morning'),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.nightlight_outlined),
                title: const Text('أذكار المساء'),
                subtitle: Text(eveningCompleted ? 'تم الإتمام ✓' : 'لم تُنجز بعد'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdhkarScreen(initialType: 'evening'),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.video_library_outlined),
                title: const Text('فيديو الأسبوع'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VideoScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
