import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'widgets/auth_wrapper.dart'; // ✅ NEW: use the wrapper instead of hardcoding HomeScreen
import 'screens/auth/login_screen.dart';     // ✅ Must match your folder structure
import 'screens/auth/register_screen.dart';  // ✅ For RegisterScreen too
import 'screens/widgets/auth_wrapper.dart';     // ✅ For AuthWrapper
import 'screens/set_budget_screen.dart';
import 'package:hive_flutter/hive_flutter.dart'; // 🐝 import Hive

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter(); // ✅ Add this line before Firebase
  await Hive.openBox('settings'); // ✅ This opens your Hive box

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAAS83SXq4BBXNkgXL5ACKPxFA9_TyZPcE",
        authDomain: "budget-manager-d7366.firebaseapp.com",
        projectId: "budget-manager-d7366",
        storageBucket: "budget-manager-d7366.firebasestorage.app",
        messagingSenderId: "147086143383",
        appId: "1:147086143383:web:0dd47110fee2894c2a9ed2",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const BudgetApp());
}


class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      
      home: const AuthWrapper(), // ✅ This handles login/logout automatically

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/set-budget': (context) => const SetBudgetScreen(),
      },
    );
  }
}
