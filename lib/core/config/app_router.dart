import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_phone_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/jobs/presentation/screens/create_job_screen.dart';
import '../../features/jobs/presentation/screens/job_details_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      final status = authProvider.status;
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isVerifying = state.matchedLocation == '/verify-phone';

      if (status == AuthStatus.unauthenticated) {
        if (!isLoggingIn && !isRegistering) {
          return '/login';
        }
      } else if (status == AuthStatus.pendingVerification) {
        if (!isVerifying) {
          final phone = authProvider.pendingPhone ?? authProvider.currentUser?.phone ?? '';
          return '/verify-phone?phone=$phone';
        }
      } else if (status == AuthStatus.authenticated) {
        if (isLoggingIn || isRegistering || isVerifying) {
          return '/';
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
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
        path: '/verify-phone',
        builder: (context, state) {
          final phoneArg = state.extra as String?;
          var queryPhone = state.uri.queryParameters['phone']?.trim();
          if (queryPhone != null && queryPhone.isNotEmpty && !queryPhone.startsWith('+')) {
            queryPhone = '+$queryPhone';
          }
          final phone = (phoneArg ?? queryPhone ?? '').trim();
          return VerifyPhoneScreen(
            phone: phone.isNotEmpty && !phone.startsWith('+') ? '+$phone' : phone,
          );
        },
      ),
      GoRoute(
        path: '/job-details/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return JobDetailsScreen(jobId: id);
        },
      ),
      GoRoute(
        path: '/create-job',
        builder: (context, state) => const CreateJobScreen(),
      ),
    ],
  );
}
