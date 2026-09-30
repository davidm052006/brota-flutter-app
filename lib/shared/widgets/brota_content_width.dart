import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Centers [child] and stops it from stretching past [maxWidth].
///
/// Every layout here is drawn for phone widths, but the app also runs on
/// the web/desktop device, where a maximized window has no upper bound:
/// without this the text fields and buttons grow to the full window and
/// the spacing scale stops matching the design.
class BrotaContentWidth extends StatelessWidget {
  const BrotaContentWidth({
    required this.child,
    super.key,
    this.maxWidth = AppSpacing.maxContentWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
