/**
 * Presenta centavos BigInt no negativos con punto y dos decimales, sin símbolo.
 * Devuelve string; no redondea. Un tipo incompatible produce TypeError por violar el contrato.
 */
export function formateadorMoneda(centavos) {
  const entero = centavos / 100n
  const decimales = (centavos % 100n).toString().padStart(2, '0')
  return `${entero}.${decimales}`
}
