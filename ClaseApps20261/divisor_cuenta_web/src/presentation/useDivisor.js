import { useState } from 'react'

/**
 * Coordina la única pantalla con dependencias recibidas: validación, cálculo y catálogo.
 * Devuelve estado/opciones/manejadores; propaga errores de programación sin convertirlos en errores de campo.
 */
export function useDivisor({ validarEntrada, calcularDivision, opcionesRedondeo }) {
  const [estado, setEstado] = useState(() => ({
    entrada: { monto: '', personas: '', propina: '', modo: opcionesRedondeo[0].id },
    salida: null,
  }))

  /** Recibe nombre/valor de campo, actualiza entrada y borra salida; no calcula ni devuelve valor. */
  function cambiarCampo(campo, valor) {
    setEstado(anterior => ({
      entrada: { ...anterior.entrada, [campo]: valor },
      salida: null,
    }))
  }

  /** Recibe id del catálogo y delega la edición; sin retorno ni errores propios. */
  function cambiarModo(id) {
    cambiarCampo('modo', id)
  }

  /** Valida el estado actual y calcula al enviar; sin retorno. Id desconocido es error de composición. */
  function calcular() {
    const validacion = validarEntrada(estado.entrada)
    if (!validacion.valida) {
      setEstado(anterior => ({ ...anterior, salida: { estado: 'error', errores: validacion.errores } }))
      return
    }
    const opcion = opcionesRedondeo.find(opcion => opcion.id === validacion.cuenta.modo)
    if (!opcion) throw new Error('Modo de redondeo no registrado')
    const salida = calcularDivision(validacion.cuenta, opcion.estrategia)
    setEstado(anterior => ({ ...anterior, salida }))
  }

  return {
    ...estado,
    opciones: opcionesRedondeo.map(({ id, etiqueta }) => ({ id, etiqueta })),
    cambiarCampo,
    cambiarModo,
    calcular,
  }
}
