import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_theme.dart';
import 'package:spend_wise/widgets/auth_gate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kioqyplydbfztuwdbimt.supabase.co', 
    publishableKey: 'sb_publishable_VvXFUOJCBu4EP4xzAa5Wrg_Qw5yC-22'
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,

  theme: AppTheme.light,

  darkTheme: AppTheme.dark,

  themeMode: ThemeMode.system,

  home: const AuthGate(),
);
  }
}
