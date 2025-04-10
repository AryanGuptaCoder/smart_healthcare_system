import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smart_healthcare_system/providers/auth_provider.dart';
import 'package:smart_healthcare_system/screens/auth/login_screen.dart';
import 'package:smart_healthcare_system/screens/auth/signup_screen.dart';
import 'package:smart_healthcare_system/screens/dashboard/dashboard_screen.dart';
import 'package:smart_healthcare_system/screens/device/device_pairing_screen.dart';
import 'package:smart_healthcare_system/screens/health/health_details_screen.dart';
import 'package:smart_healthcare_system/screens/insights/insights_screen.dart';
import 'package:smart_healthcare_system/screens/meditation/meditation_screen.dart';
import 'package:smart_healthcare_system/screens/onboarding/onboarding_screen.dart';
import 'package:smart_healthcare_system/screens/profile/profile_screen.dart';
import 'package:smart_healthcare_system/screens/splash_screen.dart';
import 'package:smart_healthcare_system/utils/app_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Healthcare System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/device-pairing': (context) => const DevicePairingScreen(),
        '/health-details': (context) => const HealthDetailsScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/meditation': (context) => const MeditationScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return const SplashScreen();
          } else if (authProvider.isAuthenticated) {
            return const DashboardScreen();
          } else {
            return const OnboardingScreen();
          }
        },
      ),
    );
  }
}