import 'package:divisor_cuenta/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('divide en partes iguales con propina', (tester) async {
    await tester.pumpWidget(const DivisorCuentaApp());

    await tester.enterText(
      find.widgetWithText(TextField, 'Total de la cuenta'),
      '100',
    );
    await tester.pump();

    // 100 + 10% de propina (por defecto) entre 2 personas.
    expect(find.text('\$55.00'), findsNWidgets(3));
    expect(find.text('\$110.00'), findsOneWidget);

    await tester.ensureVisible(find.text('Agregar persona'));
    await tester.tap(find.text('Agregar persona'));
    await tester.pump();

    expect(find.text('Personas (3)'), findsOneWidget);
    expect(find.text('\$36.67'), findsNWidgets(3));
    expect(find.text('\$36.66'), findsOneWidget);
  });

  testWidgets('divide por consumo', (tester) async {
    await tester.pumpWidget(const DivisorCuentaApp());

    await tester.tap(find.text('Por consumo'));
    await tester.pump();

    final consumos = find.widgetWithText(TextField, 'Consumió');
    expect(consumos, findsNWidgets(2));

    await tester.enterText(consumos.at(0), '30');
    await tester.enterText(consumos.at(1), '10');
    await tester.pump();

    expect(find.text('\$33.00'), findsOneWidget);
    expect(find.text('\$11.00'), findsOneWidget);
    expect(find.text('\$44.00'), findsOneWidget);
  });
}
