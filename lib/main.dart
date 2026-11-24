import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/ride_requests_screen.dart';
import 'screens/ride_history_screen.dart';
import 'screens/earnings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/settings_screen.dart';
import 'services/auth_service.dart';
import 'services/driver_service.dart';
import 'services/location_service.dart';
import 'services/notification_service.dart';
import 'services/socket_service.dart';
import 'utils/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const RydoCaptainApp());
}

class RydoCaptainApp extends StatelessWidget {
  const RydoCaptainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => DriverService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        ChangeNotifierProvider(create: (_) => SocketService()),
      ],
      child: MaterialApp(
        title: 'Rydo Captain',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/ride-requests': (context) => const RideRequestsScreen(),
          '/ride-history': (context) => const RideHistoryScreen(),
          '/earnings': (context) => const EarningsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    final poppinsTextTheme = GoogleFonts.poppinsTextTheme();

    return ThemeData(
      useMaterial3: true,

      // Seed the M3 colour scheme from brand yellow
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        error: AppColors.error,
      ),

      scaffoldBackgroundColor: AppColors.background,
      textTheme: poppinsTextTheme.copyWith(
        displayLarge: GoogleFonts.poppins(
            fontSize: 57, fontWeight: FontWeight.w400, color: AppColors.onSurface),
        displayMedium: GoogleFonts.poppins(
            fontSize: 45, fontWeight: FontWeight.w400, color: AppColors.onSurface),
        headlineLarge: GoogleFonts.poppins(
            fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        headlineMedium: GoogleFonts.poppins(
            fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.onSurface),
        headlineSmall: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        titleLarge: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface),
        titleMedium: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        titleSmall: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.onSurface),
        bodyLarge: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface),
        bodyMedium: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.onSurface),
        bodySmall: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.onSurfaceVariant),
        labelLarge: GoogleFonts.poppins(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.onPrimary),
        labelMedium: GoogleFonts.poppins(
            fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.onSurface),
      ),
      primaryTextTheme: poppinsTextTheme,

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),

      // ── Elevated Button ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          minimumSize: const Size(double.infinity, 52),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Outlined Button ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.dark,
          side: const BorderSide(color: AppColors.outline, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text Button ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.dark,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Input Decoration ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
        prefixIconColor: AppColors.onSurfaceVariant,
        suffixIconColor: AppColors.onSurfaceVariant,
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.dark,
          fontWeight: FontWeight.w500,
        ),
      ),

      // ── Card ────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        labelStyle: GoogleFonts.poppins(fontSize: 12, color: AppColors.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // ── Bottom Navigation Bar ───────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.dark,
        unselectedItemColor: AppColors.onSurfaceVariant,
        selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400),
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // ── Floating Action Button ──────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: StadiumBorder(),
      ),

      // ── SnackBar ────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.dark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
      ),

      // ── Switch ──────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.outlineVariant;
        }),
      ),

      // ── Divider ─────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),

      // ── Icon ────────────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(color: AppColors.onSurfaceVariant, size: 22),
    );
  }
}
