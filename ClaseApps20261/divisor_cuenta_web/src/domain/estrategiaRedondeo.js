/**
 * Fracción exacta en centavos: numerador >= 0n, denominador > 0n.
 * @typedef {{numerador: bigint, denominador: bigint}} ValorDivision
 */
/**
 * @typedef {Object} EstrategiaRedondeo
 * @property {(valor: ValorDivision) => bigint} aplicar Devuelve centavos >= 0n.
 * No muta valor ni realiza efectos. Todos los proveedores comparten precondiciones.
 * Un denominador cero o tipos incompatibles son errores de programación;
 * la aritmética BigInt propaga RangeError/TypeError, nunca mensajes de formulario.
 */
export {}
