import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';

class MainBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const MainBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    return Container(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.backgroundCard,
        border: Border(
          top: BorderSide(
            color: colors.textSecondary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTabSelected,
        backgroundColor: colors.backgroundCard,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textSecondary,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: FaIcon(FontAwesomeIcons.solidHouse, size: 20),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: FaIcon(FontAwesomeIcons.receipt, size: 20),
            ),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: FaIcon(FontAwesomeIcons.solidUser, size: 20),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
