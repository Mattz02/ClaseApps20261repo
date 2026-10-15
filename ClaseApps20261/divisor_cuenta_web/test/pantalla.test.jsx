import { afterEach, beforeEach, expect, it } from 'vitest'
import { cleanup, fireEvent, render, screen } from '@testing-library/react'
import PantallaDivisor from '../src/presentation/PantallaDivisor.jsx'
import { validarEntrada } from '../src/domain/validarEntrada.js'
import { calcularDivision } from '../src/domain/calcularDivision.js'
import { crearRedondeoExacto } from '../src/data/redondeoExacto.js'
import { crearRedondeoHaciaArriba } from '../src/data/redondeoHaciaArriba.js'

beforeEach(() => {
  const dependencias = {
    validarEntrada,
    calcularDivision,
    opcionesRedondeo: [
      { id: 'exacto', etiqueta: 'Exacto', estrategia: crearRedondeoExacto() },
      { id: 'arriba', etiqueta: 'Hacia arriba', estrategia: crearRedondeoHaciaArriba() },
    ],
  }

  render(<PantallaDivisor dependencias={dependencias} />)
})

afterEach(cleanup)

it('muestra 27.50 al dividir 100 entre 4 personas con 10 % de propina', () => {
  fireEvent.change(screen.getByLabelText('Monto total'), { target: { value: '100' } })
  fireEvent.change(screen.getByLabelText('Número de personas'), { target: { value: '4' } })
  fireEvent.change(screen.getByLabelText('Porcentaje de propina'), { target: { value: '10' } })

  fireEvent.click(screen.getByRole('button', { name: 'Calcular' }))

  expect(screen.getByText('27.50', { exact: true })).toBeVisible()
})

it('muestra el error de cero personas sin mostrar un resultado numérico', () => {
  fireEvent.change(screen.getByLabelText('Monto total'), { target: { value: '50' } })
  fireEvent.change(screen.getByLabelText('Número de personas'), { target: { value: '0' } })

  fireEvent.click(screen.getByRole('button', { name: 'Calcular' }))

  expect(screen.getByRole('alert')).toHaveTextContent('Debe haber al menos una persona')
  expect(screen.queryByRole('status')).not.toBeInTheDocument()
})

it('muestra Monto inválido cuando el monto es abc', () => {
  fireEvent.change(screen.getByLabelText('Monto total'), { target: { value: 'abc' } })
  fireEvent.change(screen.getByLabelText('Número de personas'), { target: { value: '4' } })

  fireEvent.click(screen.getByRole('button', { name: 'Calcular' }))

  expect(screen.getByRole('alert')).toHaveTextContent('Monto inválido')
})
