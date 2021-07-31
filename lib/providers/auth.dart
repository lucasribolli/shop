import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop/data/store.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/utils/api_keys.dart';
import 'package:shop/utils/data_keys.dart';


class Auth with ChangeNotifier {
  static const String _signUpSegment = 'signUp';
  static const String _loginSegment = 'signInWithPassword';

  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _logoutTimer;

  bool get isAuth {
    return token != null;
  }

  String get userId {
    return isAuth ? _userId : null;
  }

  String get token {
    if(_token != null && 
      _expiryDate != null &&
      _expiryDate.isAfter(DateTime.now())) {
        return _token;
    } else {
      return null;
    }
  }

  Future<void> _authenticate(
    String email, String password, String urlSegment) async {
    final url = 
      'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=${ApiKeys.FIREBASE_KEY}';

    final response = await http.post(
      url, 
      body: json.encode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      })
    );

    final responseBody = json.decode(response.body);

    if(responseBody["error"] != null) {
      throw AuthException(responseBody['error']['message']);
    } else {
      _token = responseBody["idToken"];
      _userId = responseBody["localId"];
      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(responseBody["expiresIn"])
        )
      );

      Store.saveMap(DataKeys.USER_DATA_KEY, {
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });

      _autoLogout();
      notifyListeners();
    }

    return Future.value();
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, _signUpSegment);
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, _loginSegment);
  }

  Future<void> tryAutoLogin() async {
    if(isAuth) {
      return Future.value();
    }

    final userData = await Store.getMap(DataKeys.USER_DATA_KEY);
    if(userData.isEmpty) {
      return Future.value();
    }

    final expiryDate = DateTime.parse(userData['expiryDate']);

    if(expiryDate.isBefore(DateTime.now())) {
      return Future.value();
    }

    _userId = userData['userId'];
    _token = userData['token'];
    _expiryDate = expiryDate;

    _autoLogout();
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if(_logoutTimer != null) {
      _logoutTimer.cancel();
      _logoutTimer = null;
    }
    await Store.remove(DataKeys.USER_DATA_KEY);
    notifyListeners();
  }

  void _autoLogout() {
    if(_logoutTimer != null) {
      _logoutTimer.cancel();
    }
    final timeToLogout = _expiryDate.difference(DateTime.now()).inSeconds;
    _logoutTimer = Timer(Duration(seconds: timeToLogout), logout);
  }
}