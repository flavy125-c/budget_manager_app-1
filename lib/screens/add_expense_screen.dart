import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? expenseId;
  final double? initialAmount;
  final String? initialCategory;
  final DateTime? initialDate;

  const AddExpenseScreen({
    super.key,
    this.expenseId,
    this.initialAmount,
    this.initialCategory,
    this.initialDate,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  String selectedCategory = 'Food';
  DateTime selectedDate = DateTime.now();
  String? error;
  bool isSaving = false;

  final List<String> categoryOptions = [
    'Food', 'Transport', 'Utilities', 'Health',
    'Entertainment', 'Shopping', 'Education', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill fields
    if (widget.initialAmount != null) {
      _amountController.text = widget.initialAmount!.toString();
    }
    if (widget.initialCategory != null) {
      selectedCategory = widget.initialCategory!;
    }
    if (widget.initialDate != null) {
      selectedDate = widget.initialDate!;
    }
  }

  Future<void> saveExpense() async {
    final user = FirebaseAuth.instance.currentUser;
    final amountText = _amountController.text.trim();

    if (amountText.isEmpty || user == null) {
      setState(() => error = 'Amount is required.');
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
      if (widget.expenseId != null) {
        // 🔁 Edit existing expense
        await FirebaseFirestore.instance
            .collection('expenses')
            .doc(widget.expenseId)
            .update({
          'amount': amount,
          'category': selectedCategory,
          'timestamp': Timestamp.fromDate(selectedDate),
        });
      } else {
        // ➕ Add new expense
        await FirebaseFirestore.instance.collection('expenses').add({
          'uid': user.uid,
          'amount': amount,
          'category': selectedCategory,
          'timestamp': Timestamp.fromDate(selectedDate),
        });
      }

      // Get total for this category in the month
      final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      final snapshot = await FirebaseFirestore.instance
          .collection('expenses')
          .where('uid', isEqualTo: user.uid)
          .where('category', isEqualTo: selectedCategory)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      double totalSpent = snapshot.docs.fold(0.0, (sum, doc) {
        final value = doc.data()['amount'];
        return sum + (value is num ? value.toDouble() : 0.0);
      });

      // Fetch user-defined budget
      final budgetDoc = await FirebaseFirestore.instance
          .collection('budgets')
          .doc('${user.uid}_$selectedCategory')
          .get();

      double? budgetLimit;
      if (budgetDoc.exists) {
        budgetLimit = (budgetDoc.data()?['amount'] as num?)?.toDouble();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expenseId != null
                ? '✅ Expense updated successfully'
                : '✅ Expense added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        if (budgetLimit != null && totalSpent > budgetLimit) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ You’ve exceeded the $selectedCategory budget!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      if (widget.expenseId == null) {
        // Only clear fields if adding, not editing
        _amountController.clear();
        setState(() {
          selectedCategory = 'Food';
          selectedDate = DateTime.now();
        });
      } else {
        Navigator.pop(context); // go back after editing
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to save expense. Try again.'),
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
      appBar: AppBar(title: const Text('Add Expense')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                if (value != null) setState(() => selectedCategory = value);
              },
              items: categoryOptions.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Date: ', style: TextStyle(fontSize: 16)),
                Text(
                  "${selectedDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: const Text('Pick Date'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(), // prevent future dates
                    );
                    if (picked != null && picked != selectedDate) {
                      setState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSaving ? null : saveExpense,
              child: isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.expenseId != null ? 'Update Expense' : 'Save Expense'),
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
