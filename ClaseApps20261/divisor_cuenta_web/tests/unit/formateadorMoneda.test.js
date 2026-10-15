import { expect, it } from 'vitest'
import { formateadorMoneda } from '../../src/presentation/formateadorMoneda.js'

it.each([[0n, '0.00'], [1n, '0.01'], [2750n, '27.50'], [400n, '4.00'], [1099989999989n, '10999899999.89']])(
  'formatea %s sin símbolo ni agrupación: %s', (centavos, esperado) => {
    expect(formateadorMoneda(centavos)).toBe(esperado)
  },
)
