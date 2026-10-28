import 'cuenta.dart';
import 'error_entrada.dart';

/// Lo que devuelve `ValidarEntrada`: una cuenta válida o la lista de errores.
///
/// Existe para no mezclar los errores de validación con el `Resultado` del
/// cálculo (SRP). Si `errores` está vacío, `cuenta` tiene valor; si hay
/// errores, `cuenta` es `null`.
class ResultadoValidacion {
  /// Qué hace: crea el resultado de una validación.
  /// Por qué existe: agrupa la cuenta (si la hay) y los errores encontrados.
  /// Recibe: `cuenta` (o `null` si hubo errores) y `errores`, en orden monto,
  /// personas, propina.
  /// Devuelve: la instancia de `ResultadoValidacion`.
  /// Errores: ninguno; `ValidarEntrada` respeta la regla de "cuenta o
  /// errores, nunca los dos".
  const ResultadoValidacion({required this.cuenta, required this.errores});

  /// La cuenta lista para calcular, o `null` si algún dato no es válido.
  final Cuenta? cuenta;

  /// Un error como máximo por campo, en orden: monto, personas, propina.
  final List<ErrorEntrada> errores;

  /// `true` si no hubo ningún error.
  bool get esValida => errores.isEmpty;
}
