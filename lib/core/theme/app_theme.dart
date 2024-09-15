import 'package:blog_app_clean_architecture/core/theme/app_pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static _border({Color color = AppPallete.borderColor}) => OutlineInputBorder(
      borderSide: BorderSide(color: color, width: 3),
      borderRadius: BorderRadius.circular(10));

  static _borderFocus() => _border(color: AppPallete.gradient2);

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    appBarTheme: const AppBarTheme(backgroundColor: AppPallete.backgroundColor),
    chipTheme: const ChipThemeData(
      color: WidgetStatePropertyAll(
        AppPallete.backgroundColor,
      ),
      side: BorderSide.none,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: _border(),
      contentPadding: const EdgeInsets.all(27),
      enabledBorder: _border(),
      focusedBorder: _borderFocus(),
      errorBorder: _border(color: AppPallete.errorColor),
    ),
  );
}
