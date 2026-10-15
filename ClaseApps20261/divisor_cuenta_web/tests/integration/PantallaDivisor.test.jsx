// @vitest-environment jsdom
import { createElement } from 'react'
import { afterEach, expect, it, vi } from 'vitest'
import PantallaDivisor from '../../src/presentation/PantallaDivisor.jsx'
import { montar, escribir, pulsar } from '../helpers/reactDom.js'
import { dependenciasExactas, dependenciasCompletas } from '../helpers/dependencias.js'

let vista
afterEach(async () => {
  if (vista) await vista.limpiar()
  vista = null
  vi.restoreAllMocks()
  vi.unstubAllGlobals()
})

/** Monta la pantalla con fixtures; devuelve DOM y propaga errores del montaje. */
async function abrir(dependencias = dependenciasExactas()) {
  vista = await montar(createElement(PantallaDivisor, { dependencias }))
  return vista.contenedor
}

/** Obtiene un campo por nombre y verifica que existe antes de interactuar. */
function campo(dom, nombre) {
  const input = dom.querySelector(`[name="${nombre}"]`)
  expect(input).not.toBeNull()
  return input
}

/** Completa el formulario real, sin enviarlo; devuelve promesa y propaga errores de eventos. */
async function completar(dom, monto, personas, propina = '') {
  await escribir(campo(dom, 'monto'), monto)
  await escribir(campo(dom, 'personas'), personas)
  await escribir(campo(dom, 'propina'), propina)
}

it.each([
  ['A1', '100.00', '4', '10', '27.50'],
  ['A2', '90.00', '3', '0', '30.00'],
  ['A5', '10.00', '3', '0', '3.33'],
  ['coma', '12,50', '2', '10,5', '6.91'],
  ['propina vacía', '90', '3', '', '30.00'],
])('%s: exacto %s/%s con %s -> %s', async (_id, monto, personas, propina, esperado) => {
  const dom = await abrir()
  expect(dom.querySelector('[value="exacto"]').checked).toBe(true)
  expect(dom.querySelector('form').noValidate).toBe(true)
  await completar(dom, monto, personas, propina)
  expect(dom.querySelector('output')).toBeNull()
  await pulsar(dom.querySelector('button[type="submit"]'))
  expect(dom.querySelector('output').textContent).toBe(esperado)
  expect(dom.textContent).toContain('por persona')
  await escribir(campo(dom, 'monto'), '2')
  expect(dom.querySelector('output')).toBeNull()
})

it('etiqueta los tres campos y genera opciones desde el catálogo recibido', async () => {
  const deps = dependenciasExactas()
  const aplicar = vi.fn(() => 777n)
  deps.opcionesRedondeo.push({ id: 'tercero', etiqueta: 'Prueba', estrategia: { aplicar } })
  const dom = await abrir(deps)
  for (const nombre of ['monto', 'personas', 'propina']) {
    expect(dom.querySelector(`label[for="${campo(dom, nombre).id}"]`)).not.toBeNull()
  }
  await completar(dom, '10', '3')
  await pulsar(dom.querySelector('[value="tercero"]'))
  await pulsar(dom.querySelector('button[type="submit"]'))
  expect(dom.querySelector('output').textContent).toBe('7.77')
  expect(aplicar).toHaveBeenCalledTimes(1)
})

const casosInvalidos = [
  ...['', 'abc', '0', '-1', '12.345', '1000000000'].map(valor => ['monto', valor, 'Monto inválido']),
  ...['0', '-2'].map(valor => ['personas', valor, 'Debe haber al menos una persona']),
  ...['', 'dos', '2.5', '2,5', '2.0', '1000001'].map(valor => ['personas', valor, 'Número de personas inválido']),
  ...['-1', 'abc', '0.001', '1000'].map(valor => ['propina', valor, 'Propina inválida']),
]

it.each(casosInvalidos)('%s=%s: muestra %s y nunca conserva monto anterior', async (nombre, valor, mensaje) => {
  const dom = await abrir()
  await completar(dom, '100', '4', '10')
  await pulsar(dom.querySelector('button[type="submit"]'))
  expect(dom.querySelector('output')).not.toBeNull()
  await escribir(campo(dom, nombre), valor)
  await pulsar(dom.querySelector('button[type="submit"]'))
  expect(dom.querySelector('output')).toBeNull()
  expect(dom.querySelector(`#error-${nombre}`).textContent).toBe(mensaje)
  expect(campo(dom, nombre).getAttribute('aria-invalid')).toBe('true')
  expect(campo(dom, nombre).getAttribute('aria-describedby')).toContain(`error-${nombre}`)
})

it.each(['monto', 'personas', 'propina', 'modo'])('muestra todos los errores y los borra al editar %s', async nombre => {
  const deps = dependenciasExactas()
  deps.opcionesRedondeo.push({ id: 'otro', etiqueta: 'Otro', estrategia: { aplicar: () => 100n } })
  const dom = await abrir(deps)
  await completar(dom, 'abc', '0', '-1')
  await pulsar(dom.querySelector('button[type="submit"]'))
  expect(dom.querySelectorAll('.error-campo')).toHaveLength(3)
  expect(dom.textContent).toContain('Monto inválido')
  expect(dom.textContent).toContain('Debe haber al menos una persona')
  expect(dom.textContent).toContain('Propina inválida')
  expect(dom.querySelector('output')).toBeNull()
  if (nombre === 'modo') await pulsar(dom.querySelector('[value="otro"]'))
  else await escribir(campo(dom, nombre), '2')
  expect(dom.querySelectorAll('.error-campo')).toHaveLength(0)
  expect(dom.querySelector('output')).toBeNull()
})

it.each([
  ['A6', '10', '3', '0', '4.00'],
  ['A7', '90', '3', '0', '30.00'],
  ['sin redondeo previo', '1', '1', '0.01', '2.00'],
  ['máximo', '999999999.99', '1', '999.99', '10999900000.00'],
])('%s: Hacia arriba -> %s/%s/%s = %s', async (_id, monto, personas, propina, esperado) => {
  const dom = await abrir(dependenciasCompletas())
  await completar(dom, monto, personas, propina)
  await pulsar(dom.querySelector('[value="arriba"]'))
  expect(dom.querySelector('output')).toBeNull()
  await pulsar(dom.querySelector('button[type="submit"]'))
  expect(dom.querySelector('output').textContent).toBe(esperado)
  await pulsar(dom.querySelector('[value="exacto"]'))
  expect(dom.querySelector('output')).toBeNull()
  await escribir(campo(dom, 'monto'), 'abc')
  await pulsar(dom.querySelector('button[type="submit"]'))
  expect(dom.querySelectorAll('.error-campo')).toHaveLength(1)
  await pulsar(dom.querySelector('[value="arriba"]'))
  expect(dom.querySelectorAll('.error-campo')).toHaveLength(0)
})

it('extiende el catálogo de dos modos con un tercer proveedor solo en pruebas', async () => {
  const deps = dependenciasCompletas()
  deps.opcionesRedondeo.push({ id: 'tercero', etiqueta: 'Tercero', estrategia: { aplicar: () => 123n } })
  const dom = await abrir(deps)
  await completar(dom, '10', '3')
  await pulsar(dom.querySelector('[value="tercero"]'))
  await pulsar(dom.querySelector('button[type="submit"]'))
  expect(dom.querySelector('output').textContent).toBe('1.23')
})

it.each(['exacto', 'arriba'])('sin accesos a red ni persistencia al operar en %s', async modo => {
  const prohibido = vi.fn(() => { throw new Error('Acceso externo inesperado') })
  vi.stubGlobal('fetch', prohibido)
  vi.stubGlobal('XMLHttpRequest', prohibido)
  vi.spyOn(window, 'localStorage', 'get').mockImplementation(prohibido)
  vi.spyOn(window, 'sessionStorage', 'get').mockImplementation(prohibido)
  vi.stubGlobal('indexedDB', { open: prohibido })
  vi.spyOn(document, 'cookie', 'get').mockImplementation(prohibido)
  vi.spyOn(document, 'cookie', 'set').mockImplementation(prohibido)
  const dom = await abrir(dependenciasCompletas())
  await completar(dom, '10', '3')
  await pulsar(dom.querySelector(`[value="${modo}"]`))
  await pulsar(dom.querySelector('button[type="submit"]'))
  expect(dom.querySelector('output').textContent).toBe(modo === 'exacto' ? '3.33' : '4.00')
  await escribir(campo(dom, 'monto'), 'abc')
  await pulsar(dom.querySelector('button[type="submit"]'))
  expect(dom.querySelector('#error-monto').textContent).toBe('Monto inválido')
  await pulsar(dom.querySelector(`[value="${modo === 'exacto' ? 'arriba' : 'exacto'}"]`))
  expect(dom.querySelectorAll('.error-campo')).toHaveLength(0)
  expect(prohibido).not.toHaveBeenCalled()
})

it('una nueva sesión no restaura entradas, resultado ni modo anterior', async () => {
  let dom = await abrir(dependenciasCompletas())
  await completar(dom, '10', '3', '5')
  await pulsar(dom.querySelector('[value="arriba"]'))
  await pulsar(dom.querySelector('button[type="submit"]'))
  await vista.limpiar()
  vista = null
  dom = await abrir(dependenciasCompletas())
  for (const nombre of ['monto', 'personas', 'propina']) expect(campo(dom, nombre).value).toBe('')
  expect(dom.querySelector('[value="exacto"]').checked).toBe(true)
  expect(dom.querySelector('output')).toBeNull()
  expect(dom.querySelectorAll('.error-campo')).toHaveLength(0)
})
