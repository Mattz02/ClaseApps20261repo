import 'package:divisor_cuenta/data/redondeo_exacto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const redondeo = RedondeoExacto();

  test('100.00 con 10 % entre 4 da 2750 centavos (27.50)', () {
    expect(redondeo.redondear(numerador: 110000000, denominador: 40000), 2750);
  });

  test('90.00 entre 3 da 3000 centavos (30.00)', () {
    expect(redondeo.redondear(numerador: 90000000, denominador: 30000), 3000);
  });

  test('10.00 entre 3 da 333 centavos (3.33)', () {
    expect(redondeo.redondear(numerador: 10000000, denominador: 30000), 333);
  });

  test('la mitad de un centavo sube (333.5 → 334)', () {
    expect(redondeo.redondear(numerador: 667, denominador: 2), 334);
  });

  test('cero da cero', () {
    expect(redondeo.redondear(numerador: 0, denominador: 1), 0);
  });
}
