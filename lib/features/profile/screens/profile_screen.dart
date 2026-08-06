import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/services/auth_service.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/widgets/danger_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  bool _loggingOut = false;

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await _authService.logout();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _loggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.backgroundScreen,
      appBar: AppBar(
        title: Text(
          "Profile & Settings",
          style: AppTypography.lg.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        backgroundColor: colors.backgroundScreen,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          children: [
            // User Avatar & Info (Horizontal Layout)
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FaIcon(
                    FontAwesomeIcons.solidUser,
                    size: 32,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Yash",
                        style: AppTypography.xl.copyWith(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "yash.tomar@example.com",
                        style: AppTypography.sm.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 36),

            // Financial Preferences
            _buildSectionHeader("FINANCIAL PREFERENCES", colors),
            const SizedBox(height: 14),
            _buildSettingsCard(
              colors: colors,
              children: [
                _buildTile(
                  colors: colors,
                  icon: FontAwesomeIcons.wallet,
                  title: "Monthly Budget",
                  trailingText: "\$5,000",
                  onTap: () {},
                ),
                _buildDivider(colors),
                _buildTile(
                  colors: colors,
                  icon: FontAwesomeIcons.tags,
                  title: "Manage Categories",
                  onTap: () {},
                ),
                _buildDivider(colors),
                _buildTile(
                  colors: colors,
                  icon: FontAwesomeIcons.dollarSign,
                  title: "Currency",
                  trailingText: "USD (\$)",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 36),

            // App Preferences
            _buildSectionHeader("APP PREFERENCES", colors),
            const SizedBox(height: 14),
            _buildSettingsCard(
              colors: colors,
              children: [
                _buildTile(
                  colors: colors,
                  icon: FontAwesomeIcons.moon,
                  title: "Theme",
                  trailingText: "System",
                  onTap: () {},
                ),
                _buildDivider(colors),
                _buildTile(
                  colors: colors,
                  icon: FontAwesomeIcons.bell,
                  title: "Notifications",
                  trailingText: "On",
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 36),

            // About & Support
            _buildSectionHeader("ABOUT & SUPPORT", colors),
            const SizedBox(height: 14),
            _buildSettingsCard(
              colors: colors,
              children: [
                _buildTile(
                  colors: colors,
                  icon: FontAwesomeIcons.circleInfo,
                  title: "About SpendWise",
                  trailingText: "v1.0.0",
                  showChevron: false,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Log Out Button
            DangerButton(
              title: _loggingOut ? "Logging out..." : "Log Out",
              icon: FontAwesomeIcons.arrowRightFromBracket,
              isLoading: _loggingOut,
              onPressed: _logout,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppThemeColors colors) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: AppTypography.xs.copyWith(
            color: colors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required AppThemeColors colors,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        borderRadius: AppRadius.lg,
        border: Border.all(
          color: colors.textSecondary.withValues(alpha: 0.1),
        ),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lg,
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildTile({
    required AppThemeColors colors,
    required dynamic icon,
    required String title,
    String? trailingText,
    bool showChevron = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 20,
        ),
        child: Row(
          children: [
            if (icon is IconData)
              Icon(
                icon,
                size: 18,
                color: colors.primary,
              )
            else
              FaIcon(
                icon,
                size: 18,
                color: colors.primary,
              ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.base.copyWith(
                  color: colors.textPrimary,
                ),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: AppTypography.sm.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              if (showChevron) const SizedBox(width: 8),
            ],
            if (showChevron)
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colors.textSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(AppThemeColors colors) {
    return Divider(
      height: 1,
      thickness: 1,
      color: colors.textSecondary.withValues(alpha: 0.1),
    );
  }
}
