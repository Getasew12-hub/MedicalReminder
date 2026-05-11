import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/auth_provider.dart';
import 'features/auth/domain/user_profile_provider.dart';
import 'features/medicine/domain/medicine_provider.dart';
import 'firebase_options.dart';
import 'shared/services/auth_service.dart';
import 'shared/services/database_service.dart';
import 'shared/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  //This connects the app to Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MedicationReminderApp(notificationService: notificationService));
}

class MedicationReminderApp extends StatelessWidget {
  const MedicationReminderApp({
    required this.notificationService,
    super.key,
  });

  final NotificationService notificationService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NotificationService>.value(value: notificationService),
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        Provider<DatabaseService>(
          create: (_) => DatabaseService(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(context.read<AuthService>()),
        ),
        ChangeNotifierProxyProvider<AuthProvider, MedicineProvider>(
          create: (context) => MedicineProvider(
            databaseService: context.read<DatabaseService>(),
            notificationService: notificationService,
          ),
          update: (_, authProvider, medicineProvider) {
            medicineProvider!.bindUser(authProvider.currentUser?.uid);
            return medicineProvider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, UserProfileProvider>(
          create: (context) => UserProfileProvider(
            databaseService: context.read<DatabaseService>(),
            authService: context.read<AuthService>(),
          ),
          update: (_, authProvider, userProfileProvider) {
            userProfileProvider!.bindUser(
              userId: authProvider.currentUser?.uid,
              fallbackEmail: authProvider.currentUser?.email ?? '',
              fallbackName: authProvider.currentUser?.displayName ?? 'Mona',
            );
            return userProfileProvider;
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final router = AppRouter.build(authProvider);
          return MaterialApp.router(
            title: 'Medication Reminder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.light,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
