import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aiden_cafe_mobile/models/menu_item.dart';
import 'package:aiden_cafe_mobile/models/cart_item.dart';
import 'package:aiden_cafe_mobile/providers/cart_provider.dart';

void main() {
  group('CartProvider Unit Tests', () {
    late CartProvider cart;

    final testItem1 = const MenuItem(
      id: 'item-1',
      badge: 'POPULAR',
      category: 'SOUTH INDIAN BREAKFAST',
      name: 'Masala Dosa',
      description: 'Crisp crepe with potato filling',
      image: 'https://example.com/dosa.jpg',
      price: 80.0,
      isVeg: true,
    );

    final testItem2 = const MenuItem(
      id: 'item-2',
      badge: 'BEVERAGES',
      category: 'BEVERAGES',
      name: 'Filter Coffee',
      description: 'Traditional frothed coffee',
      image: 'https://example.com/coffee.jpg',
      price: 40.0,
      isVeg: true,
    );

    final testItem3 = const MenuItem(
      id: 'item-3',
      badge: 'BHATHS',
      category: 'BHATHS',
      name: 'Chow Chow Bhath',
      description: 'Savory and sweet combination',
      image: 'https://example.com/bhath.jpg',
      price: 90.0,
      isVeg: true,
    );

    setUp(() {
      cart = CartProvider();
    });

    test('Initial cart is empty with zero count and total', () {
      expect(cart.isEmpty, isTrue);
      expect(cart.isNotEmpty, isFalse);
      expect(cart.items.length, 0);
      expect(cart.totalCount, 0);
      expect(cart.subtotal, 0.0);
      expect(cart.total, 0.0);
    });

    test('Add item adds a single item correctly', () {
      cart.addItem(testItem1);

      expect(cart.isEmpty, isFalse);
      expect(cart.items.length, 1);
      expect(cart.items.first.id, 'item-1');
      expect(cart.items.first.name, 'Masala Dosa');
      expect(cart.items.first.price, 80.0);
      expect(cart.items.first.quantity, 1);
      expect(cart.totalCount, 1);
      expect(cart.total, 80.0);
    });

    test('Add same item increments its quantity', () {
      cart.addItem(testItem1);
      cart.addItem(testItem1, quantity: 2);

      expect(cart.items.length, 1);
      expect(cart.items.first.quantity, 3);
      expect(cart.totalCount, 3);
      expect(cart.total, 240.0);
    });

    test('Add multiple different items calculates totals correctly', () {
      cart.addItem(testItem1, quantity: 2); // 2 * 80 = 160
      cart.addItem(testItem2, quantity: 3); // 3 * 40 = 120
      cart.addItem(testItem3, quantity: 1); // 1 * 90 = 90

      expect(cart.items.length, 3);
      expect(cart.totalCount, 6);
      expect(cart.subtotal, 370.0);
      expect(cart.total, 370.0);
    });

    test('Increase quantity increments item quantity and updates total', () {
      cart.addItem(testItem1);
      expect(cart.totalCount, 1);

      cart.increaseQuantity('item-1');
      expect(cart.getQuantity('item-1'), 2);
      expect(cart.totalCount, 2);
      expect(cart.total, 160.0);
    });

    test('Decrease quantity decrements quantity when greater than 1', () {
      cart.addItem(testItem1, quantity: 2);
      expect(cart.getQuantity('item-1'), 2);

      cart.decreaseQuantity('item-1');
      expect(cart.getQuantity('item-1'), 1);
      expect(cart.totalCount, 1);
      expect(cart.total, 80.0);
    });

    test('Decrease quantity removes item when quantity reaches 0', () {
      cart.addItem(testItem1, quantity: 1);
      expect(cart.containsItem('item-1'), isTrue);

      cart.decreaseQuantity('item-1');
      expect(cart.containsItem('item-1'), isFalse);
      expect(cart.items.isEmpty, isTrue);
      expect(cart.totalCount, 0);
      expect(cart.total, 0.0);
    });

    test('Explicit removeItem removes item matching id', () {
      cart.addItem(testItem1, quantity: 2);
      cart.addItem(testItem2, quantity: 1);
      expect(cart.items.length, 2);

      cart.removeItem('item-1');
      expect(cart.items.length, 1);
      expect(cart.containsItem('item-1'), isFalse);
      expect(cart.containsItem('item-2'), isTrue);
      expect(cart.total, 40.0);
    });

    test('Clear removes all items and resets total', () {
      cart.addItem(testItem1, quantity: 2);
      cart.addItem(testItem2, quantity: 3);
      expect(cart.totalCount, 5);

      cart.clear();
      expect(cart.isEmpty, isTrue);
      expect(cart.totalCount, 0);
      expect(cart.total, 0.0);
    });

    test('CartItem model properties and calculations', () {
      const item = CartItem(
        id: '10',
        name: 'Filter Coffee',
        price: 40.0,
        image: 'https://example.com/c.jpg',
        quantity: 3,
        category: 'BEVERAGES',
      );

      expect(item.subtotal, 120.0);
      expect(item['name'], 'Filter Coffee');
      expect(item['price'], 40.0);
      expect(item['quantity'], 3);
      expect(item['subtotal'], 120.0);

      final modified = item.copyWith(quantity: 5);
      expect(modified.quantity, 5);
      expect(modified.subtotal, 200.0);
      expect(modified.name, 'Filter Coffee');
    });

    test('Toggle, open, and close cart visibility flags', () {
      expect(cart.showCart, isFalse);

      cart.openCart();
      expect(cart.showCart, isTrue);

      cart.closeCart();
      expect(cart.showCart, isFalse);

      cart.toggleCart();
      expect(cart.showCart, isTrue);
      cart.toggleCart();
      expect(cart.showCart, isFalse);
    });
  });

  group('CartProvider State Preservation across Widget Navigation', () {
    testWidgets('Cart state is preserved across screen navigation', (WidgetTester tester) async {
      final cartProvider = CartProvider();

      await tester.pumpWidget(
        ChangeNotifierProvider<CartProvider>.value(
          value: cartProvider,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      children: [
                        Consumer<CartProvider>(
                          builder: (context, cart, child) {
                            return Text('CartCount: ${cart.totalCount}');
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<CartProvider>().addItem(
                              const MenuItem(
                                id: 'nav-item-1',
                                badge: 'MENU',
                                category: 'BREAKFAST',
                                name: 'Idli',
                                description: 'Fluffy idli',
                                image: '',
                                price: 60.0,
                              ),
                            );
                          },
                          child: const Text('Add Idli'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  appBar: AppBar(title: const Text('Second Screen')),
                                  body: Consumer<CartProvider>(
                                    builder: (context, cart, child) {
                                      return Text('SecondScreenCount: ${cart.totalCount}');
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          child: const Text('Go To Second Screen'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('CartCount: 0'), findsOneWidget);

      // Tap to add item
      await tester.tap(find.text('Add Idli'));
      await tester.pump();
      expect(find.text('CartCount: 1'), findsOneWidget);

      // Navigate to second screen
      await tester.tap(find.text('Go To Second Screen'));
      await tester.pumpAndSettle();

      // Verify state is preserved in second screen
      expect(find.text('SecondScreenCount: 1'), findsOneWidget);

      // Navigate back to first screen
      Navigator.pop(tester.element(find.text('SecondScreenCount: 1')));
      await tester.pumpAndSettle();

      // Verify state is still intact
      expect(find.text('CartCount: 1'), findsOneWidget);
    });
  });
}
