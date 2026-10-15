import { validarEntrada } from '../../src/domain/validarEntrada.js'
import { calcularDivision } from '../../src/domain/calcularDivision.js'
import { crearRedondeoExacto } from '../../src/data/redondeoExacto.js'
import { crearRedondeoHaciaArriba } from '../../src/data/redondeoHaciaArriba.js'

/** Crea fixtures reales del modo Exacto; devuelve dependencias, sin errores propios. */
export function dependenciasExactas() {
  return {
    validarEntrada,
    calcularDivision,
    opcionesRedondeo: [{ id: 'exacto', etiqueta: 'Exacto', estrategia: crearRedondeoExacto() }],
  }
}

/** Crea catálogo de producción para pruebas; devuelve dependencias sin errores propios. */
export function dependenciasCompletas() {
  const deps = dependenciasExactas()
  deps.opcionesRedondeo.push({ id: 'arriba', etiqueta: 'Hacia arriba', estrategia: crearRedondeoHaciaArriba() })
  return deps
}
