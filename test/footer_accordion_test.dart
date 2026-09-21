import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aiden_cafe_mobile/widgets/shared/footer.dart';

void main() {
  group('MainFooter Accordion on Mobile Screen', () {
    testWidgets('sections are collapsed by default on mobile', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MainFooter(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Titles are displayed
      expect(find.text('VISIT US'), findsOneWidget);
      expect(find.text('EXPLORE'), findsOneWidget);
      expect(find.text('LEGAL'), findsOneWidget);

      // Down chevron icons are displayed for the 3 sections
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNWidgets(3));

      // Collapsed by default - links should not be visible on screen
      expect(find.text('Locations'), findsNothing);
      expect(find.text('Our Story'), findsNothing);
      expect(find.text('Menu'), findsNothing);
      expect(find.text('Privacy Policy'), findsNothing);
    });

    testWidgets('tapping a section expands it, tapping again collapses it', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MainFooter(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially collapsed
      expect(find.text('Locations'), findsNothing);

      // Tap 'VISIT US'
      await tester.ensureVisible(find.text('VISIT US'));
      await tester.tap(find.text('VISIT US'));
      await tester.pumpAndSettle();

      // Now VISIT US links are visible
      expect(find.text('Locations'), findsOneWidget);
      expect(find.text('Our Story'), findsOneWidget);
      expect(find.text('Catering'), findsOneWidget);
      expect(find.text('Gift Cards'), findsOneWidget);

      // Other sections remain collapsed
      expect(find.text('Menu'), findsNothing);
      expect(find.text('Privacy Policy'), findsNothing);

      // Tap 'VISIT US' again to collapse
      await tester.tap(find.text('VISIT US'));
      await tester.pumpAndSettle();

      // Links are hidden again
      expect(find.text('Locations'), findsNothing);
    });

    testWidgets('sections expand independently', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MainFooter(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'EXPLORE'
      await tester.ensureVisible(find.text('EXPLORE'));
      await tester.tap(find.text('EXPLORE'));
      await tester.pumpAndSettle();

      // 'EXPLORE' items visible
      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('Blog'), findsOneWidget);
      // 'VISIT US' and 'LEGAL' items still collapsed
      expect(find.text('Locations'), findsNothing);
      expect(find.text('Privacy Policy'), findsNothing);

      // Tap 'LEGAL'
      await tester.ensureVisible(find.text('LEGAL'));
      await tester.tap(find.text('LEGAL'));
      await tester.pumpAndSettle();

      // Both EXPLORE and LEGAL can be open
      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('Locations'), findsNothing);
    });
  });

  group('MainFooter on Desktop Screen', () {
    testWidgets('all links are visible directly without accordion chevrons', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MainFooter(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Titles visible
      expect(find.text('VISIT US'), findsOneWidget);
      expect(find.text('EXPLORE'), findsOneWidget);
      expect(find.text('LEGAL'), findsOneWidget);

      // Links visible directly on desktop
      expect(find.text('Locations'), findsOneWidget);
      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);

      // No accordion chevrons on desktop
      expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
    });
  });
}
