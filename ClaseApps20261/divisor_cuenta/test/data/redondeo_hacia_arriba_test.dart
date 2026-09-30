import 'package:divisor_cuenta/data/redondeo_hacia_arriba.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const redondeo = RedondeoHaciaArriba();

  test('10.00 entre 3 sube a 400 centavos (4.00)', () {
    expect(redondeo.redondear(numerador: 10000000, denominador: 30000), 400);
  });

  test('un monto que ya es entero no sube (90.00 entre 3 → 30.00)', () {
    expect(redondeo.redondear(numerador: 90000000, denominador: 30000), 3000);
  });

  test('27.50 sube a 28.00', () {
    expect(redondeo.redondear(numerador: 110000000, denominador: 40000), 2800);
  });

  test('un solo centavo de más ya sube al entero siguiente', () {
    expect(redondeo.redondear(numerador: 1, denominador: 1), 100);
  });

  test('cero da cero', () {
    expect(redondeo.redondear(numerador: 0, denominador: 1), 0);
  });
}
