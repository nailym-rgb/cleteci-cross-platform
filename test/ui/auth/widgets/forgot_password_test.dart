import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cleteci_cross_platform/ui/auth/widgets/forgot_password.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ForgotPassword can be instantiated', (WidgetTester tester) async {
    // Test that the widget can be created without Firebase initialization
    final forgotPassword = ForgotPassword();
    expect(forgotPassword, isNotNull);
    expect(forgotPassword.email, isNull);
  });

  testWidgets('ForgotPassword accepts email parameter', (WidgetTester tester) async {
    const testEmail = 'test@example.com';
    final forgotPassword = ForgotPassword(email: testEmail);
    expect(forgotPassword.email, equals(testEmail));
  });

  testWidgets('ForgotPassword handles null email parameter', (WidgetTester tester) async {
    final forgotPassword = ForgotPassword(email: null);
    expect(forgotPassword.email, isNull);
  });

  testWidgets('ForgotPassword is a StatelessWidget', (WidgetTester tester) async {
    final forgotPassword = ForgotPassword();
    expect(forgotPassword, isA<StatelessWidget>());
  });
}