import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalAuthState', () {
    late LocalAuthState authState;

    setUp(() {
      authState = LocalAuthState();
    });

    test('initial state should be unauthorized', () {
      expect(authState.authorized, LocalAuthStateValue.unauthorized);
    });

    test('initial support state should be unknown', () {
      expect(authState.supportState, LocalAuthSupportState.unknown);
    });

    test('should have empty available biometrics initially', () {
      expect(authState.availableBiometrics, isEmpty);
    });

    test('should not be authenticating initially', () {
      expect(authState.isAuthenticating, false);
    });

    test('should not be able to check biometrics initially', () {
      expect(authState.canCheckBiometrics, false);
    });
  });
}