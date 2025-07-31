import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class BudgetLimitScreen extends StatefulWidget {
  const BudgetLimitScreen({super.key});

  @override
  State<BudgetLimitScreen> createState() => _BudgetLimitScreenState();
}

class _BudgetLimitScreenState extends State<BudgetLimitScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final box = Hive.box('settings');
    _controller.text = box.get('budgetLimit', defaultValue: '0');
  }

  void _saveLimit() {
    final limit = _controller.text.trim();
    Hive.box('settings').put('budgetLimit', limit);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget limit saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Monthly Budget')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Enter monthly limit (£)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _saveLimit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
