/// Datos de la cuenta ya validados, listos para calcular la división.
///
/// Existe para que el cálculo trabaje con números seguros en lugar del texto
/// que escribió el usuario. Solo `ValidarEntrada` la construye, y garantiza:
/// - `montoCentavos`: 1 a 99 999 999 999 (0.01 a 999 999 999.99).
/// - `personas`: 1 a 1 000 000.
/// - `propinaCentesimas`: 0 a 99 999 (0 % a 999.99 %; 10 % = 1000).
///
/// Los montos son enteros (centavos) para evitar los errores de redondeo de
/// `double`: por ejemplo, `100 * 1.1 / 4` da `27.500000000000004`.
class Cuenta {
  /// Qué hace: crea una cuenta con los tres valores ya convertidos a enteros.
  /// Por qué existe: agrupa los datos de entrada en un solo objeto inmutable.
  /// Recibe: el monto en centavos, el número de personas y la propina en
  /// centésimas de porcentaje (10 % = 1000).
  /// Devuelve: la instancia de `Cuenta`.
  /// Errores: ninguno; los rangos los asegura `ValidarEntrada` antes.
  const Cuenta({
    required this.montoCentavos,
    required this.personas,
    required this.propinaCentesimas,
  });

  /// Monto total de la cuenta en centavos (100.00 → 10000).
  final int montoCentavos;

  /// Cuántas personas pagan.
  final int personas;

  /// Propina en centésimas de porcentaje (10 % → 1000, 12.5 % → 1250).
  final int propinaCentesimas;
}
