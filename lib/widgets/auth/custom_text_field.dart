import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Custom text field with traveler's diary aesthetic
/// Designed to look like writing on parchment with subtle shadows and borders
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final String? errorText;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.errorText,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with traveler's diary styling
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: Text(
              widget.label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.inkBlack,
                fontWeight: FontWeight.w600,
              ),
            ),
          ), // Parchment-style container
        Container(
          decoration: BoxDecoration(
            // Subtle parchment-like gradient
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.parchmentWhite,
                AppColors.surfaceLight,
                AppColors.parchmentWhite.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            // Soft shadow for depth
            boxShadow: [
              BoxShadow(
                color: AppColors.fadeGray.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ), // Subtle depth shadow
              BoxShadow(
                color: AppColors.lightGray.withValues(alpha: 0.2),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
            // Border that changes with focus
            border: Border.all(
              color:
                  _isFocused
                      ? AppColors.primaryBrown.withValues(alpha: 0.8)
                      : AppColors.lightGray.withValues(alpha: 0.6),
              width: _isFocused ? 2.0 : 1.0,
            ),
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            enabled: widget.enabled,
            textCapitalization: widget.textCapitalization,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.inkBlack,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.fadeGray,
                fontStyle: FontStyle.italic,
              ),
              prefixIcon:
                  widget.prefixIcon != null
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: widget.prefixIcon,
                      )
                      : null,
              suffixIcon:
                  widget.suffixIcon != null
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: widget.suffixIcon,
                      )
                      : null,
              // Remove default borders since we're using container decoration
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              // Comfortable padding for text
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: widget.maxLines > 1 ? 16 : 12,
              ),
              // Remove default error text since we handle it below
              errorText: null,
              errorStyle: const TextStyle(height: 0),
            ),
          ),
        ),

        // Custom error text with themed styling
        if (widget.errorText != null && widget.errorText!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6.0, left: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.errorRed,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.errorRed,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Specialized email text field
class EmailTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;

  const EmailTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: 'Explorer\'s Email',
      hint: 'Enter your email address',
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      validator: validator ?? _defaultEmailValidator,
      onChanged: onChanged,
      errorText: errorText,
      prefixIcon: Icon(
        Icons.mail_outline_rounded,
        color: AppColors.fadeGray,
        size: 20,
      ),
    );
  }

  String? _defaultEmailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Every explorer needs an email address';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}

/// Specialized password text field
class PasswordTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;
  final String? label;
  final String? hint;

  const PasswordTextField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
    this.label,
    this.hint,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label ?? 'Explorer\'s Password',
      hint: widget.hint ?? 'Enter your password',
      controller: widget.controller,
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
      validator: widget.validator ?? _defaultPasswordValidator,
      onChanged: widget.onChanged,
      errorText: widget.errorText,
      prefixIcon: Icon(
        Icons.lock_outline_rounded,
        color: AppColors.fadeGray,
        size: 20,
      ),
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded,
          color: AppColors.fadeGray,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }

  String? _defaultPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'A password is required for your journey';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }

    return null;
  }
}
