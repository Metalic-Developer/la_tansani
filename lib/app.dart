import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'screens/login_screen.dart';

class LaTansaniApp extends StatelessWidget {
  const LaTansaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'لا تنساني',
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
