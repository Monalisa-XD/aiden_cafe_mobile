import 'package:flutter/material.dart';

class FeaturesScreen extends StatelessWidget {
  const FeaturesScreen({super.key});

  static const Color _bgDark = Color(0xFF070A0F);
  static const Color _surfaceDark = Color(0xFF0C1019);
  static const Color _surfaceBorder = Color(0xFF192233);
  static const Color _goldPrimary = Color(0xFFE5A93C);
  static const Color _textGray = Color(0xFF94A3B8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        title: const Text(
          "SYSTEM FEATURES",
          style: TextStyle(
            color: _goldPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Operational Mastery",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Engineered for the modern establishment. A cohesive suite of tools designed to optimize culinary operations.",
                style: TextStyle(
                  fontSize: 16,
                  color: _textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildFeatureItem(
                icon: Icons.sync_rounded,
                title: "Real-Time Synchronization",
                description: "Menu changes, category modifications, and item availability reflect instantly across all customer devices and dining tables.",
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                icon: Icons.restaurant_menu_rounded,
                title: "Dynamic Menu Builder",
                description: "Create, format, and organize rich digital menus with customizable categories, item descriptions, and premium food photography links.",
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                icon: Icons.security_rounded,
                title: "Aiden-Guard™ Security",
                description: "Secure, encrypted administrator login and register mechanisms protecting restaurant configuration and private sales data.",
              ),
              const SizedBox(height: 24),
              _buildFeatureItem(
                icon: Icons.phone_android_rounded,
                title: "Responsive Client Native App",
                description: "A fluid, adaptive experience optimized for all device widths—including Android, iOS, tablets, and web browsers.",
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _surfaceBorder, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _goldPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: _goldPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _textGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
