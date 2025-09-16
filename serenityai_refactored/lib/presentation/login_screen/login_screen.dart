import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:serenityai/core/app_export.dart';
import 'package:serenityai/services/local_auth_service.dart';
import 'package:serenityai/services/supabase_auth_service.dart';
import './widgets/biometric_auth_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await SupabaseAuthService.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (result['success']) {
      // Success - trigger haptic feedback
      HapticFeedback.lightImpact();

      Fluttertoast.showToast(
        msg: "Login successful! Welcome back to SerenityAI",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        textColor: AppTheme.lightTheme.colorScheme.onPrimary,
      );

      // Navigate to dashboard
      Navigator.pushReplacementNamed(context, '/home-dashboard');
    } else {
      // Show error message
      _showErrorDialog(
        result['error'] ??
            'Invalid credentials. Please check your email and password.',
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Login Failed',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
          content: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleForgotPassword() {
    if (_emailController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email address first.');
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Reset Password',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
              content: Text(
                'Send a password reset email to ${_emailController.text.trim()}?',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              actions: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.outline,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          final result =
                              await SupabaseAuthService.resetPassword(
                            email: _emailController.text.trim(),
                          );

                          Navigator.of(context).pop();

                          if (result['success']) {
                            Fluttertoast.showToast(
                              msg: result['message'] ??
                                  'Password reset email sent!',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor:
                                  AppTheme.lightTheme.colorScheme.primary,
                              textColor:
                                  AppTheme.lightTheme.colorScheme.onPrimary,
                            );
                          } else {
                            _showErrorDialog(result['error'] ??
                                'Failed to send reset email.');
                          }
                        },
                  child: isLoading
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        )
                      : Text('Send Reset Email'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleBiometricAuth() {
    Fluttertoast.showToast(
      msg:
          "Biometric authentication will be available after first successful login",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      textColor: AppTheme.lightTheme.colorScheme.onSecondary,
    );
  }

  void _handleSocialLogin(String provider) async {
    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> result;

    if (provider == 'Google') {
      result = await SupabaseAuthService.signInWithGoogle();
    } else if (provider == 'Apple') {
      result = await SupabaseAuthService.signInWithApple();
    } else {
      result = {
        'success': false,
        'error': '$provider login will be available in the next update',
      };
    }

    if (result['success']) {
      Fluttertoast.showToast(
        msg: result['message'] ?? '$provider login initiated',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        textColor: AppTheme.lightTheme.colorScheme.onPrimary,
      );
    } else {
      Fluttertoast.showToast(
        msg: result['error'] ?? '$provider login failed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        textColor: AppTheme.lightTheme.colorScheme.onError,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 8.h),

              // App Logo
              Container(
                width: 25.w,
                height: 25.w,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 0.3,
                      ),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'psychology',
                    size: 12.w,
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // Welcome Text
              Text(
                'Welcome Back',
                style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Sign in to continue your wellness journey',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),

              // Login Form
              LoginFormWidget(
                emailController: _emailController,
                passwordController: _passwordController,
                formKey: _formKey,
                onSignInPressed: _handleSignIn,
                onForgotPasswordPressed: _handleForgotPassword,
                isLoading: _isLoading,
              ),

              // Biometric Authentication
              BiometricAuthWidget(
                onBiometricPressed: _handleBiometricAuth,
                isLoading: _isLoading,
              ),

              // Social Login
              SocialLoginWidget(
                onGooglePressed: () => _handleSocialLogin('Google'),
                onApplePressed: () => _handleSocialLogin('Apple'),
                isLoading: _isLoading,
              ),

              SizedBox(height: 4.h),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to SerenityAI? ',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _navigateToSignUp,
                    child: Text(
                      'Sign Up',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Local Users Info
              FutureBuilder<int>(
                future: LocalAuthService.getRegisteredUsersCount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data! > 0) {
                    return Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Local Account Info:',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '${snapshot.data} account(s) registered locally',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              SizedBox(height: 4.h),

              // Configuration Status Info (Development Helper)
              if (kDebugMode)
                FutureBuilder<Map<String, dynamic>>(
                  future: Future.value(SupabaseAuthService.configurationStatus),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final config = snapshot.data!;
                      final isReady = config['is_ready'] ?? false;

                      return Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: isReady
                              ? AppTheme.lightTheme.colorScheme.primary
                                  .withValues(alpha: 0.1)
                              : AppTheme.lightTheme.colorScheme.error
                                  .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isReady
                                ? AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.3)
                                : AppTheme.lightTheme.colorScheme.error
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Supabase Configuration:',
                              style: AppTheme.lightTheme.textTheme.labelLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'URL: ${config['supabase_url']}\nKey: ${config['supabase_anon_key']}\nStatus: ${isReady ? 'Ready' : 'Not Configured'}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}