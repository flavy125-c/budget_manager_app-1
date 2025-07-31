import 'package:flutter/material.dart';
import 'add_expense_screen.dart';
import 'view_expenses_screen.dart';
import 'summary_screen.dart';
import '../services/auth_service.dart';
import 'budget_limit_screen.dart'; // ✅ Add this import



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final logoutConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;

    if (!logoutConfirmed) return;

    try {
      await AuthService().logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login', 
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logout failed. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Manager'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Logout', // Adds accessibility hint
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MenuButton(
              title: '➕ Add Expense',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
              ),
            ),
            const SizedBox(height: 20),
            MenuButton(
              title: '📋 View Expenses',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ViewExpensesScreen()),
              ),
            ),
            const SizedBox(height: 20),
            MenuButton(
              title: '💰 Set Budgets',
              onTap: () => Navigator.pushNamed(context, '/set-budget'),
            ),

            const SizedBox(height: 20),
            MenuButton(
                title: '⚙️ Set Budget Limit',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BudgetLimitScreen()),
                ),
              ),

            const SizedBox(height: 20),
            MenuButton(
              title: '📊 Monthly Summary',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SummaryScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Your original MenuButton class (unchanged)
class MenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const MenuButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(60),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white, // ✅ Makes the text white and visible
        textStyle: const TextStyle(fontSize: 18),
      ),
      onPressed: onTap,
      child: Text(title),
    );
  }
}
