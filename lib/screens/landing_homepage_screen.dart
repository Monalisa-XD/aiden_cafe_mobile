import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'south_kitchen/south_kitchen_screen.dart';

class LandingHomepageScreen extends StatefulWidget {
  const LandingHomepageScreen({super.key});

  @override
  State<LandingHomepageScreen> createState() => LandingHomepageScreenState();
}

class LandingHomepageScreenState extends State<LandingHomepageScreen> {
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _portfolioKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _pricingKey = GlobalKey();

  // Color Palette from Screenshots
  static const Color _bgDark = Color(0xFF070A0F);
  static const Color _surfaceDark = Color(0xFF0C1019);
  static const Color _surfaceBorder = Color(0xFF192233);
  static const Color _goldPrimary = Color(0xFFE5A93C);
  static const Color _textGray = Color(0xFF94A3B8);
  static const Color _greenBg = Color(0xFF0F2617);
  static const Color _greenBorder = Color(0xFF1C4226);
  static const Color _greenText = Color(0xFF22C55E);

  void scrollToSection(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void scrollToPortfolio() {
    scrollToSection(_portfolioKey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Stack(
        children: [
          // Main Scrollable Content
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderNavBar(
                    onExperienceTap: () => scrollToSection(_heroKey),
                    onPortfolioTap: () => scrollToSection(_portfolioKey),
                    onFeaturesTap: () => scrollToSection(_featuresKey),
                    onPricingTap: () => scrollToSection(_pricingKey),
                  ),
                  KeyedSubtree(key: _heroKey, child: _buildHeroSection(context)),
                  const SizedBox(height: 60),
                  KeyedSubtree(
                    key: _portfolioKey,
                    child: _buildBrandMarqueeSection(),
                  ),
                  const SizedBox(height: 60),
                  _buildOperationalMasteryHeader(),
                  const SizedBox(height: 48),
                  KeyedSubtree(
                    key: _featuresKey,
                    child: _buildFeatureCardsGrid(context),
                  ),
                  const SizedBox(height: 80),
                  KeyedSubtree(
                    key: _pricingKey,
                    child: _buildPricingSection(context),
                  ),
                  const SizedBox(height: 100),
                  _buildTestimonialsSection(context),
                  const SizedBox(height: 100),
                  _buildFooterSection(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Persistent Floating Badge (Bottom Right)
          Positioned(
            bottom: 24,
            right: 24,
            child: _buildFloatingStatusBadge(context),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 1. HERO SECTION
  // ==========================================
  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 5, child: _buildHeroLeftText()),
                const SizedBox(width: 48),
                Expanded(flex: 5, child: _buildHeroRightImage()),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroLeftText(),
                const SizedBox(height: 40),
                _buildHeroRightImage(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildHeroLeftText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subtitle Eyebrow
        const Text(
          "THE NEW STANDARD OF SERVICE",
          style: TextStyle(
            color: _goldPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 20),

        // Headline
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -1.0,
              fontFamily: 'Roboto',
            ),
            children: [
              TextSpan(text: "Your\nRestaurant,\n"),
              TextSpan(
                text: "Digitized.",
                style: TextStyle(color: _goldPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Subtext Paragraph
        const Text(
          "AidenCafe provides a beautiful, modern digital menu and management platform for forward-thinking cafes and restaurants. Real-time synchronization for the culinary elite.",
          style: TextStyle(
            fontSize: 16,
            color: _textGray,
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 36),

        // Action Buttons
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                elevation: 0,
              ),
              child: const Text(
                "BEGIN INTEGRATION",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: _surfaceBorder, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                "VIEW EXPERIENCES",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroRightImage() {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161C24),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _surfaceBorder, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          "https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=1200&q=80",
          fit: BoxFit.cover,
          colorBlendMode: BlendMode.darken,
          color: Colors.black.withValues(alpha: 0.35),
          errorBuilder: (context, error, stackTrace) {
            return Container(color: const Color(0xFF161C24));
          },
        ),
      ),
    );
  }

  // ==========================================
  // 2. BRAND MARQUEE & OPERATIONAL MASTERY
  // ==========================================
  Widget _buildBrandMarqueeSection() {
    final brands = [
      "Brew Barn",
      "South Kitchen",
      "Mane Holige",
      "The Brew Barn",
      "Aiden Cafe",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(
            "DIGITAL EXPERIENCES FOR AMAZING RESTAURANTS",
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: brands.length,
            separatorBuilder: (context, index) => const SizedBox(width: 48),
            itemBuilder: (context, index) {
              return Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _goldPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.hexagon_rounded,
                      color: _goldPrimary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    brands[index],
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOperationalMasteryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Uncompromising Operational\nMastery",
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Text(
              "Everything you need to run your menu. We provide the tools that allow masters of their craft to focus on the plate, while we handle the complexity of the ecosystem.",
              style: TextStyle(
                fontSize: 15,
                color: _textGray,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 3. FEATURE CARDS GRID
  // ==========================================
  Widget _buildFeatureCardsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 850;
          if (isWide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSingleFeatureCard(
                    icon: Icons.qr_code_2_rounded,
                    title: "QR Code Menus",
                    body:
                        "Instantly generate QR codes for tables. Customers scan and browse in seconds.",
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildSingleFeatureCard(
                    icon: Icons.smartphone_rounded,
                    title: "Mobile First",
                    body:
                        "Beautifully responsive menus that look like native apps on any device.",
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildSingleFeatureCard(
                    icon: Icons.speed_rounded,
                    title: "Real-time Updates",
                    body:
                        "Change prices or 86 an item? Your digital menu updates instantly — no app store approvals.",
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                _buildSingleFeatureCard(
                  icon: Icons.qr_code_2_rounded,
                  title: "QR Code Menus",
                  body:
                      "Instantly generate QR codes for tables. Customers scan and browse in seconds.",
                ),
                const SizedBox(height: 20),
                _buildSingleFeatureCard(
                  icon: Icons.smartphone_rounded,
                  title: "Mobile First",
                  body:
                      "Beautifully responsive menus that look like native apps on any device.",
                ),
                const SizedBox(height: 20),
                _buildSingleFeatureCard(
                  icon: Icons.speed_rounded,
                  title: "Real-time Updates",
                  body:
                      "Change prices or 86 an item? Your digital menu updates instantly — no app store approvals.",
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSingleFeatureCard({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF261D0C),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, color: _goldPrimary, size: 24),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              color: _textGray,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 4. PRICING / INVESTMENT SECTION
  // ==========================================
  Widget _buildPricingSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Text(
            "INVESTMENT",
            style: TextStyle(
              color: _goldPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Invest in Excellence",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildArtisanCard()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildSyndicateCard()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildEstateCard()),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildArtisanCard(),
                    const SizedBox(height: 32),
                    _buildSyndicateCard(),
                    const SizedBox(height: 32),
                    _buildEstateCard(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArtisanCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ARTISAN",
            style: TextStyle(
              color: _textGray,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
              children: [
                TextSpan(text: "\$0"),
                TextSpan(
                  text: "/mo",
                  style: TextStyle(fontSize: 16, color: _textGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "For independent cafes and boutique bistros seeking a refined digital presence and simplified menu orchestration.",
            style: TextStyle(
              fontSize: 14,
              color: _textGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildCheckItem("Perfect for small cafes"),
          const SizedBox(height: 12),
          _buildCheckItem("Up to 50 menu items"),
          const SizedBox(height: 12),
          _buildCheckItem("Basic QR code Digital Menu"),
          const SizedBox(height: 12),
          _buildCheckItem("Community Support"),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: _surfaceBorder, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                "JOIN ARTISAN",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyndicateCard() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: _surfaceDark,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _goldPrimary, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "SYNDICATE",
                style: TextStyle(
                  color: _goldPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  children: [
                    TextSpan(text: "\$29"),
                    TextSpan(
                      text: "/mo",
                      style: TextStyle(fontSize: 16, color: _textGray),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "For growing businesses requiring advanced synchronization, deeper guest insights, and prioritized operational agility.",
                style: TextStyle(
                  fontSize: 14,
                  color: _textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              _buildCheckItem("Unlimited menu items"),
              const SizedBox(height: 12),
              _buildCheckItem("Custom branded QR codes"),
              const SizedBox(height: 12),
              _buildCheckItem("Staff accounts (RBAC)"),
              const SizedBox(height: 12),
              _buildCheckItem("Priority 24/7 support"),
              const SizedBox(height: 12),
              _buildCheckItem("Advanced Analytics"),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _goldPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "JOIN THE SYNDICATE",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Top Centered Pill Badge "RECOMMENDED"
        Positioned(
          top: -12,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _goldPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "RECOMMENDED",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstateCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _surfaceBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ESTATE",
            style: TextStyle(
              color: _textGray,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Custom",
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "For hospitality groups managing multiple concepts and global locations requiring bespoke multi-tenant infrastructure.",
            style: TextStyle(
              fontSize: 14,
              color: _textGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          _buildCheckItem("Unlimited Scale"),
          const SizedBox(height: 12),
          _buildCheckItem("Multi-Brand Architecture"),
          const SizedBox(height: 12),
          _buildCheckItem("Custom API & Reporting"),
          const SizedBox(height: 12),
          _buildCheckItem("Dedicated Success Architect"),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: _surfaceBorder, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                "INQUIRE NOW",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_rounded, color: _goldPrimary, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // FLOATING STATUS BADGE (BOTTOM RIGHT)
  // ==========================================
  Widget _buildFloatingStatusBadge(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SouthKitchenScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _greenBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _greenBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.restaurant_rounded,
              color: _greenText,
              size: 20,
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "NOW OPEN",
                  style: TextStyle(
                    color: _greenText,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "South Kitchen",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 5. TESTIMONIALS SECTION
  // ==========================================
  Widget _buildTestimonialsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          if (isDesktop) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    height: 480,
                    decoration: BoxDecoration(
                      color: const Color(0xFF161C24),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _surfaceBorder, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        "https://images.unsplash.com/photo-1577219491135-ce391730fb2c?auto=format&fit=crop&w=1200&q=80",
                        fit: BoxFit.cover,
                        colorBlendMode: BlendMode.darken,
                        color: Colors.black.withValues(alpha: 0.3),
                        errorBuilder: (context, error, stackTrace) {
                          return Container(color: const Color(0xFF161C24));
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "THE TESTIMONIALS",
                        style: TextStyle(
                          color: _goldPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "\"AidenCafe completely transformed how we handle our menu. During busy mornings, the QR codes save our staff hours — and our guests love it.\"",
                        style: TextStyle(
                          fontSize: 32,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                          height: 1.3,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        "Sarah Mitchell",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Head of Operations, South Kitchen",
                        style: TextStyle(
                          fontSize: 14,
                          color: _textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161C24),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _surfaceBorder, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      "https://images.unsplash.com/photo-1577219491135-ce391730fb2c?auto=format&fit=crop&w=1200&q=80",
                      fit: BoxFit.cover,
                      colorBlendMode: BlendMode.darken,
                      color: Colors.black.withValues(alpha: 0.3),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(color: const Color(0xFF161C24));
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  "THE TESTIMONIALS",
                  style: TextStyle(
                    color: _goldPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "\"AidenCafe completely transformed how we handle our menu. During busy mornings, the QR codes save our staff hours — and our guests love it.\"",
                  style: TextStyle(
                    fontSize: 24,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Sarah Mitchell",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Head of Operations, South Kitchen",
                  style: TextStyle(
                    fontSize: 14,
                    color: _textGray,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  // ==========================================
  // 6. FOOTER SECTION
  // ==========================================
  Widget _buildFooterSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF05080E),
        border: Border(
          top: BorderSide(color: Color(0xFF161C28), width: 1),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 850;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Col 1: Brand
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _goldPrimary.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.hexagon_rounded,
                                    color: _goldPrimary,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "AIDEN CAFE",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "THE DIGITAL MAÎTRE D' FOR THE MODERN CAFE.",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),

                      // Col 2: Navigation
                      Expanded(
                        flex: 2,
                        child: _buildFooterColumn(
                          title: "NAVIGATION",
                          links: [
                            _FooterLink("FEATURES"),
                            _FooterLink("PRICING"),
                            _FooterLink("CONTACT"),
                          ],
                        ),
                      ),

                      // Col 3: Legal
                      Expanded(
                        flex: 2,
                        child: _buildFooterColumn(
                          title: "LEGAL",
                          links: [
                            _FooterLink("TERMS OF SERVICE"),
                            _FooterLink("PRIVACY POLICY", isHighlight: true),
                          ],
                        ),
                      ),

                      // Col 4: Newsletter
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "NEWSLETTER",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.only(bottom: 8),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color(0xFF334155),
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: const Text(
                                "YOUR EMAIL",
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand
                      Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _goldPrimary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.hexagon_rounded,
                              color: _goldPrimary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "AIDEN CAFE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "THE DIGITAL MAÎTRE D' FOR THE MODERN CAFE.",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),

                      _buildFooterColumn(
                        title: "NAVIGATION",
                        links: [
                          _FooterLink("FEATURES"),
                          _FooterLink("PRICING"),
                          _FooterLink("CONTACT"),
                        ],
                      ),
                      const SizedBox(height: 28),

                      _buildFooterColumn(
                        title: "LEGAL",
                        links: [
                          _FooterLink("TERMS OF SERVICE"),
                          _FooterLink("PRIVACY POLICY", isHighlight: true),
                        ],
                      ),
                      const SizedBox(height: 28),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "NEWSLETTER",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            decoration: const BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFF334155),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: const Text(
                              "YOUR EMAIL",
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 60),

          // Bottom Bar Copyright
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "© 2026 AIDENCAFE. ALL RIGHTS RESERVED.",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn({
    required String title,
    required List<_FooterLink> links,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        ...links.map((link) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                link.title,
                style: TextStyle(
                  color: link.isHighlight
                      ? _goldPrimary
                      : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            )),
      ],
    );
  }
}

class _FooterLink {
  final String title;
  final bool isHighlight;

  _FooterLink(this.title, {this.isHighlight = false});
}

// ==========================================
class _HeaderNavBar extends StatefulWidget {
  final VoidCallback? onExperienceTap;
  final VoidCallback? onPortfolioTap;
  final VoidCallback? onFeaturesTap;
  final VoidCallback? onPricingTap;

  const _HeaderNavBar({
    this.onExperienceTap,
    this.onPortfolioTap,
    this.onFeaturesTap,
    this.onPricingTap,
  });

  @override
  State<_HeaderNavBar> createState() => _HeaderNavBarState();
}

class _HeaderNavBarState extends State<_HeaderNavBar> {
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF070A0F),
        border: Border(
          bottom: BorderSide(color: Color(0xFF161C28), width: 1),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;

          if (isWide) {
            // Desktop Layout
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLogo(),
                Row(
                  children: [
                    _buildNavLink(
                      "EXPERIENCE",
                      isHighlight: true,
                      onTap: widget.onExperienceTap,
                    ),
                    _buildNavLink("PORTFOLIO", onTap: widget.onPortfolioTap),
                    _buildNavLink("FEATURES", onTap: widget.onFeaturesTap),
                    _buildNavLink("PRICING", onTap: widget.onPricingTap),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "SIGN IN",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5A93C),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "GET STARTED FREE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          } else {
            // Mobile Layout
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLogo(),
                    IconButton(
                      icon: Icon(
                        _isMenuOpen ? Icons.close_rounded : Icons.menu_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        setState(() {
                          _isMenuOpen = !_isMenuOpen;
                        });
                      },
                    ),
                  ],
                ),
                if (_isMenuOpen) ...[
                  const SizedBox(height: 24),
                  _buildMobileMenuItem(
                    "EXPERIENCE",
                    color: const Color(0xFFE5A93C),
                    onTap: () {
                      setState(() => _isMenuOpen = false);
                      widget.onExperienceTap?.call();
                    },
                  ),
                  _buildMobileMenuItem(
                    "PORTFOLIO",
                    color: const Color(0xFF94A3B8),
                    onTap: () {
                      setState(() => _isMenuOpen = false);
                      widget.onPortfolioTap?.call();
                    },
                  ),
                  _buildMobileMenuItem(
                    "FEATURES",
                    color: const Color(0xFF94A3B8),
                    onTap: () {
                      setState(() => _isMenuOpen = false);
                      widget.onFeaturesTap?.call();
                    },
                  ),
                  _buildMobileMenuItem(
                    "PRICING",
                    color: const Color(0xFF94A3B8),
                    onTap: () {
                      setState(() => _isMenuOpen = false);
                      widget.onPricingTap?.call();
                    },
                  ),
                  _buildMobileMenuItem(
                    "SIGN IN",
                    color: Colors.white,
                    onTap: () {
                      setState(() => _isMenuOpen = false);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _isMenuOpen = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE5A93C),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "GET STARTED FREE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFE5A93C).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hexagon_rounded,
            color: Color(0xFFE5A93C),
            size: 16,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          "AIDEN CAFE",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNavLink(
    String title, {
    bool isHighlight = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          title,
          style: TextStyle(
            color:
                isHighlight ? const Color(0xFFE5A93C) : const Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildMobileMenuItem(
    String title, {
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
