import 'package:divisor_cuenta/logic/calculadora.dart';
import 'package:flutter_test/flutter_test.dart';

int suma(List<int> valores) => valores.fold<int>(0, (a, b) => a + b);

void main() {
  group('parsearCentavos', () {
    test('acepta coma o punto como decimal', () {
      expect(parsearCentavos('12,50'), 1250);
      expect(parsearCentavos('12.5'), 1250);
      expect(parsearCentavos(' 7 '), 700);
    });

    test('vacío es cero e inválido es null', () {
      expect(parsearCentavos(''), 0);
      expect(parsearCentavos('abc'), isNull);
      expect(parsearCentavos('1.2.3'), isNull);
      expect(parsearCentavos('-5'), isNull);
    });
  });

  test('formatearCentavos', () {
    expect(formatearCentavos(123456), '\$1234.56');
    expect(formatearCentavos(5), '\$0.05');
    expect(formatearCentavos(0), '\$0.00');
  });

  group('dividirPartesIguales', () {
    test('reparte los centavos sobrantes sin perder dinero', () {
      final r = dividirPartesIguales(
        subtotal: 10000,
        personas: 3,
        propinaPorcentaje: 0,
      );
      expect(r.porPersona, [3334, 3333, 3333]);
      expect(suma(r.porPersona), r.total);
    });

    test('suma la propina', () {
      final r = dividirPartesIguales(
        subtotal: 10000,
        personas: 2,
        propinaPorcentaje: 10,
      );
      expect(r.propina, 1000);
      expect(r.total, 11000);
      expect(r.porPersona, [5500, 5500]);
    });
  });

  group('dividirPorConsumo', () {
    test('la propina se reparte en proporción a lo consumido', () {
      final r = dividirPorConsumo(
        consumos: [3000, 1000],
        propinaPorcentaje: 10,
      );
      expect(r.subtotal, 4000);
      expect(r.propina, 400);
      expect(r.porPersona, [3300, 1100]);
    });

    test('la suma siempre cuadra con el total', () {
      final r = dividirPorConsumo(
        consumos: [333, 333, 334, 1999, 1],
        propinaPorcentaje: 17,
      );
      expect(suma(r.porPersona), r.total);
    });

    test('sin consumos nadie paga', () {
      final r = dividirPorConsumo(consumos: [0, 0], propinaPorcentaje: 10);
      expect(r.porPersona, [0, 0]);
    });
  });
}
