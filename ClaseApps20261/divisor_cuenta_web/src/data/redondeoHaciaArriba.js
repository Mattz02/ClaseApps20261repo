/** Crea la política al entero superior para main; devuelve EstrategiaRedondeo sin estado. */
export function crearRedondeoHaciaArriba() {
  return {
    /** Recibe fracción en centavos; devuelve centavos del techo entero. Propaga errores de contrato BigInt. */
    aplicar({ numerador, denominador }) {
      const divisorEntero = 100n * denominador
      const entero = numerador / divisorEntero
      const resto = numerador % divisorEntero
      return (entero + (resto === 0n ? 0n : 1n)) * 100n
    },
  }
}
