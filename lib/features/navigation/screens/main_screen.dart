import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/services/sync_providers.dart';
import 'package:flutter/material.dart';
import 'package:spend_wise/features/expenses/presentation/screens/all_expenses_screen.dart';
import 'package:spend_wise/features/expenses/presentation/screens/home_screen.dart';
import 'package:spend_wise/features/navigation/widgets/main_bottom_nav_bar.dart';
import 'package:spend_wise/features/profile/presentation/screens/profile_screen.dart';
import 'package:spend_wise/widgets/fade_indexed_stack.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(syncServiceProvider.notifier).syncNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AllExpensesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
        body: FadeIndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: MainBottomNavBar(
          currentIndex: _currentIndex,
          onTabSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
