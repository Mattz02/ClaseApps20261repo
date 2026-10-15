import { useDivisor } from './useDivisor.js'
import { formateadorMoneda } from './formateadorMoneda.js'

const campos = [
  { nombre: 'monto', etiqueta: 'Monto total', ejemplo: '100.00', teclado: 'decimal' },
  { nombre: 'personas', etiqueta: 'Número de personas', ejemplo: '4', teclado: 'numeric' },
  { nombre: 'propina', etiqueta: 'Porcentaje de propina', ejemplo: '0', teclado: 'decimal' },
]

/** Recibe dependencias y muestra el formulario; devuelve JSX. Los errores de entrada los gestiona el hook. */
export default function PantallaDivisor({ dependencias }) {
  const { entrada, salida, opciones, cambiarCampo, cambiarModo, calcular } = useDivisor(dependencias)
  const errores = salida?.estado === 'error' ? salida.errores : {}

  /** Evita navegación y solicita cálculo; recibe submit, no devuelve valor y propaga errores de contrato. */
  function enviar(evento) {
    evento.preventDefault()
    calcular()
  }

  return (
    <main className="pagina">
      <header className="encabezado">
        <div className="marca" aria-hidden="true">÷</div>
        <p className="eyebrow">CUENTAS CLARAS</p>
        <h1>La cuenta, entre todos.</h1>
        <p className="introduccion">Agrega la propina y descubre cuánto paga cada persona.</p>
      </header>

      <section className="tarjeta" aria-label="Dividir la cuenta">
        <form noValidate onSubmit={enviar}>
          <div className="titulo-formulario"><span className="paso">01</span><h2>Los números de la mesa</h2></div>
          <div className="campos">
            {campos.map(({ nombre, etiqueta, ejemplo, teclado }) => (
              <div className={`campo campo-${nombre}`} key={nombre}>
                <label htmlFor={nombre}>{etiqueta}</label>
                <div className="entrada-contenedor">
                  <input id={nombre} name={nombre} type="text" inputMode={teclado}
                    placeholder={ejemplo} autoComplete="off" spellCheck={false}
                    aria-invalid={errores[nombre] ? true : undefined}
                    aria-describedby={errores[nombre] ? `error-${nombre}` : nombre === 'propina' ? 'ayuda-propina' : undefined}
                    value={entrada[nombre]} onChange={evento => cambiarCampo(nombre, evento.target.value)} />
                  {nombre === 'propina' && <span className="sufijo" aria-hidden="true">%</span>}
                </div>
                {nombre === 'propina' && <small id="ayuda-propina">Opcional. Vacío equivale a 0 %.</small>}
                {errores[nombre] && <p className="error-campo" id={`error-${nombre}`} role="alert">{errores[nombre]}</p>}
              </div>
            ))}
          </div>

          <fieldset>
            <legend>¿Cómo quieres redondear?</legend>
            <div className="modos">
              {opciones.map(({ id, etiqueta }) => (
                <label className="opcion" key={id}>
                  <input type="radio" name="modo" value={id} checked={entrada.modo === id}
                    onChange={() => cambiarModo(id)} />
                  <span>{etiqueta}</span>
                </label>
              ))}
            </div>
          </fieldset>

          <button className="calcular" type="submit">Calcular <span aria-hidden="true">↗</span></button>
        </form>

        <div className="panel-resultado" aria-live="polite" aria-atomic="true">
          {salida?.estado === 'exito' ? (
            <>
              <p className="eyebrow">A CADA PERSONA LE TOCA</p>
              <p className="importe"><output aria-label="Monto por persona">{formateadorMoneda(salida.montoPorPersonaCentavos)}</output></p>
              <p className="por-persona">por persona</p>
              <span className="linea" />
              <p className="nota-resultado">Una misma parte para todos.<br />Ahora sí, a disfrutar la sobremesa.</p>
            </>
          ) : (
            <>
              <span className="ilustracion" aria-hidden="true">{salida?.estado === 'error' ? '!' : '÷'}</span>
              <h2>{salida?.estado === 'error' ? 'Revisemos los datos.' : 'Compartir es más fácil.'}</h2>
              <p>{salida?.estado === 'error' ? 'Corrige los campos marcados y vuelve a calcular.' : <>Completa los datos y pulsa<br /><strong>Calcular</strong> para dividir la cuenta.</>}</p>
            </>
          )}
        </div>
      </section>
      <footer>Hecho para la mesa. <span>Funciona sin conexión después de cargar.</span></footer>
    </main>
  )
}
