import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:local_auth/local_auth.dart';
import 'package:cleteci_cross_platform/ui/auth/view_model/local_auth_state.dart';
import 'package:flutter/services.dart';

import 'local_auth_state_test.mocks.dart';

@GenerateMocks([LocalAuthentication])
void main() {
  late MockLocalAuthentication mockAuth;
  late LocalAuthState localAuthState;

  setUpAll(() async {
    // Ensure binding is initialized
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockAuth = MockLocalAuthentication();
    when(mockAuth.isDeviceSupported()).thenAnswer((_) async => true);
    localAuthState = LocalAuthState(auth: mockAuth);
  });

  test('Initial state is correct after init', () async {
    await Future.delayed(const Duration(milliseconds: 10));
    expect(localAuthState.supportState, LocalAuthSupportState.supported);
    expect(localAuthState.canCheckBiometrics, false);
    expect(localAuthState.availableBiometrics, <BiometricType>[]);
    expect(localAuthState.authorized, 'Not Authorized');
    expect(localAuthState.isAuthenticating, false);
  });

  test('checkBiometrics sets canCheckBiometrics to true', () async {
    when(mockAuth.canCheckBiometrics).thenAnswer((_) async => true);
    await localAuthState.checkBiometrics();
    expect(localAuthState.canCheckBiometrics, true);
  });

  test('checkBiometrics sets canCheckBiometrics to false on exception', () async {
    when(mockAuth.canCheckBiometrics).thenThrow(PlatformException(code: 'error'));
    await localAuthState.checkBiometrics();
    expect(localAuthState.canCheckBiometrics, false);
  });

  test('getAvailableBiometrics sets availableBiometrics', () async {
    final biometrics = [BiometricType.fingerprint, BiometricType.face];
    when(mockAuth.getAvailableBiometrics()).thenAnswer((_) async => biometrics);
    await localAuthState.getAvailableBiometrics();
    expect(localAuthState.availableBiometrics, biometrics);
  });

  test('getAvailableBiometrics sets availableBiometrics to empty on exception', () async {
    when(mockAuth.getAvailableBiometrics()).thenThrow(PlatformException(code: 'error'));
    await localAuthState.getAvailableBiometrics();
    expect(localAuthState.availableBiometrics, <BiometricType>[]);
  });

  test('authenticate sets authorized to Authorized on success', () async {
    when(mockAuth.authenticate(
      localizedReason: anyNamed('localizedReason'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => true);
    await localAuthState.authenticate();
    expect(localAuthState.authorized, 'Authorized');
    expect(localAuthState.isAuthenticating, false);
  });

  test('authenticate sets authorized to Not Authorized on failure', () async {
    when(mockAuth.authenticate(
      localizedReason: anyNamed('localizedReason'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => false);
    await localAuthState.authenticate();
    expect(localAuthState.authorized, 'Not Authorized');
    expect(localAuthState.isAuthenticating, false);
  });

  test('authenticate sets authorized to error message on exception', () async {
    when(mockAuth.authenticate(
      localizedReason: anyNamed('localizedReason'),
      options: anyNamed('options'),
    )).thenThrow(PlatformException(code: 'error', message: 'Test error'));
    await localAuthState.authenticate();
    expect(localAuthState.authorized, contains('Error'));
    expect(localAuthState.isAuthenticating, false);
  });

  test('authenticateWithBiometrics sets authorized to Authorized on success', () async {
    when(mockAuth.authenticate(
      localizedReason: anyNamed('localizedReason'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => true);
    await localAuthState.authenticateWithBiometrics();
    expect(localAuthState.authorized, 'Authorized');
    expect(localAuthState.isAuthenticating, false);
  });

  test('authenticateWithBiometrics sets authorized to Not Authorized on failure', () async {
    when(mockAuth.authenticate(
      localizedReason: anyNamed('localizedReason'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => false);
    await localAuthState.authenticateWithBiometrics();
    expect(localAuthState.authorized, 'Not Authorized');
    expect(localAuthState.isAuthenticating, false);
  });

  test('authenticateWithBiometrics sets authorized to error message on exception', () async {
    when(mockAuth.authenticate(
      localizedReason: anyNamed('localizedReason'),
      options: anyNamed('options'),
    )).thenThrow(PlatformException(code: 'error', message: 'Test error'));
    await localAuthState.authenticateWithBiometrics();
    expect(localAuthState.authorized, contains('Error'));
    expect(localAuthState.isAuthenticating, false);
  });

  test('cancelAuthentication sets isAuthenticating to false', () async {
    when(mockAuth.stopAuthentication()).thenAnswer((_) async => true);
    localAuthState.isAuthenticating = true;
    await localAuthState.cancelAuthentication();
    expect(localAuthState.isAuthenticating, false);
  });
}