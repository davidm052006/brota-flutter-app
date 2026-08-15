import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale sourced from the web app's real type system
/// (`MOBILE_DESIGN_BRIEF.md` section 1.4, itself lifted from
/// `frontend/src/index.css`): **Bricolage Grotesque** for display/
/// headline styles (titulares, cifras destacadas), **Plus Jakarta
/// Sans** for everything else (cuerpo, UI, formularios).
///
/// Named after the token's role rather than Flutter's TextTheme roles,
/// since the mobile app only ever needs the mobile-scale entries (e.g.
/// `headlineLgMobile`, never the 40px desktop `headlineLg`).
abstract final class AppTypography {
  static TextStyle _bricolage({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
    required Color color,
  }) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height / fontSize,
      letterSpacing: letterSpacing * fontSize,
      color: color,
    );
  }

  static TextStyle _jakarta({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
    required Color color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height / fontSize,
      letterSpacing: letterSpacing * fontSize,
      color: color,
    );
  }

  static TextStyle displayLg(Color color) => _bricolage(
    fontSize: 56,
    fontWeight: FontWeight.w800,
    height: 64,
    letterSpacing: -0.02,
    color: color,
  );

  static TextStyle headlineLgMobile(Color color) => _bricolage(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40,
    color: color,
  );

  static TextStyle headlineMd(Color color) => _bricolage(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32,
    color: color,
  );

  /// Saludo del dashboard ("Hola, {nombre} 👋"), 30px/800 — valor real
  /// documentado en `MOBILE_DESIGN_BRIEF.md` sección 1.4, no un tamaño
  /// intermedio inventado entre [headlineMd] y [headlineLgMobile].
  static TextStyle greeting(Color color) => _bricolage(
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 38,
    color: color,
  );

  static TextStyle bodyLg(Color color) => _jakarta(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 28,
    color: color,
  );

  static TextStyle bodyMd(Color color) => _jakarta(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24,
    color: color,
  );

  static TextStyle labelMd(Color color) => _jakarta(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20,
    letterSpacing: 0.01,
    color: color,
  );

  static TextStyle button(Color color) => _jakarta(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24,
    color: color,
  );
}
