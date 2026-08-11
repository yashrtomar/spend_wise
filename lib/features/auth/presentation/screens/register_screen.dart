import 'package:flutter/material.dart';
import 'package:spend_wise/features/auth/presentation/screens/login_screen.dart';
import 'package:spend_wise/features/auth/presentation/widgets/auth_layout.dart';
// import 'package:spend_wise/features/auth/presentation/widgets/oauth_button_row.dart';
import 'package:spend_wise/features/auth/presentation/widgets/section_divider.dart';
import 'package:spend_wise/features/auth/presentation/providers/auth_di_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/utils/snackbar_helper.dart';
import 'package:spend_wise/widgets/primary_button.dart';
import 'package:spend_wise/widgets/text_input.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final VoidCallback? onToggle;
  const RegisterScreen({super.key, this.onToggle});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();


  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _loading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final registerUseCase = ref.read(registerUseCaseProvider);
      await registerUseCase.execute(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);

      SnackbarHelper.showSuccess(context, "Registration successful. Please verify your email.");
    } on Exception catch (e) {
      if (!mounted) return;

      SnackbarHelper.showError(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
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
            const SizedBox(height: AppSpacing.md),
            TextInput(
              hintText: "Name",
              controller: _nameController,
              focusNode: _nameFocus,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "Name is required";
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_emailFocus);
              },
            ),
            const SizedBox(height: AppSpacing.md),
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
            const SizedBox(height: AppSpacing.md),
            TextInput(
              hintText: "Password",
              controller: _passwordController,
              focusNode: _passwordFocus,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Password is required";
                }
                if (value.length < 6) {
                  return "Password must be at least 6 characters";
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
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_confirmPasswordFocus);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            TextInput(
              hintText: "Confirm Password",
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please confirm your password";
                }
                if (value != _passwordController.text) {
                  return "Passwords do not match";
                }
                return null;
              },
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
              ),
              onFieldSubmitted: (_) => _register(),
            ),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              title: _loading ? "Creating Account..." : "Create Account",
              height: 48,
              onPressed: _loading ? null : _register,
            ),
            const SizedBox(height: AppSpacing.md),
            const SectionDivider(),
            const SizedBox(height: AppSpacing.lg),
            // const OauthButtonRow(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account?",
                  style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.onToggle != null) {
                      widget.onToggle!();
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
