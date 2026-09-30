import '../domain/estrategia_redondeo.dart';

/// Modo "Hacia arriba": sube el monto al entero siguiente; si ya es entero,
/// no cambia.
///
/// Existe como implementación concreta de `EstrategiaRedondeo` (FR-006). Se
/// agregó sin editar ninguna clase existente: solo esta clase y una línea en
/// `main.dart` (OCP).
class RedondeoHaciaArriba implements EstrategiaRedondeo {
  /// Qué hace: crea la estrategia (no tiene estado).
  /// Por qué existe: permite crearla como `const` en `main.dart`.
  /// Recibe: nada.
  /// Devuelve: la instancia de `RedondeoHaciaArriba`.
  /// Errores: ninguno.
  const RedondeoHaciaArriba(/* Sin parámetros: estrategia sin estado. */);

  /// Qué hace: redondea `numerador / denominador` centavos hacia arriba, al
  /// múltiplo de 100 centavos (entero) igual o mayor.
  /// Por qué existe: es la regla del modo hacia arriba (FR-006).
  /// Recibe: `numerador >= 0` y `denominador > 0`.
  /// Devuelve: los centavos redondeados, siempre múltiplo de 100.
  /// Errores: ninguno si se cumplen las condiciones de los parámetros.
  ///
  /// `d = 100 × denominador` es el tamaño de "un entero" en esta fracción.
  /// Sumar `d − 1` antes de la división entera hace que cualquier resto, por
  /// pequeño que sea, sume un entero más; si no hay resto, no suma nada. Todo
  /// es aritmética entera, así que un monto justo no sube por error:
  /// `10000000 / 30000` = 3.33 enteros → `(10000000 + 2999999) ~/ 3000000` = 4 → 400.
  /// `90000000 / 30000` = 30 enteros → `(90000000 + 2999999) ~/ 3000000` = 30 → 3000.
  @override
  int redondear({required int numerador, required int denominador}) {
    final d = 100 * denominador;
    return ((numerador + d - 1) ~/ d) * 100;
  }
}
