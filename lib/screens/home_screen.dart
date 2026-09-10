import 'package:flutter/material.dart';
import '../core/app_day.dart';
import '../core/colors.dart';
import '../models/assignment.dart';
import '../models/user.dart';
import '../services/adhkar_service.dart';
import '../services/assignment_service.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../services/video_service.dart';
import '../widgets/home_card.dart';
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
  bool morningDone = false;
  bool eveningDone = false;
  double percentage = 0;
  String? videoTitle;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final current = await AuthService().getCurrentUser();
    if (current == null) return;

    final items = await AssignmentService().getTodayAssignments(current.id);
    final adhkar = AdhkarService();
    final morning = await adhkar.isCompleted(studentId: current.id, type: 'morning');
    final evening = await adhkar.isCompleted(studentId: current.id, type: 'evening');
    final report = await ReportService().refreshReport(current.id);
    final video = await VideoService().getCurrentWeekVideo();

    if (!mounted) return;
    setState(() {
      user = current;
      assignments = items;
      morningDone = morning;
      eveningDone = evening;
      percentage = report.percentage;
      videoTitle = video?.title;
      loading = false;
    });
  }

  Assignment? _find(AssignmentType type) {
    for (final a in assignments) {
      if (a.type == type) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (loading || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final quran = _find(AssignmentType.quran);
    final qiyam = _find(AssignmentType.qiyam);
    final quranDone = quran?.isCompleted ?? false;
    final qiyamDone = qiyam?.isCompleted ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('لا تنساني')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اليوم ${AppDay.arabicName()}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('أهلًا بك يا ${user!.username}',
                      style: const TextStyle(fontSize: 17, color: AppColors.muted)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('إنجاز اليوم ${percentage.toStringAsFixed(0)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            minHeight: 8,
                            backgroundColor: Colors.white,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('ورد اليوم',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            if (quran != null)
              HomeCard(
                icon: Icons.menu_book_rounded,
                title: 'ورد القرآن',
                subtitle: '${quran.surahName} • ${quran.startAyah}-${quran.endAyah}',
                completed: quranDone,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuranAssignmentScreen(assignment: quran),
                    ),
                  );
                  _load();
                },
              ),
            if (qiyam != null)
              HomeCard(
                icon: Icons.nightlight_round,
                title: 'قيام الليل',
                subtitle: '${qiyam.surahName} • ${qiyam.startAyah}-${qiyam.endAyah}',
                completed: qiyamDone,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QiyamScreen(assignment: qiyam)),
                  );
                  _load();
                },
              ),
            HomeCard(
              icon: Icons.wb_sunny_outlined,
              title: 'أذكار الصباح',
              subtitle: morningDone ? 'تم الإتمام ✓' : 'لم تُنجز بعد',
              completed: morningDone,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdhkarTabScreen(initialType: 'morning'),
                ),
              ).then((_) => _load()),
            ),
            HomeCard(
              icon: Icons.nightlight_outlined,
              title: 'أذكار المساء',
              subtitle: eveningDone ? 'تم الإتمام ✓' : 'لم تُنجز بعد',
              completed: eveningDone,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdhkarTabScreen(initialType: 'evening'),
                ),
              ).then((_) => _load()),
            ),
            if (videoTitle != null)
              HomeCard(
                icon: Icons.video_library_outlined,
                title: 'فيديو الأسبوع',
                subtitle: videoTitle!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const VideoScreen()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}