import 'package:coaching_fit_coach/core/storage/secure_storage.dart';
import 'package:coaching_fit_coach/features/auth/presentation/screens/email_confirmation_screen.dart';
import 'package:coaching_fit_coach/features/auth/presentation/screens/login_screen.dart';
import 'package:coaching_fit_coach/features/auth/presentation/screens/register_screen.dart';
import 'package:coaching_fit_coach/features/auth/presentation/screens/splash_screen.dart';
import 'package:coaching_fit_coach/features/profile/presentation/screens/create_profile_screen.dart';
import 'package:coaching_fit_coach/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:coaching_fit_coach/features/profile/presentation/screens/pending_approval_screen.dart';
import 'package:coaching_fit_coach/features/profile/presentation/screens/view_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final SecureStorage _secureStorage;

  AppRouter(this._secureStorage);

  late final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/email-confirmation',
        builder: (context, state) => const EmailConfirmationScreen(),
      ),
      GoRoute(
        path: '/create-profile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      GoRoute(
        path: '/pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        path: '/view-profile',
        builder: (context, state) => const ViewProfileScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) async {
      final token = await _secureStorage.readToken();
      final loggingIn = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      if (token == null) {
        return loggingIn ? null : '/login';
      }

      // TODO: Add logic for profile check and IsActive check
      if (loggingIn) return '/';

      return null;
    },
  );
}
