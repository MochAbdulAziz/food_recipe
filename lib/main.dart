import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/home/home_cubit.dart';
import 'bloc/auth/auth_cubit.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/meal_plan/meal_plan_cubit.dart';
import 'bloc/shopping/shopping_cubit.dart';
import 'data/api_client.dart';
import 'data/api_recipe_source.dart';
import 'data/auth_service.dart';
import 'data/local_storage.dart';
import 'data/sync_service.dart';
import 'screens/main_screen.dart';
import 'screens/onboarding_screen.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.init();

  final authService = MockAuthService();
  await authService.init();

  runApp(MainApp(authService: authService));
}

class MainApp extends StatelessWidget {
  final AuthService authService;
  const MainApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>.value(value: authService),
        RepositoryProvider<SyncService>(
          create: (_) => SyncService(authService: authService),
        ),
      ],
      child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(authService)..checkAuth(),
        ),
        BlocProvider<HomeCubit>(
          create: (_) =>
              HomeCubit(ApiRecipeSource(ApiClient()))..loadData(),
        ),
        BlocProvider<ShoppingCubit>(
          create: (_) => ShoppingCubit(),
        ),
        BlocProvider<MealPlanCubit>(
          create: (_) => MealPlanCubit(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Food App',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          primaryColor: AppColors.primary,
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.primary,
            surface: AppColors.cardBackground,
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            ThemeData.light().textTheme,
          ).apply(
            bodyColor: AppColors.textDark,
            displayColor: AppColors.textDark,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            elevation: 0,
            toolbarTextStyle: TextStyle(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        home: BlocConsumer<AuthCubit, AuthState>(
          // Rebuild on every auth state change
          listenWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
          listener: (context, state) {
            // handled by builder
          },
          builder: (context, state) {
            if (state is AuthInitial || state is AuthLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (state is AuthAuthenticated) {
              return const MainScreen();
            }
            return const OnboardingScreen();
          },
        ),
      ),
    ),
    );
  }
}
