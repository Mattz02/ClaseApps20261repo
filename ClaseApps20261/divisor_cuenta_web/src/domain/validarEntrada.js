/**
 * Lee un decimal completo con máximo dos cifras y lo convierte a centésimas exactas.
 * Recibe texto o número; devuelve bigint o null si la sintaxis es inválida. No redondea.
 */
function leerDecimal(texto) {
  const limpio = String(texto).trim()
  if (!/^[+-]?(?:\d+(?:[.,]\d{0,2})?|[.,]\d{1,2})$/.test(limpio)) return null
  const sinSigno = limpio.replace(/^[+-]/, '').replace(',', '.')
  const [entero, decimales = ''] = sinSigno.split('.')
  const centesimas = BigInt(entero || '0') * 100n + BigInt(decimales.padEnd(2, '0'))
  return limpio.startsWith('-') ? -centesimas : centesimas
}

/**
 * Valida los tres campos numéricos para impedir cuentas inválidas y conserva el id de modo.
 * @param {{monto: string | number, personas: string | number, propina: string | number, modo: string}} entrada
 * @returns {import('./resultado.js').ValidacionEntrada} Cuenta normalizada o todos los mensajes.
 * Acepta campos de texto o numéricos; NaN e Infinity producen mensajes de validación.
 */
export function validarEntrada(entrada) {
  const errores = {}
  const montoCentavos = leerDecimal(entrada.monto)
  const propinaCentesimas = String(entrada.propina).trim() === '' ? 0n : leerDecimal(entrada.propina)
  const textoPersonas = String(entrada.personas).trim()
  const personas = /^[+-]?\d+$/.test(textoPersonas) ? BigInt(textoPersonas) : null

  if (montoCentavos === null || montoCentavos <= 0n || montoCentavos > 99999999999n) {
    errores.monto = 'Monto inválido'
  }
  if (personas === null || personas > 1000000n) {
    errores.personas = 'Número de personas inválido'
  } else if (personas < 1n) {
    errores.personas = 'Debe haber al menos una persona'
  }
  if (propinaCentesimas === null || propinaCentesimas < 0n || propinaCentesimas > 99999n) {
    errores.propina = 'Propina inválida'
  }
  if (Object.keys(errores).length) return { valida: false, errores }

  return {
    valida: true,
    cuenta: { montoCentavos, personas, propinaCentesimas, modo: entrada.modo },
  }
}
