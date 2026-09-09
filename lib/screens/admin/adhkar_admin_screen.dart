import 'package:flutter/material.dart';

import '../../services/supabase_service.dart';

class AdhkarAdminScreen extends StatefulWidget {
  const AdhkarAdminScreen({super.key});

  @override
  State<AdhkarAdminScreen> createState() => _AdhkarAdminScreenState();
}

class _AdhkarAdminScreenState extends State<AdhkarAdminScreen> {
  final textController = TextEditingController();
  final rewardController = TextEditingController();
  final repetitionsController = TextEditingController(text: '1');

  String type = 'morning';
  int level = 1;
  int order = 0;

  @override
  void dispose() {
    textController.dispose();
    rewardController.dispose();
    repetitionsController.dispose();
    super.dispose();
  }

  Future<void> add() async {
    if (textController.text.trim().isEmpty) return;

    await SupabaseService.instance.client.from('adhkar').insert({
      'type': type,
      'text': textController.text.trim(),
      'reward': rewardController.text.trim().isEmpty ? null : rewardController.text.trim(),
      'repetitions': int.tryParse(repetitionsController.text) ?? 1,
      'level': level,
      'sort_order': order,
      'active': true,
    });

    textController.clear();
    rewardController.clear();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إضافة الذكر')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة الأذكار')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          DropdownButtonFormField<String>(
            initialValue: type,
            items: const [
              DropdownMenuItem(value: 'morning', child: Text('أذكار الصباح')),
              DropdownMenuItem(value: 'evening', child: Text('أذكار المساء')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => type = value);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: textController,
            maxLines: 5,
            decoration: const InputDecoration(labelText: 'نص الذكر'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: rewardController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'الأجر - اختياري'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: repetitionsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'عدد التكرارات'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: level,
            items: const [
              DropdownMenuItem(value: 1, child: Text('المستوى 1')),
              DropdownMenuItem(value: 2, child: Text('المستوى 2')),
              DropdownMenuItem(value: 3, child: Text('المستوى 3')),
              DropdownMenuItem(value: 4, child: Text('المستوى 4')),
            ],
            onChanged: (value) {
              if (value != null) setState(() => level = value);
            },
          ),
          const SizedBox(height: 25),
          FilledButton(
            onPressed: add,
            child: const Text('إضافة الذكر'),
          ),
        ],
      ),
    );
  }
}