import 'package:flutter/material.dart';

class AarogyaMotion {
  AarogyaMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 260);
  static const Duration smooth = Duration(milliseconds: 380);

  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve easeInOut = Curves.easeInOutCubic;
  static const Curve spring = Curves.elasticOut;
}

/// Spring interactive scale wrapper for cards and primary buttons
class AarogyaScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleDown;
  final Duration duration;

  const AarogyaScaleButton({
    super.key,
    required this.child,
    this.onTap,
    this.scaleDown = 0.975,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<AarogyaScaleButton> createState() => _AarogyaScaleButtonState();
}

class _AarogyaScaleButtonState extends State<AarogyaScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.onTap != null
          ? () => setState(() => _isPressed = false)
          : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleDown : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutQuad,
        child: widget.child,
      ),
    );
  }
}

/// Pulsing telemetry beacon for live statuses (OPD Queue, Cloud Sync, Verified)
class AarogyaPulseBeacon extends StatefulWidget {
  final Color color;
  final double size;
  final bool animate;

  const AarogyaPulseBeacon({
    super.key,
    required this.color,
    this.size = 8.0,
    this.animate = true,
  });

  @override
  State<AarogyaPulseBeacon> createState() => _AarogyaPulseBeaconState();
}

class _AarogyaPulseBeaconState extends State<AarogyaPulseBeacon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final glowOpacity = (0.2 + (_controller.value * 0.4)).clamp(0.0, 1.0);
        final spread = 2.0 + (_controller.value * 3.0);

        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: glowOpacity),
                blurRadius: spread * 2,
                spreadRadius: spread * 0.5,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Staggered slide & fade entrance for lists and telemetry modules
class StaggeredSlideFade extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;
  final Offset offset;

  const StaggeredSlideFade({
    super.key,
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 40),
    this.duration = const Duration(milliseconds: 300),
    this.offset = const Offset(0.0, 0.08),
  });

  @override
  State<StaggeredSlideFade> createState() => _StaggeredSlideFadeState();
}

class _StaggeredSlideFadeState extends State<StaggeredSlideFade>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    final delay = widget.baseDelay * widget.index;
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
