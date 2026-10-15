import { describe, expect, it } from 'vitest'
import { crearRedondeoExacto } from '../../src/data/redondeoExacto.js'
import { crearRedondeoHaciaArriba } from '../../src/data/redondeoHaciaArriba.js'

describe('Exacto: centavo más cercano, mitades suben', () => {
  it.each([
    [110000000n, 40000n, 2750n],
    [90000000n, 30000n, 3000n],
    [10000000n, 30000n, 333n],
    [6670000n, 20000n, 334n],
    [10000n, 10000000000n, 0n],
    [10999899999890001n, 10000n, 1099989999989n],
  ])('%s/%s centavos -> %s', (numerador, denominador, esperado) => {
    expect(crearRedondeoExacto().aplicar({ numerador, denominador })).toBe(esperado)
  })
})

describe('Hacia arriba: techo entero sin redondeo previo', () => {
  it.each([
    [10000000n, 30000n, 400n],
    [90000000n, 30000n, 3000n],
    [6670000n, 20000n, 400n],
    [1000100n, 10000n, 200n],
    [10000n, 10000000000n, 100n],
    [10999899999890001n, 10000n, 1099990000000n],
  ])('%s/%s centavos -> %s', (numerador, denominador, esperado) => {
    expect(crearRedondeoHaciaArriba().aplicar({ numerador, denominador })).toBe(esperado)
  })
})
