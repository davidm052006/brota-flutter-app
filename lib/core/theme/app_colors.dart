import 'package:flutter/material.dart';

/// Color tokens lifted verbatim from the sibling web app's real source of
/// truth (`frontend/src/index.css` `:root` / `html.dark` custom
/// properties, documented in `MOBILE_DESIGN_BRIEF.md` section 1.3).
/// Treat this file as the single source of truth for brand color — never
/// hardcode a hex value outside of it.
///
/// This replaces the earlier `design_reference/*/DESIGN.md` ("Organic
/// Growth System") palette, which predates the brief and does not match
/// the web app's actual brand (wrong green, no orange accent, single
/// typeface). See CLAUDE.md "Sistema de marca" for the full rationale.
///
/// `error`/`onError`/`errorContainer`/`onErrorContainer` have no web
/// equivalent — `index.css` defines no danger token (the web's
/// `Button.jsx` `danger` variant falls back to a plain Tailwind red, see
/// brief section 1.6). Standard red-500/red-600 tones are used here.
abstract final class AppColors {
  // --- Light mode (`:root`) ---
  static const Color lightBg = Color(0xFFF4F3EC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurface2 = Color(0xFFEFEEE5);
  static const Color lightInk = Color(0xFF15241B);
  static const Color lightInkSoft = Color(0xFF67756B);
  static const Color lightLine = Color(0xFFE6E4DA);
  static const Color lightPrimary = Color(0xFF21BD68);
  static const Color lightPrimaryDeep = Color(0xFF0E7D43);
  static const Color lightPrimaryInk = Color(0xFFFFFFFF);
  static const Color lightPrimarySoft = Color(0xFFE2F6EC);
  static const Color lightPrimaryGlow = Color(0x4721BD68); // rgba(33,189,104,.28)
  static const Color lightAccent = Color(0xFFE07A42);
  static const Color lightAccentSoft = Color(0xFFFBE8DC);
  static const Color lightAccentDeep = Color(0xFF8A3D14);
  static const Color lightError = Color(0xFFEF4444);
  static const Color lightOnError = Color(0xFFFFFFFF);
  static const Color lightErrorContainer = Color(0xFFFEE2E2);
  static const Color lightOnErrorContainer = Color(0xFF991B1B);

  // --- Dark mode (`html.dark`) ---
  static const Color darkBg = Color(0xFF0C1310);
  static const Color darkSurface = Color(0xFF151F19);
  static const Color darkSurface2 = Color(0xFF1C2A22);
  static const Color darkInk = Color(0xFFEAF3EC);
  static const Color darkInkSoft = Color(0xFF94A69B);
  static const Color darkLine = Color(0xFF27362D);
  static const Color darkPrimary = Color(0xFF34D27D);
  static const Color darkPrimaryDeep = Color(0xFF1FA862);
  static const Color darkPrimaryInk = Color(0xFF04301C);
  static const Color darkPrimarySoft = Color(0xFF16301F);
  static const Color darkPrimaryGlow = Color(0x3834D27D); // rgba(52,210,125,.22)
  static const Color darkAccent = Color(0xFFF0996A);
  static const Color darkAccentSoft = Color(0xFF2C2018);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkOnError = Color(0xFF450A0A);
  static const Color darkErrorContainer = Color(0xFF7F1D1D);
  static const Color darkOnErrorContainer = Color(0xFFFECACA);
}
