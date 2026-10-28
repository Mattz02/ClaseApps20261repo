import 'package:divisor_cuenta/domain/error_entrada.dart';
import 'package:divisor_cuenta/domain/validar_entrada.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validador = ValidarEntrada();

  group('entradas válidas', () {
    test('convierte monto, personas y propina a enteros', () {
      final r = validador.validar(
        monto: '100.00',
        personas: '4',
        propina: '10',
      );

      expect(r.esValida, isTrue);
      expect(r.errores, isEmpty);
      expect(r.cuenta!.montoCentavos, 10000);
      expect(r.cuenta!.personas, 4);
      expect(r.cuenta!.propinaCentesimas, 1000);
    });

    test('acepta coma decimal en el monto', () {
      final r = validador.validar(monto: '12,50', personas: '1', propina: '');
      expect(r.cuenta!.montoCentavos, 1250);
    });

    test('ignora espacios alrededor', () {
      final r = validador.validar(
        monto: ' 90 ',
        personas: ' 3 ',
        propina: ' 0 ',
      );
      expect(r.cuenta!.montoCentavos, 9000);
      expect(r.cuenta!.personas, 3);
    });

    test('un solo decimal cuenta como décimas (3.1 → 310 centavos)', () {
      final r = validador.validar(monto: '3.1', personas: '1', propina: '');
      expect(r.cuenta!.montoCentavos, 310);
    });

    test('acepta propina con decimales, con punto o coma', () {
      expect(
        validador
            .validar(monto: '10', personas: '1', propina: '12.5')
            .cuenta!
            .propinaCentesimas,
        1250,
      );
      expect(
        validador
            .validar(monto: '10', personas: '1', propina: '12,5')
            .cuenta!
            .propinaCentesimas,
        1250,
      );
    });

    test('la propina vacía vale 0', () {
      final r = validador.validar(monto: '10', personas: '1', propina: '');
      expect(r.esValida, isTrue);
      expect(r.cuenta!.propinaCentesimas, 0);
    });

    test('acepta los topes exactos', () {
      final r = validador.validar(
        monto: '999999999.99',
        personas: '1000000',
        propina: '999.99',
      );
      expect(r.esValida, isTrue);
    });
  });

  group('entradas inválidas', () {
    /// Los errores que produce un valor de monto con personas y propina
    /// válidas.
    List<ErrorEntrada> erroresDeMonto(String monto) =>
        validador.validar(monto: monto, personas: '2', propina: '10').errores;

    List<ErrorEntrada> erroresDePersonas(String personas) => validador
        .validar(monto: '50.00', personas: personas, propina: '10')
        .errores;

    List<ErrorEntrada> erroresDePropina(String propina) => validador
        .validar(monto: '50.00', personas: '2', propina: propina)
        .errores;

    for (final monto in [
      'abc',
      '',
      '   ',
      '0',
      '0.00',
      '-5',
      '+5',
      '1e5',
      '12.345',
      '1.000,50',
      '1000000000',
      '99999999999999999999',
    ]) {
      test('monto "$monto" → Monto inválido', () {
        expect(erroresDeMonto(monto), [ErrorEntrada.montoInvalido]);
      });
    }

    for (final personas in ['0', '-3', '-99999999999']) {
      test('personas "$personas" → Debe haber al menos una persona', () {
        expect(erroresDePersonas(personas), [ErrorEntrada.personasMenorQueUno]);
      });
    }

    for (final personas in [
      '',
      '2.5',
      '-2.5',
      'dos',
      '1000001',
      '99999999999999999999',
    ]) {
      test('personas "$personas" → Número de personas inválido', () {
        expect(erroresDePersonas(personas), [ErrorEntrada.personasInvalido]);
      });
    }

    for (final propina in ['-1', 'abc', '10.555', '1000']) {
      test('propina "$propina" → Propina inválida', () {
        expect(erroresDePropina(propina), [ErrorEntrada.propinaInvalida]);
      });
    }

    test('con los tres campos inválidos da los tres errores, en orden', () {
      final r = validador.validar(monto: 'abc', personas: '0', propina: 'x');

      expect(r.esValida, isFalse);
      expect(r.cuenta, isNull);
      expect(r.errores, [
        ErrorEntrada.montoInvalido,
        ErrorEntrada.personasMenorQueUno,
        ErrorEntrada.propinaInvalida,
      ]);
    });
  });
}
