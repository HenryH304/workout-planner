import 'package:flutter/material.dart';
import 'screens/main_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Color scheme based on design
  static const Color primaryBlue = Color(0xFF3B5BDB);
  static const Color lightBackground = Color(0xFFF0F0F8);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);
  static const Color textGray = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Planner',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          surface: cardWhite,
          onSurface: textDark,
          surfaceContainerHighest: lightBackground,
        ),
        scaffoldBackgroundColor: lightBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: lightBackground,
          foregroundColor: textDark,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: cardWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: cardWhite,
          selectedColor: textDark,
          labelStyle: const TextStyle(color: textGray),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: cardWhite,
          selectedItemColor: primaryBlue,
          unselectedItemColor: textGray,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        listTileTheme: const ListTileThemeData(
          textColor: textDark,
          subtitleTextStyle: TextStyle(color: textGray),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: textDark, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: textDark, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: textDark),
          bodyMedium: TextStyle(color: textGray),
        ),
      ),
      home: const MainShell(),
    );
  }
}
