import 'package:flutter/material.dart';
import 'package:mcq_grader/src/theme/app_theme.dart';
import 'package:mcq_grader/src/screens/splash_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MCQ Grader Pro',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default to dark mode for modern feel
      home: const SplashScreen(),
    );
  }
}
