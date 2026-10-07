import 'package:flutter/material.dart';

class AppTheme {
  static const Color twitterBlue = Color(0xFF1DA1F2);
  static const Color twitterDarkBlue = Color(0xFF1A91DA);
  static const Color twitterBlack = Color(0xFF14171A);
  static const Color twitterDarkGray = Color(0xFF657786);
  static const Color twitterLightGray = Color(0xFFAAB8C2);
  static const Color twitterExtraLightGray = Color(0xFFE1E8ED);
  static const Color twitterExtraExtraLightGray = Color(0xFFF5F8FA);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: twitterBlue,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: twitterBlack,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: twitterBlue),
        titleTextStyle: TextStyle(
          color: twitterBlack,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: twitterBlue,
        secondary: twitterDarkBlue,
        surface: Colors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: twitterExtraLightGray,
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: twitterBlue,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: twitterBlack),
        bodyMedium: TextStyle(color: twitterBlack),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: twitterBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: twitterBlue,
      scaffoldBackgroundColor: twitterBlack,
      appBarTheme: const AppBarTheme(
        backgroundColor: twitterBlack,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        iconTheme: IconThemeData(color: twitterBlue),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: twitterBlue,
        secondary: twitterDarkBlue,
        surface: twitterBlack,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF38444D),
        thickness: 1,
        space: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: twitterBlue,
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: twitterBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      useMaterial3: true,
    );
  }
}