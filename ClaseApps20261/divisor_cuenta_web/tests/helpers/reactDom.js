import { StrictMode, act, createElement } from 'react'
import { createRoot } from 'react-dom/client'

globalThis.IS_REACT_ACT_ENVIRONMENT = true

/** Monta una vista aislada; recibe un elemento y devuelve contenedor/limpieza. Propaga errores React. */
export async function montar(elemento) {
  const contenedor = document.createElement('div')
  document.body.append(contenedor)
  const raiz = createRoot(contenedor)
  await act(async () => raiz.render(createElement(StrictMode, null, elemento)))
  return {
    contenedor,
    /** Desmonta React y retira el DOM del test; propaga errores del desmontaje. */
    async limpiar() {
      await act(async () => raiz.unmount())
      contenedor.remove()
    },
  }
}

/** Cambia un input controlado con su setter nativo y evento; devuelve promesa, sin errores propios. */
export async function escribir(campo, valor) {
  await act(async () => {
    const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set
    setter.call(campo, valor)
    campo.dispatchEvent(new Event('input', { bubbles: true }))
  })
}

/** Pulsa botón/radio como el usuario; espera React, devuelve promesa y propaga errores del evento. */
export async function pulsar(elemento) {
  await act(async () => elemento.click())
}
