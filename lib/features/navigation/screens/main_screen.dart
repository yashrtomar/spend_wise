import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:spend_wise/features/expenses/screens/all_expenses_screen.dart';
import 'package:spend_wise/features/expenses/screens/home_screen.dart';
import 'package:spend_wise/features/profile/screens/profile_screen.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_spacing.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AllExpensesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
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
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
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
        ),
      ),
    );
  }
}
