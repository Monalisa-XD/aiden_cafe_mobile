import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/shared/footer.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';

final ValueNotifier<List<Map<String, dynamic>>> cartNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);

class SouthKitchenScreen extends StatefulWidget {
  const SouthKitchenScreen({super.key});

  @override
  State<SouthKitchenScreen> createState() => _SouthKitchenScreenState();
}

class _SouthKitchenScreenState extends State<SouthKitchenScreen> {
  static const Color _goldPrimary = Color(0xFFD4A034);
  final ScrollController _iconsScrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey _locationsSectionKey = GlobalKey();

  List<Map<String, String>> _menuItems = [];
  List<Map<String, String>> _locations = [];
  bool _showCart = false;

  int _currentHeroSlide = 0;
  late Timer _heroTimer;

  static const List<HeroSlide> _heroSlides = [
    HeroSlide(
      desktopImage: "https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?auto=format&fit=crop&w=2000&q=80",
      mobileImage: "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=1200&q=80",
      heading: "Where Every\nMorning Matters.",
      subtitle: "Start your day with the finest artisanal Filter Coffee.",
    ),
    HeroSlide(
      desktopImage: "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=2000&q=80",
      mobileImage: "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=1200&q=80",
      heading: "Crafted with\nTradition.",
      subtitle: "Authentic South Indian flavours, freshly prepared every day.",
    ),
    HeroSlide(
      desktopImage: "https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=2000&q=80",
      mobileImage: "https://images.unsplash.com/photo-1552566626-52f8b828add9?auto=format&fit=crop&w=1200&q=80",
      heading: "Taste the\nHeritage.",
      subtitle: "Experience timeless recipes served with warmth and hospitality.",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _heroTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _currentHeroSlide = (_currentHeroSlide + 1) % _heroSlides.length;
        });
      }
    });
  }

  Future<void> _loadData() async {
    final menu = await ApiService.getMenuItems();
    final locs = await ApiService.getLocations();
    if (mounted) {
      setState(() {
        _menuItems = menu;
        _locations = locs;
      });
    }
  }

  @override
  void dispose() {
    _heroTimer.cancel();
    _iconsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? const Color(0xFF0F141C) : const Color(0xFFF7F3EE),
      drawerScrimColor: Colors.black.withValues(alpha: 0.6),
      onDrawerChanged: (isOpen) {
        setState(() {});
      },
      drawer: const SouthKitchenDrawer(activeItem: "MENUS"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 800;
          final screenHeight = constraints.maxHeight;

          return Stack(
            children: [
              // 1. Main Scrollable Content (pushed down by fixed header height ~80)
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Space for the fixed header
                      const SizedBox(height: 80),
                      // HERO SECTION (FULL SCREEN HEIGHT minus header)
                      SizedBox(
                        height: (screenHeight - 80) < 520 ? 520 : (screenHeight - 80),
                        width: double.infinity,
                        child: Stack(
                          children: [
                            // Hero Background Image
                            Positioned.fill(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 1000),
                                layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                                  return Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      ...previousChildren,
                                      currentChild ?? const SizedBox.shrink(),
                                    ],
                                  );
                                },
                                transitionBuilder: (Widget child, Animation<double> animation) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                child: Image.network(
                                  isDesktop
                                      ? _heroSlides[_currentHeroSlide].desktopImage
                                      : _heroSlides[_currentHeroSlide].mobileImage,
                                  key: ValueKey<int>(_currentHeroSlide),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                  colorBlendMode: BlendMode.darken,
                                  color: Colors.black.withValues(alpha: 0.65),
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(color: const Color(0xFF0F141C));
                                  },
                                ),
                              ),
                            ),

                            // Gradient Overlay for readability
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.7),
                                      Colors.black.withValues(alpha: 0.4),
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Content Layout
                            SafeArea(
                              top: false,
                              bottom: false,
                              child: Column(
                                children: [
                                  // Main Center Hero Content
                                  Expanded(
                                    child: _showCart 
                                      ? const RealCartView()
                                      : Center(
                                          child: SingleChildScrollView(
                                            padding: const EdgeInsets.symmetric(horizontal: 24),
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxWidth: isDesktop ? 800 : 500,
                                              ),
                                              child: isDesktop
                                                  ? _buildDesktopHeroContent()
                                                  : _buildMobileHeroContent(),
                                            ),
                                          ),
                                        ),
                                  ),

                                  // Bottom Slide Indicator (Desktop)
                                  if (isDesktop) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(3, (index) {
                                        final isActive = index == _currentHeroSlide;
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          width: isActive ? 24 : 8,
                                          height: isActive ? 6 : 8,
                                          decoration: BoxDecoration(
                                            color: isActive ? _goldPrimary : Colors.white.withValues(alpha: 0.4),
                                            borderRadius: isActive ? BorderRadius.circular(4) : null,
                                            shape: isActive ? BoxShape.rectangle : BoxShape.circle,
                                          ),
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 2. OUR PHILOSOPHY SECTION
                      _buildOurPhilosophySection(isDesktop),

                      // 3. THE ICONS SECTION
                      _buildIconsSection(isDesktop),

                      // 4. OUR FLAGSHIP SECTION
                      _buildFlagshipSection(isDesktop),

                      // 5. WHERE TO FIND US SECTION
                      _buildLocationsSection(isDesktop),

                      // 6. GIFT CARDS SECTION
                      _buildGiftCardSection(isDesktop),

                      // 7. CATERING SECTION
                      _buildCateringSection(isDesktop),

                      // 8. TESTIMONIAL SECTION
                      _buildTestimonialSection(isDesktop),

                      // 9. FOOTER SECTION
                      const MainFooter(),
                    ],
                  ),
                ),
              ),
              
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: isDark ? const Color(0xFF0F141C).withValues(alpha: 0.95) : const Color(0xFFF7F3EE).withValues(alpha: 0.95),
                  child: SafeArea(
                    bottom: false,
                    child: _buildHeaderNavBar(isDesktop),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- HEADER NAVBAR ---
  Widget _buildHeaderNavBar(bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo + Location (Desktop)
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "SOUTH KITCHEN",
                      style: TextStyle(
                        fontFamily: 'serif',
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF2D2115),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "GROUP",
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF94A3B8) : const Color(0xFF7E7367),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
              if (isDesktop) ...[
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: _goldPrimary,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Set Location",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),

          // Right Navigation Items (Desktop vs Mobile)
          if (isDesktop)
            Row(
              children: [
                _buildHeaderNavLink("MENUS"),
                _buildHeaderNavLink("LOCATIONS"),
                _buildHeaderNavLink("CATERING"),
                _buildHeaderNavLink("GIFT CARDS"),
                _buildHeaderNavLink("BLOG"),
                const SizedBox(width: 24),
                IconButton(
                  onPressed: () {
                    context.read<AppStateProvider>().toggleTheme();
                  },
                  icon: const Icon(
                    Icons.wb_sunny_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showCart = !_showCart;
                    });
                  },
                  icon: Icon(
                    _showCart ? Icons.close_outlined : Icons.shopping_bag_outlined,
                    color: Colors.white70,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    "SIGN IN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _showCart = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _goldPrimary,
                    side: const BorderSide(color: _goldPrimary, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    "ORDER NOW",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    context.read<AppStateProvider>().toggleTheme();
                  },
                  icon: Icon(
                    Icons.wb_sunny_outlined,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      _showCart = !_showCart;
                    });
                  },
                  icon: Icon(
                    Icons.shopping_bag_outlined,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
                      Navigator.pop(context);
                    } else {
                      _scaffoldKey.currentState?.openDrawer();
                    }
                  },
                  icon: Icon(
                    _scaffoldKey.currentState?.isDrawerOpen == true
                        ? Icons.close
                        : Icons.menu_outlined,
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                    size: 22,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }



  Widget _buildHeaderNavLink(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }


  // --- DESKTOP HERO CONTENT ---
  Widget _buildDesktopHeroContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Align(
            key: ValueKey<int>(_currentHeroSlide),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _heroSlides[_currentHeroSlide].heading,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _heroSlides[_currentHeroSlide].subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (_locationsSectionKey.currentContext != null) {
                  Scrollable.ensureVisible(
                    _locationsSectionKey.currentContext!,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOutCubic,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Row(
                children: [
                  Text(
                    "FIND A LOCATION",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {
                if (_locationsSectionKey.currentContext != null) {
                  Scrollable.ensureVisible(
                    _locationsSectionKey.currentContext!,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOutCubic,
                  );
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                "OUR LOCATIONS",
                style: TextStyle(
                  fontSize: 12,
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

  // --- MOBILE HERO CONTENT ---
  Widget _buildMobileHeroContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: Align(
            key: ValueKey<int>(_currentHeroSlide),
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _heroSlides[_currentHeroSlide].heading,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _heroSlides[_currentHeroSlide].subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showCart = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _goldPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "ORDER NOW",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (_locationsSectionKey.currentContext != null) {
                    Scrollable.ensureVisible(
                      _locationsSectionKey.currentContext!,
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeInOutCubic,
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  "OUR LOCATIONS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- OUR PHILOSOPHY SECTION ---
  Widget _buildOurPhilosophySection(bool isDesktop) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0B0E14),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 96 : 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildPhilosophyTextContent(isDesktop),
                    ),
                    const SizedBox(width: 64),
                    Expanded(
                      flex: 5,
                      child: _buildPhilosophyImageCard(isDesktop),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPhilosophyImageCard(isDesktop),
                    const SizedBox(height: 40),
                    _buildPhilosophyTextContent(isDesktop),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPhilosophyTextContent(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "OUR PHILOSOPHY",
          style: TextStyle(
            color: _goldPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "Soulful dishes.\n",
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: isDesktop ? 46 : 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: "Warm hospitality.",
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: isDesktop ? 46 : 34,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: _goldPrimary,
                  height: 1.15,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          height: 2,
          width: 48,
          color: _goldPrimary,
        ),
        const SizedBox(height: 24),
        const Text(
          "At South Kitchen Group, we believe breakfast is not just a meal — it's a ritual. Our recipes are drawn from generations of Karnataka kitchens, refined with care and served with the warmth that defines South Indian culture. From the crispest vada to the most aromatic filter coffee, every dish is crafted to transport you home.",
          style: TextStyle(
            color: Color(0xFFA0AEC0),
            fontSize: 15,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 32),
        OutlinedButton(
          onPressed: () {
            setState(() {
              _showCart = true;
            });
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "OUR STORY",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhilosophyImageCard(bool isDesktop) {
    return Container(
      height: isDesktop ? 440 : 320,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF161C24),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Philosophy Card Network Image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=1200&q=80",
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: const Color(0xFF161C24));
                },
              ),
            ),
          ),

          // Circular EST. 2010 Badge (Bottom Right)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: _goldPrimary,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  "EST.\n2010",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF1A150E),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- THE ICONS SECTION ---
  Widget _buildIconsSection(bool isDesktop) {
    final horizontalPadding = isDesktop ? 64.0 : 24.0;
    
    final List<Map<String, String>> menuItems = _menuItems.isNotEmpty 
        ? _menuItems 
        : [
            {
              "badge": "MENU ITEM",
              "category": "SOUTH INDIAN BREAKFAST",
              "name": "Idli",
              "description": "Fluffy steamed rice cakes served with sambar and fresh coconut chutney.",
              "image": "https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?auto=format&fit=crop&w=800&q=80"
            },
            {
              "badge": "MENU ITEM",
              "category": "SOUTH INDIAN BREAKFAST",
              "name": "Masala Dosa",
              "description": "Crispy rice crepes filled with spiced potato mash, served with rich chutneys.",
              "image": "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80"
            },
            {
              "badge": "BEVERAGES",
              "category": "AUTHENTIC BREW",
              "name": "Filter Coffee",
              "description": "Freshly brewed decoction mixed with hot frothed milk, served in a traditional dabara.",
              "image": "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80"
            },
            {
              "badge": "MENU ITEM",
              "category": "SOUTH INDIAN BREAKFAST",
              "name": "Medu Vada",
              "description": "Crispy golden fried lentil donuts seasoned with pepper, curry leaves, and cumin.",
              "image": "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80"
            }
          ];

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F141C),
      padding: EdgeInsets.symmetric(vertical: isDesktop ? 80 : 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Subtitle + Title on left, Arrow controls on right
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "FROM OUR KITCHEN",
                      style: TextStyle(
                        color: _goldPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "The Icons",
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: isDesktop ? 46 : 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                
                // Scrolling Controls
                Row(
                  children: [
                    _buildScrollArrowButton(
                      icon: Icons.keyboard_arrow_left_rounded,
                      onTap: () {
                        _iconsScrollController.animateTo(
                          _iconsScrollController.offset - (isDesktop ? 340 : 300),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildScrollArrowButton(
                      icon: Icons.keyboard_arrow_right_rounded,
                      onTap: () {
                        _iconsScrollController.animateTo(
                          _iconsScrollController.offset + (isDesktop ? 340 : 300),
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Horizontal ListView
          SizedBox(
            height: isDesktop ? 460 : 420,
            child: ListView.builder(
              controller: _iconsScrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: _buildMenuItemCard(item, isDesktop),
                );
              },
            ),
          ),
          
          const SizedBox(height: 36),
          
          // Centered View Full Menu Button
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showCart = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _goldPrimary,
                foregroundColor: const Color(0xFF070A0F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "VIEW FULL MENU",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SCROLL ARROW BUTTON ---
  Widget _buildScrollArrowButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  // --- MENU ITEM CARD ---
  Widget _buildMenuItemCard(Map<String, String> item, bool isDesktop) {
    final double cardWidth = isDesktop ? 320.0 : 280.0;
    
    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Placeholder Section (with golden "MENU ITEM" badge)
            Expanded(
              flex: 11,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      item["image"] ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A2130),
                                Color(0xFF0F141C),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              item["name"] == "Filter Coffee" 
                                  ? Icons.local_cafe_outlined 
                                  : Icons.restaurant_menu_outlined,
                              color: Colors.white.withValues(alpha: 0.15),
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Gold Badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _goldPrimary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item["badge"] ?? "MENU ITEM",
                        style: const TextStyle(
                          color: Color(0xFF070A0F),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Text Content Section
            Expanded(
              flex: 8,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["category"] ?? "SOUTH INDIAN BREAKFAST",
                          style: const TextStyle(
                            color: _goldPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item["name"] ?? "",
                          style: const TextStyle(
                            fontFamily: 'serif',
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      item["description"] ?? "",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- OUR FLAGSHIP SECTION ---
  Widget _buildFlagshipSection(bool isDesktop) {
    final horizontalPadding = isDesktop ? 64.0 : 24.0;
    
    return SizedBox(
      height: isDesktop ? 500 : 460,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=1600&q=80",
              fit: BoxFit.cover,
              colorBlendMode: BlendMode.darken,
              color: Colors.black.withValues(alpha: 0.65),
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: const Color(0xFF0F141C),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF161E2E),
                          Color(0xFF0B0E14),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Gradient Overlay for text readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.75),
                  ],
                ),
              ),
            ),
          ),

          // Content Layer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Tagline & Headline
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "OUR FLAGSHIP",
                      style: TextStyle(
                        color: _goldPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Basavanagudi",
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: isDesktop ? 48 : 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 600 : double.infinity,
                      ),
                      child: const Text(
                        "Our original location on Bull Temple Road — where South Kitchen began and where the spirit of traditional Bengaluru breakfast lives on.",
                        style: TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 15,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),

                // Bottom Meta Details + Call to Action
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Inline Info Rows (Location & Hours)
                    Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: _goldPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Bull Temple Road, Basavanagudi",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: _goldPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Open 7:00 AM – 10:00 PM",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),

                    // Find all locations button
                    ElevatedButton(
                      onPressed: () {
                        if (_locationsSectionKey.currentContext != null) {
                          Scrollable.ensureVisible(
                            _locationsSectionKey.currentContext!,
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeInOutCubic,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _goldPrimary,
                        foregroundColor: const Color(0xFF070A0F),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "FIND ALL LOCATIONS",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WHERE TO FIND US SECTION ---
  Widget _buildLocationsSection(bool isDesktop) {
    final horizontalPadding = isDesktop ? 64.0 : 24.0;
    
    final List<Map<String, String>> locations = _locations.isNotEmpty 
        ? _locations 
        : [
            {
              "name": "Basvanagudi",
              "address": "South Kitchen, 1st Main Road, Thyagaraja Nagar, N.R Colony, Bengaluru West City Corporation, Bengaluru, Bangalore North, Bengaluru Urban, Karnataka, 560004, India",
              "image": "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80"
            },
            {
              "name": "Jayanagar",
              "address": "South Kitchen, 4th Block, Near Jayanagar Metro Station, Jayanagar, Bengaluru, Karnataka, 560011, India",
              "image": "https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80"
            },
            {
              "name": "Indiranagar",
              "address": "South Kitchen, 100 Feet Road, HAL 2nd Stage, Indiranagar, Bengaluru, Karnataka, 560038, India",
              "image": "https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?auto=format&fit=crop&w=800&q=80"
            },
            {
              "name": "Malleshwaram",
              "address": "South Kitchen, Margosa Road, Near 15th Cross, Malleshwaram, Bengaluru, Karnataka, 560003, India",
              "image": "https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80"
            }
          ];

    return Container(
      key: _locationsSectionKey,
      width: double.infinity,
      color: const Color(0xFF070A0F), // Dark background matching landing screen
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isDesktop ? 96 : 64,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Section
          const Text(
            "WHERE TO FIND US",
            style: TextStyle(
              color: _goldPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Four Locations,\nOne Family",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: isDesktop ? 46 : 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -0.5,
            ),
          ),
          
          const SizedBox(height: 48),

          // Cards Layout (Grid on Desktop, Column on Mobile)
          isDesktop
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 32,
                    mainAxisSpacing: 32,
                    childAspectRatio: 1.15,
                  ),
                  itemCount: locations.length,
                  itemBuilder: (context, index) {
                    return _buildLocationCard(locations[index]);
                  },
                )
              : Column(
                  children: locations.map((loc) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _buildLocationCard(loc),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // --- LOCATION CARD WIDGET ---
  Widget _buildLocationCard(Map<String, String> location) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0B0E14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area (Commented out network image with premium fallback representation)
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      location["image"] ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1E2638),
                                Color(0xFF0B0E14),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.storefront_outlined,
                              color: Colors.white.withValues(alpha: 0.15),
                              size: 56,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Text Details Area
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location["name"] ?? "",
                    style: const TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    location["address"] ?? "",
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // "VIEW DETAILS" link
                  InkWell(
                    onTap: () {},
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "VIEW DETAILS",
                          style: TextStyle(
                            color: _goldPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: _goldPrimary,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- GIFT CARDS SECTION ---
  Widget _buildGiftCardSection(bool isDesktop) {
    final horizontalPadding = isDesktop ? 64.0 : 24.0;
    
    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F3EE), // Warm cream background
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isDesktop ? 96 : 64,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFEFE8DE),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gift Emoji
                const Text(
                  "🎁",
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 24),

                // Tagline
                const Text(
                  "GIFT SOMEONE SPECIAL",
                  style: TextStyle(
                    color: Color(0xFFC68A1E), // Amber primary matching Auth module
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Headline
                const Text(
                  "South Kitchen Gift Cards",
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: Color(0xFF2D2115), // Dark text matching Auth module
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  "Share the joy of authentic South Indian food. Gift cards from ₹500 to ₹5000.",
                  style: TextStyle(
                    color: Color(0xFF7E7367), // Warm grey text matching Auth module
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const GiftCardsScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                    if (result == 'locations' && mounted) {
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (_locationsSectionKey.currentContext != null) {
                          Scrollable.ensureVisible(
                            _locationsSectionKey.currentContext!,
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeInOut,
                          );
                        }
                      });
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC68A1E),
                    side: const BorderSide(color: Color(0xFFC68A1E), width: 1.5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "GET A GIFT CARD",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- CATERING SECTION ---
  Widget _buildCateringSection(bool isDesktop) {
    final horizontalPadding = isDesktop ? 64.0 : 24.0;
    
    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F3EE), // Continues with warm cream background
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: isDesktop ? 96 : 64, // Reduce top padding as it shares cream bg with Gift Cards
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: const Color(0xFF0B0E14), // Dark background card
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.05),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plate Emoji
                const Text(
                  "🍽️",
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 24),

                // Tagline
                const Text(
                  "EVENTS & GATHERINGS",
                  style: TextStyle(
                    color: _goldPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Headline
                const Text(
                  "Catering for Every\nOccasion",
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  "From intimate family gatherings to large corporate events — we bring South Kitchen to you.",
                  style: TextStyle(
                    color: Color(0xFF94A3B8), // Off-white/slate text
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                // CTA Button
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showCart = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _goldPrimary,
                    foregroundColor: const Color(0xFF070A0F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "ENQUIRE NOW",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- TESTIMONIAL SECTION ---
  Widget _buildTestimonialSection(bool isDesktop) {
    final horizontalPadding = isDesktop ? 64.0 : 24.0;
    
    return Container(
      width: double.infinity,
      color: const Color(0xFF070A0F), // Contrast dark background
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: isDesktop ? 100 : 72,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 5 Star rating Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(
                      Icons.star,
                      color: _goldPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Main Testimonial Quote
              Text(
                "\"The filter coffee alone is worth the trip. Nothing in Bengaluru comes close to the warmth and authenticity of South Kitchen. It feels like visiting a grandmother who just happens to run the best breakfast place in town.\"",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontSize: isDesktop ? 26 : 20,
                  height: 1.6,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 28),

              // Author attribution
              const Text(
                "— Arjun M., Jayanagar Regular",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _goldPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroSlide {
  final String desktopImage;
  final String mobileImage;
  final String heading;
  final String subtitle;

  const HeroSlide({
    required this.desktopImage,
    required this.mobileImage,
    required this.heading,
    required this.subtitle,
  });
}

class GiftCardsScreen extends StatelessWidget {
  const GiftCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Center a gift icon at the top
                  const Icon(
                    Icons.card_giftcard_outlined,
                    color: Color(0xFFD4A034),
                    size: 64,
                  ),
                  const SizedBox(height: 32),

                  // Main heading
                  const Text(
                    "Gift Cards Coming Soon",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Subtitle
                  const Text(
                    "We're currently upgrading our digital gift card experience. In the meantime, please visit any of our restaurant locations to purchase physical gift cards.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Gold CTA button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, 'locations');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4A034),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "VIEW LOCATIONS",
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
          ),
        ),
      ),
    );
  }
}

class SouthKitchenDrawer extends StatefulWidget {
  final String activeItem;
  const SouthKitchenDrawer({super.key, required this.activeItem});

  @override
  State<SouthKitchenDrawer> createState() => _SouthKitchenDrawerState();
}

class _SouthKitchenDrawerState extends State<SouthKitchenDrawer> {
  static const Color _goldPrimary = Color(0xFFD4A034);

  Widget _buildDrawerNavItem(String title, VoidCallback onTap) {
    final isActive = title == widget.activeItem;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? _goldPrimary : const Color(0xFFB0A89F),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: const Color(0xFF0B0E14),
      child: SafeArea(
        child: Column(
          children: [
            // 1. Header Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Brand Logo
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "SOUTH KITCHEN",
                        style: TextStyle(
                          fontFamily: 'serif',
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "GROUP",
                        style: TextStyle(
                          color: _goldPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ],
                  ),
                  // Action Icons (Theme, Cart, Close)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          context.read<AppStateProvider>().toggleTheme();
                        },
                        icon: const Icon(
                          Icons.wb_sunny_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Cart action trigger
                        },
                        icon: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF161C28), height: 1),

            // 2. Main Scrollable List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Set Delivery Location Button
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const DeliveryLocationScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F141C),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: _goldPrimary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Set Delivery Location",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Nav Items
                    _buildDrawerNavItem("MENUS", () {
                      Navigator.pop(context);
                      if (widget.activeItem != "MENUS") {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const SouthKitchenScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      }
                    }),
                    const SizedBox(height: 28),
                    _buildDrawerNavItem("LOCATIONS", () {
                      Navigator.pop(context);
                      if (widget.activeItem != "LOCATIONS") {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const LocationsScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      }
                    }),
                    const SizedBox(height: 28),
                    _buildDrawerNavItem("CATERING", () {
                      Navigator.pop(context);
                      if (widget.activeItem != "CATERING") {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) => const CateringScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      }
                    }),
                    const SizedBox(height: 28),
                    _buildDrawerNavItem("GIFT CARDS", () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const GiftCardsScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 28),
                    _buildDrawerNavItem("BLOG", () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const BlogScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 40),
                    const Divider(color: Color(0xFF161C28), height: 1),
                    const SizedBox(height: 24),

                    // SIGN IN or LOGOUT
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        if (auth.isAuthenticated) {
                          return InkWell(
                            onTap: () async {
                              await auth.logout();
                              if (!context.mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Logged out successfully")),
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.logout, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  "LOGOUT (${auth.user?['name'] ?? ''})",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            "SIGN IN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 3. Fixed Order Now Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF0B0E14),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.activeItem != "MENUS") {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => const SouthKitchenScreen(),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      ),
                    );
                  }
                },
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
                  "ORDER NOW",
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
    );
  }
}

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        title: const Text("LOCATIONS", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const SouthKitchenDrawer(activeItem: "LOCATIONS"),
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, color: Color(0xFFD4A034), size: 64),
              SizedBox(height: 24),
              Text(
                "Our Locations",
                style: TextStyle(fontFamily: 'serif', color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "Visit any of our restaurants in Basavanagudi, Jayanagar, Indiranagar, or Malleshwaram for the authentic taste of South Indian recipes.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CateringScreen extends StatelessWidget {
  const CateringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        title: const Text("CATERING", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const SouthKitchenDrawer(activeItem: "CATERING"),
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant_menu_outlined, color: Color(0xFFD4A034), size: 64),
              SizedBox(height: 24),
              Text(
                "Premium Catering",
                style: TextStyle(fontFamily: 'serif', color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "Experience our premium catering service at your events. Traditional taste served with warmth.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        title: const Text("BLOG", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const SouthKitchenDrawer(activeItem: "BLOG"),
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.article_outlined, color: Color(0xFFD4A034), size: 64),
              SizedBox(height: 24),
              Text(
                "South Kitchen Blog",
                style: TextStyle(fontFamily: 'serif', color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "We are currently preparing articles about South Indian cuisine culture and heritage recipes. Check back soon!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeliveryLocationScreen extends StatelessWidget {
  const DeliveryLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F141C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        title: const Text("DELIVERY LOCATION", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, color: Color(0xFFD4A034), size: 64),
              SizedBox(height: 24),
              Text(
                "Select Location",
                style: TextStyle(fontFamily: 'serif', color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                "Locate your position on the map to find the nearest South Kitchen outlet delivering to you.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, height: 1.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItemData {
  final String id;
  final String category;
  final String name;
  final String description;
  final String image;
  final double price;
  final bool isVeg;

  const MenuItemData({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    this.isVeg = true,
  });
}

const List<MenuItemData> _staticMenuItems = [
  MenuItemData(
    id: '1',
    category: 'SOUTH INDIAN BREAKFAST',
    name: 'Idli',
    description: 'Soft and fluffy steamed rice cakes served with aromatic sambar and fresh coconut chutney.',
    image: 'https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?auto=format&fit=crop&w=800&q=80',
    price: 60.0,
  ),
  MenuItemData(
    id: '2',
    category: 'SOUTH INDIAN BREAKFAST',
    name: 'Masala Dosa',
    description: 'Crispy golden rice crepe filled with seasoned potato masala, served with coconut and tomato chutneys.',
    image: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?auto=format&fit=crop&w=800&q=80',
    price: 80.0,
  ),
  MenuItemData(
    id: '3',
    category: 'SOUTH INDIAN BREAKFAST',
    name: 'Medu Vada',
    description: 'Crisp and golden-fried lentil donuts seasoned with black pepper, curry leaves, and cumin.',
    image: 'https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=800&q=80',
    price: 50.0,
  ),
  MenuItemData(
    id: '4',
    category: 'SOUTH INDIAN BREAKFAST',
    name: 'Rava Idli',
    description: 'Steamed semolina cakes tempered with mustard, cashews, and coriander, served with ghee.',
    image: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80',
    price: 70.0,
  ),
  MenuItemData(
    id: '5',
    category: 'BHATHS',
    name: 'Khara Bhath',
    description: 'Savory semolina porridge cooked with mixed vegetables, ghee, and local spices.',
    image: 'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?auto=format&fit=crop&w=800&q=80',
    price: 55.0,
  ),
  MenuItemData(
    id: '6',
    category: 'BHATHS',
    name: 'Chow Chow Bhath',
    description: 'A classic combination of equal portions of savory Khara Bhath and sweet Kesari Bhath.',
    image: 'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?auto=format&fit=crop&w=800&q=80',
    price: 90.0,
  ),
  MenuItemData(
    id: '7',
    category: 'BHATHS',
    name: 'Bisi Bele Bhath',
    description: 'A wholesome spicy rice dish cooked with lentils, mixed vegetables, tamarind, and local spices.',
    image: 'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?auto=format&fit=crop&w=800&q=80',
    price: 85.0,
  ),
  MenuItemData(
    id: '8',
    category: 'SWEETS',
    name: 'Kesari Bhath',
    description: 'Sweet saffron-infused semolina pudding loaded with dry fruits and roasted cashews.',
    image: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
    price: 50.0,
  ),
  MenuItemData(
    id: '9',
    category: 'SWEETS',
    name: 'Mysore Pak',
    description: 'A rich, melt-in-the-mouth traditional sweet made of gram flour, generous ghee, and sugar.',
    image: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?auto=format&fit=crop&w=800&q=80',
    price: 75.0,
  ),
  MenuItemData(
    id: '10',
    category: 'BEVERAGES',
    name: 'Filter Coffee',
    description: 'Aromatic chicory blend coffee brewed traditionally and frothed with hot milk.',
    image: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80',
    price: 40.0,
  ),
  MenuItemData(
    id: '11',
    category: 'BEVERAGES',
    name: 'Badam Milk',
    description: 'Warm, creamy milk flavored with almond paste, saffron, cardamom, and sliced nuts.',
    image: 'https://images.unsplash.com/photo-154432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80',
    price: 50.0,
  ),
];

class MenusScreen extends StatefulWidget {
  const MenusScreen({super.key});

  @override
  State<MenusScreen> createState() => _MenusScreenState();
}

class _MenusScreenState extends State<MenusScreen> {
  static const Color _goldPrimary = Color(0xFFD4A034);
  bool _isGridView = true;
  String _activeCategory = 'ALL';
  bool _showCart = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<MenuItemData> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    try {
      final data = await ApiService.getMenuItems();
      if (mounted) {
        setState(() {
          _menuItems = data.map((item) => MenuItemData(
                id: item['id'] ?? '',
                category: item['category'] ?? '',
                name: item['name'] ?? '',
                description: item['description'] ?? '',
                image: item['image'] ?? '',
                price: 50.0,
                isVeg: true,
              )).toList();
          if (_menuItems.isEmpty) {
            _menuItems = _staticMenuItems;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _menuItems = _staticMenuItems;
          _isLoading = false;
        });
      }
    }
  }

  final List<String> _categories = [
    'ALL',
    'SOUTH INDIAN BREAKFAST',
    'BHATHS',
    'SWEETS',
    'BEVERAGES'
  ];

  void _addToCart(MenuItemData item) {
    final currentCart = List<Map<String, dynamic>>.from(cartNotifier.value);
    final index = currentCart.indexWhere((cartItem) => cartItem['id'] == item.id);
    if (index >= 0) {
      currentCart[index]['quantity'] += 1;
    } else {
      currentCart.add({
        'id': item.id,
        'name': item.name,
        'price': item.price,
        'image': item.image,
        'quantity': 1,
      });
    }
    cartNotifier.value = currentCart;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${item.name} added to cart!"),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _goldPrimary,
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF161C28), width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isActive = cat == _activeCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                _activeCategory = cat;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 24),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isActive ? _goldPrimary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                cat,
                style: TextStyle(
                  color: isActive ? _goldPrimary : const Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemCard(MenuItemData item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF161C28), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1A2130)),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: item.isVeg ? Colors.green : Colors.red,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.isVeg ? "VEG" : "NON-VEG",
                            style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.4),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₹${item.price.toInt()}",
                      style: const TextStyle(
                        color: _goldPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _addToCart(item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2130),
                        foregroundColor: _goldPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                          side: const BorderSide(color: _goldPrimary, width: 1),
                        ),
                      ),
                      child: const Text("+ ADD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemListItem(MenuItemData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF161C28), width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1A2130)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.circle,
                      color: item.isVeg ? Colors.green : Colors.red,
                      size: 10,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontFamily: 'serif',
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  "₹${item.price.toInt()}",
                  style: const TextStyle(
                    color: _goldPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _addToCart(item),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A2130),
              foregroundColor: _goldPrimary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: const BorderSide(color: _goldPrimary, width: 1),
              ),
            ),
            child: const Text("+ ADD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String title, List<MenuItemData> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'serif',
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _isGridView
            ? GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildItemCard(items[index]),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildItemListItem(items[index]),
              ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F141C),
        body: Center(child: CircularProgressIndicator(color: _goldPrimary)),
      );
    }

    final Map<String, List<MenuItemData>> categorizedItems = {
      'South Indian Breakfast': _menuItems.where((i) => i.category == 'SOUTH INDIAN BREAKFAST').toList(),
      'Bhaths': _menuItems.where((i) => i.category == 'BHATHS').toList(),
      'Sweets': _menuItems.where((i) => i.category == 'SWEETS').toList(),
      'Beverages': _menuItems.where((i) => i.category == 'BEVERAGES').toList(),
    };

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF0F141C),
      drawerScrimColor: Colors.black.withValues(alpha: 0.6),
      drawer: const SouthKitchenDrawer(activeItem: "MENUS"),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E14),
        elevation: 0,
        title: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "SOUTH KITCHEN",
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "GROUP",
                  style: TextStyle(
                    color: _goldPrimary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AppStateProvider>().toggleTheme();
            },
            icon: const Icon(Icons.wb_sunny_outlined, color: Colors.white),
          ),
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: cartNotifier,
            builder: (context, cartItems, child) {
              final count = cartItems.fold<int>(0, (sum, item) => sum + (item['quantity'] as int));
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showCart = !_showCart;
                      });
                    },
                    icon: Icon(
                      _showCart ? Icons.close : Icons.shopping_bag_outlined,
                      color: Colors.white,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: _goldPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          "$count",
                          style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: _showCart
            ? const RealCartView()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 240,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              "https://images.unsplash.com/photo-1610192244261-3f33de3f55e4?auto=format&fit=crop&w=2000&q=80",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.65),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Our Menu",
                                    style: TextStyle(
                                      fontFamily: 'serif',
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Select your nearest location to see dishes and pricing.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Basvanagudi",
                                style: TextStyle(
                                  fontFamily: 'serif',
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showCart = true;
                                  });
                                },
                                icon: const Icon(Icons.calendar_today_outlined, size: 14, color: _goldPrimary),
                                label: const Text(
                                  "BOOK A TABLE",
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _goldPrimary,
                                  side: const BorderSide(color: _goldPrimary, width: 1),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B0E14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => setState(() => _isGridView = true),
                                  icon: Icon(
                                    Icons.grid_view_rounded,
                                    color: _isGridView ? _goldPrimary : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => setState(() => _isGridView = false),
                                  icon: Icon(
                                    Icons.list_rounded,
                                    color: !_isGridView ? _goldPrimary : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildCategoryTabs(),
                    const SizedBox(height: 8),
                    if (_activeCategory == 'ALL') ...[
                      _buildCategorySection('South Indian Breakfast', categorizedItems['South Indian Breakfast']!),
                      _buildCategorySection('Bhaths', categorizedItems['Bhaths']!),
                      _buildCategorySection('Sweets', categorizedItems['Sweets']!),
                      _buildCategorySection('Beverages', categorizedItems['Beverages']!),
                    ] else if (_activeCategory == 'SOUTH INDIAN BREAKFAST') ...[
                      _buildCategorySection('South Indian Breakfast', categorizedItems['South Indian Breakfast']!),
                    ] else if (_activeCategory == 'BHATHS') ...[
                      _buildCategorySection('Bhaths', categorizedItems['Bhaths']!),
                    ] else if (_activeCategory == 'SWEETS') ...[
                      _buildCategorySection('Sweets', categorizedItems['Sweets']!),
                    ] else if (_activeCategory == 'BEVERAGES') ...[
                      _buildCategorySection('Beverages', categorizedItems['Beverages']!),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}

class RealCartView extends StatelessWidget {
  const RealCartView({super.key});

  @override
  Widget build(BuildContext context) {
    const Color goldPrimary = Color(0xFFD4A034);

    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: cartNotifier,
      builder: (context, cartItems, child) {
        if (cartItems.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    color: Colors.white.withValues(alpha: 0.15),
                    size: 96,
                  ),
                  const SizedBox(height: 36),
                  const Text(
                    "Your cart is empty",
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Add items from our menu to start your order.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        final double total = cartItems.fold<double>(0, (sum, item) => sum + (item['price'] as double) * (item['quantity'] as int));

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F141C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF161C28), width: 1),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Image.network(
                              item['image'] ?? "",
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF1A2130)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] ?? "",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${(item['price'] as double).toInt()}",
                                style: const TextStyle(color: goldPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                final currentCart = List<Map<String, dynamic>>.from(cartNotifier.value);
                                if (currentCart[index]['quantity'] > 1) {
                                  currentCart[index]['quantity'] -= 1;
                                } else {
                                  currentCart.removeAt(index);
                                }
                                cartNotifier.value = currentCart;
                              },
                              icon: const Icon(Icons.remove_circle_outline, color: goldPrimary, size: 22),
                            ),
                            Text(
                              "${item['quantity']}",
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () {
                                final currentCart = List<Map<String, dynamic>>.from(cartNotifier.value);
                                currentCart[index]['quantity'] += 1;
                                cartNotifier.value = currentCart;
                              },
                              icon: const Icon(Icons.add_circle_outline, color: goldPrimary, size: 22),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF0B0E14),
                border: Border(top: BorderSide(color: Color(0xFF161C28), width: 1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Total Amount", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text("₹${total.toInt()}", style: const TextStyle(color: goldPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Order placed successfully!")),
                        );
                        cartNotifier.value = [];
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                      child: const Text("PROCEED TO CHECKOUT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
