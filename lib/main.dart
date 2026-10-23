import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/config/app_router.dart';
import 'core/network/api_client.dart';
import 'core/network/secure_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/jobs/data/datasources/jobs_remote_data_source.dart';
import 'features/jobs/data/repositories/jobs_repository_impl.dart';
import 'features/jobs/presentation/providers/jobs_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final secureStorageService = SecureStorageService();
  final apiClient = ApiClient(secureStorageService: secureStorageService);
  final authRemoteDataSource = AuthRemoteDataSource(apiClient: apiClient);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    secureStorageService: secureStorageService,
  );

  final jobsRemoteDataSource = JobsRemoteDataSource(apiClient: apiClient);
  final jobsRepository = JobsRepositoryImpl(
    remoteDataSource: jobsRemoteDataSource,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(authRepository: authRepository)..checkAuthStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => JobsProvider(jobsRepository: jobsRepository),
        ),
      ],
      child: const BridgoApp(),
    ),
  );
}

class BridgoApp extends StatefulWidget {
  const BridgoApp({super.key});

  @override
  State<BridgoApp> createState() => _BridgoAppState();
}

class _BridgoAppState extends State<BridgoApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bridgo Job Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}
