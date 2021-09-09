import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constants.dart';
import 'package:shop/providers/cart.dart';

class Order {
  final String? id;
  final double? total;
  final List<CartItem>? products;
  final DateTime? date;

  Order({this.id, this.total, this.products, this.date});
}

class Orders with ChangeNotifier {
  List<Order> _items = [];
  String? _token;
  String? _userId;
  late http.Client _client;

  Orders(this._client, [this._token, this._userId, this._items = const []]);

  List<Order> get items => [..._items];

  int get itemsCount {
    return _items.length;
  }

  Future<void> addOrder(Cart cart) async {
    final date = DateTime.now();
    final url =
        Uri.parse("${Constants.BASE_URL_ORDERS}/$_userId.json?auth=$_token");
    final response = await _client.post(url,
        body: json.encode({
          'total': cart.totalAmout,
          'date': date.toIso8601String(),
          'products': cart.items.values
              .map((cartItem) => {
                    'id': cartItem.id,
                    'productId': cartItem.productId,
                    'title': cartItem.title,
                    'quantity': cartItem.quantity,
                    'price': cartItem.price,
                  })
              .toList(),
        }));

    _items.insert(
        0,
        Order(
          id: json.decode(response.body)['name'],
          total: cart.totalAmout,
          date: date,
          products: cart.items.values.toList(),
        ));
    notifyListeners();
  }

  List<CartItem> _getProductsFromOrder(List<dynamic>? order) {
    if (order == null) {
      return <CartItem>[];
    }
    return order.map((item) {
      return CartItem(
          id: item['id'],
          price: item['price'],
          productId: item['productId'],
          quantity: item['quantity'],
          title: item['title']);
    }).toList();
  }

  Future<void> loadOrders() async {
    List<Order> loadedItems = [];
    final url =
        Uri.parse("${Constants.BASE_URL_ORDERS}/$_userId.json?auth=$_token");
    final response = await _client.get(url);

    Map<String, dynamic>? data = json.decode(response.body);

    if (data != null) {
      data.forEach((orderId, orderData) {
        loadedItems.add(Order(
            id: orderId,
            total: orderData['total'],
            date: DateTime.parse(orderData['date']),
            products: _getProductsFromOrder(
                orderData['products'] as List<dynamic>?)));
      });
    }
    _items = loadedItems.reversed.toList();
    notifyListeners();

    return Future.value();
  }
}
