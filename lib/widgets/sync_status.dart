import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/services/sync_providers.dart';
import 'package:spend_wise/services/sync_service.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';

/// A small, accessible status row shared by Home, All Expenses and Profile.
class SyncStatusBanner extends ConsumerWidget {
  const SyncStatusBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncServiceProvider);
    final colors = context.colors;
    final (label, icon) = switch (sync.phase) {
      SyncPhase.idle => ('Getting your data ready…', Icons.cloud_outlined),
      SyncPhase.syncing => ('Syncing…', Icons.sync_rounded),
      SyncPhase.success => ('All changes synced', Icons.cloud_done_outlined),
      SyncPhase.offline => (
        sync.lastError is SocketException || sync.lastError is TimeoutException
            ? "Couldn't sync — you're working offline"
            : "Couldn't sync. Your data is saved on this device",
        Icons.cloud_off_outlined,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: sync.phase == SyncPhase.success
                      ? colors.success
                      : colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.xs.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ),
                if (sync.phase == SyncPhase.offline)
                  TextButton(
                    onPressed: sync.syncNow,
                    child: const Text('Retry'),
                  ),
              ],
            ),
            if (sync.phase == SyncPhase.syncing) ...[
              const SizedBox(height: 4),
              LinearProgressIndicator(
                minHeight: 2,
                color: colors.primary,
                backgroundColor: colors.border,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
