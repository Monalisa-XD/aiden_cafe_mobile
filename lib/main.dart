import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'router/app_router.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const AidenCafeApp(),
    ),
  );
}

class AidenCafeApp extends StatelessWidget {
  const AidenCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Aiden Cafe',
      themeMode: appState.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF7F3EE),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F141C),
      ),
      routerConfig: appRouter,
    );
  }
}
