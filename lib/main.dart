import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const AidenCafeApp());
}

class AidenCafeApp extends StatelessWidget {
  const AidenCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aiden Cafe',
      theme: ThemeData(useMaterial3: true),
      home: const MainNavigationScreen(),
    );
  }
}
