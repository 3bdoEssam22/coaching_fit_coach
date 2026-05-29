import 'package:coaching_fit_coach/core/routing/app_routes.dart';
import 'package:coaching_fit_coach/core/storage/secure_storage.dart';
import 'package:coaching_fit_coach/features/auth/presentation/screens/email_confirmation_screen.dart';
import 'package:coaching_fit_coach/features/auth/presentation/screens/login_screen.dart';
import 'package:coaching_fit_coach/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:coaching_fit_coach/features/auth/presentation/screens/register_screen.dart';
import 'package:coaching_fit_coach/features/auth/presentation/screens/splash_screen.dart';
import 'package:coaching_fit_coach/features/certificates/data/models/certificate_response.dart';
import 'package:coaching_fit_coach/features/certificates/presentation/screens/certificate_detail_screen.dart';
import 'package:coaching_fit_coach/features/certificates/presentation/screens/my_certificates_screen.dart';
import 'package:coaching_fit_coach/features/certificates/presentation/screens/upload_certificate_screen.dart';
import 'package:coaching_fit_coach/features/profile/presentation/screens/create_profile_screen.dart';
import 'package:coaching_fit_coach/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:coaching_fit_coach/features/profile/presentation/screens/pending_approval_screen.dart';
import 'package:coaching_fit_coach/features/profile/presentation/screens/view_profile_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  final SecureStorage _secureStorage;

  AppRouter(this._secureStorage);

  late final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        name: AppRoutes.splash,
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: AppRoutes.onboarding,
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        name: AppRoutes.login,
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: AppRoutes.register,
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        name: AppRoutes.emailConfirmation,
        path: '/email-confirmation',
        builder: (context, state) => const EmailConfirmationScreen(),
      ),
      GoRoute(
        name: AppRoutes.createProfile,
        path: '/create-profile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      GoRoute(
        name: AppRoutes.pendingApproval,
        path: '/pending-approval',
        builder: (context, state) => const PendingApprovalScreen(),
      ),
      GoRoute(
        name: AppRoutes.viewProfile,
        path: '/view-profile',
        builder: (context, state) => const ViewProfileScreen(),
      ),
      GoRoute(
        name: AppRoutes.editProfile,
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        name: AppRoutes.certificates,
        path: '/certificates',
        builder: (context, state) => const MyCertificatesScreen(),
      ),
      GoRoute(
        name: AppRoutes.certificatesUpload,
        path: '/certificates/upload',
        builder: (context, state) => const UploadCertificateScreen(),
      ),
      GoRoute(
        name: AppRoutes.certificateDetail,
        path: '/certificates/:id',
        builder: (context, state) {
          final cert = state.extra as CertificateResponse;
          return CertificateDetailScreen(certificate: cert);
        },
      ),
    ],
    redirect: (context, state) async {
      final path = state.matchedLocation;

      // Splash handles its own routing logic
      if (path == '/') return null;

      final token = await _secureStorage.readToken();

      if (token == null) {
        const publicPaths = ['/login', '/register', '/email-confirmation', '/onboarding'];
        if (publicPaths.contains(path)) return null;
        return '/login';
      }

      final hasProfile = await _secureStorage.readHasProfile();
      if (!hasProfile) {
        if (path == '/create-profile') return null;
        return '/create-profile';
      }

      // Logged-in user on an auth screen — bounce to home
      const authPaths = ['/login', '/register', '/email-confirmation', '/onboarding'];
      if (authPaths.contains(path)) return '/view-profile';

      return null;
    },
  );
}
