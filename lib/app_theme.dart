import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  static const Color _gold = Color(0xFFD4A843);
  static const Color _burgundy = Color(0xFF6B1C1C);
  static const Color _burgundyDark = Color(0xFF3D0F0F);
  static const Color _darkBg = Color(0xFF0A090C);
  static const Color _darkSurface = Color(0xFF141218);
  static const Color _darkCard = Color(0xFF1C1920);
  static const Color _warmWhite = Color(0xFFF5F0E8);
  static const Color _parchment = Color(0xFFEFE5D0);

  static const Color _morningAccent = Color(0xFFE65100);
  static const Color _middayAccent = Color(0xFFD4A843);
  static const Color _eveningAccent = Color(0xFF7B3FCB);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBg,
      colorScheme: ColorScheme.dark(
        primary: _gold,
        onPrimary: _darkBg,
        secondary: _burgundy,
        onSecondary: _warmWhite,
        tertiary: const Color(0xFF9B7A3C),
        surface: _darkSurface,
        onSurface: _warmWhite.withValues(alpha: 0.95),
        surfaceContainerHighest: _darkCard,
        outline: _warmWhite.withValues(alpha: 0.1),
        outlineVariant: _warmWhite.withValues(alpha: 0.05),
        error: const Color(0xFFCF6679),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBg,
        foregroundColor: _warmWhite,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _warmWhite,
          letterSpacing: 0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: _warmWhite.withValues(alpha: 0.07),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkSurface,
        indicatorColor: _gold.withValues(alpha: 0.15),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _gold,
              letterSpacing: 0.3,
            );
          }
          return TextStyle(
            fontSize: 11,
            color: _warmWhite.withValues(alpha: 0.4),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _gold, size: 26);
          }
          return IconThemeData(
              color: _warmWhite.withValues(alpha: 0.4), size: 26);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(_gold),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _gold.withValues(alpha: 0.25);
          }
          return _warmWhite.withValues(alpha: 0.12);
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: _darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _warmWhite.withValues(alpha: 0.1)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: _warmWhite.withValues(alpha: 0.06),
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 44,
          fontWeight: FontWeight.w800,
          color: _warmWhite,
          letterSpacing: 0.3,
          height: 1.1,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: _warmWhite,
          letterSpacing: 0.2,
        ),
        headlineLarge: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _warmWhite,
          letterSpacing: 0.2,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _warmWhite,
        ),
        titleLarge: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: _warmWhite,
          letterSpacing: 0.2,
        ),
        titleMedium: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _warmWhite,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: _warmWhite.withValues(alpha: 0.9),
          height: 1.75,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _warmWhite.withValues(alpha: 0.6),
        ),
        labelLarge: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _gold,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _warmWhite.withValues(alpha: 0.4),
          letterSpacing: 0.8,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _warmWhite.withValues(alpha: 0.3),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _parchment,
      colorScheme: ColorScheme.light(
        primary: _burgundy,
        onPrimary: _warmWhite,
        secondary: _gold,
        onSecondary: _burgundyDark,
        tertiary: const Color(0xFF9B7A3C),
        surface: _warmWhite,
        surfaceContainerHighest: _parchment,
        outline: _burgundy.withValues(alpha: 0.12),
        outlineVariant: _burgundy.withValues(alpha: 0.06),
        error: const Color(0xFFB00020),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _parchment,
        foregroundColor: _burgundyDark,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _burgundyDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: _warmWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: _burgundy.withValues(alpha: 0.08),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _warmWhite,
        indicatorColor: _burgundy.withValues(alpha: 0.1),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _burgundy,
              letterSpacing: 0.3,
            );
          }
          return TextStyle(
            fontSize: 11,
            color: _burgundy.withValues(alpha: 0.4),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _burgundy, size: 26);
          }
          return IconThemeData(
              color: _burgundy.withValues(alpha: 0.4), size: 26);
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all(_burgundy),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _burgundy.withValues(alpha: 0.2);
          }
          return _burgundy.withValues(alpha: 0.1);
        }),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: _warmWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: _burgundy.withValues(alpha: 0.1)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: _burgundy.withValues(alpha: 0.06),
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 44,
          fontWeight: FontWeight.w800,
          color: _burgundyDark,
          letterSpacing: 0.3,
          height: 1.1,
        ),
        displayMedium: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: _burgundyDark,
          letterSpacing: 0.2,
        ),
        headlineLarge: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: _burgundyDark,
          letterSpacing: 0.2,
        ),
        headlineMedium: const TextStyle(
          fontFamily: 'Georgia',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: _burgundyDark,
        ),
        titleLarge: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: _burgundyDark,
          letterSpacing: 0.2,
        ),
        titleMedium: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _burgundyDark,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 17,
          fontWeight: FontWeight.w400,
          color: _burgundyDark.withValues(alpha: 0.85),
          height: 1.75,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: _burgundy.withValues(alpha: 0.6),
        ),
        labelLarge: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: _burgundy,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _burgundy.withValues(alpha: 0.4),
          letterSpacing: 0.8,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _burgundy.withValues(alpha: 0.3),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  static Color get morningAccent => _morningAccent;
  static Color get middayAccent => _middayAccent;
  static Color get eveningAccent => _eveningAccent;
}
