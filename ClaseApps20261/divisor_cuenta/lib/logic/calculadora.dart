/// Lógica pura para dividir la cuenta. Todos los montos se manejan en
/// centavos (int) para evitar errores de redondeo con double.
library;

enum ModoDivision { partesIguales, porConsumo }

class ResultadoDivision {
  const ResultadoDivision({
    required this.subtotal,
    required this.propina,
    required this.porPersona,
  });

  final int subtotal;
  final int propina;
  final List<int> porPersona;

  int get total => subtotal + propina;
}

/// Convierte texto como "12,50" o "12.5" a centavos.
/// Devuelve 0 si está vacío y null si no es un monto válido.
int? parsearCentavos(String texto) {
  final limpio = texto.trim().replaceAll(',', '.');
  if (limpio.isEmpty) return 0;
  final valor = double.tryParse(limpio);
  if (valor == null || !valor.isFinite || valor < 0) return null;
  return (valor * 100).round();
}

/// Formatea centavos como "$12.50".
String formatearCentavos(int centavos) {
  final signo = centavos < 0 ? '-' : '';
  final abs = centavos.abs();
  final decimales = (abs % 100).toString().padLeft(2, '0');
  return '$signo\$${abs ~/ 100}.$decimales';
}

int calcularPropina(int subtotal, int porcentaje) =>
    (subtotal * porcentaje / 100).round();

/// Reparte [monto] en proporción a [pesos] usando el método del mayor
/// residuo, así la suma de las partes siempre es exactamente [monto].
List<int> repartirProporcional(int monto, List<int> pesos) {
  final sumaPesos = pesos.fold<int>(0, (a, b) => a + b);
  if (sumaPesos == 0) return List.filled(pesos.length, 0);

  final exactos = [for (final p in pesos) monto * p / sumaPesos];
  final partes = [for (final e in exactos) e.floor()];
  final sobrante = monto - partes.fold<int>(0, (a, b) => a + b);

  // Los centavos sobrantes van a quienes tienen mayor parte decimal;
  // en empate, al primero de la lista.
  final orden = List.generate(pesos.length, (i) => i)
    ..sort((a, b) {
      final cmp = (exactos[b] - partes[b]).compareTo(exactos[a] - partes[a]);
      return cmp != 0 ? cmp : a.compareTo(b);
    });
  for (final i in orden.take(sobrante)) {
    partes[i]++;
  }
  return partes;
}

ResultadoDivision dividirPartesIguales({
  required int subtotal,
  required int personas,
  required int propinaPorcentaje,
}) {
  final propina = calcularPropina(subtotal, propinaPorcentaje);
  return ResultadoDivision(
    subtotal: subtotal,
    propina: propina,
    porPersona: repartirProporcional(
      subtotal + propina,
      List.filled(personas, 1),
    ),
  );
}

ResultadoDivision dividirPorConsumo({
  required List<int> consumos,
  required int propinaPorcentaje,
}) {
  final subtotal = consumos.fold<int>(0, (a, b) => a + b);
  final propina = calcularPropina(subtotal, propinaPorcentaje);
  return ResultadoDivision(
    subtotal: subtotal,
    propina: propina,
    porPersona: repartirProporcional(subtotal + propina, consumos),
  );
}
