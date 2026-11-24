import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/order.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      'Accepted' => (AppColors.citrusTint, AppColors.citrusDark),
      'Ready' => (AppColors.sky, AppColors.skyDark),
      'Completed' => (AppColors.leafTint, AppColors.leafDark),
      _ => (const Color(0xFFEDEFE9), AppColors.ink), // Pending
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(status,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

/// Pending → Accepted → Ready → Completed, with the current step highlighted.
class StatusTimeline extends StatelessWidget {
  final String status;

  const StatusTimeline({super.key, required this.status});

  static const _subtitles = {
    'Pending': 'Request sent to the seller',
    'Accepted': 'Seller is preparing your order',
    'Ready': 'Ready for pickup',
    'Completed': 'Order fulfilled',
  };

  @override
  Widget build(BuildContext context) {
    final current = orderStatuses.indexOf(status).clamp(0, orderStatuses.length - 1);
    final t = Theme.of(context).textTheme;

    return Column(
      children: [
        for (var i = 0; i < orderStatuses.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 24,
                  child: Column(
                    children: [
                      _Dot(done: i < current || (i == current && i == orderStatuses.length - 1),
                          active: i == current),
                      if (i < orderStatuses.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            color: i < current ? AppColors.leaf : AppColors.line,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(orderStatuses[i],
                            style: t.titleSmall?.copyWith(
                              fontWeight: i <= current ? FontWeight.w700 : FontWeight.w500,
                              color: i <= current ? AppColors.ink : AppColors.muted,
                            )),
                        Text(_subtitles[orderStatuses[i]]!,
                            style: t.bodySmall?.copyWith(color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool done;
  final bool active;

  const _Dot({required this.done, required this.active});

  @override
  Widget build(BuildContext context) {
    if (done) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(color: AppColors.leaf, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
      );
    }
    if (active) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.citrus,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.citrusTint, width: 4),
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFC9D6BE), width: 2),
      ),
    );
  }
}
