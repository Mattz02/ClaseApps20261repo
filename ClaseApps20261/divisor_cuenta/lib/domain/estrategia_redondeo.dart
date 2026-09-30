/// Regla para convertir el monto exacto por persona en centavos enteros.
///
/// Existe para que cada modo de redondeo sea una clase aparte (patrón
/// Estrategia). Así, agregar un modo nuevo no obliga a editar las clases que
/// ya existen (OCP), y quien la usa no necesita saber qué modo concreto
/// recibe (DIP y LSP).
abstract interface class EstrategiaRedondeo {
  /// Qué hace: redondea el monto exacto `numerador / denominador` (en
  /// centavos) a un número entero de centavos.
  /// Por qué existe: es el único punto donde difieren los modos de redondeo.
  /// Recibe: `numerador >= 0` y `denominador > 0`. Por ejemplo, 10.00 entre
  /// 3 personas llega como `10000000 / 30000` = 333.33… centavos.
  /// Devuelve: los centavos redondeados, siempre `>= 0`.
  /// Errores: ninguno si se cumplen las condiciones de los parámetros.
  int redondear({required int numerador, required int denominador});
}
