import 'package:flutter/material.dart';
import 'package:spend_wise/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:spend_wise/features/auth/presentation/screens/register_screen.dart';
import 'package:spend_wise/features/auth/presentation/widgets/auth_layout.dart';
import 'package:spend_wise/features/auth/presentation/widgets/section_divider.dart';
import 'package:spend_wise/features/auth/presentation/providers/auth_di_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/utils/snackbar_helper.dart';
import 'package:spend_wise/widgets/primary_button.dart';
import 'package:spend_wise/widgets/text_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final VoidCallback? onToggle;
  const LoginScreen({super.key, this.onToggle});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();


  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocus.dispose();
    _passwordFocus.dispose();

    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final loginUseCase = ref.read(loginUseCaseProvider);
      await loginUseCase.execute(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      // We don't need popUntil anymore if we aren't pushing auth screens
      // But we leave it in case it's used elsewhere
      Navigator.of(context).popUntil((route) => route.isFirst);

      SnackbarHelper.showSuccess(context, "Login successful");
    } on Exception catch (e) {
      if (!mounted) return;

      SnackbarHelper.showError(context, e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSpacing.md),
            TextInput(
              hintText: "Email",
              controller: _emailController,
              focusNode: _emailFocus,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Email is required";
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_passwordFocus);
              },
            ),
            SizedBox(height: AppSpacing.md),
            TextInput(
              hintText: "Password",
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password is required";
                }
                return null;
              },
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
              ),
              onFieldSubmitted: (_) => _login(),
            ),

            const SizedBox(height: AppSpacing.xs),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text("Forgot Password?"),
              ),
            ),

            PrimaryButton(
              title: _loading ? "Signing In..." : "Login",
              onPressed: _loading ? null : _login,
              height: 48,
            ),

            const SizedBox(height: AppSpacing.xl),

            // const SectionDivider(),
            // const SizedBox(height: AppSpacing.xl),
            // const OauthButtonRow(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.onToggle != null) {
                      widget.onToggle!();
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    }
                  },
                  child: const Text("Register"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
