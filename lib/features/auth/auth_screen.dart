import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/domain/models/user.dart';
import '../../shared/state/aarogya_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form Mode
  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Role Selection
  UserRole _selectedRole = UserRole.patient;

  // Email/Password Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Institutional Staff Code for Doctors & Admins (Short-Term Governance)
  final _staffCodeController = TextEditingController();

  // Password Strength State (Immediate UX)
  int _passwordStrength = 0; // 0 = None, 1 = Weak, 2 = Fair, 3 = Good, 4 = Strong
  String _passwordStrengthLabel = '';

  // Phone OTP Controllers & 30s Cooldown (Immediate UX)
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _codeSent = false;
  Timer? _resendTimer;
  int _resendCountdown = 0;

  // Biometric Auth State (Mid-Term Clinical Rounds)
  bool _isBiometricSupported = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _passwordController.addListener(_onPasswordChanged);
    _checkBiometrics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.removeListener(_onPasswordChanged);
    _passwordController.dispose();
    _staffCodeController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _onPasswordChanged() {
    _evaluatePasswordStrength(_passwordController.text);
  }

  void _evaluatePasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0;
        _passwordStrengthLabel = '';
      });
      return;
    }

    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password) && RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score == 0 && password.isNotEmpty) score = 1;

    String label;
    switch (score) {
      case 1:
        label = 'Weak (use 8+ chars & numbers)';
        break;
      case 2:
        label = 'Fair (add uppercase & symbols)';
        break;
      case 3:
        label = 'Good (secure for clinical access)';
        break;
      case 4:
        label = 'Excellent (HIPAA/ISO standard)';
        break;
      default:
        label = '';
    }

    setState(() {
      _passwordStrength = score;
      _passwordStrengthLabel = label;
    });
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown <= 1) {
        timer.cancel();
        if (mounted) setState(() => _resendCountdown = 0);
      } else {
        if (mounted) setState(() => _resendCountdown--);
      }
    });
  }

  Future<void> _checkBiometrics() async {
    final bio = ref.read(biometricAuthServiceProvider);
    final available = await bio.isBiometricAvailable();
    if (mounted) {
      setState(() => _isBiometricSupported = available);
    }
  }

  Future<void> _handleBiometricLogin() async {
    final bio = ref.read(biometricAuthServiceProvider);
    final authenticated = await bio.authenticate(
      reason: 'Scan Face ID / Touch ID to enter Aarogya Clinical Station',
    );
    if (authenticated) {
      final targetRole = _selectedRole == UserRole.patient ? UserRole.doctor : _selectedRole;
      _demoLogin(targetRole);
    }
  }

  Future<void> _handleEmailAuth() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = ref.read(authServiceProvider);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please provide both email and password.';
      });
      return;
    }

    if (_isSignUp && password.length < 6) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Password must be at least 6 characters long.';
      });
      return;
    }

    // Clinical Governance: Lock self-registration for Doctors & Admins
    if (_isSignUp && (_selectedRole == UserRole.doctor || _selectedRole == UserRole.admin)) {
      final code = _staffCodeController.text.trim().toUpperCase();
      final validCode = _selectedRole == UserRole.doctor ? 'HOSP-DOC-2026' : 'AIMS-ADMIN-2026';
      final isVerifiedEmail = email.toLowerCase().endsWith('@aarogya.health');

      if (!isVerifiedEmail && code != validCode) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Institutional verification required. ${_selectedRole.displayName} registrations require an approved @aarogya.health staff email or token "$validCode". Patients may register freely.';
        });
        return;
      }
    }

    try {
      if (_isSignUp) {
        final name = _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : email.split('@').first;
        await auth.signUpWithEmail(
          name: name,
          email: email,
          password: password,
          role: _selectedRole,
        );
      } else {
        await auth.signInWithEmail(
          email: email,
          password: password,
          role: _selectedRole,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit mobile number.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = ref.read(authServiceProvider);
    await auth.sendPhoneOtp(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() {
            _codeSent = true;
            _isLoading = false;
          });
          _startResendCountdown();
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        }
      },
    );
  }

  Future<void> _showForgotPasswordDialog(BuildContext context, bool isDark) async {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    bool isSubmitting = false;
    String? dialogError;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF0E1524) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00BFA5).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Color(0xFF00BFA5),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your registered hospital or patient email. We will send you an official Aarogya password reset link.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? Colors.white70 : const Color(0xFF475467),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: 'user@aarogya.health',
                      prefixIcon: const Icon(
                        Icons.alternate_email_rounded,
                        size: 18,
                        color: Color(0xFF00BFA5),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      dialogError!,
                      style: const TextStyle(fontSize: 12, color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final email = resetEmailController.text.trim();
                        if (email.isEmpty || !email.contains('@')) {
                          setDialogState(() {
                            dialogError = 'Please enter a valid email address.';
                          });
                          return;
                        }
                        setDialogState(() {
                          isSubmitting = true;
                          dialogError = null;
                        });
                        try {
                          await ref.read(authServiceProvider).sendPasswordResetEmail(email);
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Password reset link sent to $email. Check your inbox.',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF00897B),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() {
                            isSubmitting = false;
                            dialogError = e.toString();
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BFA5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Send Reset Link', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 6) {
      setState(() {
        _errorMessage = 'Please enter the 6-digit verification code.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = ref.read(authServiceProvider);
    try {
      await auth.verifyPhoneOtp(
        smsCode: otp,
        role: _selectedRole,
        name: _nameController.text.trim().isNotEmpty
            ? _nameController.text.trim()
            : null,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _demoLogin(UserRole role) {
    ref.read(authServiceProvider).signInWithDemoRole(role);
    ref.read(repositoryProvider).switchRole(role);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0A0E17) : const Color(0xFFF4F6F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Brand Header
                  _buildBrandHeader(isDark),
                  const SizedBox(height: 18),

                  // Main Auth Card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0E1524) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? const Color(0x29FFFFFF)
                            : const Color(0x140F172A),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? const Color(0x80000000)
                              : Colors.black.withValues(alpha: 0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 18.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Sign In vs Sign Up Toggle
                          _buildModeToggle(isDark),
                          const SizedBox(height: 16),

                          // Tab Bar: Phone vs Email
                          Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              dividerColor: Colors.transparent,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                color: const Color(0xFF00BFA5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              labelColor: Colors.white,
                              unselectedLabelColor: isDark
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : const Color(0xFF475467),
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            tabs: const [
                              Tab(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.badge_rounded, size: 16),
                                      SizedBox(width: 8),
                                      Text('Email & Staff'),
                                    ],
                                  ),
                                ),
                              ),
                              Tab(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.phone_android_rounded,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Phone OTP'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Error Banner
                        if (_errorMessage != null) ...[
                          _buildErrorBanner(_errorMessage!),
                          const SizedBox(height: 16),
                        ],

                        // Role Selector
                        _buildRoleSelector(isDark),
                        const SizedBox(height: 20),

                        // Tab Content - Smoothly animated without jumping
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOutCubic,
                          alignment: Alignment.topCenter,
                          child: AnimatedBuilder(
                            animation: _tabController,
                            builder: (context, _) {
                              return _tabController.index == 0
                                  ? _buildEmailTab(isDark)
                                  : _buildPhoneTab(isDark);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Demo Session Bypass Strip
                _buildQuickDemoStrip(isDark),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildBrandHeader(bool isDark) {
    return Column(
      children: [
        Container(
          width: 66,
          height: 66,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/Aarogya.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF00BFA5), Color(0xFF00897B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Aarogya',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: isDark ? Colors.white : const Color(0xFF101828),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          'Next-Gen Hospital & Healthcare Network',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : const Color(0xFF475467),
          ),
        ),
      ],
    );
  }

  Widget _buildModeToggle(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Text(
            _isSignUp ? 'Create your Account' : 'Welcome to Aarogya',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF101828),
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isSignUp = !_isSignUp;
              _errorMessage = null;
            });
          },
          child: Text(
            _isSignUp ? 'Sign In Instead' : 'Register',
            style: const TextStyle(
              color: Color(0xFF00BFA5),
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Role',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            textBaseline: TextBaseline.alphabetic,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : const Color(0xFF475467),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildRoleChip(
              UserRole.patient,
              'Patient',
              Icons.person_rounded,
              isDark,
            ),
            const SizedBox(width: 8),
            _buildRoleChip(
              UserRole.doctor,
              'Doctor',
              Icons.medical_services_rounded,
              isDark,
            ),
            const SizedBox(width: 8),
            _buildRoleChip(
              UserRole.admin,
              'Admin',
              Icons.admin_panel_settings_rounded,
              isDark,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleChip(
    UserRole role,
    String label,
    IconData icon,
    bool isDark,
  ) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00BFA5).withValues(alpha: isDark ? 0.2 : 0.15)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF00BFA5) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? const Color(0xFF00BFA5)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.black54),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF00796B))
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.7)
                            : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Web platform warning
        if (kIsWeb) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFFB74D).withValues(alpha: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: Colors.orange.shade800,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Phone OTP requires Firebase Console setup',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'To use Phone Auth on web, add your domain (aarogya-5abf6.web.app) to Firebase Console → Authentication → Settings → Authorized Domains.\n\nFor now, use Email & Staff tab or Quick Demo Accounts below.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.4,
                    color: Colors.orange.shade900.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _tabController.animateTo(0);
                        },
                        icon: const Icon(Icons.email_rounded, size: 14),
                        label: const Text(
                          'Use Email Login',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF00BFA5),
                          side: const BorderSide(color: Color(0xFF00BFA5)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (!_codeSent) ...[
          if (_isSignUp) ...[
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              hint: 'e.g. Rajesh Verma',
              icon: Icons.badge_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],
          // Phone Input
          _buildTextField(
            controller: _phoneController,
            label: 'Mobile Number (+91 India & ABHA)',
            hint: '98765 43210',
            icon: Icons.phone_android_rounded,
            isDark: isDark,
            keyboardType: TextInputType.phone,
            prefixText: '+91 ',
          ),
          if (!_isSignUp) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.security_rounded,
                    size: 15,
                    color: Color(0xFF00BFA5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'SMS verification code will be sent to this number for instant clinical login.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleSendOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Get OTP Code',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
          ),
        ] else ...[
          Text(
            'Enter 6-Digit OTP sent to +91 ${_phoneController.text.trim()}',
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _otpController,
            label: 'SMS Verification Code',
            hint: '123456',
            icon: Icons.lock_clock_rounded,
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _handleVerifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BFA5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Verify & Enter Clinical Workspace',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => setState(() => _codeSent = false),
                child: const Text(
                  'Change Number',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              if (_resendCountdown > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: Color(0xFF00BFA5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Resend in ${_resendCountdown}s',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                )
              else
                TextButton.icon(
                  onPressed: _isLoading ? null : _handleSendOtp,
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text(
                    'Resend Code',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEmailTab(bool isDark) {
    String emailLabel;
    String emailHint;
    String buttonText;

    switch (_selectedRole) {
      case UserRole.patient:
        emailLabel = 'Patient Email Address';
        emailHint = 'patient@aarogya.health';
        buttonText =
            _isSignUp ? 'Create Patient Account' : 'Access Patient Portal';
        break;
      case UserRole.doctor:
        emailLabel = 'Hospital Work Email';
        emailHint = 'specialist@aarogya.health';
        buttonText = _isSignUp
            ? 'Register Doctor Account'
            : 'Access Clinical Dashboard';
        break;
      default:
        emailLabel = 'Hospital Staff Email';
        emailHint = 'admin@aarogya.health';
        buttonText =
            _isSignUp ? 'Register Staff Account' : 'Access Command Center';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isSignUp) ...[
          _buildTextField(
            controller: _nameController,
            label: _selectedRole == UserRole.patient
                ? 'Full Name'
                : 'Full Name / Staff Title',
            hint: _selectedRole == UserRole.patient
                ? 'Rajesh Verma'
                : 'Dr. Priya Sharma',
            icon: Icons.person_outline_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
        ],
        _buildTextField(
          controller: _emailController,
          label: emailLabel,
          hint: emailHint,
          icon: Icons.alternate_email_rounded,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Password',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.6)
                    : const Color(0xFF475467),
              ),
            ),
            if (!_isSignUp)
              GestureDetector(
                onTap: () => _showForgotPasswordDialog(context, isDark),
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF00BFA5),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: '••••••••',
            prefixIcon: const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF00BFA5)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF00BFA5),
                width: 1.5,
              ),
            ),
          ),
        ),
        if (_isSignUp) ...[
          const SizedBox(height: 8),
          _buildPasswordStrengthMeter(isDark),
        ],

        // Institutional Verification for Doctors & Admins
        if (_isSignUp && (_selectedRole == UserRole.doctor || _selectedRole == UserRole.admin)) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _staffCodeController,
            label: 'Institutional Verification Code',
            hint: _selectedRole == UserRole.doctor ? 'HOSP-DOC-2026' : 'AIMS-ADMIN-2026',
            icon: Icons.verified_user_outlined,
            isDark: isDark,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131F33) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_rounded, size: 15, color: Color(0xFF00BFA5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Clinical Governance: Self-registration for ${_selectedRole.displayName}s is restricted. Use an approved @aarogya.health staff email or token "${_selectedRole == UserRole.doctor ? "HOSP-DOC-2026" : "AIMS-ADMIN-2026"}". Patients register freely.',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.35,
                      color: isDark ? Colors.white70 : const Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleEmailAuth,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BFA5),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  buttonText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPasswordStrengthMeter(bool isDark) {
    Color getBarColor(int index) {
      if (_passwordStrength == 0) {
        return isDark ? Colors.white12 : const Color(0xFFE2E8F0);
      }
      if (index > _passwordStrength) {
        return isDark ? Colors.white12 : const Color(0xFFE2E8F0);
      }
      switch (_passwordStrength) {
        case 1:
          return Colors.redAccent;
        case 2:
          return Colors.orangeAccent;
        case 3:
          return const Color(0xFF00BFA5);
        case 4:
          return const Color(0xFF00897B);
        default:
          return const Color(0xFF00BFA5);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? 4.0 : 0),
                decoration: BoxDecoration(
                  color: getBarColor(index + 1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        if (_passwordStrengthLabel.isNotEmpty) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(
                _passwordStrength >= 3
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                size: 13,
                color: _passwordStrength >= 3
                    ? const Color(0xFF00897B)
                    : Colors.orangeAccent,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Password Strength: $_passwordStrengthLabel',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _passwordStrength >= 3
                        ? (isDark ? const Color(0xFF80CBC4) : const Color(0xFF00796B))
                        : (isDark ? Colors.orange.shade200 : Colors.orange.shade800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? prefixText,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withValues(alpha: 0.6)
                : const Color(0xFF475467),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText,
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF00BFA5)),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF00BFA5),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    final isPhoneWebError =
        message.contains('Authorized Domains') ||
        message.contains('Test Phone Number');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => setState(() => _errorMessage = null),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          if (isPhoneWebError) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: const Color(0xFF00BFA5),
                  ),
                  onPressed: () {
                    _phoneController.text = '9876543210';
                    _handleSendOtp();
                  },
                  child: const Text(
                    'Use Test Number',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickDemoStrip(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E1524) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0x29FFFFFF) : const Color(0x140F172A),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 15,
                color: Color(0xFF00BFA5),
              ),
              const SizedBox(width: 5),
              Text(
                'Sandbox & QA Credentials (1-Tap)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.65)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDemoButton(
                  'Rajesh',
                  'Patient',
                  UserRole.patient,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDemoButton(
                  'Dr. Priya',
                  'Doctor',
                  UserRole.doctor,
                  isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDemoButton(
                  'Col. Nair',
                  'Admin',
                  UserRole.admin,
                  isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Clinical Duty Rounds 1-Tap Biometric Authentication
          InkWell(
            onTap: _handleBiometricLogin,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF00BFA5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF00BFA5).withValues(alpha: 0.4),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.fingerprint_rounded,
                    size: 18,
                    color: Color(0xFF00897B),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      _isBiometricSupported
                          ? 'Face ID / Touch ID Clinical Rounds Sign-In'
                          : 'Quick Biometric Sign-In (Clinical Duty)',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00796B),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(
    String name,
    String roleName,
    UserRole role,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => _demoLogin(role),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF00BFA5).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF00BFA5).withValues(alpha: 0.3),
            width: 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              roleName,
              style: const TextStyle(
                color: Color(0xFF00897B),
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              name,
              style: TextStyle(
                color: isDark ? Colors.white54 : const Color(0xFF64748B),
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
