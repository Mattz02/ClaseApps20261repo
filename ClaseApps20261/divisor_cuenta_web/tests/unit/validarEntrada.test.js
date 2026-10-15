import { describe, expect, it } from 'vitest'
import { validarEntrada } from '../../src/domain/validarEntrada.js'

const base = { monto: '100.00', personas: '4', propina: '10', modo: 'exacto' }

describe('validarEntrada: normalización exacta', () => {
  it.each([
    ['100.00', '4', '10', 10000n, 4n, 1000n],
    ['  +0012,50 ', ' +02 ', '10,5', 1250n, 2n, 1050n],
    ['.5', '1', '', 50n, 1n, 0n],
    ['12.', '1', '  ', 1200n, 1n, 0n],
    ['0,01', '1000000', '999.99', 1n, 1000000n, 99999n],
    ['999999999.99', '1', '0', 99999999999n, 1n, 0n],
  ])('acepta %s / %s / %s', (monto, personas, propina, m, p, t) => {
    expect(validarEntrada({ ...base, monto, personas, propina })).toEqual({
      valida: true,
      cuenta: { montoCentavos: m, personas: p, propinaCentesimas: t, modo: 'exacto' },
    })
  })

  it('conserva un id nuevo sin conocer la estrategia', () => {
    expect(validarEntrada({ ...base, modo: 'tercero' }).cuenta.modo).toBe('tercero')
  })
})

const invalidos = [
  ...['', ' ', 'abc', '0', '-1', '12.345', '12,345', '1000000000', '1e2', '0x10', '1.000,00', '1,2.3', '1abc', '.']
    .map(valor => ['monto', valor, 'Monto inválido']),
  ...['0', '-1', '-1000001'].map(valor => ['personas', valor, 'Debe haber al menos una persona']),
  ...['', ' ', 'dos', '2.5', '2,5', '2.0', '1000001', '1e2', '0x10', '2abc']
    .map(valor => ['personas', valor, 'Número de personas inválido']),
  ...['-1', 'abc', '0.001', '1,234', '1000', '999.991', '1e2', '0x10', '1.000,00']
    .map(valor => ['propina', valor, 'Propina inválida']),
]

describe('validarEntrada: mensajes y exclusión de Cuenta', () => {
  it.each(invalidos)('%s=%s -> %s', (campo, valor, mensaje) => {
    expect(validarEntrada({ ...base, [campo]: valor })).toEqual({
      valida: false, errores: { [campo]: mensaje },
    })
  })

  it('devuelve todos los errores a la vez sin cuenta parcial', () => {
    expect(validarEntrada({ ...base, monto: 'abc', personas: '0', propina: '-1' })).toEqual({
      valida: false,
      errores: { monto: 'Monto inválido', personas: 'Debe haber al menos una persona', propina: 'Propina inválida' },
    })
  })
})
