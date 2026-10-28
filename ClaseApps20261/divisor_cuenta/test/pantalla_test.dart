import 'package:divisor_cuenta/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Registra los tres escenarios de pantalla del punto 9.3 del deber.
/// No recibe ni devuelve valores; una expectativa incumplida falla la prueba.
void main() {
  testWidgets('100, 4 personas y 10 % muestran 27.50 al calcular', (
    tester,
  ) async {
    await tester.pumpWidget(construirApp());

    await tester.enterText(find.byKey(const Key('campo_monto')), '100');
    await tester.enterText(find.byKey(const Key('campo_personas')), '4');
    await tester.enterText(find.byKey(const Key('campo_propina')), '10');
    await tester.pump();
    await tester.ensureVisible(find.text('Calcular'));
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();

    expect(find.text('27.50'), findsOneWidget);
  });

  testWidgets('50 y 0 personas muestran un error sin resultado', (tester) async {
    await tester.pumpWidget(construirApp());

    await tester.enterText(find.byKey(const Key('campo_monto')), '50');
    await tester.enterText(find.byKey(const Key('campo_personas')), '0');
    await tester.pump();
    await tester.ensureVisible(find.text('Calcular'));
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();

    expect(find.text('Debe haber al menos una persona'), findsOneWidget);
    expect(find.byKey(const Key('texto_resultado')), findsNothing);
    expect(find.text('Cada persona paga'), findsNothing);
  });

  testWidgets('el monto abc muestra Monto inválido al calcular', (tester) async {
    await tester.pumpWidget(construirApp());

    await tester.enterText(find.byKey(const Key('campo_monto')), 'abc');
    await tester.enterText(find.byKey(const Key('campo_personas')), '4');
    await tester.pump();
    await tester.ensureVisible(find.text('Calcular'));
    await tester.tap(find.text('Calcular'));
    await tester.pumpAndSettle();

    expect(find.text('Monto inválido'), findsOneWidget);
  });
}
