import 'package:brota_flutter_app/shared/widgets/brota_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BrotaTextField renders hint text and accepts input', (
    WidgetTester tester,
  ) async {
    final TextEditingController controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BrotaTextField(
            controller: controller,
            hintText: 'Correo electrónico',
            leadingIcon: Icons.email_outlined,
          ),
        ),
      ),
    );

    expect(find.text('Correo electrónico'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'hola@brota.app');
    expect(controller.text, 'hola@brota.app');
  });
}
