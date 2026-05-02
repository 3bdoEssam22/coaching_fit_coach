import 'package:coaching_fit_coach/core/storage/secure_storage.dart';
import 'package:coaching_fit_coach/core/theme/app_colors.dart';
import 'package:coaching_fit_coach/core/theme/text_styles.dart';
import 'package:coaching_fit_coach/features/profile/data/repositories/profile_repository.dart';
import 'package:coaching_fit_coach/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final secureStorage = sl<SecureStorage>();
    final token = await secureStorage.readToken();

    if (token == null) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.go('/onboarding');
      }
      return;
    }

    // Token exists, check profile
    try {
      final profileRepository = sl<ProfileRepository>();
      final profile = await profileRepository.getMyProfile();
      await secureStorage.writeHasProfile(true);
      // TODO: Check isActive from profile and store it
      if (mounted) {
        context.go('/view-profile');
      }
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        await secureStorage.writeHasProfile(false);
        if (mounted) {
          context.go('/create-profile');
        }
      } else {
        // Handle other errors, maybe logout and go to login
        await secureStorage.clearAll();
        if (mounted) {
          context.go('/login');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    );
  }
}
