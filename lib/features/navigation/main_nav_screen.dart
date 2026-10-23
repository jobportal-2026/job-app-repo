import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../applications/presentation/screens/applications_screen.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../chat/presentation/screens/chat_list_screen.dart';
import '../employer/presentation/screens/applicants_list_screen.dart';
import '../employer/presentation/screens/employer_dashboard_screen.dart';
import '../employer/presentation/screens/packs_screen.dart';
import '../home/presentation/screens/home_screen.dart';
import '../jobs/presentation/screens/create_job_screen.dart';
import '../profile/presentation/screens/employer_profile_screen.dart';
import '../profile/presentation/screens/student_profile_screen.dart';
import '../wallet/presentation/screens/wallet_screen.dart';

class MainNavScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isEmployer = user?.role == 'employer';

    final List<Widget> studentScreens = const [
      HomeScreen(),
      ApplicationsScreen(),
      WalletScreen(),
      ChatListScreen(),
      StudentProfileScreen(),
    ];

    final List<Widget> employerScreens = const [
      EmployerDashboardScreen(),
      CreateJobScreen(),
      ApplicantsListScreen(),
      PacksScreen(),
      EmployerProfileScreen(),
    ];

    final currentScreens = isEmployer ? employerScreens : studentScreens;
    final safeIndex = _currentIndex.clamp(0, currentScreens.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: currentScreens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: safeIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: isEmployer
              ? const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard_rounded),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.add_circle_outline),
                    activeIcon: Icon(Icons.add_circle_rounded),
                    label: 'Post Job',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline_rounded),
                    activeIcon: Icon(Icons.people_rounded),
                    label: 'Applicants',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_2_outlined),
                    activeIcon: Icon(Icons.inventory_2_rounded),
                    label: 'Packs',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.business_outlined),
                    activeIcon: Icon(Icons.business_rounded),
                    label: 'Company',
                  ),
                ]
              : const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.work_outline_rounded),
                    activeIcon: Icon(Icons.work_rounded),
                    label: 'Jobs Feed',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment_outlined),
                    activeIcon: Icon(Icons.assignment_rounded),
                    label: 'Applications',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet_outlined),
                    activeIcon: Icon(Icons.account_balance_wallet_rounded),
                    label: 'Wallet',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline_rounded),
                    activeIcon: Icon(Icons.chat_bubble_rounded),
                    label: 'Chat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline_rounded),
                    activeIcon: Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                ],
        ),
      ),
    );
  }
}
