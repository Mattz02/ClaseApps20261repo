import 'package:divisor_cuenta/domain/calcular_division.dart';
import 'package:divisor_cuenta/domain/estrategia_redondeo.dart';
import 'package:divisor_cuenta/domain/validar_entrada.dart';
import 'package:divisor_cuenta/presentation/divisor_controller.dart';
import 'package:divisor_cuenta/presentation/formateador_moneda.dart';
import 'package:flutter_test/flutter_test.dart';

/// Estrategia de prueba que siempre devuelve el mismo número de centavos.
class EstrategiaFija implements EstrategiaRedondeo {
  const EstrategiaFija(this.centavos);

  final int centavos;

  @override
  int redondear({required int numerador, required int denominador}) => centavos;
}

DivisorController crearController() => DivisorController(
  validador: const ValidarEntrada(),
  calculadora: const CalcularDivision(),
  estrategias: const {
    'Primero': EstrategiaFija(2750),
    'Segundo': EstrategiaFija(400),
  },
  formateador: const FormateadorMoneda(),
);

void main() {
  group('cálculo', () {
    test('los modos respetan el orden del mapa y el primero es el inicial', () {
      final controller = crearController();
      expect(controller.modos, ['Primero', 'Segundo']);
      expect(controller.modoSeleccionado, 'Primero');
      expect(controller.montoPorPersona, isNull);
    });

    test('calcular con datos válidos usa la estrategia del modo elegido', () {
      final controller = crearController();

      controller.calcular(monto: '100.00', personas: '4', propina: '10');
      expect(controller.montoPorPersona, '27.50');

      controller.seleccionarModo('Segundo');
      controller.calcular(monto: '100.00', personas: '4', propina: '10');
      expect(controller.modoSeleccionado, 'Segundo');
      expect(controller.montoPorPersona, '4.00');
    });

    test('descartarResultado borra el resultado (FR-014)', () {
      final controller = crearController()
        ..calcular(monto: '100.00', personas: '4', propina: '10');

      controller.descartarResultado();
      expect(controller.montoPorPersona, isNull);
    });

    test('cambiar de modo borra el resultado (FR-014)', () {
      final controller = crearController()
        ..calcular(monto: '100.00', personas: '4', propina: '10');

      controller.seleccionarModo('Segundo');
      expect(controller.montoPorPersona, isNull);
    });

    test('un modo que no existe es un error de programación', () {
      expect(
        () => crearController().seleccionarModo('Inexistente'),
        throwsArgumentError,
      );
    });

    test('no se puede crear sin estrategias', () {
      expect(
        () => DivisorController(
          validador: const ValidarEntrada(),
          calculadora: const CalcularDivision(),
          estrategias: const {},
          formateador: const FormateadorMoneda(),
        ),
        throwsArgumentError,
      );
    });
  });

  group('errores', () {
    test(
      'con datos inválidos guarda un mensaje por campo y no hay resultado',
      () {
        final controller = crearController()
          ..calcular(monto: 'abc', personas: '0', propina: 'x');

        expect(controller.errorMonto, 'Monto inválido');
        expect(controller.errorPersonas, 'Debe haber al menos una persona');
        expect(controller.errorPropina, 'Propina inválida');
        expect(controller.montoPorPersona, isNull);
      },
    );

    test('solo el campo inválido tiene mensaje', () {
      final controller = crearController()
        ..calcular(monto: '50.00', personas: '2.5', propina: '10');

      expect(controller.errorMonto, isNull);
      expect(controller.errorPersonas, 'Número de personas inválido');
      expect(controller.errorPropina, isNull);
    });

    test('un cálculo válido borra los errores anteriores', () {
      final controller = crearController()
        ..calcular(monto: 'abc', personas: '0', propina: 'x')
        ..calcular(monto: '100.00', personas: '4', propina: '10');

      expect(controller.errorMonto, isNull);
      expect(controller.errorPersonas, isNull);
      expect(controller.errorPropina, isNull);
      expect(controller.montoPorPersona, '27.50');
    });

    test('descartarResultado también borra los errores (FR-014)', () {
      final controller = crearController()
        ..calcular(monto: 'abc', personas: '0', propina: 'x')
        ..descartarResultado();

      expect(controller.errorMonto, isNull);
      expect(controller.errorPersonas, isNull);
      expect(controller.errorPropina, isNull);
    });
  });
}
