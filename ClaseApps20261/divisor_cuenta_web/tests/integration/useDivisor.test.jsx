// @vitest-environment jsdom
import { act, createElement, useLayoutEffect } from 'react'
import { afterEach, expect, it, vi } from 'vitest'
import { useDivisor } from '../../src/presentation/useDivisor.js'
import { montar } from '../helpers/reactDom.js'
import { dependenciasExactas, dependenciasCompletas } from '../helpers/dependencias.js'

let vista
afterEach(async () => { if (vista) await vista.limpiar() })

/** Monta un componente observador del hook; devuelve acceso al estado actual, propaga errores React. */
async function observar(dependencias) {
  let estado
  function Observador() {
    const actual = useDivisor(dependencias)
    useLayoutEffect(() => { estado = actual })
    return null
  }
  vista = await montar(createElement(Observador))
  return () => estado
}

it('inicia vacío, calcula solo al enviar y usa dependencias recibidas', async () => {
  const deps = dependenciasExactas()
  const calcularDivision = vi.fn(deps.calcularDivision)
  const estado = await observar({ ...deps, calcularDivision })
  expect(estado().entrada).toEqual({ monto: '', personas: '', propina: '', modo: 'exacto' })
  expect(estado().salida).toBeNull()
  await act(async () => { estado().cambiarCampo('monto', '100'); estado().cambiarCampo('personas', '4'); estado().cambiarCampo('propina', '10') })
  expect(calcularDivision).not.toHaveBeenCalled()
  await act(async () => estado().calcular())
  expect(calcularDivision).toHaveBeenCalledTimes(1)
  expect(estado().salida).toEqual({ estado: 'exito', montoPorPersonaCentavos: 2750n })
})

it.each(['monto', 'personas', 'propina'])('editar %s oculta éxito sin calcular', async campo => {
  const estado = await observar(dependenciasExactas())
  await act(async () => { estado().cambiarCampo('monto', '10'); estado().cambiarCampo('personas', '3') })
  await act(async () => estado().calcular())
  expect(estado().salida.estado).toBe('exito')
  await act(async () => estado().cambiarCampo(campo, '2'))
  expect(estado().salida).toBeNull()
})

it('nunca llama al cálculo con entradas inválidas', async () => {
  const calcularDivision = vi.fn()
  const estado = await observar({ ...dependenciasExactas(), calcularDivision })
  await act(async () => estado().calcular())
  expect(calcularDivision).not.toHaveBeenCalled()
  expect(estado().salida?.estado).not.toBe('exito')
})

it('admite un proveedor adicional inyectado sin preguntar su tipo', async () => {
  const deps = dependenciasExactas()
  const aplicar = vi.fn(() => 777n)
  deps.opcionesRedondeo.push({ id: 'tercero', etiqueta: 'Prueba', estrategia: { aplicar } })
  const estado = await observar(deps)
  await act(async () => { estado().cambiarCampo('monto', '10'); estado().cambiarCampo('personas', '3'); estado().cambiarModo('tercero') })
  await act(async () => estado().calcular())
  expect(aplicar).toHaveBeenCalledTimes(1)
  expect(estado().salida.montoPorPersonaCentavos).toBe(777n)
})

it.each(['monto', 'personas', 'propina', 'modo'])('edición de %s borra todos los errores', async campo => {
  const deps = dependenciasExactas()
  deps.opcionesRedondeo.push({ id: 'otro', etiqueta: 'Otro', estrategia: { aplicar: () => 100n } })
  const calcularDivision = vi.fn(deps.calcularDivision)
  const estado = await observar({ ...deps, calcularDivision })
  await act(async () => { estado().cambiarCampo('monto', '100'); estado().cambiarCampo('personas', '4') })
  await act(async () => estado().calcular())
  expect(estado().salida.estado).toBe('exito')
  calcularDivision.mockClear()
  await act(async () => { estado().cambiarCampo('monto', 'abc'); estado().cambiarCampo('personas', '0'); estado().cambiarCampo('propina', '-1') })
  await act(async () => estado().calcular())
  expect(estado().salida).toEqual({ estado: 'error', errores: {
    monto: 'Monto inválido', personas: 'Debe haber al menos una persona', propina: 'Propina inválida',
  } })
  expect(calcularDivision).not.toHaveBeenCalled()
  await act(async () => campo === 'modo' ? estado().cambiarModo('otro') : estado().cambiarCampo(campo, '2'))
  expect(estado().salida).toBeNull()
  expect(calcularDivision).not.toHaveBeenCalled()
})

it.each([['exacto', 333n], ['arriba', 400n], ['tercero', 777n]])('resuelve %s con consumidores reales', async (modo, esperado) => {
  const deps = dependenciasCompletas()
  deps.opcionesRedondeo.push({ id: 'tercero', etiqueta: 'Prueba', estrategia: { aplicar: () => 777n } })
  const estado = await observar(deps)
  await act(async () => { estado().cambiarCampo('monto', '10'); estado().cambiarCampo('personas', '3'); estado().cambiarModo(modo) })
  expect(estado().salida).toBeNull()
  await act(async () => estado().calcular())
  expect(estado().salida.montoPorPersonaCentavos).toBe(esperado)
  await act(async () => estado().cambiarModo('arriba'))
  expect(estado().salida).toBeNull()
  await act(async () => estado().cambiarCampo('monto', 'abc'))
  await act(async () => estado().calcular())
  expect(estado().salida.estado).toBe('error')
  await act(async () => estado().cambiarModo('exacto'))
  expect(estado().salida).toBeNull()
})
