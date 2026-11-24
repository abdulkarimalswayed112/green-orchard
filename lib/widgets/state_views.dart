import 'package:flutter/material.dart';

import '../core/theme.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: AppColors.leaf),
      );
}

/// Shown for network failures and API errors, always with a Retry (FR10).
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final offline = message.toLowerCase().contains('internet');
    return _Centered(
      icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      iconColor: AppColors.danger,
      title: offline ? 'You\'re offline' : 'Couldn\'t load this',
      subtitle: message,
      action: FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size(160, 48)),
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Try again'),
      ),
    );
  }
}

/// "No products found", "No favorites yet", etc. (API returns []).
class EmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) => _Centered(
        icon: icon,
        iconColor: AppColors.leaf,
        title: title,
        subtitle: subtitle,
        action: action,
      );
}

class _Centered extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? action;

  const _Centered({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.leafTint,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 16),
            Text(title, style: t.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(subtitle,
                style: t.bodyMedium?.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

void showMessage(BuildContext context, String message, {SnackBarAction? action}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message), action: action));
}
