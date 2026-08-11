import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/services/auth_service.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_typography.dart';
import 'package:spend_wise/utils/snackbar_helper.dart';
import 'package:spend_wise/widgets/danger_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/profile/providers/profile_provider.dart';
import 'package:spend_wise/features/profile/widgets/manage_categories_bottom_sheet.dart';
import 'package:spend_wise/features/profile/widgets/update_budget_dialog.dart';
import 'package:spend_wise/features/profile/widgets/settings_card.dart';
import 'package:spend_wise/features/profile/widgets/settings_divider.dart';
import 'package:spend_wise/features/profile/widgets/settings_section_header.dart';
import 'package:spend_wise/features/profile/widgets/settings_tile.dart';
import 'package:spend_wise/features/profile/widgets/user_profile_header.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _authService = AuthService();
  bool _loggingOut = false;

  Future<void> _logout() async {
    setState(() => _loggingOut = true);
    try {
      await _authService.logout();
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showError(context, e.toString());
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
    final profileAsync = ref.watch(profileProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? "";
    final name = profileAsync.value?.name ?? "User";
    final budget = profileAsync.value?.monthlyBudget ?? 0.0;

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
            UserProfileHeader(
              name: name,
              email: email,
            ),

            const SizedBox(height: 36),

            // Financial Preferences
            const SettingsSectionHeader(title: "FINANCIAL PREFERENCES"),
            const SizedBox(height: 14),
            SettingsCard(
              children: [
                SettingsTile(
                  icon: FontAwesomeIcons.wallet,
                  title: "Monthly Budget",
                  trailingText: budget.toStringAsFixed(0),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => UpdateBudgetDialog(currentBudget: budget),
                    );
                  },
                ),
                const SettingsDivider(),
                SettingsTile(
                  icon: FontAwesomeIcons.tags,
                  title: "Manage Categories",
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      showDragHandle: true,
                      backgroundColor: colors.backgroundCard,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => const ManageCategoriesBottomSheet(),
                    );
                  },
                ),
                // const SettingsDivider(),
                // SettingsTile(
                //   icon: FontAwesomeIcons.dollarSign,
                //   title: "Currency",
                //   trailingText: "USD (\$)",
                //   onTap: () {},
                // ),
              ],
            ),

            const SizedBox(height: 36),

            // App Preferences
            // const SettingsSectionHeader(title: "APP PREFERENCES"),
            // const SizedBox(height: 14),
            // SettingsCard(
            //   children: [
            //     SettingsTile(
            //       icon: FontAwesomeIcons.solidMoon,
            //       title: "Theme",
            //       trailingText: "System",
            //       onTap: () {},
            //     ),
            //     const SettingsDivider(),
            //     SettingsTile(
            //       icon: FontAwesomeIcons.solidBell,
            //       title: "Notifications",
            //       trailingText: "On",
            //       onTap: () {},
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 36),

            // About & Support
            const SettingsSectionHeader(title: "ABOUT & SUPPORT"),
            const SizedBox(height: 14),
            SettingsCard(
              children: [
                SettingsTile(
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
}
