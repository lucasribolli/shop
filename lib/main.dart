import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';

import 'package:shop/utils/app_routes.dart';
import 'package:shop/utils/custom_transition.dart';
import 'package:shop/views/auth_home_screen.dart';
import 'package:shop/views/cart_screen.dart';
import 'package:shop/views/orders_screen.dart';
import 'package:shop/views/product_detail_screen.dart';
import 'package:shop/views/product_form_screen.dart';
import 'package:shop/providers/products.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/views/products_screen.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    http.Client client = http.Client();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => new Auth(client),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(client),
          update: (_, auth, previousProducts) => new Products(
            client,
            auth.token,
            auth.userId,
            previousProducts!.items,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(client),
          update: (_, auth, previousOrders) => new Orders(
            client,
            auth.token,
            auth.userId,
            previousOrders!.items,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => new Cart(),
        ),
      ],
      child: MaterialApp(
          title: 'Minha Loja',
          theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              })),
          routes: {
            AppRoutes.AUTH_HOME: (_) => AuthOrHomeScreen(),
            AppRoutes.PRODUCT_DETAIL: (_) => ProductDetailScreen(),
            AppRoutes.CART: (_) => CartScreen(),
            AppRoutes.ORDERS: (_) => OrdersScreen(),
            AppRoutes.PRODUCTS: (_) => ProductsScreen(),
            AppRoutes.PRODUCT_FORM: (_) => ProductFormScreen(),
          }),
    );
  }
}
