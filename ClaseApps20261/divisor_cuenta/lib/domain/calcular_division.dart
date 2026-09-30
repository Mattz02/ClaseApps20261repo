import 'cuenta.dart';
import 'estrategia_redondeo.dart';
import 'resultado.dart';

/// Calcula cuánto paga cada persona a partir de una cuenta válida.
///
/// Existe para que la fórmula de la división (FR-004) esté en un solo lugar.
/// No valida (eso lo hace `ValidarEntrada`), no formatea (eso lo hace
/// `FormateadorMoneda`) y no sabe qué modo de redondeo recibe (SRP y DIP).
class CalcularDivision {
  /// Qué hace: crea el caso de uso (no tiene estado).
  /// Por qué existe: permite crearlo como `const` en `main.dart`.
  /// Recibe: nada.
  /// Devuelve: la instancia de `CalcularDivision`.
  /// Errores: ninguno.
  const CalcularDivision();

  /// Qué hace: calcula el monto por persona, (monto + propina) / personas, y
  /// deja que la estrategia decida cómo redondearlo.
  /// Por qué existe: es el cálculo central de la app (FR-004).
  /// Recibe: una `Cuenta` válida y la `EstrategiaRedondeo` del modo elegido.
  /// Devuelve: un `Resultado` con los centavos que paga cada persona.
  /// Errores: ninguno con una `Cuenta` válida (personas ≥ 1, así que el
  /// denominador nunca es 0).
  ///
  /// Para no usar `double`, el monto exacto se expresa como una fracción de
  /// enteros en centavos. 10000 centésimas equivalen al 100 %, así que el
  /// monto con propina es `monto × (10000 + propina) / 10000`, y dividido
  /// entre las personas queda:
  /// `numerador = montoCentavos × (10000 + propinaCentesimas)`
  /// `denominador = 10000 × personas`
  /// Ejemplo: 100.00, 10 %, 4 personas → `10000 × 11000 / 40000` = 2750.
  Resultado calcular(Cuenta cuenta, EstrategiaRedondeo estrategia) {
    final numerador = cuenta.montoCentavos * (10000 + cuenta.propinaCentesimas);
    final denominador = 10000 * cuenta.personas;
    return Resultado(
      montoPorPersonaCentavos: estrategia.redondear(
        numerador: numerador,
        denominador: denominador,
      ),
    );
  }
}
