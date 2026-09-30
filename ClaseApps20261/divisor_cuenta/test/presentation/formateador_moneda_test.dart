import 'package:divisor_cuenta/presentation/formateador_moneda.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formateador = FormateadorMoneda();

  test('siempre muestra 2 decimales con punto y sin símbolo', () {
    expect(formateador.formatear(2750), '27.50');
    expect(formateador.formatear(400), '4.00');
    expect(formateador.formatear(5), '0.05');
    expect(formateador.formatear(0), '0.00');
    expect(formateador.formatear(123456), '1234.56');
  });
}
