import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'config/app_colors.dart';
import 'config/app_text_styles.dart';
import 'config/app_dimensions.dart';
import 'providers/user_provider.dart';
import 'providers/booking_cart_provider.dart';
import 'screens/splash_screen.dart';
import './utils/http_overrides_Version2.dart';
import 'providers/booking_provider.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  HttpOverrides.global = MyHttpOverrides();
  
  // Set orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BookingCartProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'Khách sạn Thanh Trà',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Primary colors
          primaryColor: AppColors.primary,
          primaryColorDark: AppColors.primaryDark,
          primaryColorLight: AppColors.primaryLight,
          
          // Color scheme
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            secondary: AppColors.secondary,
            surface: AppColors.surface,
            error: AppColors.error,
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: AppColors.textPrimary,
            onError: Colors.white,
          ),

          // Scaffold
          scaffoldBackgroundColor: AppColors.background,

          // AppBar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            iconTheme: IconThemeData(color: Colors.white),
          ),

          // Card theme
          cardTheme: CardThemeData(
            color: AppColors.cardBg,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            ),
          ),

          // Button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              textStyle: AppTextStyles.button,
            ),
          ),

          // Text button theme
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTextStyles.button.copyWith(fontSize: 14),
            ),
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.md,
            ),
          ),

          // Divider theme
          dividerTheme: const DividerThemeData(
            color: AppColors.divider,
            thickness: 1,
            space: 1,
          ),

          // Bottom navigation bar theme
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            elevation: 8,
          ),

          // Icon theme
          iconTheme: const IconThemeData(
            color: AppColors.textPrimary,
          ),

          // Text theme
          textTheme: const TextTheme(
            displayLarge: AppTextStyles.display1,
            headlineLarge: AppTextStyles.h1,
            headlineMedium: AppTextStyles.h2,
            headlineSmall: AppTextStyles.h3,
            titleLarge: AppTextStyles.h4,
            bodyLarge: AppTextStyles.body1,
            bodyMedium: AppTextStyles.body2,
            bodySmall: AppTextStyles.caption,
            labelLarge: AppTextStyles.button,
          ),

          // Font family
          fontFamily: AppTextStyles.fontFamily,

          // Use Material 3
          useMaterial3: true,

          // Visual density
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}