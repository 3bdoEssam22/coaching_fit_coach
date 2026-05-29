import 'package:coaching_fit_coach/core/routing/app_routes.dart';
import 'package:coaching_fit_coach/core/widgets/responsive_helper.dart';
import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            context.goNamed(_routeFor(state.nextStep));
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: responsive.horizontalPadding),
            child: responsive.content(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 80),
                    const Icon(Icons.fitness_center, color: AppColors.primary, size: 64),
                    const SizedBox(height: 16),
                    Text('Welcome Back', textAlign: TextAlign.center, style: AppTextStyles.heading2),
                    const SizedBox(height: 8),
                    Text('Log in to continue your coaching journey', textAlign: TextAlign.center, style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 48),
                    TextFormField(
                      controller: _emailController,
                      decoration: _inputDecoration('Email', responsive),
                      validator: (value) => (value?.isEmpty ?? true) ? 'Please enter your email' : null,
                      style: AppTextStyles.bodyM,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: _inputDecoration('Password', responsive).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: AppColors.textHint),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ),
                      validator: (value) => (value?.isEmpty ?? true) ? 'Please enter your password' : null,
                      style: AppTextStyles.bodyM,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Forgot password feature coming soon.')),
                          );
                        },
                        child: Text('Forgot Password?', style: AppTextStyles.bodyS.copyWith(color: AppColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: state is AuthLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        minimumSize: Size(double.infinity, responsive.buttonHeight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(responsive.cardRadius),
                        ),
                      ),
                      child: state is AuthLoading
                          ? const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                          : Text('Login', style: AppTextStyles.button),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ", style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
                        TextButton(
                          onPressed: () => context.goNamed(AppRoutes.register),
                          child: Text('Register', style: AppTextStyles.bodyM.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, ResponsiveHelper responsive) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
    );
  }

  String _routeFor(AuthNextStep step) => switch (step) {
        AuthNextStep.onboarding => AppRoutes.onboarding,
        AuthNextStep.login => AppRoutes.login,
        AuthNextStep.createProfile => AppRoutes.createProfile,
        AuthNextStep.pendingApproval => AppRoutes.pendingApproval,
        AuthNextStep.viewProfile => AppRoutes.viewProfile,
      };

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().login(
            _emailController.text.trim(),
            _passwordController.text.trim(),
          );
    }
  }
}
