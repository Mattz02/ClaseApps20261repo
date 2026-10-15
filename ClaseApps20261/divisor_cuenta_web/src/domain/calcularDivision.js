/**
 * Divide una cuenta ya válida usando la política recibida, sin validar ni formatear.
 * @param {import('./cuenta.js').Cuenta} cuenta
 * @param {import('./estrategiaRedondeo.js').EstrategiaRedondeo} estrategia
 * @returns {import('./resultado.js').ResultadoExito}
 * Propaga errores de programación de la dependencia o aritmética; no crea mensajes de entrada.
 */
export function calcularDivision(cuenta, estrategia) {
  const numerador = cuenta.montoCentavos * (10000n + cuenta.propinaCentesimas)
  const denominador = 10000n * cuenta.personas
  const montoPorPersonaCentavos = estrategia.aplicar({ numerador, denominador })
  return { estado: 'exito', montoPorPersonaCentavos }
}
