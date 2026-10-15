import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import PantallaDivisor from './presentation/PantallaDivisor.jsx'
import { validarEntrada } from './domain/validarEntrada.js'
import { calcularDivision } from './domain/calcularDivision.js'
import { crearRedondeoExacto } from './data/redondeoExacto.js'
import { crearRedondeoHaciaArriba } from './data/redondeoHaciaArriba.js'

const dependencias = {
  validarEntrada,
  calcularDivision,
  opcionesRedondeo: [
    { id: 'exacto', etiqueta: 'Exacto', estrategia: crearRedondeoExacto() },
    { id: 'arriba', etiqueta: 'Hacia arriba', estrategia: crearRedondeoHaciaArriba() },
  ],
}

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <PantallaDivisor dependencias={dependencias} />
  </StrictMode>,
)
