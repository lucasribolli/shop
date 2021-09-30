import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' as test;
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/product.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/views/products_overview_screen.dart';
import 'package:shop/widgets/app_drawer.dart';
import 'package:shop/widgets/product_grid_item.dart';
import 'package:test/test.dart';
import '../providers/auth_test.mocks.dart';
import 'products_overview_test.mocks.dart';
import 'utils/home_widget_utils.dart';

@GenerateMocks([Products])
void main() {
  group('Product Overview Screen', () {
    late MockClient client;
    late Widget productsScreen;
    late StreamController<Products> _controller;

    setUp(() {
      _controller = StreamController<Products>();
      client = MockClient();
      productsScreen = createHomeScreen(client, ProductOverviewScreen());
    });

    tearDown(() {
      _controller.close();
    });

    test.testWidgets('Test app name shows up in a App Bar', (tester) async {
      await tester.pumpWidget(productsScreen);
      await tester.pumpAndSettle();
      expect(test.find.byType(AppBar), test.findsOneWidget);
      expect(test.find.text('Minha loja'), test.findsOneWidget);
    });

    test.testWidgets('Test if GridView shows up', (tester) async {
      await tester.pumpWidget(productsScreen);
      await tester.pumpAndSettle();
      expect(test.find.byType(GridView), test.findsOneWidget);
    });

    test.testWidgets('First time in app should shows 0 ProductItem', (tester) async {
      await tester.pumpWidget(productsScreen);
      await tester.pumpAndSettle();
      expect(test.find.byType(ProductItem), test.findsNothing);
    });

    test.testWidgets('When click in AppDrawer it should shows MenuDrawer with 4 ListTitle', (tester) async {
      await tester.pumpWidget(
        createHomeScreen(client, AppDrawer()),
      );
      await tester.pumpAndSettle();

      await tester.tap(test.find.byType(AppDrawer));
      expect(test.find.byType(ListTile), test.findsNWidgets(4));
    });

    test.testWidgets('When click in Sair it should back to main screen and show logo app', (tester) async {
      await tester.pumpWidget(
        createHomeScreen(client, AppDrawer()),
      );
      await tester.pumpAndSettle();

      await tester.tap(test.find.byType(AppDrawer));
      await tester.tap(test.find.byKey(ValueKey('sair_key')));
      expect(test.find.text('Minha Loja'), test.findsOneWidget);
    }, skip: true);

    // https://medium.com/codechai/testing-provider-in-flutter-8fe3876796e1
    // https://blog.flutterando.com.br/widget-testing-dealing-with-dependencies-c429fc90a9b5
    // https://github.com/rrousselGit/provider/issues/182
    test.testWidgets(
        'When there is one Product in Provider it should shows 1 ProductItem',
        (test.WidgetTester tester) async {
      Products products = MockProducts();
      await products.addProduct(mockProduct(client).first);
      _controller.add(products);

      await tester.pumpWidget(
        StreamProvider<Products>(
          initialData: products,
          create: (c) {
            return _controller.stream;
          },
          child: productsScreen,
        ),
      );

      // await tester.pumpWidget(
      //   Provider<Products>.value(
      //     value: products,
      //     child: productsScreen,
      //   ),
      // );
      
      await tester.pumpAndSettle();

      expect(test.find.byType(ProductItem), test.findsOneWidget);
    }, skip: true);
  });
}

List<Product> mockProduct(MockClient client) {
  return [
    Product(
      title: 'Socker ball',
      description: 'From Fifa',
      price: 50,
      imageUrl:
      'https://cdn.pixabay.com/photo/2013/07/13/10/51/football-157930_960_720.png',
      client: client
    ),
  ];
}
