import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FamilyPlanApp());
}

class FamilyPlanApp extends StatelessWidget {
  const FamilyPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Plan',
      debugShowCheckedModeBanner: false,

      // 🌑 Gunakan hanya dark theme
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),

      home: const LoginScreen(),
    );
  }
}
