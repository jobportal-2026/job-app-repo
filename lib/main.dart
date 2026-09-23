import 'package:flutter/material.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

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

class BridgoApp extends StatelessWidget {
  const BridgoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final router = createRouter(authProvider);

    return MaterialApp.router(
      title: 'Bridgo Job Portal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
