/// Convierte centavos en el texto que ve el usuario.
///
/// Existe para que el formato (FR-007) esté separado del cálculo (SRP).
class FormateadorMoneda {
  /// Qué hace: crea el formateador (no tiene estado).
  /// Por qué existe: permite crearlo como `const` en `main.dart`.
  /// Recibe: nada.
  /// Devuelve: la instancia de `FormateadorMoneda`.
  /// Errores: ninguno.
  const FormateadorMoneda();

  /// Qué hace: escribe los centavos con exactamente 2 decimales, punto
  /// decimal y sin símbolo de moneda: 2750 → "27.50", 5 → "0.05".
  /// Por qué existe: la spec exige siempre 2 decimales (FR-007).
  /// Recibe: un monto en centavos, `>= 0`.
  /// Devuelve: el texto formateado.
  /// Errores: ninguno.
  String formatear(int centavos) {
    final enteros = centavos ~/ 100;
    final decimales = (centavos % 100).toString().padLeft(2, '0');
    return '$enteros.$decimales';
  }
}
