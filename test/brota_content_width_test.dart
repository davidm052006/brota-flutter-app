import 'package:brota_flutter_app/core/theme/app_spacing.dart';
import 'package:brota_flutter_app/shared/widgets/brota_content_width.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Size> _sizeAt(WidgetTester tester, Size surface, Widget child) async {
  await tester.binding.setSurfaceSize(surface);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    MaterialApp(home: Scaffold(body: BrotaContentWidth(child: child))),
  );

  return tester.getSize(find.byKey(const Key('contenido')));
}

void main() {
  const Widget stretchingChild = SizedBox.expand(key: Key('contenido'));

  testWidgets('no deja crecer el contenido más allá de maxContentWidth en una '
      'ventana de escritorio', (WidgetTester tester) async {
    final Size size = await _sizeAt(
      tester,
      const Size(1600, 900),
      stretchingChild,
    );

    expect(size.width, AppSpacing.maxContentWidth);
  });

  testWidgets('usa todo el ancho disponible en un viewport de teléfono', (
    WidgetTester tester,
  ) async {
    final Size size = await _sizeAt(
      tester,
      const Size(390, 844),
      stretchingChild,
    );

    expect(size.width, 390);
  });
}
