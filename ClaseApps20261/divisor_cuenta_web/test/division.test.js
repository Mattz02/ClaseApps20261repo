import { afterEach, expect, it, vi } from 'vitest'
import { casos } from './casosDePrueba.js'
import { validarEntrada } from '../src/domain/validarEntrada.js'
import * as division from '../src/domain/calcularDivision.js'
import { crearRedondeoExacto } from '../src/data/redondeoExacto.js'
import { crearRedondeoHaciaArriba } from '../src/data/redondeoHaciaArriba.js'

const redondeoExacto = crearRedondeoExacto()
const redondeoHaciaArriba = crearRedondeoHaciaArriba()
const estrategias = { exacto: redondeoExacto, arriba: redondeoHaciaArriba }

afterEach(() => vi.restoreAllMocks())

for (const caso of casos) {
  it(caso.nombre, () => {
    const calcular = vi.spyOn(division, 'calcularDivision')
    const validacion = validarEntrada(caso)

    if ('errorEsperado' in caso) {
      expect(validacion.valida).toBe(false)
      expect(Object.values(validacion.errores)).toEqual([caso.errorEsperado])
      expect(validacion).not.toHaveProperty('cuenta')
      expect(calcular).not.toHaveBeenCalled()
      return
    }

    expect(caso).toHaveProperty('esperado')
    expect(validacion.valida).toBe(true)
    const estrategia = estrategias[caso.modo]
    expect(estrategia).toBeDefined()
    const resultado = calcular(validacion.cuenta, estrategia)
    expect(resultado.estado).toBe('exito')
    // La producción conserva BigInt; el matcher compara unidades monetarias numéricas.
    expect(Number(resultado.montoPorPersonaCentavos) / 100).toBeCloseTo(caso.esperado, 2)
    expect(calcular).toHaveBeenCalledExactlyOnceWith(validacion.cuenta, estrategia)
  })
}

it('LSP: el mismo calcularDivision acepta ambas estrategias sin comprobar su tipo', () => {
  const validacion = validarEntrada({ monto: 10, personas: 3, propina: 0, modo: 'exacto' })
  expect(validacion.valida).toBe(true)

  const exacto = division.calcularDivision(validacion.cuenta, redondeoExacto)
  const arriba = division.calcularDivision(validacion.cuenta, redondeoHaciaArriba)

  expect(Number(exacto.montoPorPersonaCentavos) / 100).toBeCloseTo(3.33, 2)
  expect(Number(arriba.montoPorPersonaCentavos) / 100).toBeCloseTo(4.00, 2)
})
