import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/typography.dart';

class AarogyaAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final bool isOnline;
  final Color? ringColor;

  const AarogyaAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 44.0,
    this.isOnline = false,
    this.ringColor,
  });

  String get _initials {
    if (name == null || name!.trim().isEmpty) return 'A';
    final parts = name!.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final borderCol =
        ringColor ?? AarogyaColors.primaryCyan.withValues(alpha: 0.5);

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderCol, width: 1.5),
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: borderCol.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildFallback(),
                  )
                : _buildFallback(),
          ),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AarogyaColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AarogyaColors.success.withValues(alpha: 0.8),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallback() {
    return Center(
      child: Text(
        _initials,
        style: AarogyaTypography.caption(Colors.white)
            .copyWith(fontWeight: FontWeight.w700, fontSize: size * 0.36),
      ),
    );
  }
}
