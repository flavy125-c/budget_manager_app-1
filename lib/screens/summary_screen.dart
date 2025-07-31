import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  Map<String, double> categoryTotals = {};
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchSummary();
  }

  Future<void> fetchSummary() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('expenses').get();

      final Map<String, double> totals = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'Other';
        final rawAmount = data['amount'];
        double amount = 0.0;

        if (rawAmount is int) {
          amount = rawAmount.toDouble();
        } else if (rawAmount is double) {
          amount = rawAmount;
        } else if (rawAmount is String) {
          amount = double.tryParse(rawAmount) ?? 0.0;
        } else {
          print('⚠️ Unknown amount type: $rawAmount');
        }

        totals[category] = (totals[category] ?? 0) + amount;
      }

      if (mounted) {
        setState(() {
          categoryTotals = totals;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching summary: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  Widget buildBudgetWarning() {
    final settingsBox = Hive.box('settings');
    final limitStr = settingsBox.get('budgetLimit', defaultValue: '0');
    final budgetLimit = double.tryParse(limitStr) ?? 0;
    final totalExpenses = categoryTotals.values.fold(0.0, (sum, val) => sum + val);

    if (budgetLimit > 0 && totalExpenses > budgetLimit) {
      return Container(
        color: Colors.red.shade100,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.all(10),
        child: Text(
          '⚠️ Over budget! You spent £${totalExpenses.toStringAsFixed(2)} (limit: £${budgetLimit.toStringAsFixed(2)})',
          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }
    return const SizedBox(); // No warning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Summary')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('Failed to load summary.'))
              : categoryTotals.isEmpty
                  ? const Center(child: Text('No expenses to summarize.'))
                  : ListView(
                      children: [
                        buildBudgetWarning(), // ✅ Show warning if needed
                        ...categoryTotals.entries.map((entry) {
                          return ListTile(
                            leading: const Icon(Icons.category),
                            title: Text(entry.key),
                            trailing: Text('£${entry.value.toStringAsFixed(2)}'),
                          );
                        }),
                      ],
                    ),
    );
  }
}
