import 'package:flutter/material.dart';
import 'landing_homepage_screen.dart';
import 'auth/login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const LandingHomepageScreen(),
    const Scaffold(
      backgroundColor: Color(0xFF070A0F),
      body: Center(
        child: Text(
          "Features coming soon...",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
        ),
      ),
    ),
    const Scaffold(
      backgroundColor: Color(0xFF070A0F),
      body: Center(
        child: Text(
          "Pricing coming soon...",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
        ),
      ),
    ),
    const Scaffold(
      backgroundColor: Color(0xFF070A0F),
      body: Center(
        child: Text(
          "Demo booking coming soon...",
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
        ),
      ),
    ),
    const LoginScreen(), // Account / Sign In
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A0F),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF070A0F),
          border: Border(
            top: BorderSide(color: Color(0xFF161C28), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF070A0F),
          selectedItemColor: const Color(0xFFE5A93C),
          unselectedItemColor: const Color(0xFF64748B),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          showUnselectedLabels: true,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              activeIcon: Icon(Icons.star),
              label: "Features",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments_outlined),
              activeIcon: Icon(Icons.payments),
              label: "Pricing",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline),
              activeIcon: Icon(Icons.play_circle),
              label: "Demo",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Account",
            ),
          ],
        ),
      ),
    );
  }
}
