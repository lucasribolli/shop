import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/utils/constants.dart';
import 'package:shop/exceptions/http_exception.dart';
import 'package:shop/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items;
  String _token;
  String _userId;

  Products([this._token, this._userId, this._items = const []]);


  List<Product> get items => [..._items];

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  Future<void> loadProducts() async {
    final response = await http.get("${Constants.BASE_URL_PRODUCTS}.json?auth=$_token");
    Map<String, dynamic> data = json.decode(response.body);
    final favResponse = 
      await http.get("${Constants.BASE_URL_USER_FAVORITES}/$_userId.json?auth=$_token");
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
        ));
      });
      notifyListeners();
    }
    return Future.value();
  }

  Future<void> addProduct(Product newProduct) async {
    final response = await http.post(
      "${Constants.BASE_URL_PRODUCTS}.json?auth=$_token",
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
    ));
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    if (product != null && product.id != null) {
      final index = _items.indexWhere((prod) => prod.id == product.id);

      if (index >= 0) {
        await http.patch(
          "${Constants.BASE_URL_PRODUCTS}/${product.id}.json?auth=$_token",
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
  }

  Future<void> deleteProduct(String id) async {
    final index = _items.indexWhere((prod) => prod.id == id);
    if (index >= 0) {
      final product = _items[index];

      _items.removeWhere((prod) => prod.id == id);
      notifyListeners();

      final response = await http.delete("${Constants.BASE_URL_PRODUCTS}/${product.id}.json?auth=$_token");

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
