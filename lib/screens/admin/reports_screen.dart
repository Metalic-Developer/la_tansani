import 'package:flutter/material.dart';

import '../../core/app_day.dart';
import '../../services/supabase_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<dynamic> reports = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final result = await SupabaseService.instance.client
        .from('daily_reports')
        .select('*, users(username)')
        .eq('day_key', AppDay.dateKey());

    if (!mounted) return;

    setState(() {
      reports = result as List;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تقرير اليوم')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (_, index) {
                final item = reports[index];
                final completed = [
                  item['quran_completed'],
                  item['qiyam_completed'],
                  item['morning_completed'],
                  item['evening_completed'],
                ].where((e) => e == true).length;

                return Card(
                  child: ListTile(
                    title: Text(item['users']['username']),
                    subtitle: Text('الإنجاز: $completed / 4'),
                  ),
                );
              },
            ),
    );
  }
}
