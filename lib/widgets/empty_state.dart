import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Reusable widget for loading, empty, and error feedback states.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isLoading;

  const EmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.isLoading = false,
  });

  factory EmptyStateWidget.loading({String message = 'Loading energy data...'}) {
    return EmptyStateWidget(
      icon: Icons.sync_rounded,
      title: message,
      isLoading: true,
    );
  }

  factory EmptyStateWidget.empty({
    String title = 'No consumption data available.',
    String? message,
    VoidCallback? onAction,
  }) {
    return EmptyStateWidget(
      icon: Icons.bar_chart_rounded,
      title: title,
      message: message,
      actionLabel: onAction != null ? 'Refresh Data' : null,
      onAction: onAction,
    );
  }

  factory EmptyStateWidget.error({
    String title = 'Unable to load energy data.',
    String? message = 'Please check simulated service connection.',
    VoidCallback? onRetry,
  }) {
    return EmptyStateWidget(
      icon: Icons.error_outline_rounded,
      title: title,
      message: message,
      actionLabel: onRetry != null ? 'Try Again' : null,
      onAction: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: AppColors.primary),
              ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
