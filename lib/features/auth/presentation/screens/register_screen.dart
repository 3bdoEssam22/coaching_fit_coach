import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/auth/data/models/register_request.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is RegistrationSuccess) {
            context.go('/email-confirmation', extra: _emailController.text.trim());
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
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Create Account', style: AppTextStyles.heading2),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          decoration: _inputDecoration('First Name'),
                          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
                          style: AppTextStyles.bodyM,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          decoration: _inputDecoration('Last Name'),
                          validator: (value) => (value?.isEmpty ?? true) ? 'Required' : null,
                          style: AppTextStyles.bodyM,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    decoration: _inputDecoration('Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) return 'Enter a valid email';
                      return null;
                    },
                    style: AppTextStyles.bodyM,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration('Phone Number (01XXXXXXXXX)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your phone number';
                      if (!RegExp(r'^01[0125][0-9]{8}$').hasMatch(value)) return 'Enter a valid Egyptian number';
                      return null;
                    },
                    style: AppTextStyles.bodyM,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: _inputDecoration('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textHint),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) => (value?.isEmpty ?? true) ? 'Please enter a password' : null,
                    style: AppTextStyles.bodyM,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Min 8 chars · Uppercase · Number · Special character',
                    style: AppTextStyles.bodyS.copyWith(color: AppColors.textHint),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: _inputDecoration('Confirm Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.textHint),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                    style: AppTextStyles.bodyM,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: state is AuthLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state is AuthLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : Text('Register', style: AppTextStyles.button),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account? ", style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text('Log in', style: AppTextStyles.bodyM.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.bodyM.copyWith(color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
    );
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      final request = RegisterRequest(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        confirmPassword: _confirmPasswordController.text.trim(),
      );
      context.read<AuthCubit>().register(request);
    }
  }
}
