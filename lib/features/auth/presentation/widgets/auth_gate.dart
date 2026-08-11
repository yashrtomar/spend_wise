import 'package:flutter/material.dart';
import 'package:spend_wise/features/auth/presentation/screens/login_screen.dart';
import 'package:spend_wise/features/auth/presentation/screens/register_screen.dart';
import 'package:spend_wise/features/navigation/screens/main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/features/auth/presentation/providers/auth_di_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authStateAsync = ref.watch(authStateProvider);

    return authStateAsync.when(
      data: (user) {
        if (user != null) {
          return const MainScreen();
        }
        return const AuthSwitcher();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, st) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }
}

class AuthSwitcher extends StatefulWidget {
  const AuthSwitcher({super.key});

  @override
  State<AuthSwitcher> createState() => _AuthSwitcherState();
}

class _AuthSwitcherState extends State<AuthSwitcher> {
  bool _showLogin = true;

  void _toggleScreen() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _showLogin
          ? LoginScreen(
              key: const ValueKey('login'),
              onToggle: _toggleScreen,
            )
          : RegisterScreen(
              key: const ValueKey('register'),
              onToggle: _toggleScreen,
            ),
    );
  }
}