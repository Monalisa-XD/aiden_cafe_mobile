import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../screens/south_kitchen/south_kitchen_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/content_screen.dart';

class MainFooter extends StatefulWidget {
  final String brandName;
  final String brandDescription;

  const MainFooter({
    super.key,
    this.brandName = "SOUTH KITCHEN GROUP",
    this.brandDescription = "Authentic South Indian flavors, crafted with love and served with warmth across our four locations.",
  });

  @override
  State<MainFooter> createState() => _MainFooterState();
}

class _MainFooterState extends State<MainFooter> {
  static const Color _goldPrimary = Color(0xFFD4A034);
  static const Color _bgDark = Color(0xFF070A0F);
  static const Color _borderDark = Color(0xFF161C28);

  final Set<String> _expandedSections = {};

  void _toggleSection(String title) {
    setState(() {
      if (_expandedSections.contains(title)) {
        _expandedSections.remove(title);
      } else {
        _expandedSections.add(title);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 850;
        final horizontalPadding = isDesktop ? 64.0 : 24.0;

        return Column(
          children: [
            // 1. STAY CONNECTED (MAILING LIST) SECTION
            Container(
              width: double.infinity,
              color: _bgDark,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isDesktop ? 80 : 56,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: _buildMailingListText(),
                            ),
                            const SizedBox(width: 48),
                            Expanded(
                              flex: 5,
                              child: _buildMailingListInput(context),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMailingListText(),
                            const SizedBox(height: 32),
                            _buildMailingListInput(context),
                          ],
                        ),
                ),
              ),
            ),

            Divider(color: _borderDark, height: 1, thickness: 1),

            // 2. MAIN FOOTER LINKS & BRAND SECTION
            Container(
              width: double.infinity,
              color: _bgDark,
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isDesktop ? 80 : 56,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    children: [
                      isDesktop
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Brand Column
                                Expanded(
                                  flex: 4,
                                  child: _buildBrandCol(),
                                ),
                                const SizedBox(width: 64),
                                // Links Columns
                                Expanded(
                                  flex: 6,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: _buildLinksCol(
                                          context: context,
                                          title: "VISIT US",
                                          links: ["Locations", "Our Story", "Catering", "Gift Cards"],
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildLinksCol(
                                          context: context,
                                          title: "EXPLORE",
                                          links: ["Menu", "Blog", "Careers", "Contact Us"],
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildLinksCol(
                                          context: context,
                                          title: "LEGAL",
                                          links: ["Privacy Policy", "Terms of Use", "Feedback", "Admin"],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildBrandCol(),
                                const SizedBox(height: 36),
                                _buildMobileAccordionSection(
                                  context: context,
                                  title: "VISIT US",
                                  links: ["Locations", "Our Story", "Catering", "Gift Cards"],
                                ),
                                _buildMobileAccordionSection(
                                  context: context,
                                  title: "EXPLORE",
                                  links: ["Menu", "Blog", "Careers", "Contact Us"],
                                ),
                                _buildMobileAccordionSection(
                                  context: context,
                                  title: "LEGAL",
                                  links: ["Privacy Policy", "Terms of Use", "Feedback", "Admin"],
                                ),
                                Divider(color: _borderDark, height: 1, thickness: 1),
                              ],
                            ),

                      if (isDesktop) ...[
                        const SizedBox(height: 80),
                        Divider(color: _borderDark.withValues(alpha: 0.5), height: 1, thickness: 1),
                        const SizedBox(height: 24),
                      ] else ...[
                        const SizedBox(height: 36),
                      ],

                      // 3. BOTTOM COPYRIGHT ROW
                      isDesktop
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildCopyrightText(),
                                _buildPoweredByText(),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildCopyrightText(textAlign: TextAlign.center),
                                const SizedBox(height: 12),
                                _buildPoweredByText(textAlign: TextAlign.center),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- MAILING LIST TEXT ---
  Widget _buildMailingListText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "STAY CONNECTED",
          style: TextStyle(
            color: _goldPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Join Our Mailing List",
          style: TextStyle(
            fontFamily: 'serif',
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Be the first to hear about new dishes, seasonal specials and events.",
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // --- MAILING LIST INPUT FIELD + BUTTON ---
  Widget _buildMailingListInput(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF0F141C),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: _borderDark,
                width: 1.5,
              ),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: "Your email address",
                hintStyle: TextStyle(color: Color(0xFF475569), fontSize: 14),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Subscribed!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _goldPrimary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
            ),
            child: const Text(
              "JOIN",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- BRAND COLUMN ---
  Widget _buildBrandCol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.brandName,
              style: const TextStyle(
                fontFamily: 'serif',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const Text(
              "GROUP",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Description
        Text(
          widget.brandDescription,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        // Social Media Buttons Row
        Row(
          children: [
            _buildSocialButton(Icons.facebook_outlined, "https://facebook.com/placeholder"),
            const SizedBox(width: 10),
            _buildSocialButton(Icons.camera_alt_outlined, "https://instagram.com/placeholder"),
            const SizedBox(width: 10),
            _buildSocialButton(Icons.play_circle_outline_rounded, "https://youtube.com/placeholder"),
            const SizedBox(width: 10),
            _buildSocialButton(Icons.close_rounded, "https://x.com/placeholder"),
          ],
        ),
      ],
    );
  }

  // --- SOCIAL BUTTON CONTAINER ---
  Widget _buildSocialButton(IconData icon, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.6),
            size: 18,
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, String link) {
    Widget? destination;
    switch (link) {
      case "Locations":
        destination = const LocationsScreen();
        break;
      case "Catering":
        destination = const CateringScreen();
        break;
      case "Gift Cards":
        destination = const GiftCardsScreen();
        break;
      case "Menu":
        destination = const MenusScreen();
        break;
      case "Blog":
        destination = const BlogScreen();
        break;
      case "Admin":
        destination = const LoginScreen();
        break;
      case "Our Story":
      case "Careers":
      case "Contact Us":
      case "Privacy Policy":
      case "Terms of Use":
      case "Feedback":
        destination = ContentScreen(title: link);
        break;
    }
    
    if (destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination!),
      );
    }
  }

  // --- LINKS COLUMN (DESKTOP) ---
  Widget _buildLinksCol({
    required BuildContext context,
    required String title,
    required List<String> links,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _goldPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        ...links.map((link) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                _handleNavigation(context, link);
              },
              child: Text(
                link,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- MOBILE ACCORDION SECTION ---
  Widget _buildMobileAccordionSection({
    required BuildContext context,
    required String title,
    required List<String> links,
  }) {
    final isExpanded = _expandedSections.contains(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: _borderDark, height: 1, thickness: 1),
        InkWell(
          onTap: () => _toggleSection(title),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _goldPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _goldPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: links.map((link) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () {
                            _handleNavigation(context, link);
                          },
                          child: Text(
                            link,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // --- COPYRIGHT TEXT ---
  Widget _buildCopyrightText({TextAlign? textAlign}) {
    return Text(
      "© 2026 South Kitchen Group. All rights reserved.",
      textAlign: textAlign,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
      ),
    );
  }

  // --- POWERED BY TEXT ---
  Widget _buildPoweredByText({TextAlign? textAlign}) {
    return RichText(
      textAlign: textAlign ?? TextAlign.start,
      text: const TextSpan(
        style: TextStyle(
          color: Color(0xFF64748B),
          fontSize: 12,
        ),
        children: [
          TextSpan(text: "Powered by "),
          TextSpan(
            text: "Aiden",
            style: TextStyle(
              color: _goldPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
