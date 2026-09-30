/// Resultado del cálculo: cuánto paga cada persona.
///
/// Existe para que `CalcularDivision` devuelva un valor con nombre propio en
/// lugar de un `int` suelto. Solo contiene números; darle formato de texto
/// es trabajo de la capa de presentación.
class Resultado {
  /// Qué hace: crea el resultado con el monto por persona.
  /// Por qué existe: envuelve el número que produce el cálculo.
  /// Recibe: el monto por persona en centavos, ya redondeado según el modo.
  /// Devuelve: la instancia de `Resultado`.
  /// Errores: ninguno.
  const Resultado({required this.montoPorPersonaCentavos});

  /// Monto que paga cada persona, en centavos (27.50 → 2750). Siempre ≥ 0.
  final int montoPorPersonaCentavos;
}
