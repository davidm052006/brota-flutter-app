/// 8px-base spacing scale from DESIGN.md `spacing` tokens.
abstract final class AppSpacing {
  static const double base = 8;
  static const double xs = base * 0.5; // 4
  static const double sm = base; // 8
  static const double md = base * 2; // 16
  static const double lg = base * 3; // 24
  static const double xl = base * 4; // 32
  static const double xxl = base * 6; // 48

  /// Screen edge margin on mobile viewports.
  static const double screenMargin = 20;

  /// Gutter between grid columns / large sections.
  static const double gutter = 24;

  /// Widest a form column grows before it stops stretching. Past this the
  /// input rows read as a banner instead of a field.
  static const double maxFormWidth = 420;

  /// Widest the general content column grows on a desktop-sized window.
  static const double maxContentWidth = 640;
}
