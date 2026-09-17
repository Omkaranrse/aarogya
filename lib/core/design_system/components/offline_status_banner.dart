import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tokens/colors.dart';
import '../tokens/radius.dart';
import '../tokens/typography.dart';
import '../../../shared/state/aarogya_providers.dart';

/// Non-blocking clinical connectivity banner.
/// Displays when network is lost and offers reconnect / cache status.
class OfflineStatusBanner extends ConsumerWidget {
  const OfflineStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);
    if (isOnline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF59E0B),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'You are offline. Showing cached clinical data (DPDP Act Local Storage).',
                style: AarogyaTypography.caption(Colors.white).copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: () {
                ref.read(isOnlineProvider.notifier).state = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connected to Aarogya Clinical Gateway.'),
                    backgroundColor: AarogyaColors.success,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.15),
                  borderRadius: AarogyaRadius.radius4,
                ),
                child: Text(
                  'Retry',
                  style: AarogyaTypography.caption(Colors.white).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
