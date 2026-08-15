import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Builds the app's [ThemeData] for both brightness modes from the
/// brand tokens in [AppColors]/[AppTypography]/[AppRadii].
///
/// Both schemes are mapped by hand from real brand values (not
/// [ColorScheme.fromSeed]) because the web app defines exact colors for
/// every role in both modes — synthesizing them from a single seed would
/// drift from the real brand instead of matching it.
abstract final class AppTheme {
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightPrimary,
    onPrimary: AppColors.lightPrimaryInk,
    primaryContainer: AppColors.lightPrimarySoft,
    onPrimaryContainer: AppColors.lightPrimaryDeep,
    secondary: AppColors.lightInkSoft,
    onSecondary: AppColors.lightSurface,
    secondaryContainer: AppColors.lightSurface2,
    onSecondaryContainer: AppColors.lightInk,
    tertiary: AppColors.lightAccent,
    onTertiary: Colors.white,
    tertiaryContainer: AppColors.lightAccentSoft,
    onTertiaryContainer: AppColors.lightAccentDeep,
    error: AppColors.lightError,
    onError: AppColors.lightOnError,
    errorContainer: AppColors.lightErrorContainer,
    onErrorContainer: AppColors.lightOnErrorContainer,
    surface: AppColors.lightBg,
    onSurface: AppColors.lightInk,
    surfaceDim: AppColors.lightSurface2,
    surfaceBright: AppColors.lightSurface,
    surfaceContainerLowest: AppColors.lightSurface,
    surfaceContainerLow: AppColors.lightSurface2,
    surfaceContainer: AppColors.lightSurface2,
    surfaceContainerHigh: AppColors.lightSurface2,
    surfaceContainerHighest: AppColors.lightSurface2,
    onSurfaceVariant: AppColors.lightInkSoft,
    outline: AppColors.lightLine,
    outlineVariant: AppColors.lightLine,
    inverseSurface: AppColors.darkSurface,
    onInverseSurface: AppColors.darkInk,
    inversePrimary: AppColors.darkPrimary,
    surfaceTint: AppColors.lightPrimary,
    scrim: Colors.black,
    shadow: Colors.black,
  );

  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkPrimaryInk,
    primaryContainer: AppColors.darkPrimarySoft,
    onPrimaryContainer: AppColors.darkPrimary,
    secondary: AppColors.darkInkSoft,
    onSecondary: AppColors.darkSurface,
    secondaryContainer: AppColors.darkSurface2,
    onSecondaryContainer: AppColors.darkInk,
    tertiary: AppColors.darkAccent,
    onTertiary: AppColors.darkBg,
    tertiaryContainer: AppColors.darkAccentSoft,
    onTertiaryContainer: AppColors.darkAccent,
    error: AppColors.darkError,
    onError: AppColors.darkOnError,
    errorContainer: AppColors.darkErrorContainer,
    onErrorContainer: AppColors.darkOnErrorContainer,
    surface: AppColors.darkBg,
    onSurface: AppColors.darkInk,
    surfaceDim: AppColors.darkBg,
    surfaceBright: AppColors.darkSurface2,
    surfaceContainerLowest: AppColors.darkSurface,
    surfaceContainerLow: AppColors.darkSurface2,
    surfaceContainer: AppColors.darkSurface2,
    surfaceContainerHigh: AppColors.darkSurface2,
    surfaceContainerHighest: AppColors.darkSurface2,
    onSurfaceVariant: AppColors.darkInkSoft,
    outline: AppColors.darkLine,
    outlineVariant: AppColors.darkLine,
    inverseSurface: AppColors.lightSurface,
    onInverseSurface: AppColors.lightInk,
    inversePrimary: AppColors.lightPrimary,
    surfaceTint: AppColors.darkPrimary,
    scrim: Colors.black,
    shadow: Colors.black,
  );

  static ThemeData light() => _build(_lightScheme);

  static ThemeData dark() => _build(_darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    final TextTheme textTheme = TextTheme(
      displayLarge: AppTypography.displayLg(scheme.onSurface),
      headlineLarge: AppTypography.headlineLgMobile(scheme.onSurface),
      headlineMedium: AppTypography.headlineMd(scheme.onSurface),
      bodyLarge: AppTypography.bodyLg(scheme.onSurface),
      bodyMedium: AppTypography.bodyMd(scheme.onSurfaceVariant),
      labelLarge: AppTypography.button(scheme.onPrimary),
      labelMedium: AppTypography.labelMd(scheme.secondary),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.xlRadius,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadii.xlRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.xlRadius,
          borderSide: BorderSide(color: scheme.primaryContainer, width: 2),
        ),
        hintStyle: AppTypography.bodyMd(scheme.onSurfaceVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(56),
          textStyle: AppTypography.button(scheme.onPrimary),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.xlRadius),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.secondary,
          textStyle: AppTypography.labelMd(scheme.secondary),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.xxlRadius),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.headlineMd(scheme.onSurface),
      ),
    );
  }
}
