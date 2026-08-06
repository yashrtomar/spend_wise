import 'package:flutter/material.dart';
import 'package:spend_wise/theme/app_colors.dart';
import 'package:spend_wise/theme/app_radius.dart';
import 'package:spend_wise/theme/app_spacing.dart';
import 'package:spend_wise/theme/app_typography.dart';

class TextInput extends StatelessWidget {
  final String? hintText;

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final bool isAmount;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;

  final TextInputType keyboardType;
  final TextInputAction? textInputAction;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;

  final FormFieldValidator<String>? validator;
  final AutovalidateMode autovalidateMode;

  final Widget? prefixIcon;
  final Widget? suffixIcon;

  final int? maxLines;
  final int? minLines;
  final int? maxLength;

  const TextInput({
    super.key,
    this.hintText,
    this.controller,
    this.focusNode,
    this.isAmount = false,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,

          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,

          obscureText: obscureText,

          keyboardType: keyboardType,
          textInputAction: textInputAction,

          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,

          validator: validator,
          autovalidateMode: autovalidateMode,

          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,

          style: AppTypography.base.copyWith(
            color: colors.textPrimary,
            fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
          ),

          decoration: InputDecoration(
            hintText: hintText,

            hintStyle: TextStyle(color: colors.textMuted),

            filled: true,
            fillColor: Colors.transparent,

            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,

            counterText: "",

            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: colors.border),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: colors.primary, width: 2),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: colors.error),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.md,
              borderSide: BorderSide(color: colors.error, width: 2),
            ),

            errorStyle: TextStyle(color: colors.error),
          ),
        ),
      ],
    );
  }
}
