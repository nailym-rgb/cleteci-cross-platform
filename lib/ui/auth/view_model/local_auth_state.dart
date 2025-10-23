import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:local_auth/local_auth.dart';

class LocalAuthState extends ChangeNotifier {
  final LocalAuthentication auth;
  LocalAuthSupportState _supportState = LocalAuthSupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  LocalAuthStateValue _authorized = LocalAuthStateValue.unauthorized;
  bool isAuthenticating = false;

  LocalAuthSupportState get supportState => _supportState;
  bool get canCheckBiometrics => _canCheckBiometrics ?? false;
  List<BiometricType> get availableBiometrics =>
      _availableBiometrics ?? <BiometricType>[];
  LocalAuthStateValue get authorized => _authorized;

  LocalAuthState({LocalAuthentication? auth})
    : auth = auth ?? LocalAuthentication() {
    _init();
  }

  Future<void> _init() async {
    try {
      final bool isSupported = await auth.isDeviceSupported();
      _supportState = isSupported
          ? LocalAuthSupportState.supported
          : LocalAuthSupportState.unsupported;
    } on Exception catch (_) {
      _supportState = LocalAuthSupportState.unsupported;
    } finally {
      notifyListeners();
    }
  }

  Future<void> checkBiometrics() async {
    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (_) {
      _canCheckBiometrics = false;
    }
    notifyListeners();
  }

  Future<void> getAvailableBiometrics() async {
    try {
      _availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      _availableBiometrics = <BiometricType>[];
    }
    notifyListeners();
  }

  Future<void> authenticate() async {
    try {
      isAuthenticating = true;
      _authorized = LocalAuthStateValue.loading;
      notifyListeners();

      final authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
      );
      isAuthenticating = false;
      _authorized = authenticated
          ? LocalAuthStateValue.authorized
          : LocalAuthStateValue.unauthorized;
      notifyListeners();
    } on PlatformException catch (_) {
      isAuthenticating = false;
      _authorized = LocalAuthStateValue.error;
      notifyListeners();
    }
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      isAuthenticating = true;
      _authorized = LocalAuthStateValue.loading;
      notifyListeners();

      final authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint or face to authenticate',
        biometricOnly: true,
      );
      isAuthenticating = false;
      _authorized = authenticated
          ? LocalAuthStateValue.authorized
          : LocalAuthStateValue.unauthorized;
      notifyListeners();
    } on PlatformException catch (_) {
      isAuthenticating = false;
      _authorized = LocalAuthStateValue.error;
      notifyListeners();
    }
  }

  Future<void> cancelAuthentication() async {
    await auth.stopAuthentication();
    isAuthenticating = false;
    notifyListeners();
  }
}

enum LocalAuthSupportState { unknown, supported, unsupported }

enum LocalAuthStateValue { authorized, error, loading, unauthorized }
