import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop/views/auth_home_screen.dart';
import '../providers/auth_test.mocks.dart';
import 'utils/home_widget_utils.dart';

void main() {
  group('Auth Page Widget Tests', () {
    testWidgets('Test app name shows up', (tester) async {
      final MockClient client = MockClient();
      await tester.pumpWidget(createHomeScreen(client, AuthOrHomeScreen()));
      // wait all animations complete
      await tester.pumpAndSettle();
      expect(find.text('Minha Loja'), findsOneWidget);
    });

    testWidgets('Test if a card shows up', (tester) async {
      final MockClient client = MockClient();
      await tester.pumpWidget(createHomeScreen(client, AuthOrHomeScreen()));
      // wait all animations complete
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('Testing if there is textfields', (tester) async {
      final MockClient client = MockClient();
      await tester.pumpWidget(createHomeScreen(client, AuthOrHomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('Test if buttons shows up', (tester) async {
      final MockClient client = MockClient();
      await tester.pumpWidget(createHomeScreen(client, AuthOrHomeScreen()));
      // wait all animations complete
      await tester.pumpAndSettle();
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
