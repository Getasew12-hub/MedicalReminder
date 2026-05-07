import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/validators.dart';
import '../../../features/auth/domain/auth_provider.dart';
import '../../../features/auth/widgets/auth_error_message.dart';
import '../../../features/auth/widgets/auth_footer_link.dart';
import '../../../features/auth/widgets/social_auth_row.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/auth_text_field.dart';
import '../../../shared/widgets/gradient_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    _clearError();
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ??
                'We could not create your account. Please try again.',
          ),
        ),
      );
    }
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
          padding: AppConstants.screenPadding.copyWith(top: 34, bottom: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(child: AppLogo(size: 68)),
                const SizedBox(height: 22),
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Start tracking your medicines and daily reminders.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                AuthTextField(
                  controller: _nameController,
                  hint: 'Full Name',
                  icon: Icons.person_outline_rounded,
                  validator: (value) => Validators.required(value, 'Full name'),
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  validator: Validators.password,
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: 14),
                AuthTextField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock_reset_rounded,
                  obscureText: true,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: 22),
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
                      label: 'Sign Up',
                      icon: Icons.person_add_alt_1_rounded,
                      isLoading: authProvider.isLoading,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: 26),
                const SocialAuthRow(),
                const SizedBox(height: 24),
                AuthFooterLink(
                  text: 'Already have an account?',
                  actionText: 'Login',
                  onTap: () => context.go('/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
