import 'package:http/http.dart' as http;
import 'package:shop/utils/api_keys.dart';

class AuthUtils {

  static Future<void> createNewAccount(http.Client client, String body) async {
    await client.post(
      Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${ApiKeys.FIREBASE_KEY}',
      ),
      body: body
    );
  }

  static Future<void> login(http.Client client, String body) async {
    await client.post(
      Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${ApiKeys.FIREBASE_KEY}',
      ),
      body: body
    );
  }

}