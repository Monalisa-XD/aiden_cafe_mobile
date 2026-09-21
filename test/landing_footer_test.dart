import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aiden_cafe_mobile/screens/landing_homepage_screen.dart';
import 'package:aiden_cafe_mobile/screens/features_screen.dart';
import 'package:aiden_cafe_mobile/screens/pricing_screen.dart';
import 'package:aiden_cafe_mobile/providers/app_state_provider.dart';
import 'package:aiden_cafe_mobile/providers/cart_provider.dart';
import 'package:aiden_cafe_mobile/providers/auth_provider.dart';

Widget _createTestWidget({required Size screenSize}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: screenSize),
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const Scaffold(
          body: LandingHomepageScreen(),
        ),
      ),
    ),
  );
}

void main() {
  group('Landing Page Footer Mobile Layout & Email Input', () {
    testWidgets('mobile layout has centered headings and editable email TextField', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestWidget(screenSize: const Size(390, 844)));
      await tester.pumpAndSettle();

      // Scroll to footer
      final newsletterFinder = find.text('NEWSLETTER');
      await tester.scrollUntilVisible(newsletterFinder, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      // Verify centered elements exist
      expect(find.text('AIDEN CAFE'), findsWidgets);
      expect(find.text("THE DIGITAL MAÎTRE D' FOR THE MODERN CAFE."), findsOneWidget);
      expect(find.text('NAVIGATION'), findsOneWidget);
      expect(find.text('FEATURES'), findsWidgets);
      expect(find.text('PRICING'), findsWidgets);
      expect(find.text('CONTACT'), findsOneWidget);
      expect(find.text('LEGAL'), findsOneWidget);
      expect(find.text('TERMS OF SERVICE'), findsOneWidget);
      expect(find.text('PRIVACY POLICY'), findsOneWidget);
      expect(find.text('NEWSLETTER'), findsOneWidget);

      // Verify PRIVACY POLICY has the same color as TERMS OF SERVICE (Color(0xFF94A3B8))
      final termsText = tester.widget<Text>(find.text('TERMS OF SERVICE'));
      final privacyText = tester.widget<Text>(find.text('PRIVACY POLICY'));
      expect(termsText.style?.color, const Color(0xFF94A3B8));
      expect(privacyText.style?.color, const Color(0xFF94A3B8));
      expect(privacyText.style?.color, termsText.style?.color);

      // Verify horizontal centering on mobile (screen width 390 -> center ~195)
      const expectedCenterX = 390 / 2;
      expect(tester.getCenter(find.text("THE DIGITAL MAÎTRE D' FOR THE MODERN CAFE.")).dx, closeTo(expectedCenterX, 2.0));
      expect(tester.getCenter(find.text('NAVIGATION')).dx, closeTo(expectedCenterX, 2.0));
      expect(tester.getCenter(find.text('LEGAL')).dx, closeTo(expectedCenterX, 2.0));
      expect(tester.getCenter(find.text('NEWSLETTER')).dx, closeTo(expectedCenterX, 2.0));

      // Verify the newsletter email field is an actual editable TextField
      final emailTextFieldFinder = find.byType(TextField);
      expect(emailTextFieldFinder, findsOneWidget);

      // Verify hint text "YOUR EMAIL" is present in the input decoration
      final TextField emailField = tester.widget(emailTextFieldFinder);
      expect(emailField.decoration?.hintText, 'YOUR EMAIL');

      // Test typing into the email TextField
      await tester.enterText(emailTextFieldFinder, 'customer@example.com');
      await tester.pumpAndSettle();

      expect(find.text('customer@example.com'), findsOneWidget);

      // Verify floating badge is present and does not overlap the email field
      final badgeFinder = find.text('NOW OPEN');
      expect(badgeFinder, findsOneWidget);

      final emailRect = tester.getRect(emailTextFieldFinder);
      final badgeRect = tester.getRect(badgeFinder);

      // Email is positioned on the left side of the mobile screen
      expect(emailRect.left, lessThan(100));
      // Badge is positioned on the right side
      expect(badgeRect.right, greaterThan(emailRect.right));
    });
  });

  group('Landing Page Footer Desktop Layout', () {
    testWidgets('desktop layout preserves 4 columns and editable email input', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestWidget(screenSize: const Size(1200, 900)));
      await tester.pumpAndSettle();

      // Scroll to footer
      final newsletterFinder = find.text('NEWSLETTER');
      await tester.scrollUntilVisible(newsletterFinder, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      expect(find.text('AIDEN CAFE'), findsWidgets);
      expect(find.text('NAVIGATION'), findsOneWidget);
      expect(find.text('LEGAL'), findsOneWidget);
      expect(find.text('NEWSLETTER'), findsOneWidget);

      // Email input is an editable TextField on desktop
      final emailTextFieldFinder = find.byType(TextField);
      expect(emailTextFieldFinder, findsOneWidget);

      await tester.enterText(emailTextFieldFinder, 'webuser@example.com');
      await tester.pumpAndSettle();

      expect(find.text('webuser@example.com'), findsOneWidget);
    });
  });

  group('Landing Page Footer Clickable Links Navigation', () {
    testWidgets('clicking CONTACT navigates to Contact content screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestWidget(screenSize: const Size(390, 844)));
      await tester.pumpAndSettle();

      final contactFinder = find.text('CONTACT');
      await tester.scrollUntilVisible(contactFinder, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      await tester.tap(contactFinder);
      await tester.pumpAndSettle();

      expect(find.text('CONTACT'), findsWidgets);
      expect(find.text('Content for Contact will appear here soon.'), findsOneWidget);
    });

    testWidgets('clicking PRIVACY POLICY navigates to Privacy Policy content screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestWidget(screenSize: const Size(390, 844)));
      await tester.pumpAndSettle();

      final privacyFinder = find.text('PRIVACY POLICY');
      await tester.scrollUntilVisible(privacyFinder, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      await tester.tap(privacyFinder);
      await tester.pumpAndSettle();

      expect(find.text('PRIVACY POLICY'), findsWidgets);
      expect(find.text('Content for Privacy Policy will appear here soon.'), findsOneWidget);
    });

    testWidgets('clicking TERMS OF SERVICE navigates to Terms of Service content screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestWidget(screenSize: const Size(390, 844)));
      await tester.pumpAndSettle();

      final termsFinder = find.text('TERMS OF SERVICE');
      await tester.scrollUntilVisible(termsFinder, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      await tester.tap(termsFinder);
      await tester.pumpAndSettle();

      expect(find.text('TERMS OF SERVICE'), findsWidgets);
      expect(find.text('Content for Terms of Service will appear here soon.'), findsOneWidget);
    });

    testWidgets('clicking FEATURES navigates to FeaturesScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestWidget(screenSize: const Size(390, 844)));
      await tester.pumpAndSettle();

      // Find the footer FEATURES link
      final featuresFinder = find.text('FEATURES').last;
      await tester.scrollUntilVisible(featuresFinder, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      await tester.tap(featuresFinder);
      await tester.pumpAndSettle();

      expect(find.byType(FeaturesScreen), findsOneWidget);
    });

    testWidgets('clicking PRICING navigates to PricingScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestWidget(screenSize: const Size(390, 844)));
      await tester.pumpAndSettle();

      // Find the footer PRICING link
      final pricingFinder = find.text('PRICING').last;
      await tester.scrollUntilVisible(pricingFinder, 500.0, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      await tester.tap(pricingFinder);
      await tester.pumpAndSettle();

      expect(find.byType(PricingScreen), findsOneWidget);
    });
  });
}
