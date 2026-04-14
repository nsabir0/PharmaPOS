import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark Palette (Pixel Perfect to image)
  static const darkScaffoldBg = Color(0xFF000000);
  static const darkSidebarBg = Color(0xFF111111);
  static const darkCardBg = Color(0xFF1A1A1A);
  static const darkProductCardBg = Color(0xFF1E1E1E);
  static const darkTextGrey = Color(0xFF666666);

  static ThemeData getDarkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: darkScaffoldBg,
      cardColor: darkCardBg,
      primaryColor: Colors.white,
      dividerColor: Color(0xFF222222),
      appBarTheme: const AppBarTheme(backgroundColor: darkScaffoldBg, elevation: 0),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    );
  }

  static ThemeData getLightTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Color(0xFFF5F5F5),
      cardColor: Colors.white,
      primaryColor: Colors.blue,
      dividerColor: Colors.grey[300],
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
    );
  }
}
