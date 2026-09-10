import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../models/adhkar.dart';
import '../services/adhkar_service.dart';
import '../services/auth_service.dart';

class AdhkarScreen extends StatefulWidget {
  final String initialType;
  const AdhkarScreen({super.key, this.initialType = 'morning'});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  late String type;
  List<Dhikr> items = [];
  int index = 0;
  int remaining = 0;
  bool loading = true;
  bool completed = false;

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final user = await AuthService().getCurrentUser();
    if (user == null) return;

    final done = await AdhkarService().isCompleted(
      studentId: user.id,
      type: type,
    );
    if (done) {
      if (!mounted) return;
      setState(() {
        completed = true;
        loading = false;
      });
      return;
    }

    final level = await AdhkarService().getLevel(studentId: user.id, type: type);
    final list = await AdhkarService().getAdhkar(type: type, level: level);
    if (!mounted) return;
    setState(() {
      items = list;
      index = 0;
      remaining = list.isEmpty ? 0 : list.first.repetitions;
      completed = false;
      loading = false;
    });
  }

  Future<void> _press() async {
    if (items.isEmpty) return;
    if (remaining > 1) {
      setState(() => remaining--);
      return;
    }
    if (index < items.length - 1) {
      setState(() {
        index++;
        remaining = items[index].repetitions;
      });
      return;
    }

    final user = await AuthService().getCurrentUser();
    if (user == null) return;
    await AdhkarService().complete(studentId: user.id, type: type);
    if (!mounted) return;
    setState(() => completed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final current = items.isEmpty ? null : items[index];
    final isMorning = type == 'morning';

    return Scaffold(
      appBar: AppBar(
        title: Text(isMorning ? 'أذكار الصباح' : 'أذكار المساء'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'morning', label: Text('صباح')),
                ButtonSegment(value: 'evening', label: Text('مساء')),
              ],
              selected: {type},
              onSelectionChanged: (v) {
                setState(() {
                  type = v.first;
                  items = [];
                  completed = false;
                });
                _load();
              },
            ),
          ),
          Expanded(
            child: completed
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle,
                            size: 80, color: AppColors.green),
                        const SizedBox(height: 16),
                        Text(
                          isMorning
                              ? 'تم إتمام أذكار الصباح ✓'
                              : 'تم إتمام أذكار المساء ✓',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                : current == null
                    ? const Center(child: Text('لا توجد أذكار مضافة'))
                    : Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Text(
                                      current.text,
                                      textDirection: TextDirection.rtl,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 22, height: 1.9),
                                    ),
                                    if (current.reward != null) ...[
                                      const SizedBox(height: 16),
                                      Text(
                                        current.reward!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: AppColors.muted),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: FilledButton(
                                onPressed: _press,
                                style: FilledButton.styleFrom(
                                  shape: const CircleBorder(),
                                ),
                                child: Text(
                                  '$remaining',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}