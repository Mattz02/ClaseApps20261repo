/**
 * Texto del formulario antes de validar; inicialmente vacío y modo exacto.
 * @typedef {Object} EntradaFormulario
 * @property {string} monto
 * @property {string} personas
 * @property {string} propina Vacío equivale a cero.
 * @property {string} modo Id del catálogo, sin enum cerrado.
 */

/**
 * Cuenta validada: datos puros, sin React ni implementaciones de redondeo.
 * @typedef {Object} Cuenta
 * @property {bigint} montoCentavos Entre 1n y 99999999999n.
 * @property {bigint} personas Entre 1n y 1000000n.
 * @property {bigint} propinaCentesimas Entre 0n y 99999n (10 % = 1000n).
 * @property {string} modo Id del catálogo; exacto y arriba son los iniciales.
 */
export {}
