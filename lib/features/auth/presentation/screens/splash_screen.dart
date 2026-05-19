import 'package:coaching_fit_coach/core/routing/app_routes.dart';
import 'package:coaching_fit_coach/core/theme/app_theme.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:coaching_fit_coach/features/auth/presentation/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    await context.read<AuthCubit>().resolveSession();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (_, next) => next is AuthSuccess,
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.goNamed(_routeFor(state.nextStep));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.fitness_center,
                color: AppColors.primary,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'CoachingFit',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 8),
              Text(
                'Train · Inspire · Earn',
                style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
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
}
