import { expect, it, vi } from 'vitest'
import { calcularDivision } from '../../src/domain/calcularDivision.js'

it.each([
  [10000n, 4n, 1000n, 110000000n, 40000n],
  [99999999999n, 1n, 99999n, 10999899999890001n, 10000n],
])('entrega la fracción exacta a cualquier estrategia', (m, p, t, n, d) => {
  const aplicar = vi.fn(() => 123n)
  const cuenta = Object.freeze({ montoCentavos: m, personas: p, propinaCentesimas: t, modo: 'tercero' })
  expect(calcularDivision(cuenta, { aplicar })).toEqual({ estado: 'exito', montoPorPersonaCentavos: 123n })
  expect(aplicar).toHaveBeenCalledExactlyOnceWith({ numerador: n, denominador: d })
})
