import '../domain/estrategia_redondeo.dart';

/// Modo "Exacto": redondea al centavo más cercano, y las mitades suben.
///
/// Existe como implementación concreta de `EstrategiaRedondeo` (FR-005). Solo
/// se crea en `main.dart`; el resto de la app la usa a través de la interfaz.
class RedondeoExacto implements EstrategiaRedondeo {
  /// Qué hace: crea la estrategia (no tiene estado).
  /// Por qué existe: permite crearla como `const` en `main.dart`.
  /// Recibe: nada.
  /// Devuelve: la instancia de `RedondeoExacto`.
  /// Errores: ninguno.
  const RedondeoExacto(/* Sin parámetros: estrategia sin estado. */);

  /// Qué hace: redondea `numerador / denominador` centavos al centavo más
  /// cercano; si queda justo en la mitad, sube.
  /// Por qué existe: es la regla del modo exacto (FR-005).
  /// Recibe: `numerador >= 0` y `denominador > 0`.
  /// Devuelve: los centavos redondeados.
  /// Errores: ninguno si se cumplen las condiciones de los parámetros.
  ///
  /// Sumar medio denominador antes de la división entera equivale a sumar
  /// 0.5 y truncar, sin usar `double`. Se multiplica todo por 2 para que ese
  /// "medio" sea entero:
  /// `10000000 / 30000` = 333.33 → `(20000000 + 30000) ~/ 60000` = 333.
  /// `667 / 2` = 333.5 → `(1334 + 2) ~/ 4` = 334.
  @override
  int redondear({required int numerador, required int denominador}) =>
      (2 * numerador + denominador) ~/ (2 * denominador);
}
