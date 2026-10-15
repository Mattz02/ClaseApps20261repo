# Tasks: Dividir la cuenta del restaurante

**Input**: documentos de `specs/001-divisor-cuenta/`.

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md),
[data-model.md](data-model.md), [dominio](contracts/dominio.md),
[pantalla](contracts/pantalla.md), [quickstart.md](quickstart.md) y constitución v2.0.0
en `.specify/memory/constitution.md`.

**Tests**: obligatorias por la petición «Pruebas con Vitest», el plan y la constitución.
Las tareas de pruebas preceden a la implementación del comportamiento correspondiente;
comprobar fallos esperados antes de implementarlo, sin aceptar fallos de configuración
como evidencia de comportamiento. Conservar todas las suites anteriores al añadir historias.

**Organization**: Setup -> Foundational -> US1 (P1) -> US2 (P2) -> US3 (P3) -> Polish.
Las casillas [X] registran tareas realizadas; las casillas sin marcar conservan trabajo pendiente.
La spec se conserva intacta. No se añaden backend, estado externo, persistencia ni PWA.

**Alcance actualizado**: después de cargar los recursos, cálculos, validaciones y cambios
de modo funcionan sin red, sin peticiones ni persistencia del formulario. No se garantiza
primera apertura remota ni recarga sin conexión. OCP 2.0.0 permite el registro en main
sin modificar cálculo, validación, hook ni pantalla.

## Format: `[ID] [P?] [Story] Description`

- Cada tarea tiene casilla, identificador secuencial y rutas exactas.
- `[P]` permite trabajo simultáneo solo cuando sus prerrequisitos estén completos y los
  archivos sean distintos. No autoriza ejecutar tareas dependientes antes de tiempo.
- `[US1]`, `[US2]` y `[US3]` identifican historias; Setup, Foundational y Polish no llevan historia.

## Path Conventions

Rutas relativas a la raíz `divisor_cuenta_web`: `src/`, `tests/`, `specs/001-divisor-cuenta/`.
Las fábricas concretas solo se instancian en `src/main.jsx` en producción; los tests pueden
instanciarlas como fixtures. Los modelos son registros de datos con contratos JSDoc.

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: preparar el proyecto Vite existente y el runner, sin volver a inicializar React.

- [X] T001 Añadir Vitest 5 y jsdom 30 como devDependencies en `package.json` y resolver `package-lock.json`, conservar React/Vite y lint existentes, declarar Node 24 >=24.15.0 y scripts `test: vitest run` y `test:watch: vitest`; comprobar instalación reproducible con npm ci.
- [X] T002 Configurar Vitest en `vite.config.js`, conservando el plugin React, con entorno Node por defecto y soporte para suites `.test.js`/`.test.jsx`; las suites UI seleccionarán jsdom mediante `@vitest-environment jsdom`, sin añadir bibliotecas de estado ni de pruebas adicionales.
- [X] T003 [P] Crear `tests/helpers/reactDom.js` para montar/desmontar con createRoot y act de React, habilitar IS_REACT_ACT_ENVIRONMENT, limpiar contenedores y emitir eventos que activen onChange controlado; soportar StrictMode y evitar asignar value sin evento como sustituto de interacción (depende de T001; compatible en paralelo con T002).

**Checkpoint**: dependencias instaladas y entorno preparado para escribir pruebas reales.

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: contratos de datos, estrategia y validación compartidos por las tres historias.
Completar esta fase antes de implementar historias. La detección de inválidos es compartida;
US2 incorpora su presentación y las interacciones de errores, sin duplicar el validador.

- [X] T004 [P] Definir con JSDoc Cuenta/EntradaFormulario en `src/domain/cuenta.js` y Resultado/ValidacionEntrada en `src/domain/resultado.js`: montoCentavos bigint «1..99999999999», personas bigint «1..1000000», propinaCentesimas bigint «0..99999», modo string «exacto o arriba en esta feature»; entradas monto/personas «vacío», propina «vacío, equivale a cero al calcular», modo «exacto»; éxito/error excluyentes, sin monto en error y sin cálculo, formato ni servicios concretos en modelos. La restricción «exacto o arriba en esta feature» describe los ids iniciales: modo sigue siendo string, sin enum cerrado en validación.
- [X] T005 [P] Definir en `src/domain/estrategiaRedondeo.js` el contrato JSDoc de ValorDivision y EstrategiaRedondeo: numerador «bigint >=0», denominador «bigint >0», único método `aplicar(valor) -> bigint` en centavos no negativos, sin mutación ni efectos; documentar las precondiciones comunes y los errores de programación fuera del contrato.
- [X] T006 [P] Escribir `tests/unit/validarEntrada.test.js` para entradas válidas y todos los bordes FR-008–013: coma/punto, propina vacía, signos/ceros/espacios, .5 y 12., rechazo de exponentes/hex/miles/separadores mezclados, monto vacío/abc/0/negativo/>2 decimales/topes, personas 0/negativas vs vacío/dos/2.5/2,5/2.0/>1000000, propina negativa/abc/>2 decimales/>999.99 y varios errores simultáneos; comprobar tipos BigInt y mensajes exactos de `specs/001-divisor-cuenta/contracts/dominio.md`. Agregar entrada numérica válida con un tercer id de modo y verificar que se conserva, sin imponer una lista exacto/arriba.
- [X] T007 Implementar `validarEntrada(entrada)` en `src/domain/validarEntrada.js` después de T004/T006: validar texto completo, recortar espacios, normalizar coma y escala sin Number/parseFloat ni redondeo; devolver `{valida: true, cuenta}` o `{valida: false, errores}` sin excepciones por entrada del usuario y sin Cuenta parcial; respetar todos los límites de T004 y pasar T006. Conservar el id de modo recibido sin validarlo contra un enum cerrado ni reglas por estrategia; la selección procede del catálogo controlado.

**Checkpoint**: contratos disponibles y validación completa probada; ningún flujo necesita
calcular con entradas inválidas. Estos módulos no importan React ni utilizan DOM.

## Phase 3: User Story 1 - Calcular cuánto paga cada persona (Priority: P1) — MVP

**Goal**: introducir datos válidos y calcular en modo Exacto con propina, dos decimales y
ocultación del resultado al editar. Esta entrega inicial publica solo la estrategia Exacto;
US3 añadirá Hacia arriba mediante el catálogo sin cambiar consumidores.

**Independent Test**: formulario real: A1 (100.00/4/10 -> 27.50), A2 (90.00/3/0 -> 30.00),
A5 (10.00/3/0 -> 3.33). No calcular al escribir; editar borra el resultado.

### Tests for User Story 1

- [X] T008 [P] [US1] Crear `tests/contract/estrategiaRedondeo.test.js` con una suite reutilizable aplicada inicialmente a crearRedondeoExacto: único método aplicar, retorno BigInt no negativo, no mutación, cero y una unidad monetaria; reutilizar esa suite al registrar la segunda estrategia en US3.
- [X] T009 [P] [US1] Escribir `tests/unit/calcularDivision.test.js` con Cuenta válida y estrategia ficticia inyectada: comprobar N=montoCentavos*(10000n+propinaCentesimas), D=10000n*personas, una llamada a aplicar y Resultado con su retorno; incluir los máximos y demostrar que no hay elección por tipo, validación de texto ni formato en el cálculo.
- [X] T010 [P] [US1] Escribir casos Exacto en `tests/unit/redondeo.test.js` para 27.50, 30.00, 3.33, mitad 6.67/2 -> 3.34, valor diminuto -> 0.00 y máximo -> 10999899999.89, según `specs/001-divisor-cuenta/contracts/dominio.md`, usando fracciones BigInt sin convertirlas a Number.
- [X] T011 [P] [US1] Escribir `tests/unit/formateadorMoneda.test.js` para 0n -> 0.00, 1n -> 0.01, 2750n -> 27.50, 400n -> 4.00 y el máximo del contrato, siempre con punto y dos cifras, sin símbolo ni agrupación de miles.
- [X] T012 [P] [US1] Escribir `tests/integration/useDivisor.test.jsx` en jsdom con dependencias ficticias: entradas iniciales vacías, modo exacto, salida null, escritura sin cálculo, submit con una llamada, edición de cada campo borra éxito, y validación falsa nunca llama al cálculo; no exigir mensajes visibles hasta US2. Agregar un id/proveedor ficticio adicional al catálogo y comprobar selección genérica por id y uso de aplicar, sin cambiar consumidores.
- [X] T013 [P] [US1] Escribir `tests/integration/PantallaDivisor.test.jsx` usando `tests/helpers/reactDom.js`: tres campos etiquetados, modo Exacto inicial, submit sin navegación, A1/A2/A5, coma en monto/propina (12,50/2/10,5 -> 6.91), propina vacía como cero y ocultación del éxito al editar; probar interacción bajo StrictMode. Probar también una opción con id/proveedor ficticio adicional solo en el catálogo inyectado de pruebas, calculada mediante aplicar sin cambios en los consumidores ni tercer modo de producción.

### Implementation for User Story 1

- [X] T014 [P] [US1] Implementar crearRedondeoExacto en `src/data/redondeoExacto.js`: aplicar recibe N/D en centavos, usa q=N/D y r=N%D, devuelve q+1n si 2n*r>=D, o q; sin formato ni validación de formulario y con igual contrato de T005 (después de T008/T010).
- [X] T015 [P] [US1] Implementar `calcularDivision(cuenta, estrategia)` en `src/domain/calcularDivision.js` con las fórmulas de T009 y retorno de éxito de T004; llamar aplicar una vez sin redondeo previo, switches, validación ni formato (después de T009).
- [X] T016 [P] [US1] Implementar `formateadorMoneda(centavos)` en `src/presentation/formateadorMoneda.js` con cociente/resto BigInt entre 100n y relleno de dos cifras, sin Number, locale ni símbolos (después de T011).
- [X] T017 [US1] Implementar `useDivisor(dependencias)` en `src/presentation/useDivisor.js` con useState local y `{validarEntrada, calcularDivision, opcionesRedondeo}` recibidos: `{entrada, salida}` con salida null inicial, editar borra salida en la misma actualización, submit valida antes de calcular y resuelve estrategia genéricamente por id sin enum cerrado ni switches; ante inválidos no calcular ni conservar éxito, sin importar data ni crear proveedores (después de T012).
- [X] T018 [US1] Implementar `src/presentation/PantallaDivisor.jsx` y estilos locales en `src/index.css`: hook inyectado, formulario noValidate, inputs de texto controlados con inputMode, catálogo de modos generado desde datos y resultado formateado «por persona»; sin React/DOM en dominio ni peticiones a recursos remotos (después de T013/T016/T017).
- [X] T019 [US1] Componer en `src/main.jsx` la estrategia Exacto una sola vez, las funciones de dominio y el catálogo `{id: 'exacto', etiqueta: 'Exacto', estrategia}`; pasar dependencias a PantallaDivisor y conservar StrictMode; retirar montaje/archivos de demostración sin uso de `src/App.jsx`, `src/App.css` y `src/assets/` sin afectar recursos del proyecto (después de T014/T015/T018).
- [X] T020 [US1] Ejecutar las suites de `tests/unit/`, `tests/contract/estrategiaRedondeo.test.js` y `tests/integration/`, comprobar A1/A2/A5 y build del incremento, y registrar resultados reales del checkpoint US1 en `specs/001-divisor-cuenta/quickstart.md`; corregir fallos dentro de los archivos de esta historia antes de cerrarla.

**Checkpoint**: cálculo exacto funcional con datos válidos, sin reparto de centavos sobrantes.
La validación protege el cálculo; la visualización completa de sus errores sigue en US2.

## Phase 4: User Story 2 - Avisar cuando los datos no son válidos (Priority: P2)

**Goal**: mostrar todos los mensajes exactos de campo, nunca un monto inválido, y eliminar
errores al editar cualquier campo o modo. Reutilizar la validación de Foundational.

**Independent Test**: A3 (50.00/0 -> «Debe haber al menos una persona») y A4 (abc ->
«Monto inválido»), sin resultado. Probar varios errores tras un éxito y su eliminación al editar.

### Tests for User Story 2

- [X] T021 [P] [US2] Ampliar `tests/integration/useDivisor.test.jsx`: validación falsa produce Resultado de error con todos los campos y sin monto, jamás llama al cálculo, no conserva éxito previo y cada campo/modo borra todos los errores hasta nuevo submit; usar catálogo ficticio de dos ids para probar cambio de modo sin depender de US3.
- [X] T022 [P] [US2] Ampliar `tests/integration/PantallaDivisor.test.jsx` con A3/A4 y matriz inválida FR-009–013 del contrato: distinguir «Debe haber al menos una persona», «Número de personas inválido», «Monto inválido» y «Propina inválida»; comprobar mensajes simultáneos, asociación a campos, ausencia de monto incluso tras éxito, y desaparición al editar sin errores HTML nativos.

### Implementation for User Story 2

- [X] T023 [US2] Completar la rama inválida en `src/presentation/useDivisor.js` para representar `{estado: 'error', errores}` de validación con exclusión total del monto anterior y limpieza atómica al editar; no duplicar reglas del validador ni capturar errores de programación como errores de campo (después de T021).
- [X] T024 [US2] Mostrar errores por campo en `src/presentation/PantallaDivisor.jsx`, con texto exacto, etiquetas/asociaciones de error y aria-invalid cuando corresponda; representar exclusivamente errores o éxito y mantener noValidate, sin añadir validación/calculadora en JSX (después de T022/T023).
- [X] T025 [US2] Ejecutar `tests/unit/validarEntrada.test.js` y las suites de `tests/integration/` junto con regresión US1, comprobar A3/A4 y todos los límites, y registrar resultados reales del checkpoint US2 en `specs/001-divisor-cuenta/quickstart.md`.

**Checkpoint**: US1 y US2 se verifican con sus escenarios aislados; ninguna entrada inválida
produce monto visible (SC-005). El hook ya admite cualquier estrategia del catálogo.

## Phase 5: User Story 3 - Redondear hacia arriba (Priority: P3)

**Goal**: añadir Hacia arriba con el contrato existente y publicar los dos modos.

**Independent Test**: A6 (10.00/3/0 -> 4.00) y A7 (90.00/3/0 -> 30.00); cambiar modo
oculta salida y solo el siguiente submit calcula con la estrategia elegida.

### Tests for User Story 3

- [X] T026 [P] [US3] Añadir casos Hacia arriba en `tests/unit/redondeo.test.js`: A6/A7, 6.67/2 -> 4.00, 1.00 con 0.01 % -> 2.00 sin redondeo previo, 0.01/1000000 -> 1.00 y máximo -> 10999900000.00; conservar casos Exacto sin cambiar sus expectativas.
- [X] T027 [P] [US3] Ampliar `tests/contract/estrategiaRedondeo.test.js` para aplicar la misma suite a crearRedondeoExacto y crearRedondeoHaciaArriba: mismos parámetros/unidades/retornos y no mutación, sin exigir igualdad de importes entre políticas; mantener prueba de sustitución del cálculo.
- [X] T028 [P] [US3] Ampliar `tests/integration/useDivisor.test.jsx` con catálogo de ambas estrategias reales como fixtures: seleccionar por id, usar la dependencia correcta y borrar resultados/errores al alternar modos, sin recalcular ni consultar tipos concretos. Agregar al catálogo un tercer id/proveedor ficticio y usar validador/cálculo reales para demostrar extensión sin editar validación, cálculo, hook ni pantalla.
- [X] T029 [P] [US3] Ampliar `tests/integration/PantallaDivisor.test.jsx` con ambas opciones generadas desde catálogo, A6/A7, alternancia Exacto/Hacia arriba y ocultación del éxito/error hasta enviar de nuevo; verificar resultado siempre con dos cifras y conservación de A1–A5. Repetir con un tercer id/proveedor ficticio inyectado y dependencias reales, sin editar los cuatro consumidores ni publicarlo en el catálogo de producción.

### Implementation for User Story 3

- [X] T030 [US3] Implementar crearRedondeoHaciaArriba en `src/data/redondeoHaciaArriba.js`: aplicar obtiene techo de N/(100n*D) con cociente/resto y multiplica por 100n, conserva los enteros y no llama al redondeo exacto ni convierte a Number (después de T026/T027).
- [X] T031 [US3] Instanciar Hacia arriba una vez y añadir `{id: 'arriba', etiqueta: 'Hacia arriba', estrategia}` al catálogo en `src/main.jsx`, manteniendo Exacto como inicial; registro permitido por la constitución 2.0.0; comprobar que no requiere editar `src/domain/calcularDivision.js`, `src/domain/validarEntrada.js`, `src/presentation/useDivisor.js` ni `src/presentation/PantallaDivisor.jsx` (después de T030).
- [X] T032 [US3] Ejecutar todas las suites en `tests/`, comprobar los seis escenarios originales 6/6, A7 y tabla de precisión de ambos modos, y registrar resultados reales del checkpoint US3 en `specs/001-divisor-cuenta/quickstart.md`.

**Checkpoint**: las tres historias completas, con catálogos intercambiables y todos los criterios
de aceptación funcionales cubiertos por pruebas ejecutables.

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: verificar el conjunto, los límites de operación y la comprensión del código.

- [X] T033 [P] Añadir en `tests/integration/PantallaDivisor.test.jsx` pruebas de aislamiento que bloqueen accesos de aplicación a fetch/XHR/localStorage/sessionStorage/IndexedDB/cookies durante cálculos y edición; desmontar/remontar como nueva sesión para verificar valores iniciales, y restaurar los spies tras cada prueba (FR-015). Cubrir además validaciones y cambios de modo sin peticiones ni persistencia; complementar con el recorrido de navegador sobre build en T036.
- [X] T034 [P] Actualizar `README.md` con instalación/ejecución/pruebas, unidades BigInt, diagrama de capas y composición, y guía para explicar cada función generada por propósito, entradas, retorno y errores, incluyendo helpers de tests; enlazar `specs/001-divisor-cuenta/quickstart.md` sin afirmar una revisión del estudiante que no se haya realizado. Documentar constitución 2.0.0 y operación sin red tras cargar recursos: cálculos, validaciones y modos sin peticiones ni persistencia del formulario; sin garantizar primera apertura remota ni recarga sin conexión.
- [X] T035 Revisar dependencias y seguridad en `src/main.jsx`, `src/domain/`, `src/data/` y `src/presentation/`: dominio sin React/DOM/formato, presentación sin data, fábricas concretas solo en main, sin type switches, enums cerrados de modo ni secretos/API keys; contrastar con `.specify/memory/constitution.md` y registrar hallazgos/correcciones reales en `specs/001-divisor-cuenta/quickstart.md`. Aplicar OCP 2.0.0: registro permitido en main sin editar cálculo, validación, hook ni pantalla; comprobar la extensión con tercer id en las pruebas.
- [X] T036 Ejecutar npm test, npm run lint y npm run build con los scripts de `package.json`; servir dist con npm run preview, cargar todos los recursos del build y activar Offline sin recargar; ejecutar A1–A7 verificando los mismos resultados y mensajes de `specs/001-divisor-cuenta/contracts/pantalla.md`, incluido ningún monto para A3/A4, y probar límites, edición y cambios de ambos modos con limpieza de salida hasta el siguiente submit; comprobar cero peticiones durante cálculos, validaciones y cambios de modo y cero persistencia del formulario; registrar evidencia real de FR-015/SC-001/004/005 en `specs/001-divisor-cuenta/quickstart.md`, sin garantizar primera apertura remota ni recarga sin conexión.
- [X] T037 Seguir las mediciones de `specs/001-divisor-cuenta/quickstart.md`: primer uso real <30 s (SC-002) y submit hasta frame con resultado <1000 ms en build, ambos modos y máximos (SC-003); documentar tiempos/dispositivo y revisión explicativa con el estudiante cuando se realicen, dejando explícitamente pendiente cualquier verificación humana no disponible y sin reemplazarla por tiempos jsdom.

**Checkpoint**: pruebas, lint y build pasan; los criterios medibles se registran con evidencia.
No marcar comprobaciones manuales como realizadas si solo se preparó su procedimiento.

## Dependencies & Execution Order

### Phase Dependencies

```text
Setup (T001–T003)
        |
Foundational (T004–T007)
        |
US1 / P1 (T008–T020)
        |
US2 / P2 (T021–T025)
        |
US3 / P3 (T026–T032)
        |
Polish (T033–T037)
```

US2 reutiliza el cálculo/formulario de US1. US3 reutiliza su composición genérica y se entrega
después de US2 para verificar también los errores al cambiar modo. Los tests de cada historia
son aislados, pero no se deben editar hook/pantalla de distintas historias simultáneamente.

### Within Each Phase

- Setup: T001 antes de T002/T003; T002 y T003 pueden hacerse a la vez.
- Foundational: T004/T005/T006 en paralelo; T007 requiere T004/T006; cerrar también T005.
- US1: T008–T013 son pruebas en archivos distintos; después T014/T015/T016 pueden avanzar
  en paralelo. T017 requiere T012 y la base; T018 requiere T013/T016/T017; T019 requiere
  T014/T015/T018; T020 cierra la historia con todas sus pruebas.
- US2: T021/T022 en paralelo; después T023 -> T024 -> T025.
- US3: T026–T029 en paralelo; después T030 -> T031 -> T032.
- Polish: T033/T034 en paralelo; después T035 -> T036 -> T037. El registro compartido en
  quickstart se actualiza secuencialmente para evitar sobrescrituras.

### Parallel Opportunities

`[P]` describe oportunidades para quien ejecute las tareas; no implica delegación automática.
No paralelizar tareas sobre el mismo archivo aunque pertenezcan a historias diferentes.
Las implementaciones T014/T015/T016 requieren sus pruebas y contratos previos, pero ninguna
requiere que las otras dos implementaciones estén terminadas.

## Parallel Example: User Story 1

Con Foundational completa, preparar T008/T009/T010/T011/T012/T013 en archivos distintos.
Después de las pruebas correspondientes: T014 (`src/data/redondeoExacto.js`), T015
(`src/domain/calcularDivision.js`) y T016 (`src/presentation/formateadorMoneda.js`) pueden
implementarse simultáneamente; completar hook, pantalla y composición en el orden indicado.

## Parallel Example: User Story 2

Con US1 completa, T021 (`tests/integration/useDivisor.test.jsx`) y T022
(`tests/integration/PantallaDivisor.test.jsx`) pueden prepararse en paralelo.
No modificar ambos archivos desde otra historia durante esa preparación.

## Parallel Example: User Story 3

Con US2 completa, preparar en paralelo T026 (unitarias de redondeo), T027 (contrato),
T028 (hook) y T029 (pantalla): son cuatro archivos distintos.
El proveedor y su registro en main siguen en secuencia, T030 -> T031.

## Implementation Strategy

### MVP First (User Story 1 Only)

Completar Setup, Foundational y US1 (T001–T020). Validar A1/A2/A5 con la pantalla montada
y comprobar la mitad ascendente y los máximos. El MVP cubre cálculo exacto con entradas
válidas; no representa la entrega completa de la spec hasta incorporar US2 y US3.

### Incremental Delivery

1. Entregar US1 y conservar sus pruebas como regresión.
2. Añadir US2: errores exactos por campo y limpieza de salidas, sin reescribir el cálculo.
3. Añadir US3: nuevo proveedor y registro en main, sin modificar consumidores.
4. Completar Polish y ejecutar el recorrido completo de quickstart sobre el build.

### Traceability

| Cobertura | Tareas principales |
|-----------|--------------------|
| FR-001/003/004/005/007, A1/A2/A5 | T009–T020 |
| FR-008/009/010/011/012/013, A3/A4 | T006/T007, T013, T021–T025 |
| FR-002/006, A6/A7 | T026–T032 (modo inicial en T012/T013/T019) |
| FR-014 | T012/T013/T017, T021–T024, T028/T029 |
| FR-015, SC-004 (tras cargar recursos; Offline sin recargar) | T033/T034/T036 |
| SC-001, SC-005 | T020/T025/T032/T036 |
| SC-002/003 | T037 |
| SOLID, capas, seguridad y regla de la materia | T004–T009/T012/T013, T019/T027–T031, T034/T035/T037 |

## Notes

- Total: 37 tareas; Setup 3, Foundational 4, US1 13, US2 5, US3 7, Polish 5.
- Completar las casillas solo con implementación o comprobación real y evidencia adecuada.
- No modificar spec.md para adaptar requisitos a la implementación.
- La extensión con un tercer id/proveedor es un fixture de pruebas OCP, no un tercer modo del producto.
- La verificación offline requiere cargar build, activar Offline sin recargar y ejecutar A1–A7.
- Mantener el registro de implementaciones permitido en main según constitución 2.0.0.
- Cada función generada debe ser explicable por el estudiante; mantener responsabilidades pequeñas.
- Sin hooks de extensiones: `.specify/extensions.yml` no existe al generar estas tareas.

## Estado de ejecución

37 de 37 tareas completadas. SC-003 medido en Firefox; SC-002 informado por el usuario
con aproximadamente 5 segundos de primer uso. El usuario también confirmó que puede explicar
las funciones tras revisar la guía del README. La evidencia y los límites están en quickstart.md.
