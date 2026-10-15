/** Crea la política al centavo para componerla en main; devuelve EstrategiaRedondeo sin estado. */
export function crearRedondeoExacto() {
  return {
    /** Recibe fracción en centavos; devuelve BigInt con mitades arriba. Propaga errores de contrato BigInt. */
    aplicar({ numerador, denominador }) {
      const cociente = numerador / denominador
      const resto = numerador % denominador
      return cociente + (2n * resto >= denominador ? 1n : 0n)
    },
  }
}
