import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shop/data/store.dart';
import 'package:shop/exceptions/auth_exception.dart';
import 'package:shop/providers/auth.dart';
import 'package:shop/utils/api_keys.dart';
import 'package:shop/utils/data_keys.dart';
import 'auth_test.mocks.dart';

// Generate mocks: `flutter packages pub run build_runner build`
// Run all tests: `flutter test`

// Generate a MockClient using the Mockito package.
// Create new instances of this class in each test.
@GenerateMocks([http.Client])
void main() {
  group('Authentication', () {
    test('Sign up with a valid account should set token in Auth Provider', () async {
      final MockClient client = MockClient();

      when(
        client.post(
          Uri.parse(
            SIGN_UP_URL,
          ),
          body: json.encode(REQUEST_SIGN_ACCOUNT)
        ),
      )
      .thenAnswer((_) async =>
        http.Response(RESPONSE_SIGN_SUCCESS, 200));

      final Auth auth = Auth(client);

      await expectLater(
        auth.signup(
          REQUEST_SIGN_ACCOUNT['email'], 
          REQUEST_SIGN_ACCOUNT['password']
        ), 
        isA<Future<void>>()
      );
      expect(auth.token, isA<String>());
      expect(await Store.getMap(DataKeys.USER_DATA_KEY), isA<Map<String, dynamic>>());
    });

    test('Sign up with an e-mail that already exists should not succeed', () async {
      final MockClient client = MockClient();
      final Uri url = Uri.parse(
        SIGN_UP_URL,
      );

      when(
        client.post(
          url,
          body: json.encode(REQUEST_SIGN_ACCOUNT)
        ),
      )
      .thenAnswer((_) async =>
        http.Response(RESPONSE_SIGN_ERROR, 400));

      final Auth auth = Auth(client);
      expect(
        auth.signup(
          REQUEST_SIGN_ACCOUNT['email'], 
          REQUEST_SIGN_ACCOUNT['password']
        ), 
        throwsA(isA<AuthException>())
      );
      expect(auth.token, null);
      expect(await Store.getMap(DataKeys.USER_DATA_KEY), isA<Map<String, dynamic>>());
    });

    test('throws AuthException if password in login is invalid', () async {
      final MockClient client = MockClient();

      when(
        client.post(
          Uri.parse(
            LOGIN_URL,
          ),
          body: json.encode(REQUEST_LOGIN_WRONG_PASSWORD)
        ),
      )
      .thenAnswer((_) async =>
        http.Response(RESPONSE_LOGIN_WRONG_PASSWORD, 400));
      
      final Auth auth = Auth(client);
      expect(
        auth.login(
          REQUEST_LOGIN_WRONG_PASSWORD['email'], 
          REQUEST_LOGIN_WRONG_PASSWORD['password']
        ), 
        throwsA(isA<AuthException>())
      );
      expect(auth.token, null);
      expect(await Store.getMap(DataKeys.USER_DATA_KEY), isA<Map<String, dynamic>>());
    });
  });

  test('Autologin should work after login in a valid account', () async {
    
  }, skip: true);
}

const LOGIN_URL =  'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${ApiKeys.FIREBASE_KEY}';

const SIGN_UP_URL = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${ApiKeys.FIREBASE_KEY}';

const Map<String, dynamic> REQUEST_SIGN_ACCOUNT = 
{
  "email": "email@email.com",
  "password": "123456789",
  "returnSecureToken": true
};

const Map REQUEST_LOGIN_WRONG_PASSWORD = 
{
  'email': 'email@email.com',
  'password': '1234567',
  'returnSecureToken': true
};

const String RESPONSE_SIGN_SUCCESS = 
'''
{
    "kind": "identitytoolkit#SignupNewUserResponse",
    "idToken": "fakeIdToken",
    "email": "email@email.com",
    "refreshToken": "fakeRefreshToken",
    "expiresIn": "3600",
    "localId": "fakeLocalId"
}
''';

const String RESPONSE_SIGN_ERROR =
'''
{
  "error": {
    "code": 400,
    "message": "EMAIL_EXISTS",
    "errors": [
      {
        "message": "EMAIL_EXISTS",
        "domain": "global",
        "reason": "invalid"
      }
    ]
  }
}
''';

const String RESPONSE_LOGIN_WRONG_PASSWORD = 
'''
{
  "error": {
    "code": 400,
    "message": "INVALID_PASSWORD",
    "errors": [
      {
        "message": "INVALID_PASSWORD",
        "domain": "global",
        "reason": "invalid"
      }
    ]
  }
}
''';