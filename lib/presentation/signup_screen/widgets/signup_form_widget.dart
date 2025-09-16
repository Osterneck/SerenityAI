import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';

class SignupFormWidget extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey<FormState> formKey;
  final VoidCallback? onSignUpPressed;
  final bool isLoading;
  final bool acceptedTerms;
  final ValueChanged<bool>? onTermsChanged;

  const SignupFormWidget({
    Key? key,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.formKey,
    this.onSignUpPressed,
    this.isLoading = false,
    this.acceptedTerms = false,
    this.onTermsChanged,
  }) : super(key: key);

  @override
  State<SignupFormWidget> createState() => _SignupFormWidgetState();
}

class _SignupFormWidgetState extends State<SignupFormWidget> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    widget.fullNameController.addListener(_validateForm);
    widget.emailController.addListener(_validateForm);
    widget.passwordController.addListener(_validateForm);
    widget.confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    widget.fullNameController.removeListener(_validateForm);
    widget.emailController.removeListener(_validateForm);
    widget.passwordController.removeListener(_validateForm);
    widget.confirmPasswordController.removeListener(_validateForm);
    super.dispose();
  }

  void _validateForm() {
    final isValid =
        widget.fullNameController.text.trim().isNotEmpty &&
        widget.emailController.text.isNotEmpty &&
        widget.passwordController.text.isNotEmpty &&
        widget.confirmPasswordController.text.isNotEmpty &&
        _isValidEmail(widget.emailController.text) &&
        widget.passwordController.text.length >= 6 &&
        widget.passwordController.text ==
            widget.confirmPasswordController.text &&
        widget.acceptedTerms;

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    if (value.trim().length < 2) {
      return 'Full name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9])').hasMatch(value)) {
      return 'Password must contain letters and numbers';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != widget.passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name Field
          TextFormField(
            controller: widget.fullNameController,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            validator: _validateFullName,
            decoration: InputDecoration(
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Email Field
          TextFormField(
            controller: widget.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            validator: _validateEmail,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email address',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'email',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Password Field
          TextFormField(
            controller: widget.passwordController,
            obscureText: !_isPasswordVisible,
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            validator: _validatePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter your password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              suffixIcon: IconButton(
                onPressed:
                    widget.isLoading
                        ? null
                        : () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                icon: CustomIconWidget(
                  iconName:
                      _isPasswordVisible ? 'visibility_off' : 'visibility',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Confirm Password Field
          TextFormField(
            controller: widget.confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            textInputAction: TextInputAction.done,
            enabled: !widget.isLoading,
            validator: _validateConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Confirm your password',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock_outline',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              suffixIcon: IconButton(
                onPressed:
                    widget.isLoading
                        ? null
                        : () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                icon: CustomIconWidget(
                  iconName:
                      _isConfirmPasswordVisible
                          ? 'visibility_off'
                          : 'visibility',
                  size: 20,
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            onFieldSubmitted: (_) {
              if (_isFormValid && !widget.isLoading) {
                widget.onSignUpPressed?.call();
              }
            },
          ),
          SizedBox(height: 2.h),

          // Terms and Conditions Checkbox
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: widget.acceptedTerms,
                onChanged: widget.isLoading ? null : (bool? value) => widget.onTermsChanged?.call(value ?? false),
                activeColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 1.5.w),
                  child: RichText(
                    text: TextSpan(
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Sign Up Button
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed:
                  (_isFormValid && !widget.isLoading)
                      ? widget.onSignUpPressed
                      : null,
              child:
                  widget.isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                      : Text(
                        'Create Account',
                        style: AppTheme.lightTheme.textTheme.labelLarge
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}