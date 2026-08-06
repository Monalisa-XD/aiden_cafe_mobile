import 'package:flutter/material.dart';

class PricingScreen extends StatelessWidget {
  const PricingScreen({super.key});

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
          "INVESTMENT PLANS",
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
                "Invest in Excellence",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Choose the digital standard that aligns with your establishment's scale and culinary ambitions.",
                style: TextStyle(
                  fontSize: 16,
                  color: _textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildPricingCard(
                tier: "ARTISAN",
                price: "\$49",
                period: "/ month",
                tagline: "Ideal for boutique cafes and food trucks.",
                features: [
                  "1 Active Location",
                  "Up to 50 Menu Items",
                  "Standard Color Themes",
                  "E-mail Support",
                ],
              ),
              const SizedBox(height: 24),
              _buildPricingCard(
                tier: "MAITRE D'",
                price: "\$99",
                period: "/ month",
                tagline: "Optimized for busy bistros and fine dining.",
                features: [
                  "Up to 3 Active Locations",
                  "Unlimited Menu Items",
                  "Custom Branding & Fonts",
                  "Priority 24/7 Support",
                  "Analytics Dashboard Integration",
                ],
                isPremium: true,
              ),
              const SizedBox(height: 24),
              _buildPricingCard(
                tier: "ESTABLISHMENT",
                price: "\$249",
                period: "/ month",
                tagline: "Built for restaurant chains and franchises.",
                features: [
                  "Unlimited Locations",
                  "Unlimited Menu Items",
                  "Multi-manager Access Control",
                  "Dedicated Success Manager",
                  "API Access & Custom Webhooks",
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String tier,
    required String price,
    required String period,
    required String tagline,
    required List<String> features,
    bool isPremium = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPremium ? _goldPrimary : _surfaceBorder,
          width: isPremium ? 2.0 : 1.5,
        ),
        boxShadow: isPremium
            ? [
                BoxShadow(
                  color: _goldPrimary.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tier,
                style: TextStyle(
                  color: isPremium ? _goldPrimary : const Color(0xFFC2B9AD),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                ),
              ),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _goldPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "POPULAR",
                    style: TextStyle(
                      color: _goldPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                period,
                style: const TextStyle(
                  fontSize: 14,
                  color: _textGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tagline,
            style: const TextStyle(
              fontSize: 14,
              color: _textGray,
              height: 1.4,
            ),
          ),
          const Divider(color: _surfaceBorder, height: 32, thickness: 1.5),
          ...features.map(
            (feat) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: _goldPrimary,
                    size: 18,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    feat,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
