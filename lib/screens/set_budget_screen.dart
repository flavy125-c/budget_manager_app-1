import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SetBudgetScreen extends StatefulWidget {
  const SetBudgetScreen({super.key});

  @override
  State<SetBudgetScreen> createState() => _SetBudgetScreenState();
}

class _SetBudgetScreenState extends State<SetBudgetScreen> {
  final TextEditingController _amountController = TextEditingController();
  String selectedCategory = 'Food';
  String? error;
  bool isSaving = false;

  final List<String> categoryOptions = [
    'Food', 'Transport', 'Utilities', 'Health',
    'Entertainment', 'Shopping', 'Education', 'Other',
  ];

  Future<void> saveBudget() async {
    final amountText = _amountController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (amountText.isEmpty || user == null) {
      setState(() => error = 'All fields are required.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      setState(() => error = 'Enter a valid number.');
      return;
    }

    setState(() {
      isSaving = true;
      error = null;
    });

    try {
      final budgetRef = FirebaseFirestore.instance
          .collection('budgets')
          .doc('${user.uid}_$selectedCategory');

      await budgetRef.set({
        'uid': user.uid,
        'category': selectedCategory,
        'amount': amount,
        'updatedAt': Timestamp.now(),
      });

      // ✅ Clear fields and reset dropdown
      _amountController.clear();
      setState(() {
        selectedCategory = 'Food';
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Budget saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to save budget. Try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Budget')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedCategory = value);
                }
              },
              items: categoryOptions.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monthly Budget Amount'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSaving ? null : saveBudget,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Budget'),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
