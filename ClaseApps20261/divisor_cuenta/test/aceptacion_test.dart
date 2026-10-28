// Escenarios de aceptación de specs/001-dividir-cuenta/spec.md, probados sobre
// la app completa armada por construirApp() (la misma composición que main).
import 'package:divisor_cuenta/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const campoMonto = Key('campo_monto');
const campoPersonas = Key('campo_personas');
const campoPropina = Key('campo_propina');
const botonCalcular = Key('boton_calcular');
const textoResultado = Key('texto_resultado');

/// Escribe los tres campos, elige el modo (si se indica) y toca "Calcular".
Future<void> calcular(
  WidgetTester tester, {
  required String monto,
  required String personas,
  String propina = '',
  String? modo,
}) async {
  await escribirDatos(
    tester,
    monto: monto,
    personas: personas,
    propina: propina,
  );
  if (modo != null) {
    await tester.tap(find.text(modo));
    await tester.pump();
  }
  await tester.ensureVisible(find.byKey(botonCalcular));
  await tester.tap(find.byKey(botonCalcular));
  await tester.pump();
}

/// Escribe los tres campos sin tocar "Calcular".
Future<void> escribirDatos(
  WidgetTester tester, {
  required String monto,
  required String personas,
  String propina = '',
}) async {
  await tester.enterText(find.byKey(campoMonto), monto);
  await tester.enterText(find.byKey(campoPersonas), personas);
  await tester.enterText(find.byKey(campoPropina), propina);
  await tester.pump();
}

/// El monto por persona que se ve en pantalla, o null si no hay resultado.
String? resultadoMostrado(WidgetTester tester) {
  final encontrado = find.byKey(textoResultado);
  if (encontrado.evaluate().isEmpty) return null;
  return tester.widget<Text>(encontrado).data;
}

void main() {
  group('US1 - calcular cuánto paga cada persona', () {
    testWidgets('escenario 1: 100.00, 4 personas, 10 %, exacto → 27.50', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await calcular(tester, monto: '100.00', personas: '4', propina: '10');
      expect(resultadoMostrado(tester), '27.50');
    });

    testWidgets('escenario 2: 90.00, 3 personas, 0 %, exacto → 30.00', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await calcular(tester, monto: '90.00', personas: '3', propina: '0');
      expect(resultadoMostrado(tester), '30.00');
    });

    testWidgets('escenario 5: 10.00, 3 personas, 0 %, exacto → 3.33', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await calcular(tester, monto: '10.00', personas: '3', propina: '0');
      expect(resultadoMostrado(tester), '3.33');
    });

    testWidgets('FR-003: sin tocar "Calcular" no hay resultado', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await escribirDatos(
        tester,
        monto: '100.00',
        personas: '4',
        propina: '10',
      );
      expect(resultadoMostrado(tester), isNull);
    });

    testWidgets(
      'FR-014: cambiar un dato después de calcular oculta el resultado',
      (tester) async {
        await tester.pumpWidget(construirApp());
        await calcular(tester, monto: '100.00', personas: '4', propina: '10');
        expect(resultadoMostrado(tester), '27.50');

        await tester.enterText(find.byKey(campoPersonas), '5');
        await tester.pump();
        expect(resultadoMostrado(tester), isNull);
      },
    );
  });

  group('US2 - avisar cuando los datos no son válidos', () {
    testWidgets('escenario 3: 50.00 y 0 personas → mensaje y sin resultado', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await calcular(tester, monto: '50.00', personas: '0');

      expect(find.text('Debe haber al menos una persona'), findsOneWidget);
      expect(resultadoMostrado(tester), isNull);
    });

    testWidgets('escenario 4: monto "abc" → "Monto inválido" y sin resultado', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await calcular(tester, monto: 'abc', personas: '2', propina: '10');

      expect(find.text('Monto inválido'), findsOneWidget);
      expect(resultadoMostrado(tester), isNull);
    });

    testWidgets('varios campos inválidos muestran todos sus mensajes', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await calcular(tester, monto: 'abc', personas: 'dos', propina: '-1');

      expect(find.text('Monto inválido'), findsOneWidget);
      expect(find.text('Número de personas inválido'), findsOneWidget);
      expect(find.text('Propina inválida'), findsOneWidget);
      expect(resultadoMostrado(tester), isNull);
    });

    testWidgets('al corregir y volver a calcular aparece el resultado', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await calcular(tester, monto: 'abc', personas: '4', propina: '10');
      expect(find.text('Monto inválido'), findsOneWidget);

      await calcular(tester, monto: '100.00', personas: '4', propina: '10');
      expect(find.text('Monto inválido'), findsNothing);
      expect(resultadoMostrado(tester), '27.50');
    });

    testWidgets('FR-014: cambiar un dato borra los mensajes de error', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await calcular(tester, monto: 'abc', personas: '4');
      expect(find.text('Monto inválido'), findsOneWidget);

      await tester.enterText(find.byKey(campoMonto), '100');
      await tester.pump();
      expect(find.text('Monto inválido'), findsNothing);
    });
  });

  group('US3 - redondear hacia arriba', () {
    testWidgets('el selector ofrece "Exacto" y "Hacia arriba"', (tester) async {
      await tester.pumpWidget(construirApp());
      final selector = find.byKey(const Key('selector_modo'));

      expect(
        find.descendant(of: selector, matching: find.text('Exacto')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: selector, matching: find.text('Hacia arriba')),
        findsOneWidget,
      );
    });

    testWidgets('escenario 6: 10.00, 3 personas, 0 %, hacia arriba → 4.00', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await calcular(
        tester,
        monto: '10.00',
        personas: '3',
        propina: '0',
        modo: 'Hacia arriba',
      );
      expect(resultadoMostrado(tester), '4.00');
    });

    testWidgets('90.00, 3 personas, 0 %, hacia arriba → 30.00 (no sube)', (
      tester,
    ) async {
      await tester.pumpWidget(construirApp());
      await calcular(
        tester,
        monto: '90.00',
        personas: '3',
        propina: '0',
        modo: 'Hacia arriba',
      );
      expect(resultadoMostrado(tester), '30.00');
    });

    testWidgets(
      'FR-014: cambiar de modo después de calcular oculta el resultado',
      (tester) async {
        await tester.pumpWidget(construirApp());
        await calcular(tester, monto: '10.00', personas: '3', propina: '0');
        expect(resultadoMostrado(tester), '3.33');

        await tester.tap(find.text('Hacia arriba'));
        await tester.pump();
        expect(resultadoMostrado(tester), isNull);
      },
    );
  });
}
