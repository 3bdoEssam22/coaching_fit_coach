import 'package:coaching_fit_coach/core/routing/app_routes.dart';
import 'package:coaching_fit_coach/core/widgets/responsive_helper.dart';
import 'dart:async';

import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/auth/data/repositories/auth_repository.dart';
import 'package:coaching_fit_coach/service_locator.dart';
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

  void _startCooldown(String? email) async {
    if (email == null) return;

    try {
      await sl<AuthRepository>().resendConfirmation(email);
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = GoRouterState.of(context).extra as String?;
    final responsive = ResponsiveHelper(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: responsive.horizontalPadding, vertical: 24),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight - 48),
                  child: IntrinsicHeight(
                    child: responsive.content(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          const Icon(Icons.mark_email_read_outlined,
                              color: AppColors.primary, size: 100),
                          const SizedBox(height: 32),
                          Text('Check Your Email',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.heading2),
                          const SizedBox(height: 16),
                          Text(
                            'We have sent a confirmation link to:',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyM
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email ?? 'your.email@example.com',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyL
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 40),
                          OutlinedButton(
                            onPressed: _isResendButtonDisabled
                                ? null
                                : () => _startCooldown(email),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              minimumSize:
                                  Size(double.infinity, responsive.buttonHeight),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(responsive.cardRadius),
                              ),
                            ),
                            child: Text(
                              _isResendButtonDisabled
                                  ? 'Resend in $_cooldown s'
                                  : 'Resend Email',
                              style: AppTextStyles.button
                                  .copyWith(color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: () => context.goNamed(AppRoutes.login),
                            child: Text(
                              'Already confirmed? Go to Login →',
                              style: AppTextStyles.bodyM
                                  .copyWith(color: AppColors.primary),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "Didn't receive the email? Check your spam folder or try resending.",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyS
                                .copyWith(color: AppColors.textHint),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
