import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/applications/presentation/screens/applications_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/verify_phone_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/employer/presentation/screens/applicants_list_screen.dart';
import '../../features/employer/presentation/screens/candidate_profile_screen.dart';
import '../../features/employer/presentation/screens/employer_payment_screen.dart';
import '../../features/employer/presentation/screens/packs_screen.dart';
import '../../features/employer/presentation/screens/payment_mode_screen.dart';
import '../../features/jobs/presentation/screens/create_job_screen.dart';
import '../../features/jobs/presentation/screens/job_details_screen.dart';
import '../../features/navigation/main_nav_screen.dart';
import '../../features/profile/presentation/screens/employer_profile_screen.dart';
import '../../features/profile/presentation/screens/student_profile_screen.dart';
import '../../features/profile_setup/presentation/screens/profile_setup_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/wallet/presentation/screens/wallet_screen.dart';
import '../../features/wallet/presentation/screens/withdraw_screen.dart';
import '../../shared/widgets/candidate_card_widget.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      final status = authProvider.status;
      final isSplash = state.matchedLocation == '/splash';
      final isLoggingIn = state.matchedLocation == '/login';
      final isRegistering = state.matchedLocation == '/register';
      final isVerifying = state.matchedLocation == '/verify-phone';

      if (isSplash) {
        return null;
      }

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
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavScreen(),
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
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupScreen(),
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
      GoRoute(
        path: '/payment-mode',
        builder: (context, state) {
          final draft = state.extra as Map<String, dynamic>? ?? {};
          return PaymentModeScreen(jobDraft: draft);
        },
      ),
      GoRoute(
        path: '/applicants',
        builder: (context, state) => const ApplicantsListScreen(),
      ),
      GoRoute(
        path: '/candidate-details',
        builder: (context, state) {
          final candidate = state.extra as CandidateModel? ??
              const CandidateModel(
                id: 'cand-1',
                name: 'Priya Sharma',
                title: 'Certified Barista & Cashier',
                rating: 4.9,
                reviewsCount: 22,
                distanceKm: 1.8,
                skills: ['Espresso Machines', 'Customer Service', 'POS Billing'],
                availability: 'Weekends • Immediate',
                hourlyRate: '₹450/hr',
                experience: '2 years part-time barista experience',
                education: 'B.Sc Economics, Mount Carmel College',
                about: 'Passionate specialty coffee enthusiast with experience.',
                phone: '+91 98765 43210',
                email: 'priya@example.com',
              );
          return CandidateProfileScreen(candidate: candidate);
        },
      ),
      GoRoute(
        path: '/employer-payment',
        builder: (context, state) {
          final name = state.uri.queryParameters['candidateName'] ?? 'Candidate';
          final title = state.uri.queryParameters['title'] ?? 'Role';
          final amt = double.tryParse(state.uri.queryParameters['amount'] ?? '') ?? 450.0;
          return EmployerPaymentScreen(
            candidateName: name,
            jobTitle: title,
            candidatePayAmount: amt,
          );
        },
      ),
      GoRoute(
        path: '/packs',
        builder: (context, state) => const PacksScreen(),
      ),
      GoRoute(
        path: '/applications',
        builder: (context, state) => const ApplicationsScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/withdraw',
        builder: (context, state) => const WithdrawScreen(),
      ),
      GoRoute(
        path: '/chats',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final name = state.uri.queryParameters['name'] ?? 'Contact';
          final role = state.uri.queryParameters['role'] ?? 'User';
          return ChatScreen(
            contactName: name,
            contactRole: role,
          );
        },
      ),
      GoRoute(
        path: '/student-profile',
        builder: (context, state) => const StudentProfileScreen(),
      ),
      GoRoute(
        path: '/employer-profile',
        builder: (context, state) => const EmployerProfileScreen(),
      ),
    ],
  );
}
