import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/aarogya_theme_tokens.dart';

/// Privacy Screen Guard widget that obscures Protected Health Information (PHI)
/// whenever the app enters background, multitasking switcher, or inactive states.
class PrivacyScreenGuard extends StatefulWidget {
  final Widget child;
  final bool enableObscuring;

  const PrivacyScreenGuard({
    super.key,
    required this.child,
    this.enableObscuring = true,
  });

  @override
  State<PrivacyScreenGuard> createState() => _PrivacyScreenGuardState();
}

class _PrivacyScreenGuardState extends State<PrivacyScreenGuard>
    with WidgetsBindingObserver {
  bool _isObscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.enableObscuring) return;

    final shouldObscure = state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden;

    if (_isObscured != shouldObscure) {
      setState(() {
        _isObscured = shouldObscure;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        widget.child,
        if (_isObscured)
          const Positioned.fill(
            child: AarogyaPrivacyShield(),
          ),
      ],
    );
  }
}

/// Clinical Glassmorphic Privacy Shield
class AarogyaPrivacyShield extends StatelessWidget {
  const AarogyaPrivacyShield({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AarogyaColorTokens>();
    final isDark = theme.brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
      child: Container(
        color: isDark
            ? (tokens?.surfaceInformational ?? const Color(0xFF0F172A)).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (tokens?.primary ?? const Color(0xFF00A8A8)).withValues(alpha: 0.12),
              ),
              child: Icon(
                Icons.lock_rounded,
                size: 40,
                color: tokens?.primary ?? const Color(0xFF00A8A8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aarogya Clinical Privacy Shield',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sensitive Health Data Protected • DPDP Act Compliant',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: tokens?.neutrals.gray600 ?? Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
