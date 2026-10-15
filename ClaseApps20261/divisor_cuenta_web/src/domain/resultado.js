/** @typedef {{monto?: string, personas?: string, propina?: string}} ErroresEntrada */
/** @typedef {{estado: 'exito', montoPorPersonaCentavos: bigint}} ResultadoExito */
/** @typedef {{estado: 'error', errores: ErroresEntrada}} ResultadoError */
/** @typedef {ResultadoExito | ResultadoError} Resultado Estados excluyentes, sin formato. */
/**
 * @typedef {{valida: true, cuenta: import('./cuenta.js').Cuenta} |
 * {valida: false, errores: ErroresEntrada}} ValidacionEntrada
 */
export {}
