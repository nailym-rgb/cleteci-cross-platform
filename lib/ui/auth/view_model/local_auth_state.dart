import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:local_auth/local_auth.dart';

class LocalAuthState extends ChangeNotifier {
  final LocalAuthentication auth = LocalAuthentication();
  LocalAuthSupportState _supportState = LocalAuthSupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  LocalAuthSupportState get supportState => _supportState;
  bool get canCheckBiometrics => _canCheckBiometrics ?? false;
  List<BiometricType> get availableBiometrics =>
      _availableBiometrics ?? <BiometricType>[];
  String get authorized => _authorized;
  bool get isAuthenticating => _isAuthenticating;

  LocalAuthState() {
    _init();
  }

  Future<void> _init() async {
    try {
      final bool isSupported = await auth.isDeviceSupported();
      _supportState = isSupported
          ? LocalAuthSupportState.supported
          : LocalAuthSupportState.unsupported;
    } on Exception catch (e) {
      _supportState = LocalAuthSupportState.unsupported;
    } finally {
      notifyListeners();
    }
  }

  Future<void> checkBiometrics() async {
    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      _canCheckBiometrics = false;
    }
    notifyListeners();
  }

  Future<void> getAvailableBiometrics() async {
    try {
      _availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      _availableBiometrics = <BiometricType>[];
    }
    notifyListeners();
  }

  Future<void> authenticate() async {
    try {
      _isAuthenticating = true;
      _authorized = 'Authenticating';
      notifyListeners();

      final authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(stickyAuth: true),
      );
      _isAuthenticating = false;
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      notifyListeners();
    } on PlatformException catch (e) {
      _isAuthenticating = false;
      _authorized = 'Error - ${e.message}';
      notifyListeners();
    }
  }

  Future<void> authenticateWithBiometrics() async {
    try {
      _isAuthenticating = true;
      _authorized = 'Authenticating';
      notifyListeners();

      final authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      _isAuthenticating = false;
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
      notifyListeners();
    } on PlatformException catch (e) {
      _isAuthenticating = false;
      _authorized = 'Error - ${e.message}';
      notifyListeners();
    }
  }

  Future<void> cancelAuthentication() async {
    await auth.stopAuthentication();
    _isAuthenticating = false;
    notifyListeners();
  }
}

enum LocalAuthSupportState { unknown, supported, unsupported }
