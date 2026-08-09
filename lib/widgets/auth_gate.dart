import 'package:flutter/material.dart';
import 'package:spend_wise/features/auth/screens/login_screen.dart';
import 'package:spend_wise/features/auth/screens/register_screen.dart';
import 'package:spend_wise/features/navigation/screens/main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        Supabase.instance.client.auth.currentSession,
      ),
      builder: (context, snapshot) {
        if (snapshot.data?.session != null) {
          return const MainScreen();
        }

        return const AuthSwitcher();
      },
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