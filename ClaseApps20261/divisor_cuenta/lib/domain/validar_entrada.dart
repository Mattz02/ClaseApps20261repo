import 'cuenta.dart';
import 'error_entrada.dart';
import 'resultado_validacion.dart';

/// Revisa el texto que escribió el usuario y lo convierte en una `Cuenta`.
///
/// Existe para que las reglas de validación (FR-008 a FR-013) estén en un solo
/// lugar y el cálculo reciba siempre datos correctos. No calcula ni formatea
/// (SRP). Nunca lanza excepciones: todo problema se devuelve como un
/// `ErrorEntrada`.
class ValidarEntrada {
  /// Qué hace: crea el validador (no tiene estado).
  /// Por qué existe: permite crearlo como `const` en `main.dart`.
  /// Recibe: nada.
  /// Devuelve: la instancia de `ValidarEntrada`.
  /// Errores: ninguno.
  const ValidarEntrada();

  /// Monto máximo en centavos: 999 999 999.99. Evita que los cálculos con
  /// `int` se desborden (research R2).
  static const montoMaximoCentavos = 99999999999;

  /// Número máximo de personas.
  static const personasMaximo = 1000000;

  /// Propina máxima en centésimas de porcentaje: 999.99 %.
  static const propinaMaximaCentesimas = 99999;

  /// Número con como máximo 2 decimales, con punto o coma: "12", "12.5",
  /// "12,50". Rechaza signos, letras, "1e5" y "12.345".
  static final _formatoDecimal = RegExp(r'^(\d+)(?:[.,](\d{1,2}))?$');

  /// Entero con signo opcional: "4", "-3". Rechaza "2.5" y "dos".
  static final _formatoEntero = RegExp(r'^-?\d+$');

  /// Qué hace: valida los tres campos y, si todos son válidos, arma la
  /// `Cuenta`.
  /// Por qué existe: es la única puerta entre el texto del usuario y el
  /// cálculo.
  /// Recibe: el texto de cada campo, tal como lo escribió el usuario.
  /// Devuelve: un `ResultadoValidacion` con la `Cuenta`, o con un error por
  /// cada campo inválido, en orden monto, personas, propina (FR-013).
  /// Errores: ninguno; los errores de entrada van dentro del resultado.
  ResultadoValidacion validar({
    required String monto,
    required String personas,
    required String propina,
  }) {
    final errores = <ErrorEntrada>[];
    final montoCentavos = _validarMonto(monto.trim(), errores);
    final numeroPersonas = _validarPersonas(personas.trim(), errores);
    final propinaCentesimas = _validarPropina(propina.trim(), errores);

    if (montoCentavos == null ||
        numeroPersonas == null ||
        propinaCentesimas == null) {
      return ResultadoValidacion(cuenta: null, errores: errores);
    }
    return ResultadoValidacion(
      cuenta: Cuenta(
        montoCentavos: montoCentavos,
        personas: numeroPersonas,
        propinaCentesimas: propinaCentesimas,
      ),
      errores: errores,
    );
  }

  /// Qué hace: valida el monto y lo convierte a centavos.
  /// Por qué existe: separa la regla del monto (FR-009) de las demás.
  /// Recibe: el texto del monto, ya sin espacios alrededor, y la lista donde
  /// se anotan los errores.
  /// Devuelve: los centavos, o `null` si el monto está vacío, no tiene el
  /// formato, es 0 o supera `montoMaximoCentavos` (en ese caso agrega
  /// `ErrorEntrada.montoInvalido` a `errores`).
  /// Errores: ninguno.
  int? _validarMonto(String texto, List<ErrorEntrada> errores) {
    final centavos = _aCentesimas(texto);
    if (centavos == null || centavos == 0 || centavos > montoMaximoCentavos) {
      errores.add(ErrorEntrada.montoInvalido);
      return null;
    }
    return centavos;
  }

  /// Qué hace: valida el número de personas y lo convierte a entero.
  /// Por qué existe: separa las reglas de personas (FR-010 y FR-011).
  /// Recibe: el texto de personas, ya sin espacios alrededor, y la lista
  /// donde se anotan los errores.
  /// Devuelve: el número de personas, o `null` si no es válido. En ese caso
  /// agrega a `errores`:
  /// - `personasMenorQueUno` si es un entero ≤ 0 (incluidos los negativos);
  /// - `personasInvalido` si está vacío, no es entero ("2.5", "-2.5", "dos")
  ///   o supera `personasMaximo`.
  /// Errores: ninguno.
  int? _validarPersonas(String texto, List<ErrorEntrada> errores) {
    if (!_formatoEntero.hasMatch(texto)) {
      errores.add(ErrorEntrada.personasInvalido);
      return null;
    }
    // Un entero demasiado largo para `int` hace que tryParse devuelva null.
    final numero = int.tryParse(texto);
    final esNegativo = texto.startsWith('-');
    if (esNegativo || numero == 0) {
      errores.add(ErrorEntrada.personasMenorQueUno);
      return null;
    }
    if (numero == null || numero > personasMaximo) {
      errores.add(ErrorEntrada.personasInvalido);
      return null;
    }
    return numero;
  }

  /// Qué hace: valida la propina y la convierte a centésimas de porcentaje.
  /// Por qué existe: separa la regla de la propina (FR-012).
  /// Recibe: el texto de la propina, ya sin espacios alrededor, y la lista
  /// donde se anotan los errores.
  /// Devuelve: las centésimas (vacío → 0; 10 → 1000), o `null` si no tiene el
  /// formato (incluidos los negativos) o supera `propinaMaximaCentesimas` (en
  /// ese caso agrega `ErrorEntrada.propinaInvalida` a `errores`).
  /// Errores: ninguno.
  int? _validarPropina(String texto, List<ErrorEntrada> errores) {
    if (texto.isEmpty) return 0;
    final centesimas = _aCentesimas(texto);
    if (centesimas == null || centesimas > propinaMaximaCentesimas) {
      errores.add(ErrorEntrada.propinaInvalida);
      return null;
    }
    return centesimas;
  }

  /// Qué hace: convierte un número con como máximo 2 decimales a centésimas,
  /// usando solo los dígitos del texto (sin `double`): "12,5" → 1250,
  /// "3.1" → 310, "90" → 9000.
  /// Por qué existe: el monto (centavos) y la propina (centésimas de %) se
  /// convierten igual, y así no aparecen errores de redondeo de `double`.
  /// Recibe: el texto ya sin espacios alrededor.
  /// Devuelve: las centésimas, o `null` si el texto no tiene el formato o
  /// tiene más de 15 dígitos enteros (valores que igual superan cualquier
  /// tope y que harían desbordar el `int` al multiplicar por 100).
  /// Errores: ninguno.
  int? _aCentesimas(String texto) {
    final coincidencia = _formatoDecimal.firstMatch(texto);
    if (coincidencia == null) return null;
    final parteEntera = coincidencia.group(1)!;
    if (parteEntera.length > 15) return null;
    final decimales = (coincidencia.group(2) ?? '').padRight(2, '0');
    return int.parse(parteEntera) * 100 + int.parse(decimales);
  }
}
