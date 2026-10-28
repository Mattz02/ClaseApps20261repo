import 'package:divisor_cuenta/data/redondeo_exacto.dart';
import 'package:divisor_cuenta/data/redondeo_hacia_arriba.dart';
import 'package:divisor_cuenta/domain/calcular_division.dart';
import 'package:divisor_cuenta/domain/estrategia_redondeo.dart';
import 'package:divisor_cuenta/domain/resultado.dart';
import 'package:divisor_cuenta/domain/validar_entrada.dart';
import 'package:test/test.dart';

import 'casos_de_prueba.dart';

/// Registra los seis casos de la spec y la sustitución de estrategias (LSP).
/// No recibe ni devuelve valores; una expectativa incumplida falla la prueba.
void main() {
  const validador = ValidarEntrada();
  const calculadora = CalcularDivision();
  const estrategias = <String, EstrategiaRedondeo>{
    'exacto': RedondeoExacto(),
    'arriba': RedondeoHaciaArriba(),
  };

  for (final caso in casos) {
    test(caso.nombre, () {
      final validacion = validador.validar(
        // NaN representa la entrada no numérica "abc" de la spec.
        monto: caso.monto.isNaN ? 'abc' : caso.monto.toString(),
        personas: caso.personas.toString(),
        propina: caso.propina.toString(),
      );

      Resultado? resultado;
      // La validación decide si se calcula, no el resultado esperado del caso.
      if (validacion.esValida) {
        final estrategia = estrategias[caso.modo];
        expect(estrategia, isNotNull, reason: 'Modo desconocido: ${caso.modo}');
        resultado = calculadora.calcular(validacion.cuenta!, estrategia!);
      }

      if (caso.errorEsperado != null) {
        expect(validacion.esValida, isFalse);
        expect(validacion.errores.map((error) => error.mensaje), [
          caso.errorEsperado,
        ]);
        expect(validacion.cuenta, isNull);
        expect(resultado, isNull, reason: 'Una entrada inválida no se calcula');
      } else {
        expect(caso.esperado, isNotNull);
        expect(validacion.esValida, isTrue);
        expect(validacion.errores, isEmpty);
        expect(resultado, isNotNull);
        // El dominio devuelve centavos; la tabla expresa unidades monetarias.
        expect(
          resultado!.montoPorPersonaCentavos / 100,
          closeTo(caso.esperado!, 0.001),
        );
      }
    });
  }

  test('LSP: la misma calculadora acepta ambas estrategias sin if ni cast', () {
    final validacion = validador.validar(
      monto: '10.00',
      personas: '3',
      propina: '0',
    );
    expect(validacion.esValida, isTrue);
    final cuenta = validacion.cuenta!;

    EstrategiaRedondeo estrategia = const RedondeoExacto();
    expect(
      calculadora.calcular(cuenta, estrategia).montoPorPersonaCentavos / 100,
      closeTo(3.33, 0.001),
    );

    estrategia = const RedondeoHaciaArriba();
    expect(
      calculadora.calcular(cuenta, estrategia).montoPorPersonaCentavos / 100,
      closeTo(4.00, 0.001),
    );
  });
}
