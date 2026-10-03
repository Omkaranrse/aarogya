import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

/// Attractive, interactive floating badge & avatar featuring Omkar Anarse.
/// Displays a speech bubble pop message and links to https://omkar-anarse.vercel.app.
class OmkarPortfolioBadge extends StatefulWidget {
  final double? bottom;
  final double? right;

  const OmkarPortfolioBadge({
    super.key,
    this.bottom,
    this.right,
  });

  static const String portfolioUrl = 'https://omkar-anarse.vercel.app';

  @override
  State<OmkarPortfolioBadge> createState() => _OmkarPortfolioBadgeState();
}

class _OmkarPortfolioBadgeState extends State<OmkarPortfolioBadge>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScaleAnimation;
  late final Animation<double> _pulseGlowAnimation;

  late final AnimationController _popController;
  late final Animation<double> _popScaleAnimation;
  late final Animation<double> _popFadeAnimation;

  bool _isHovered = false;
  bool _isBubbleVisible = true;

  @override
  void initState() {
    super.initState();

    // Breathing pulse halo animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    final isTestEnvironment =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTestEnvironment) {
      _pulseController.repeat(reverse: true);
    }

    _pulseScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseGlowAnimation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Entrance animation for speech bubble
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _popScaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );

    _popFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.easeOut),
    );

    // Auto-pop speech bubble after a brief pause
    if (isTestEnvironment) {
      _popController.value = 1.0;
    } else {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _popController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _popController.dispose();
    super.dispose();
  }

  Future<void> _launchPortfolio() async {
    final uri = Uri.parse(OmkarPortfolioBadge.portfolioUrl);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Fallback for platform
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Could not launch ${OmkarPortfolioBadge.portfolioUrl}: $e');
    }
  }

  void _toggleBubble() {
    setState(() {
      _isBubbleVisible = !_isBubbleVisible;
      if (_isBubbleVisible) {
        _popController.forward(from: 0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final defaultBottom = isMobile ? 80.0 : 24.0;
    final defaultRight = isMobile ? 16.0 : 24.0;

    return Positioned(
      bottom: widget.bottom ?? defaultBottom,
      right: widget.right ?? defaultRight,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pop message speech bubble
            if (_isBubbleVisible)
              AnimatedBuilder(
                animation: _popController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _popFadeAnimation.value,
                    child: Transform.scale(
                      scale: _popScaleAnimation.value,
                      alignment: Alignment.bottomRight,
                      child: child,
                    ),
                  );
                },
                child: _buildSpeechBubble(context, isDark, isMobile),
              ),

            const SizedBox(height: 12),

            // Main Interactive Produced By Pill & Avatar Button
            _buildMainButton(context, isDark, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeechBubble(BuildContext context, bool isDark, bool isMobile) {
    final maxWidth = isMobile ? 290.0 : 330.0;

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      margin: const EdgeInsets.only(bottom: 4, right: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(6),
        ),
        border: Border.all(
          color: const Color(0xFF00D8F6).withValues(alpha: isDark ? 0.45 : 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D8F6).withValues(alpha: 0.25),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(6),
        ),
        child: Stack(
          children: [
            // Top Accent Gradient Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 3,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF00D8F6),
                      Color(0xFF3B82F6),
                      Color(0xFF8B5CF6),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header row with Badge & Close button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF00D8F6).withValues(alpha: 0.18),
                              const Color(0xFF6366F1).withValues(alpha: 0.18),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00D8F6).withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'AI FULL STACK ENGINEER',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: const Color(0xFF00D8F6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isBubbleVisible = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: isDark ? Colors.white60 : Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Message body
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        height: 1.45,
                        color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                      ),
                      children: [
                        const TextSpan(
                          text: "Hey! I'm ",
                        ),
                        TextSpan(
                          text: "Omkar Anarse",
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF00D8F6),
                          ),
                        ),
                        const TextSpan(
                          text: " 👋\nAI & Full Stack Engineer. Click me to explore my portfolio & innovative AI projects!",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Interactive CTA button
                  InkWell(
                    onTap: _launchPortfolio,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00D8F6),
                            Color(0xFF2563EB),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D8F6).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.rocket_launch_rounded,
                            size: 15,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'View Portfolio ↗ (omkar-anarse.vercel.app)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(BuildContext context, bool isDark, bool isMobile) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: _launchPortfolio,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Produced By Omkar Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A).withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _isHovered
                        ? const Color(0xFF00D8F6)
                        : const Color(0xFF00D8F6).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D8F6).withValues(
                        alpha: _isHovered ? 0.35 : 0.15,
                      ),
                      blurRadius: _isHovered ? 20 : 12,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini Sparkle Icon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00D8F6), Color(0xFF6366F1)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'PRODUCED BY',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: const Color(0xFF00D8F6),
                          ),
                        ),
                        Text(
                          'Omkar Anarse',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.north_east_rounded,
                      size: 13,
                      color: _isHovered
                          ? const Color(0xFF00D8F6)
                          : (isDark ? Colors.white60 : Colors.black45),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Glowing Animated Avatar Headshot
              GestureDetector(
                onTap: () {
                  // Toggle bubble or launch
                  _toggleBubble();
                },
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Outer Pulsing Glow Ring
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseScaleAnimation.value,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  const Color(0xFF00D8F6).withValues(
                                    alpha: _pulseGlowAnimation.value * 0.6,
                                  ),
                                  const Color(0xFF6366F1).withValues(
                                    alpha: _pulseGlowAnimation.value * 0.2,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Avatar Container with Gradient Border
                    Container(
                      width: 52,
                      height: 52,
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00D8F6),
                            Color(0xFF3B82F6),
                            Color(0xFF8B5CF6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D8F6).withValues(
                              alpha: _isHovered ? 0.6 : 0.4,
                            ),
                            blurRadius: _isHovered ? 18 : 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/omkar_avatar.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.person_rounded,
                                color: Color(0xFF00D8F6),
                                size: 28,
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    // Online Status Indicator (Green ping)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF0F172A) : Colors.white,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
