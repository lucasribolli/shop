import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/providers/cart.dart';
import 'package:shop/providers/orders.dart';
import 'package:shop/providers/products.dart';
import 'package:http/http.dart' as http;

Widget createHomeScreen(http.Client client, Widget home) => MultiProvider(
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
    home: home,
  )
);