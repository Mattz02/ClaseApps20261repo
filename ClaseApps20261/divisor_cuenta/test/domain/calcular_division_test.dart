import 'package:divisor_cuenta/domain/calcular_division.dart';
import 'package:divisor_cuenta/domain/cuenta.dart';
import 'package:divisor_cuenta/domain/estrategia_redondeo.dart';
import 'package:flutter_test/flutter_test.dart';

/// Estrategia de prueba: guarda lo que recibe y devuelve un valor fijo.
class EstrategiaFalsa implements EstrategiaRedondeo {
  EstrategiaFalsa(this.respuesta);

  final int respuesta;
  int? numeradorRecibido;
  int? denominadorRecibido;

  @override
  int redondear({required int numerador, required int denominador}) {
    numeradorRecibido = numerador;
    denominadorRecibido = denominador;
    return respuesta;
  }
}

void main() {
  const calculadora = CalcularDivision();

  test('arma la fracción exacta y se la pasa a la estrategia', () {
    final estrategia = EstrategiaFalsa(2750);
    const cuenta = Cuenta(
      montoCentavos: 10000,
      personas: 4,
      propinaCentesimas: 1000,
    );

    final resultado = calculadora.calcular(cuenta, estrategia);

    // 10000 × (10000 + 1000) / (10000 × 4) = 2750 centavos exactos.
    expect(estrategia.numeradorRecibido, 110000000);
    expect(estrategia.denominadorRecibido, 40000);
    expect(resultado.montoPorPersonaCentavos, 2750);
  });

  test('devuelve lo que decide la estrategia, sin redondear por su cuenta', () {
    final estrategia = EstrategiaFalsa(400);
    const cuenta = Cuenta(
      montoCentavos: 1000,
      personas: 3,
      propinaCentesimas: 0,
    );

    expect(
      calculadora.calcular(cuenta, estrategia).montoPorPersonaCentavos,
      400,
    );
    expect(estrategia.numeradorRecibido, 10000000);
    expect(estrategia.denominadorRecibido, 30000);
  });
}
