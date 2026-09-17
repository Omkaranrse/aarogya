import 'dart:async';
import 'package:flutter/material.dart';

/// Clinical Session Inactivity Manager
/// Complies with DPDP Act §8 session security safeguards by auto-locking
/// or expiring sensitive clinical sessions after a defined period of inactivity.
class SessionInactivityManager extends ChangeNotifier {
  static final SessionInactivityManager _instance = SessionInactivityManager._internal();
  factory SessionInactivityManager() => _instance;

  SessionInactivityManager._internal() {
    _lastActivity = DateTime.now();
  }

  /// Default inactivity timeout: 15 minutes
  Duration _timeout = const Duration(minutes: 15);
  DateTime _lastActivity = DateTime.now();
  bool _isLocked = false;
  Timer? _timer;
  VoidCallback? _onTimeoutCallback;

  Duration get timeout => _timeout;
  DateTime get lastActivity => _lastActivity;
  bool get isLocked => _isLocked;

  void configure({
    Duration? timeout,
    VoidCallback? onTimeout,
  }) {
    if (timeout != null) _timeout = timeout;
    if (onTimeout != null) _onTimeoutCallback = onTimeout;
  }

  void startMonitoring() {
    _timer?.cancel();
    _lastActivity = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), _checkInactivity);
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  void recordActivity() {
    _lastActivity = DateTime.now();
    if (_isLocked) {
      // Still locked until explicitly unlocked
      return;
    }
  }

  void lockSession() {
    if (!_isLocked) {
      _isLocked = true;
      notifyListeners();
      _onTimeoutCallback?.call();
    }
  }

  void unlockSession() {
    if (_isLocked) {
      _isLocked = false;
      _lastActivity = DateTime.now();
      notifyListeners();
    }
  }

  void _checkInactivity(Timer timer) {
    if (_isLocked) return;

    final elapsed = DateTime.now().difference(_lastActivity);
    if (elapsed >= _timeout) {
      lockSession();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Inactivity Touch Listener Widget
/// Wraps the screen or root navigation to capture user touch events and reset the inactivity timer.
class SessionInactivityDetector extends StatelessWidget {
  final Widget child;
  final SessionInactivityManager? manager;

  const SessionInactivityDetector({
    super.key,
    required this.child,
    this.manager,
  });

  @override
  Widget build(BuildContext context) {
    final activeManager = manager ?? SessionInactivityManager();
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => activeManager.recordActivity(),
      onPointerMove: (_) => activeManager.recordActivity(),
      onPointerHover: (_) => activeManager.recordActivity(),
      child: child,
    );
  }
}
