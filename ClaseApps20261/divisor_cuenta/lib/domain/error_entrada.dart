/// Los errores posibles al validar lo que escribe el usuario.
///
/// Existe para que las reglas de validación y las pruebas usen valores con
/// nombre en lugar de comparar cadenas sueltas. Cada valor trae el texto
/// exacto que exige la spec (FR-009 a FR-012).
enum ErrorEntrada {
  /// El monto está vacío, no es un número válido, es 0 o supera el tope.
  montoInvalido('Monto inválido'),

  /// El número de personas es un entero menor que 1 (0 o negativo).
  personasMenorQueUno('Debe haber al menos una persona'),

  /// El número de personas está vacío, no es entero o supera el tope.
  personasInvalido('Número de personas inválido'),

  /// La propina es negativa, no es un número válido o supera el tope.
  propinaInvalida('Propina inválida');

  /// Qué hace: asocia cada error con su mensaje.
  /// Por qué existe: los valores de un `enum` con datos necesitan un
  /// constructor `const`.
  /// Recibe: el texto del mensaje.
  /// Devuelve: el valor del `enum`.
  /// Errores: ninguno.
  const ErrorEntrada(this.mensaje);

  /// Texto que se le muestra al usuario, igual al de la spec.
  final String mensaje;
}
