import { describe, expect, it } from 'vitest'
import { crearRedondeoExacto } from '../../src/data/redondeoExacto.js'
import { crearRedondeoHaciaArriba } from '../../src/data/redondeoHaciaArriba.js'

/** Ejecuta el contrato común sobre una fábrica; registra tests sin efectos de aplicación. */
export function contratoEstrategia(nombre, crear) {
  describe(nombre, () => {
    it('expone solo aplicar, no muta y devuelve centavos BigInt', () => {
      const estrategia = crear()
      expect(Object.keys(estrategia)).toEqual(['aplicar'])
      const valor = Object.freeze({ numerador: 12345n, denominador: 7n })
      const resultado = estrategia.aplicar(valor)
      expect(typeof resultado).toBe('bigint')
      expect(resultado >= 0n).toBe(true)
      expect(valor).toEqual({ numerador: 12345n, denominador: 7n })
    })
    it('conserva cero y una unidad monetaria', () => {
      expect(crear().aplicar({ numerador: 0n, denominador: 1n })).toBe(0n)
      expect(crear().aplicar({ numerador: 100n, denominador: 1n })).toBe(100n)
    })
  })
}

contratoEstrategia('Exacto', crearRedondeoExacto)
contratoEstrategia('Hacia arriba', crearRedondeoHaciaArriba)
