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

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
    load();
  }

  Future<void> load() async {
    final user = await AuthService().getCurrentUser();
    if (user == null) return;

    final level = await AdhkarService().getLevel(
      studentId: user.id,
      type: type,
    );

    final result = await AdhkarService().getAdhkar(
      type: type,
      level: level,
    );

    if (!mounted) return;

    setState(() {
      items = result;
      index = 0;
      if (result.isNotEmpty) {
        remaining = result.first.repetitions;
      }
      loading = false;
    });
  }

  Future<void> press() async {
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

    await AdhkarService().complete(
      studentId: user.id,
      type: type,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تم بحمد الله'),
        content: Text(type == 'morning' ? 'تم إتمام أذكار الصباح' : 'تم إتمام أذكار المساء'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسنًا'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final current = items.isEmpty ? null : items[index];

    return Scaffold(
      appBar: AppBar(title: const Text('الأذكار')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'morning', label: Text('أذكار الصباح')),
                ButtonSegment(value: 'evening', label: Text('أذكار المساء')),
              ],
              selected: {type},
              onSelectionChanged: (value) {
                setState(() {
                  type = value.first;
                  loading = true;
                });
                load();
              },
            ),
          ),
          Expanded(
            child: current == null
                ? const Center(child: Text('لا توجد أذكار مضافة حاليًا'))
                : Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          type == 'morning' ? 'أذكار الصباح' : 'أذكار المساء',
                          style: const TextStyle(fontSize: 20, color: AppColors.muted),
                        ),
                        const SizedBox(height: 30),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                Text(
                                  current.text,
                                  textDirection: TextDirection.rtl,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 25, height: 1.9),
                                ),
                                if (current.reward != null) ...[
                                  const SizedBox(height: 20),
                                  Text(
                                    current.reward!,
                                    textDirection: TextDirection.rtl,
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
                          width: 130,
                          height: 130,
                          child: FilledButton(
                            onPressed: press,
                            style: FilledButton.styleFrom(shape: const CircleBorder()),
                            child: Text(
                              '$remaining',
                              style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
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
