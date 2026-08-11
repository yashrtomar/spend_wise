import 'package:flutter/material.dart';
import 'package:spend_wise/features/auth/presentation/widgets/auth_layout.dart';
import 'package:spend_wise/features/auth/presentation/providers/auth_di_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spend_wise/widgets/primary_button.dart';
import 'package:spend_wise/widgets/text_input.dart';
import 'package:spend_wise/utils/snackbar_helper.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  bool _loading = false;


  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final resetPasswordUseCase = ref.read(resetPasswordUseCaseProvider);
      await resetPasswordUseCase.execute(_emailController.text.trim());

      if (!mounted) return;

      SnackbarHelper.showSuccess(context, "Password reset email sent.");

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      SnackbarHelper.showError(context, e.toString());
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 16),

            TextInput(
              hintText: "Email",
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Email is required";
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            PrimaryButton(
              title: _loading
                  ? "Sending..."
                  : "Send Reset Email",
              height: 44,
              onPressed:
                  _loading ? null : _sendResetEmail,
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Back to Login"),
            ),
          ],
        ),
      ),
    );
  }
}