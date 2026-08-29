import 'package:go_router/go_router.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/south_kitchen/south_kitchen_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/demo_booking_screen.dart';
import '../screens/features_screen.dart';
import '../screens/pricing_screen.dart';
import '../screens/content_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainNavigationScreen(),
    ),
    GoRoute(
      path: '/south-kitchen',
      builder: (context, state) => const SouthKitchenScreen(),
    ),
    GoRoute(
      path: '/south-kitchen/catering',
      builder: (context, state) => const CateringScreen(),
    ),
    GoRoute(
      path: '/south-kitchen/locations',
      builder: (context, state) => const LocationsScreen(),
    ),
    GoRoute(
      path: '/south-kitchen/gift-cards',
      builder: (context, state) => const GiftCardsScreen(),
    ),
    GoRoute(
      path: '/south-kitchen/menu',
      builder: (context, state) => const MenusScreen(),
    ),
    GoRoute(
      path: '/south-kitchen/blog',
      builder: (context, state) => const BlogScreen(),
    ),
    GoRoute(
      path: '/auth/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/auth/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/demo-booking',
      builder: (context, state) => const DemoBookingScreen(),
    ),
    GoRoute(
      path: '/features',
      builder: (context, state) => const FeaturesScreen(),
    ),
    GoRoute(
      path: '/pricing',
      builder: (context, state) => const PricingScreen(),
    ),
    GoRoute(
      path: '/info/:title',
      builder: (context, state) {
        final title = state.pathParameters['title'] ?? 'Info';
        // Convert URL param to Title Case (e.g. "privacy-policy" -> "Privacy Policy")
        final formattedTitle = title.split('-').map((s) => s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : '').join(' ');
        return ContentScreen(title: formattedTitle);
      },
    ),
  ],
);
