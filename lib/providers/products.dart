import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constants.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items;
  String? _token;
  String? _userId;
  http.Client _client;

  Products(this._client, [this._token, this._userId, this._items = const []]);


  List<Product> get items => [..._items];

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Future<void> loadProducts() async {
    final productsUrl = Uri.parse("${Constants.BASE_URL_PRODUCTS}.json?auth=$_token");
    final favoritesUrl = Uri.parse("${Constants.BASE_URL_USER_FAVORITES}/$_userId.json?auth=$_token");
    final response = await _client.get(productsUrl);
    Map<String, dynamic>? data = json.decode(response.body);
    final favResponse = await _client.get(favoritesUrl);
    final favMap = json.decode(favResponse.body);

    _items.clear();
    if (data != null) {
      data.forEach((productId, productData) {
        final isFavorite = favMap == null ? false : favMap[productId] ?? false;
        _items.add(Product(
          id: productId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite: isFavorite,
          client: _client
        ));
      });
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> addProduct(Product newProduct) async {
    final url = Uri.parse("${Constants.BASE_URL_PRODUCTS}.json?auth=$_token"); 
    final response = await http.post(
      url,
      body: json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl,
      }),
    );
    _items.add(Product(
      id: json.decode(response.body)['name'],
      title: newProduct.title,
      description: newProduct.description,
      price: newProduct.price,
      imageUrl: newProduct.imageUrl,
      client: _client
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((prod) => prod.id == product.id);

    if (index >= 0) {
      final url = Uri.parse("${Constants.BASE_URL_PRODUCTS}/${product.id}.json?auth=$_token");
      await http.patch(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
        })
      );
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String? id) async {
    final index = _items.indexWhere((prod) => prod.id == id);
    if (index >= 0) {
      final product = _items[index];

      _items.removeWhere((prod) => prod.id == id);
      notifyListeners();
      final url = Uri.parse("${Constants.BASE_URL_PRODUCTS}/${product.id}.json?auth=$_token");
      final response = await http.delete(url);

      if (response.statusCode >= 400) {
        _items.insert(index, product);
        notifyListeners();
        throw HttpException("Ocorreu um erro na exclusão do produto.");
      }
    }
  }

  int get itemsCount {
    return _items.length;
  }
}
