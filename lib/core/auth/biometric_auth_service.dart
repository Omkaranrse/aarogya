import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Clinical Biometric Authentication Service
/// Supports Face ID, Touch ID, and Fingerprint re-authentication during clinical duty rounds.
class BiometricAuthService extends ChangeNotifier {
  BiometricAuthService();

  final LocalAuthentication _auth = LocalAuthentication();

  bool _isStationLocked = false;
  bool get isStationLocked => _isStationLocked;

  /// Check if hardware supports biometrics
  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Get list of available biometric types (Face, Fingerprint, Iris)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Authenticate doctor or staff member with Face ID / Touch ID / PIN fallback
  Future<bool> authenticate({
    String reason = 'Verify your clinical identity to unlock the station or resume rounds.',
    bool biometricOnly = false,
  }) async {
    if (kIsWeb) {
      // In web simulation, allow quick approval for demo testing
      _isStationLocked = false;
      notifyListeners();
      return true;
    }

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      if (authenticated) {
        _isStationLocked = false;
        notifyListeners();
      }
      return authenticated;
    } on PlatformException catch (e) {
      debugPrint('[BiometricAuthService] Error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BiometricAuthService] Unexpected error: $e');
      return false;
    }
  }

  /// Lock clinical station for security during doctor rounds
  void lockStation() {
    _isStationLocked = true;
    notifyListeners();
  }

  /// Unlock clinical station
  void unlockStation() {
    _isStationLocked = false;
    notifyListeners();
  }
}
