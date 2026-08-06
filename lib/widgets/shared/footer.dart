import 'package:flutter/material.dart';

class MainFooter extends StatelessWidget {
  final String brandName;
  final String brandDescription;

  const MainFooter({
    super.key,
    this.brandName = "SOUTH KITCHEN GROUP",
    this.brandDescription = "Authentic South Indian flavors, crafted with love and served with warmth across our four locations.",
  });

  static const Color _goldPrimary = Color(0xFFD4A034);
  static const Color _bgDark = Color(0xFF070A0F);
  static const Color _borderDark = Color(0xFF161C28);

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
                              child: _buildMailingListInput(),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMailingListText(),
                            const SizedBox(height: 32),
                            _buildMailingListInput(),
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
                                          title: "VISIT US",
                                          links: ["Locations", "Our Story", "Catering", "Gift Cards"],
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildLinksCol(
                                          title: "EXPLORE",
                                          links: ["Menu", "Blog", "Careers", "Contact Us"],
                                        ),
                                      ),
                                      Expanded(
                                        child: _buildLinksCol(
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
                                const SizedBox(height: 48),
                                _buildLinksCol(
                                  title: "VISIT US",
                                  links: ["Locations", "Our Story", "Catering", "Gift Cards"],
                                ),
                                const SizedBox(height: 32),
                                _buildLinksCol(
                                  title: "EXPLORE",
                                  links: ["Menu", "Blog", "Careers", "Contact Us"],
                                ),
                                const SizedBox(height: 32),
                                _buildLinksCol(
                                  title: "LEGAL",
                                  links: ["Privacy Policy", "Terms of Use", "Feedback", "Admin"],
                                ),
                              ],
                            ),

                      SizedBox(height: isDesktop ? 80 : 48),
                      Divider(color: _borderDark.withValues(alpha: 0.5), height: 1, thickness: 1),
                      const SizedBox(height: 24),

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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCopyrightText(),
                                const SizedBox(height: 12),
                                _buildPoweredByText(),
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
  Widget _buildMailingListInput() {
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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: _goldPrimary,
              foregroundColor: const Color(0xFF070A0F),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "SUBSCRIBE",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 14),
              ],
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
              brandName,
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
          brandDescription,
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
            _buildSocialButton(Icons.facebook_outlined),
            const SizedBox(width: 10),
            _buildSocialButton(Icons.camera_alt_outlined), // Instagram rep
            const SizedBox(width: 10),
            _buildSocialButton(Icons.play_circle_outline_rounded), // YouTube rep
            const SizedBox(width: 10),
            _buildSocialButton(Icons.close_rounded), // X / Twitter rep
          ],
        ),
      ],
    );
  }

  // --- SOCIAL BUTTON CONTAINER ---
  Widget _buildSocialButton(IconData icon) {
    return InkWell(
      onTap: () {},
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

  // --- LINKS COLUMN ---
  Widget _buildLinksCol({
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
              onTap: () {},
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

  // --- COPYRIGHT TEXT ---
  Widget _buildCopyrightText() {
    return const Text(
      "© 2026 South Kitchen Group. All rights reserved.",
      style: TextStyle(
        color: Color(0xFF64748B),
        fontSize: 12,
      ),
    );
  }

  // --- POWERED BY TEXT ---
  Widget _buildPoweredByText() {
    return RichText(
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
