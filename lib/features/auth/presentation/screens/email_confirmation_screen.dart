import 'dart:async';

import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EmailConfirmationScreen extends StatefulWidget {
  const EmailConfirmationScreen({super.key});

  @override
  State<EmailConfirmationScreen> createState() => _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState extends State<EmailConfirmationScreen> {
  bool _isResendButtonDisabled = false;
  int _cooldown = 60;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _isResendButtonDisabled = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown == 0) {
        timer.cancel();
        setState(() {
          _isResendButtonDisabled = false;
          _cooldown = 60;
        });
      } else {
        setState(() {
          _cooldown--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final email = GoRouterState.of(context).extra as String?;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_read_outlined, color: AppColors.primary, size: 100),
              const SizedBox(height: 32),
              Text('Check Your Email', textAlign: TextAlign.center, style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              Text(
                'We have sent a confirmation link to:',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Text(
                email ?? 'your.email@example.com',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyL.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              OutlinedButton(
                onPressed: _isResendButtonDisabled ? null : _startCooldown,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isResendButtonDisabled ? 'Resend in $_cooldown s' : 'Resend Email',
                  style: AppTextStyles.button.copyWith(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'Already confirmed? Go to Login →',
                  style: AppTextStyles.bodyM.copyWith(color: AppColors.primary),
                ),
              ),
              const Spacer(),
              Text(
                "Didn't receive the email? Check your spam folder or try resending.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyS.copyWith(color: AppColors.textHint),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
