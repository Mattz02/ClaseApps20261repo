# Cuentas claras

Aplicación de una pantalla para dividir una cuenta y su propina entre varias personas.
React con Vite y JavaScript. Sin backend, bibliotecas de estado externas ni persistencia.

## Ejecutar

Requiere Node 24 LTS >=24.15.0 y npm. Instalar dependencias necesita acceso al registro npm
(o disponer de ellas en caché).

```bash
npm ci
npm run dev
```

Abrir la dirección que muestra Vite. Para validar la entrega:

```bash
npm test
npm run lint
npm run build
npm run preview -- --host 127.0.0.1
```

`npm run test:watch` observa cambios. Vitest ejecuta dominio/proveedores/formato en Node y
hook/pantalla en jsdom, con React act y StrictMode.

## Usar

Ingresar monto, personas y propina opcional; elegir Exacto o Hacia arriba y pulsar Calcular.
Se aceptan punto o coma decimal. La salida no lleva símbolo de moneda y siempre tiene dos
cifras decimales. Al editar cualquier dato o modo se ocultan resultado y errores anteriores.

| Monto | Personas | Propina % | Modo | Por persona |
|-------|----------|-----------|------|-------------|
| 100.00 | 4 | 10 | Exacto | 27.50 |
| 10.00 | 3 | 0 | Exacto | 3.33 |
| 10.00 | 3 | 0 | Hacia arriba | 4.00 |

No se reparten centavos sobrantes: 3 × 3.33 puede sumar 9.99 para una cuenta de 10.00.

## Arquitectura y composición

```text
src/presentation ──> src/domain <── src/data
                         ↑
                 src/main.jsx compone
```

- `domain`: datos y funciones puras, sin React ni DOM. La validación no está en el cálculo.
- `data`: proveedores Exacto y Hacia arriba, con el único método `aplicar(valor)`.
- `presentation`: hook con dependencias recibidas, formato monetario y pantalla.
- `main.jsx`: instancia una vez los proveedores y entrega el catálogo y funciones al componente.

La constitución 2.0.0 permite registrar un nuevo proveedor en main sin editar cálculo,
validación, hook ni pantalla. La búsqueda es por id en el catálogo, sin instanceof ni switches.
Los tests prueban esto con un tercer proveedor ficticio; la aplicación publica dos modos.

## Cómo se evitan errores de redondeo

Monto en centavos (`100.00` -> `10000n`), propina en centésimas de porcentaje (`10` -> `1000n`)
y personas enteras son BigInt. La letra `n` identifica un entero exacto de JavaScript.

Para una Cuenta validada, el monto sin redondear por persona es la fracción en centavos:

```text
N = montoCentavos × (10000 + propinaCentesimas)
D = 10000 × personas
```

- Exacto: dividir N/D, conservar el resto y subir un centavo cuando sea al menos la mitad de D.
- Hacia arriba: calcular directamente el techo de N/(100×D) y volver a centavos multiplicando
  por 100. No redondear primero a centavos: 1.00 con 0.01 % da 2.00 hacia arriba.
- Formato: separar entero/resto de centavos entre 100 y completar dos cifras, sin Number.

El numerador máximo excede Number.MAX_SAFE_INTEGER; por eso toda esa aritmética usa BigInt.

## Guía para explicar las funciones

| Función | Por qué existe / qué recibe | Qué devuelve | Errores |
|---------|----------------------------|--------------|---------|
| leerDecimal | Leer un texto decimal completo y escalarlo a centésimas | bigint o null | Sintaxis inválida devuelve null |
| validarEntrada | Validar los tres textos numéricos y conservar modo | Cuenta normalizada o mapa de errores | Mensajes de campo; no lanza por entrada inválida |
| calcularDivision | Separar el cálculo de validación y formato; recibe Cuenta y estrategia | Éxito con centavos finales | Propaga fallos de contrato de la dependencia |
| crearRedondeoExacto | Crear la política de centavo al componer | Objeto con aplicar | Sin errores propios |
| Exacto.aplicar | Redondear una fracción en centavos | Centavos bigint, mitades arriba | BigInt propaga TypeError/RangeError ante contrato inválido |
| crearRedondeoHaciaArriba | Crear la política entera al componer | Objeto con aplicar | Sin errores propios |
| HaciaArriba.aplicar | Obtener techo entero de la fracción original | Centavos bigint múltiplos de 100 | Mismos errores de contrato BigInt |
| formateadorMoneda | Mostrar centavos no negativos sin alterar su valor | string con punto y dos decimales | Tipo incompatible: TypeError |
| useDivisor | Coordinar useState, validación y cálculo recibidos | Estado, opciones y manejadores | Propaga errores de composición/dependencias |
| cambiarCampo | Actualizar nombre/valor de campo y borrar salida anterior | Sin retorno | Sin errores propios; solo se usan campos del formulario |
| cambiarModo | Editar el id mediante cambiarCampo | Sin retorno | Sin errores propios |
| calcular del hook | Ejecutar validación y seleccionar estrategia al enviar | Actualiza salida, sin retorno | Id no registrado: Error de programación |
| PantallaDivisor | Presentar las dependencias mediante formulario y resultado | JSX | Propaga errores de programación; muestra mensajes de entrada |
| enviar | Recibir submit, evitar navegación y pedir cálculo | Sin retorno | Propaga errores del hook |

`cuenta.js`, `resultado.js` y `estrategiaRedondeo.js` documentan tipos JSDoc, no crean servicios.
Los callbacks de useState crean/actualizan registros sin mutarlos; map genera opciones/campos,
find localiza el id y onChange transmite el valor de un evento. No hacen cálculo monetario.

Para los tests:

- `montar(elemento)` crea un contenedor y raíz React en StrictMode; devuelve contenedor y
  `limpiar()`, que desmonta y retira el DOM. Ambos propagan errores de React.
- `escribir(campo, valor)` usa el setter nativo y un evento input; `pulsar(elemento)` hace click.
  Ambos esperan act, devuelven una promesa y propagan errores de interacción.
- `dependenciasExactas()` y `dependenciasCompletas()` crean fixtures, sin errores propios.
- `observar(dependencias)` monta un componente que copia el resultado del hook en un efecto
  de layout y devuelve una función para consultar su último estado.
- `abrir(dependencias)` monta la pantalla; `campo(dom, nombre)` localiza y comprueba un input;
  `completar(dom, monto, personas, propina)` escribe en los tres campos.
- `contratoEstrategia(nombre, crear)` registra la misma suite para cada fábrica. Los callbacks
  de it/describe/each reciben fixtures, ejecutan acciones y comparan resultados; expect lanza
  errores de aserción si no coinciden. afterEach restaura mocks y desmonta la vista.

Esta guía prepara la revisión de la materia. La explicación efectiva por parte del estudiante
se comprobará con él; no se afirma haber realizado esa revisión.

## Sin conexión y datos

Después de cargar los recursos, cálculos, validaciones y cambios de modo funcionan sin red.
La aplicación no realiza peticiones ni persiste datos del formulario. No se garantiza primera
apertura remota ni recarga sin conexión. No se incorpora PWA ni caché persistente.

La prueba consiste en cargar el build, activar Offline **sin recargar** y ejecutar A1–A7,
comprobando resultados, errores y limpieza de salida. Procedimiento y evidencia en
[quickstart](specs/001-divisor-cuenta/quickstart.md).

La spec permanece en [spec.md](specs/001-divisor-cuenta/spec.md). El plan y las tareas están
junto a ella. No se necesitan secretos ni API keys; los archivos .env están ignorados.
