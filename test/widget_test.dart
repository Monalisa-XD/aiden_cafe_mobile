import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aiden_cafe_mobile/main.dart';
import 'package:aiden_cafe_mobile/providers/app_state_provider.dart';
import 'package:aiden_cafe_mobile/providers/cart_provider.dart';
import 'package:aiden_cafe_mobile/providers/auth_provider.dart';
import 'package:aiden_cafe_mobile/screens/main_navigation_screen.dart';

void main() {
  testWidgets('App launches and displays MainNavigationScreen with providers', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
        ],
        child: const AidenCafeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.text('AIDEN CAFE'), findsWidgets);
  });
}
