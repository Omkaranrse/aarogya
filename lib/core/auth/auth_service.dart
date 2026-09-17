import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/domain/models/user.dart';

/// Clinical Auth Exception with user-friendly diagnostics
class AarogyaAuthException implements Exception {
  final String message;
  final String? code;
  AarogyaAuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Core Authentication Service wrapping FirebaseAuth with clinical roles & demo bypass
class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _initAuthSession();
  }

  fb.FirebaseAuth get _auth => fb.FirebaseAuth.instance;

  fb.User? _firebaseUser;
  User? _appUser;
  bool _isAuthenticated = false; // Starts false; checked on app launch
  bool _isDemoActive = false;
  UserRole _currentRole = UserRole.patient;

  // Phone Auth State
  String? _verificationId;
  int? _resendToken;
  fb.ConfirmationResult? _confirmationResult;

  // Getters
  fb.User? get firebaseUser => _firebaseUser;
  User? get appUser => _appUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isDemoActive => _isDemoActive;
  UserRole get currentRole => _currentRole;
  String? get verificationId => _verificationId;

  Future<void> _initAuthSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedRoleStr = prefs.getString('aarogya_user_role');
      if (savedRoleStr != null) {
        _currentRole = UserRole.values.firstWhere(
          (r) => r.name == savedRoleStr,
          orElse: () => UserRole.patient,
        );
      }

      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _firebaseUser = currentUser;
        _isAuthenticated = true;
        _isDemoActive = false;
        _appUser = User(
          id: currentUser.uid,
          name:
              currentUser.displayName ??
              currentUser.email?.split('@').first ??
              'Clinical User',
          email:
              currentUser.email ??
              '${currentUser.phoneNumber ?? "user"}@aarogya.health',
          phone: currentUser.phoneNumber ?? '+91 98765 43210',
          role: _currentRole,
          avatarUrl: currentUser.photoURL,
        );
        notifyListeners();

        // Background sync with Firestore user document
        _syncUserProfileToFirestore(
          uid: currentUser.uid,
          name: _appUser!.name,
          email: _appUser!.email,
          phone: _appUser!.phone,
          role: _currentRole,
        );
      }

      _auth.authStateChanges().listen(
        (fb.User? user) {
          _firebaseUser = user;
          if (user != null) {
            _isAuthenticated = true;
            _isDemoActive = false;
            _appUser = User(
              id: user.uid,
              name:
                  user.displayName ??
                  user.email?.split('@').first ??
                  'Clinical User',
              email:
                  user.email ?? '${user.phoneNumber ?? "user"}@aarogya.health',
              phone: user.phoneNumber ?? '+91 98765 43210',
              role: _currentRole,
              avatarUrl: user.photoURL,
            );
          } else if (!_isDemoActive) {
            _isAuthenticated = false;
            _appUser = null;
          }
          notifyListeners();
        },
        onError: (e) {
          debugPrint('Firebase Auth stream notice: $e');
        },
      );
    } catch (e) {
      debugPrint('Firebase Auth session init notice: $e');
    }
  }

  Future<void> _syncUserProfileToFirestore({
    required String uid,
    required String name,
    required String email,
    String? phone,
    required UserRole role,
  }) async {
    try {
      final userDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid);

      // Save user record immediately (cached locally by Firestore SDK)
      await userDocRef.set({
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone ?? '+91 98765 43210',
        'role': role.name,
        'abha_number': '91-4829-1039-4820',
        'abha_address':
            '${name.toLowerCase().replaceAll(RegExp(r'\s+'), '.')}@abdm',
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Attempt to load existing profile non-blockingly
      userDocRef.get(const GetOptions(source: Source.serverAndCache)).then((docSnap) {
        if (docSnap.exists) {
          final data = docSnap.data();
          if (data != null && data['role'] != null) {
            _currentRole = UserRole.values.firstWhere(
              (r) => r.name == data['role'],
              orElse: () => role,
            );
            if (_appUser != null) {
              _appUser = _appUser!.copyWith(
                role: _currentRole,
                name: data['name'] as String? ?? _appUser!.name,
              );
              notifyListeners();
            }
          }
        }
      }).catchError((_) {
        // Silently handled by offline cache
      });
    } catch (e) {
      debugPrint('[AuthService] Firestore user profile sync note: $e');
    }
  }

  Future<void> _persistRole(UserRole role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('aarogya_user_role', role.name);
    } catch (_) {}
  }

  Future<void> _clearPersistedRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('aarogya_user_role');
    } catch (_) {}
  }

  /// Sign In with Email and Password
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      _isDemoActive = false;
      _currentRole = role;
      _firebaseUser = credential.user;
      _isAuthenticated = true;
      await _persistRole(role);

      _appUser = User(
        id: _firebaseUser?.uid ?? 'usr-fb',
        name: _firebaseUser?.displayName ?? email.split('@').first,
        email: email.trim(),
        phone: '+91 98765 43210',
        role: role,
      );
      if (_firebaseUser != null && _appUser != null) {
        _syncUserProfileToFirestore(
          uid: _firebaseUser!.uid,
          name: _appUser!.name,
          email: _appUser!.email,
          phone: _appUser!.phone,
          role: role,
        );
      }
      notifyListeners();
    } on fb.FirebaseAuthException catch (e) {
      throw AarogyaAuthException(_mapFirebaseError(e), code: e.code);
    } catch (e) {
      throw AarogyaAuthException(_mapGenericError(e));
    }
  }

  /// Create Account with Email and Password
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
    String? phone,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user?.updateDisplayName(name.trim());
      _isDemoActive = false;
      _currentRole = role;
      _firebaseUser = credential.user;
      _isAuthenticated = true;
      await _persistRole(role);

      _appUser = User(
        id: _firebaseUser?.uid ?? 'usr-fb',
        name: name.trim(),
        email: email.trim(),
        phone: phone?.trim().isNotEmpty == true
            ? phone!.trim()
            : '+91 98765 43210',
        role: role,
      );
      if (_firebaseUser != null && _appUser != null) {
        _syncUserProfileToFirestore(
          uid: _firebaseUser!.uid,
          name: name.trim(),
          email: email.trim(),
          phone: _appUser!.phone,
          role: role,
        );
      }
      notifyListeners();
    } on fb.FirebaseAuthException catch (e) {
      throw AarogyaAuthException(_mapFirebaseError(e), code: e.code);
    } catch (e) {
      throw AarogyaAuthException(_mapGenericError(e));
    }
  }

  /// Send Password Reset Email for forgotten passwords
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final cleanEmail = email.trim();
      if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
        throw AarogyaAuthException('Please enter a valid clinical or personal email address.');
      }
      await _auth.sendPasswordResetEmail(email: cleanEmail);
    } on fb.FirebaseAuthException catch (e) {
      throw AarogyaAuthException(_mapFirebaseError(e), code: e.code);
    } catch (e) {
      if (e is AarogyaAuthException) rethrow;
      throw AarogyaAuthException(_mapGenericError(e));
    }
  }

  /// Send Phone OTP (India +91)
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    try {
      final formattedNumber = phoneNumber.startsWith('+')
          ? phoneNumber.trim()
          : '+91${phoneNumber.replaceAll(RegExp(r'\D'), '')}';

      if (kIsWeb) {
        final confirmationResult = await _auth.signInWithPhoneNumber(
          formattedNumber,
        );
        _confirmationResult = confirmationResult;
        _verificationId = confirmationResult.verificationId;
        onCodeSent(confirmationResult.verificationId);
        notifyListeners();
        return;
      }

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedNumber,
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          _isDemoActive = false;
          _isAuthenticated = true;
          notifyListeners();
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          onError(_mapFirebaseError(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          onCodeSent(verificationId);
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
      );
    } on fb.FirebaseAuthException catch (e) {
      onError(_mapFirebaseError(e));
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('policy') ||
          msg.contains('recaptcha') ||
          msg.contains('400') ||
          msg.contains('bad request') ||
          msg.contains('identitytoolkit') ||
          msg.contains('captcha') ||
          msg.contains('app-not-authorized') ||
          msg.contains('network') ||
          msg.contains('web-context-cancelled')) {
        onError(
          'Phone OTP is not available on web right now. Please use Email & Password sign-in, or try the Quick Demo Login. To enable Phone Auth: add your domain to Firebase Console → Authentication → Settings → Authorized Domains.',
        );
      } else {
        onError('Phone verification failed. Please try Email login instead.');
      }
    }
  }

  /// Verify Phone OTP and Sign In
  Future<void> verifyPhoneOtp({
    required String smsCode,
    required UserRole role,
    String? name,
  }) async {
    try {
      fb.UserCredential userCredential;
      if (kIsWeb && _confirmationResult != null) {
        userCredential = await _confirmationResult!.confirm(smsCode.trim());
      } else {
        if (_verificationId == null) {
          throw AarogyaAuthException(
            'Session expired. Please request a new OTP code.',
          );
        }
        final credential = fb.PhoneAuthProvider.credential(
          verificationId: _verificationId!,
          smsCode: smsCode.trim(),
        );
        userCredential = await _auth.signInWithCredential(credential);
      }
      _isDemoActive = false;
      _currentRole = role;
      _firebaseUser = userCredential.user;
      _isAuthenticated = true;
      await _persistRole(role);

      _appUser = User(
        id: _firebaseUser?.uid ?? 'usr-phone',
        name: name?.trim().isNotEmpty == true
            ? name!.trim()
            : (_firebaseUser?.displayName ?? 'Verified Patient'),
        email: '${_firebaseUser?.phoneNumber ?? "user"}@aarogya.health',
        phone: _firebaseUser?.phoneNumber ?? '+91 98765 43210',
        role: role,
      );
      notifyListeners();
    } on fb.FirebaseAuthException catch (e) {
      throw AarogyaAuthException(_mapFirebaseError(e), code: e.code);
    } catch (e) {
      throw AarogyaAuthException('OTP verification failed: ${e.toString()}');
    }
  }

  /// Instant Quick Demo Login (for frictionless testing & development)
  void signInWithDemoRole(UserRole role) {
    _isDemoActive = true;
    _currentRole = role;
    _isAuthenticated = true;
    _persistRole(role);

    switch (role) {
      case UserRole.patient:
        _appUser = const User(
          id: 'pat-1',
          name: 'Rajesh Verma',
          email: 'rajesh.verma@aarogya.health',
          phone: '+91 98765 43210',
          role: UserRole.patient,
        );
        break;
      case UserRole.doctor:
        _appUser = const User(
          id: 'doc-1',
          name: 'Dr. Priya Sharma',
          email: 'dr.priya@aarogya.health',
          phone: '+91 98220 11223',
          role: UserRole.doctor,
        );
        break;
      case UserRole.admin:
        _appUser = const User(
          id: 'admin-1',
          name: 'Col. Sanjeev Nair',
          email: 'admin.ops@aarogya.health',
          phone: '+91 98110 55443',
          role: UserRole.admin,
        );
        break;
      default:
        _appUser = const User(
          id: 'staff-1',
          name: 'Clinical Reception Desk',
          email: 'reception@aarogya.health',
          phone: '+91 98110 99887',
          role: UserRole.receptionist,
        );
        break;
    }
    notifyListeners();
  }

  /// Sign Out
  Future<void> signOut() async {
    _isDemoActive = false;
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Firebase signOut notice: $e');
    }
    await _clearPersistedRole();
    _firebaseUser = null;
    _appUser = null;
    _isAuthenticated = false;
    _verificationId = null;
    notifyListeners();
  }

  String _mapFirebaseError(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account registered with this email. Please check or sign up.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password or credentials. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'The provided email address is invalid.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-verification-code':
        return 'The entered OTP code is invalid or has expired.';
      case 'invalid-phone-number':
        return 'The phone number format is invalid. Please enter a valid 10-digit mobile number.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes before trying again.';
      case 'operation-not-allowed':
        return 'This sign-in method is not yet enabled. Go to Firebase Console → Authentication → Sign-in Providers and enable Email/Password and Phone. Use Quick Demo Accounts below to test now.';
      case 'admin-restricted-operation':
        return 'Account creation is restricted. Enable Email/Password in Firebase Console → Authentication → Sign-in Providers. Use Quick Demo Accounts below to test now.';
      case 'app-not-authorized':
      case 'captcha-check-failed':
      case 'quota-exceeded':
        return 'Phone Auth requires domain authorization. Add your domain in Firebase Console → Authentication → Settings → Authorized Domains.';
      default:
        final msg = e.message ?? '';
        if (msg.contains('OPERATION_NOT_ALLOWED') ||
            msg.contains('operation-not-allowed') ||
            msg.contains('admin-restricted')) {
          return 'This sign-in method is not enabled. Enable it in Firebase Console → Authentication → Sign-in Providers, or use Quick Demo Accounts below.';
        }
        if (msg.contains('policy') ||
            msg.contains('recaptcha') ||
            msg.contains('app-not-authorized')) {
          return 'Phone Auth requires domain authorization in Firebase Console → Authentication → Settings → Authorized Domains.';
        }
        return msg.isNotEmpty
            ? msg
            : 'Authentication error occurred (${e.code}).';
    }
  }

  /// Map generic (non-FirebaseAuthException) errors to user-friendly messages.
  /// On web, Firebase errors often arrive as plain JS exceptions, not FirebaseAuthException.
  String _mapGenericError(Object e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('operation_not_allowed') ||
        msg.contains('operation-not-allowed') ||
        msg.contains('admin-restricted') ||
        msg.contains('admin_restricted')) {
      return 'Email/Password sign-in is not enabled yet. Go to Firebase Console → Authentication → Sign-in Providers → enable Email/Password. Use Quick Demo Accounts below to test now.';
    }
    if (msg.contains('email-already-in-use') || msg.contains('email_exists')) {
      return 'An account already exists with this email. Try signing in instead.';
    }
    if (msg.contains('weak-password') || msg.contains('weak_password')) {
      return 'Password must be at least 6 characters long.';
    }
    if (msg.contains('invalid-email') || msg.contains('invalid_email')) {
      return 'Please enter a valid email address.';
    }
    if (msg.contains('user-not-found') || msg.contains('user_not_found')) {
      return 'No account found with this email. Try creating an account.';
    }
    if (msg.contains('wrong-password') ||
        msg.contains('invalid-credential') ||
        msg.contains('invalid_login')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (msg.contains('too-many-requests') ||
        msg.contains('too_many_attempts')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    }
    if (msg.contains('network') || msg.contains('timeout')) {
      return 'Network error. Please check your connection and try again.';
    }
    if (msg.contains('recaptcha') ||
        msg.contains('captcha') ||
        msg.contains('400')) {
      return 'Authentication service configuration issue. Use Quick Demo Accounts below to test the app.';
    }
    // Clean up raw exception text
    final cleaned = e
        .toString()
        .replaceAll(RegExp(r'^\[firebase_auth/[^\]]*\]\s*'), '')
        .replaceAll(RegExp(r'^Exception:\s*'), '')
        .replaceAll(RegExp(r'^FirebaseError:\s*'), '')
        .replaceAll(RegExp(r'\(auth/[^)]*\)\.?\s*'), '')
        .trim();
    return cleaned.isNotEmpty
        ? cleaned
        : 'Authentication failed. Please try Quick Demo Accounts below.';
  }

  @override
  // ignore: must_call_super
  void dispose() {
    // Singleton instance persists across transient provider scopes
  }
}
