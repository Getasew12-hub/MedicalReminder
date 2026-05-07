import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../features/auth/domain/auth_provider.dart';
import '../../../features/auth/screens/register_screen.dart';
import '../../../features/auth/widgets/auth_error_message.dart';
import '../../../features/auth/widgets/auth_footer_link.dart';
import '../../../features/auth/widgets/social_auth_row.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../../../shared/widgets/gradient_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _clearError();
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (!success) {
      _showError(
        authProvider.errorMessage ??
            'We could not log you in. Check your details and try again.',
      );
    }
  }

  Future<void> _forgotPassword() async {
    _clearError();
    final email = _emailController.text.trim();
    final emailError = Validators.email(email);
    if (emailError != null) {
      _showError('Enter your email first to reset your password.');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendPasswordReset(email);
    if (!mounted) return;
    if (!success) {
      _showError(authProvider.errorMessage);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent.')),
    );
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ??
              'We could not log you in. Check your details and try again.',
        ),
      ),
    );
  }

  void _clearError() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.errorMessage != null) {
      authProvider.clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppConstants.screenPadding.copyWith(top: 48, bottom: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo()),
                const SizedBox(height: 28),
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to keep your medicine schedule simple.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 38),
                AuthTextField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: Validators.password,
                  onChanged: (_) => _clearError(),
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed:
                            authProvider.isLoading ? null : _forgotPassword,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: AppColors.rose,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return AuthErrorMessage(
                      message: authProvider.errorMessage,
                    );
                  },
                ),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, _) {
                    return GradientButton(
                      label: 'Login',
                      icon: Icons.login_rounded,
                      isLoading: authProvider.isLoading,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: 30),
                const SocialAuthRow(),
                const SizedBox(height: 30),
                AuthFooterLink(
                  text: "Don't have an account?",
                  actionText: 'Sign Up',
                  onTap: () => context.go(RegisterScreen.routeName),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
