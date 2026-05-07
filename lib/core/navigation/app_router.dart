import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/medicine/screens/add_medicine_screen.dart';
import '../constants/app_colors.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter build(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: HomeScreen.routeName,
      refreshListenable: authProvider,
      redirect: (context, state) {
        if (authProvider.isInitializing) return SplashScreen.routeName;

        final isAuthRoute = state.matchedLocation == LoginScreen.routeName ||
            state.matchedLocation == RegisterScreen.routeName;
        final isSplash = state.matchedLocation == SplashScreen.routeName;

        if (!authProvider.isAuthenticated) {
          return isAuthRoute ? null : LoginScreen.routeName;
        }

        if (isAuthRoute || isSplash) return HomeScreen.routeName;
        return null;
      },
      routes: [
        GoRoute(
          path: SplashScreen.routeName,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: LoginScreen.routeName,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: RegisterScreen.routeName,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: HomeScreen.routeName,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AddMedicineScreen.routeName,
          builder: (context, state) => const AddMedicineScreen(),
        ),
        GoRoute(
          path: '${AddMedicineScreen.routeName}/:id',
          builder: (context, state) {
            return AddMedicineScreen(medicineId: state.pathParameters['id']);
          },
        ),
      ],
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const routeName = '/splash';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.rose),
      ),
    );
  }
}
