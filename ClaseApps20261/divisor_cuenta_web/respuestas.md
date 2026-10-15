# Parte 8 — Medir cuánto viajó


| Proyecto | Directorio del feature |
|---|---|
| Flutter original | `../divisor_cuenta/specs/001-dividir-cuenta/` |
| React | `specs/001-divisor-cuenta/` |

La carpeta original se llama `001-dividir-cuenta`, mientras que la de React
se llama `001-divisor-cuenta`. Esa diferencia explica por qué fallaba el
comando que usaba el mismo nombre de carpeta para ambos proyectos.

## 8.1 La spec

### Comparación y evidencia

El comando con las rutas reales es:

```bash
export SPECIFY_FEATURE_DIRECTORY="specs/001-divisor-cuenta"

git diff --no-index \
  ../divisor_cuenta/specs/001-dividir-cuenta/spec.md \
  "$SPECIFY_FEATURE_DIRECTORY/spec.md"
```

Resultado: diff vacío. No hubo salida estándar ni salida de error, y el
código de salida fue 0: los archivos son idénticos byte por byte.

La evidencia registrada contiene:

```json
{
  "fechaUTC": "2026-10-15T02:26:57.151Z",
  "codigoSalida": 0,
  "salidaEstandar": "",
  "salidaError": "",
  "bytesDiff": 0
}
```


```text
6c7aff2b21fac7961ba3a7f767424fb9f6ef1151b2f9662e8f80084315e307d0
```

Evidencia guardada:

- [Diff de la spec, vacío (0 bytes)](specs/001-divisor-cuenta/evidencias/comparacion-spec.diff).
- [Registro del comando, fecha, salidas, tamaños y hashes](specs/001-divisor-cuenta/evidencias/comparacion-spec.json).

Esta comprobación demuestra que la copia React sigue intacta respecto del
original disponible. El registro se generó al preparar esta entrega; no es
una captura histórica tomada en el momento de importar el archivo.

### Porcentaje reutilizado

Se reutilizó sin cambios el 100 % del texto de la spec. Como los archivos
son idénticos, todos sus enunciados se conservaron.

El análisis previo desglosa la spec en
75 enunciados independientes, agrupando las repeticiones y sin contar títulos
ni metadatos. Con ese mismo criterio:

```text
Reutilización = (enunciados conservados / enunciados analizados) × 100
Reutilización = (75 / 75) × 100 = 100 %
```

Se conservaron las entradas, la fórmula de reparto, los modos de redondeo,
los límites de validación, los mensajes, el formato de dos decimales y los
criterios de aceptación. La spec describe comportamientos observables sin
exigir widgets, clases Dart ni APIs de Flutter.

### ¿Fue necesario aplicar el protocolo de corrección?

No se detectó un enunciado dependiente de Flutter que obligara a modificar
la spec para planificar React. Por eso no hubo corrección de enunciados,
commit de adaptación ni un antes/después de `spec.md` que presentar. La
evidencia del diff vacío se conserva.

Sí hubo una precisión de alcance importante en el plan React para FR-015 y
SC-004: después de cargar los recursos, los cálculos, las validaciones y los
cambios de modo funcionan sin red. No hay peticiones de la aplicación ni
persistencia del formulario. No se garantiza la primera apertura remota ni
la recarga sin conexión. Este alcance fue indicado explícitamente por el
usuario y quedó documentado en el plan, la investigación, los contratos y
el quickstart, conservando la spec intacta.

Por tanto, el 100 % anterior mide conservación de los enunciados; no demuestra
que la web pueda abrirse por primera vez desde un servidor sin conexión.
La comprobación offline acordada consiste en cargar el build, activar Offline
sin recargar y ejecutar A1–A7 comprobando resultados y mensajes. La precisión
offline corresponde al alcance de ejecución web y no a una dependencia de
Flutter encontrada en la redacción.

## 8.2 Los casos de prueba

Se compararon estos archivos:

- Flutter: [`test/casos_de_prueba.dart`](../divisor_cuenta/test/casos_de_prueba.dart).
- React: [`test/casosDePrueba.js`](test/casosDePrueba.js).

Los seis escenarios coinciden.

| Caso | Monto en ambos | Personas | Propina | Modo | Resultado o error esperado en ambos |
|---|---:|---:|---:|---|---|
| 1. reparto normal | 100.00 | 4 | 10 % | exacto | 27.50 |
| 2. sin propina | 90.00 | 3 | 0 % | exacto | 30.00 |
| 3. cero personas | 50.00 | 0 | 0 % | exacto | `Debe haber al menos una persona` |
| 4. monto no numerico | `double.nan` / `NaN` | 4 | 0 % | exacto | `Monto inválido` |
| 5. redondeo exacto | 10.00 | 3 | 0 % | exacto | 3.33 |
| 6. redondeo hacia arriba | 10.00 | 3 | 0 % | arriba | 4.00 |

| Elemento comparado | Resultado |
|---|---|
| Entradas | Conservadas; `double.nan` y `NaN` representan la misma entrada no numérica. |
| Valores numéricos esperados | Conservados: 27.50, 30.00, 3.33 y 4.00. |
| Mensajes de error | Conservados exactamente, incluidos los acentos. |
| Escenarios | 6 originales y 6 migrados, con los mismos nombres y orden. |
| Reglas de negocio de esos casos | Conservadas: propina, reparto, validación y ambos redondeos. |

La comprobación de campos y valores también se ejecutó mediante un script:
normalizó `double.nan` y `NaN` como la misma entrada y comparó los seis
registros. Resultado: 6 de 6 coinciden. Los registros de ambos
lenguajes y el resultado de cada comparación están en
[comparacion-casos.json](specs/001-divisor-cuenta/evidencias/comparacion-casos.json).

Lo que cambió fue la representación: Dart utiliza la clase `CasoDivision`,
tipos y una lista constante; JavaScript utiliza objetos y un arreglo exportado.
En Dart, un campo opcional no indicado queda en `null`; en estos objetos de
JavaScript se omite. Eso no cambia el resultado o error esperado.

También cambia el runner: Flutter utiliza `flutter_test` y React utiliza
Vitest. Las pruebas de pantalla se realizan sobre widgets en Flutter y sobre
el DOM en React; las tres nuevas pruebas de `test/pantalla.test.jsx` utilizan
Testing Library.

El caso no numérico de ambos archivos de datos utiliza NaN. La spec también
pide probar el texto `abc`; ese caso se comprueba en la pantalla React. No se
sustituyó una entrada distinta al migrar el arreglo de casos.

La spec incluye además el escenario de 90.00 entre 3 personas en modo hacia
arriba, con resultado 30.00 (A7). No está en ninguno de estos dos arreglos de
seis casos, pero sí se verifica en la suite de integración React. Comparar
estos arreglos demuestra que sus escenarios viajaron; la cobertura completa
de la spec incluye pruebas adicionales.

Última ejecución verificada de React: `npm test`, **126 pruebas aprobadas en
9 archivos**, incluidas las seis del arreglo, la prueba LSP y las tres nuevas
de pantalla. Esta entrega no volvió a ejecutar las pruebas Flutter.

## 8.3 El plan

Se compararon:

- [Plan Flutter](../divisor_cuenta/specs/001-dividir-cuenta/plan.md).
- [Plan React](specs/001-divisor-cuenta/plan.md).

Comando con las rutas reales:

```bash
export SPECIFY_FEATURE_DIRECTORY="specs/001-divisor-cuenta"

git diff --no-index \
  ../divisor_cuenta/specs/001-dividir-cuenta/plan.md \
  "$SPECIFY_FEATURE_DIRECTORY/plan.md"
```

El diff del plan no está vacío. Git devuelve `1` porque encontró
diferencias; en este caso no significa que el comando esté mal. El resumen
de la comparación es:

```text
1 file changed, 103 insertions(+), 96 deletions(-)
```

El [diff completo del plan](specs/001-divisor-cuenta/evidencias/comparacion-plan.diff)
queda guardado como evidencia. Ese conteo mide diferencias textuales, no un
porcentaje de requisitos o decisiones reutilizadas.

### Decisiones que se conservaron y decisiones que cambiaron

| Aspecto | Plan Flutter | Plan React |
|---|---|---|
| Producto | Una pantalla para dividir cuenta y propina. | Se conserva el mismo producto. |
| Lenguaje y framework | Dart y Flutter con Material 3. | JavaScript ESM, JSX, React y Vite. |
| Plataforma | Android principal; Linux para desarrollo. | Navegador moderno con soporte de BigInt. |
| Capas | `lib/presentation`, `lib/domain`, `lib/data`. | `src/presentation`, `src/domain`, `src/data`. |
| Dependencias | `presentation -> domain <- data`. | Se conserva la misma dirección. |
| Dominio puro | Dart sin importar Flutter. | JavaScript sin React ni DOM. |
| Estado | `StatefulWidget`, `setState` y `DivisorController`. | Hook `useDivisor` con `useState`, sin librerías externas de estado. |
| Composición | `main.dart` conecta implementaciones. | `src/main.jsx` conecta implementaciones. |
| Redondeo | Interfaz `EstrategiaRedondeo` y clases concretas. | Contrato `aplicar(valor)` y proveedores con la misma operación. |
| Dinero | Centavos enteros y fracción entera antes de redondear. | Misma idea con BigInt para preservar precisión dentro de los límites. |
| Validación y formato | Responsabilidades separadas del cálculo. | Se conserva esa separación. |
| Pruebas previstas | `flutter_test`: unitarias y de widgets. | Vitest: unitarias, contratos, hook y pantalla; jsdom para interfaz. |
| Persistencia | Ninguna; datos en memoria. | Ninguna; sin backend, base de datos ni persistencia del formulario. |
| Sin conexión | Aplicación instalada, operación local sin red. | Operación local después de cargar recursos; sin garantía de primera apertura remota o recarga offline. |
| Extensión OCP | Nueva estrategia y registro en `main.dart`. | Nueva estrategia y registro permitido en `src/main.jsx` por la constitución 2.0.0; sin modificar cálculo, validación, hook ni pantalla. |
| Rendimiento | Resultado en menos de 1 segundo. | Conserva ese objetivo y explicita primer uso en menos de 30 segundos. |

El plan React se elaboró a partir de la misma spec, pero necesita otras
herramientas, archivos, componentes y mecanismos de estado. Se reutilizaron
las reglas del negocio y las decisiones de separación de responsabilidades,
inyección de dependencias y aritmética exacta. La implementación técnica de
la interfaz y la ejecución de las pruebas se adaptaron al nuevo entorno.

El plan React describe originalmente pruebas de interfaz con `act` y
`createRoot`. Posteriormente se añadieron las tres pruebas solicitadas con
Testing Library; esto describe el estado actual de las pruebas sin atribuir
esa decisión posterior al texto original del plan.

## Preguntas

### 1. ¿Qué porcentaje de la spec viajó intacto, necesitó adaptación o no pudo reutilizarse?

| Clasificación | Enunciados | Porcentaje |
|---|---:|---:|
| Intactos | 75 | 100 % |
| Necesitaron adaptación del texto | 0 | 0 % |
| No pudieron reutilizarse | 0 | 0 % |
| Total | 75 | 100 % |

Uso el desglose del [analisis_spec.md original](../divisor_cuenta/analisis_spec.md),
apartados «Criterio de análisis» y «Conteo y porcentaje de CÓMO»: 75 enunciados
independientes, todos QUÉ, sin CÓMO ni MIXTOS. Ese conteo agrupa las reglas
repetidas y excluye metadatos. El [diff vacío](specs/001-divisor-cuenta/evidencias/comparacion-spec.diff)
y el [registro de hashes iguales](specs/001-divisor-cuenta/evidencias/comparacion-spec.json)
confirman que tampoco hubo cambios textuales en la copia.

Se conservaron, por ejemplo, la fórmula de reparto (FR-004), los dos redondeos
(FR-005/006) y los mensajes de validación (FR-009/010/011/012). Cambiar cómo
se implementan esas reglas no exige cambiar lo que la spec pide.

La precisión offline se documentó en el plan: la operación sin red se verifica
después de cargar los recursos, sin recargar. Ese límite debe acompañar la
afirmación de reutilización; conservar el texto no prueba una primera apertura
remota sin conexión.

No registré un tiempo total de migración. El tiempo comunicado de unos cinco
segundos corresponde al primer uso de la pantalla, no al trabajo de migración.
Sirve como contexto de usabilidad; la evidencia de reutilización son los
enunciados conservados, las comparaciones y las pruebas.

### 2. Clasificación de cada regla de la Constitution

Comparo la constitución Flutter 1.0.1(../divisor_cuenta/.specify/memory/constitution.md)
con la constitución React 2.0.0(.specify/memory/constitution.md). En esta
clasificación, «idéntica» significa que conserva la misma obligación aunque
cambie una palabra; «adaptada en redacción» conserva el principio y ajusta su
expresión al nuevo entorno; «reemplazada» señala un cambio de alcance o de
regla, no solo de nombres.

Las columnas siguientes citan fragmentos o describen la regla del apartado
indicado en ambos archivos enlazados.

| Regla | Evidencia Flutter | Evidencia React | Clasificación y motivo |
|---|---|---|---|
| I. Obligación general de SOLID | «El código DEBE respetar los cinco principios SOLID». | La misma obligación. | **Idéntica**: mantiene los cinco principios. |
| I. SRP | «cada clase tiene una sola razón de cambio»; el cálculo no valida ni formatea. | «cada función o módulo DEBE tener una sola razón de cambio»; misma separación del cálculo. | Adaptada en redacción: cambia la unidad de organización de clases a funciones o módulos. |
| I. OCP | Agregar un redondeo «NO DEBE obligar a editar las clases que ya existen». | No modificar cálculo, validación, hook ni pantalla; se permite registrar en `src/main.jsx`. | Reemplazada en su formulación normativa: delimita los consumidores protegidos y autoriza expresamente modificar la composición. Conserva la intención de extensión. |
| I. LSP | Cualquier implementación de una interfaz puede sustituir a otra sin preguntar su tipo concreto. | La misma exigencia aplicada a la interfaz de redondeo. | Adaptada en redacción: concreta el contrato relevante para esta aplicación. |
| I. ISP | Interfaces pequeñas; ninguna clase depende de métodos que no usa. | Interfaces pequeñas; ningún consumidor depende de funciones que no usa. | Adaptada en redacción: expresa el mismo principio para consumidores y funciones. |
| I. DIP | `presentation` depende de abstracciones de `domain`, nunca de clases concretas de `data`. | La misma dirección; habla de implementaciones concretas de `data`. | Adaptada en redacción: elimina la dependencia de que la implementación sea una clase. |
| II. Organización por capas | `lib/` con `presentation`, `domain`, `data`. | `src/presentation/`, `src/domain/`, `src/data/`. | Adaptada en redacción: cambia la raíz del código, conserva las capas. |
| II. Dependencias | `presentation -> domain <- data`; domain no importa las otras capas. | `presentation -> domain <- data`. | Idéntica: conserva la restricción arquitectónica. |
| II. Dominio puro | `lib/domain/` no importa `package:flutter`; Dart puro. | `src/domain/` es JavaScript puro, sin React ni DOM. | Adaptada en redacción: cambia lenguaje y framework, conserva la independencia. |
| II. Composición | `main.dart` es el único lugar para instanciar implementaciones concretas. | `src/main.jsx` es el único lugar para hacerlo. | Adaptada en redacción: cambia el archivo de entrada. |
| III. Seguridad | No guardar secretos ni API keys en el repositorio. | El repositorio nunca debe contener secretos ni API keys. | Idéntica: misma prohibición. |
| IV. Funcionalidad crítica | «Toda funcionalidad crítica DEBE tener pruebas». | La misma regla. | Idéntica: no depende del runner. |
| IV. Aceptación ejecutable | Convertir criterios de aceptación de cada spec en pruebas ejecutables. | Convertir criterios de aceptación de la especificación en pruebas ejecutables. | Idéntica: cambia la herramienta, no la obligación. |
| V. Código explicable | Explicar toda función generada: qué hace, por qué existe, entradas, salida y errores. | Exige los mismos cinco aspectos. | Idéntica: conserva la responsabilidad del estudiante. |

La sustitución de OCP fue una decisión explícita del proyecto, no una necesidad
de React. El informe de sincronización de la constitución React registra
`1.0.0 → 2.0.0` y la «redefinición explícita de OCP solicitada por el usuario».
El [plan Flutter](../divisor_cuenta/specs/001-dividir-cuenta/plan.md) ya proponía
registrar estrategias en `main.dart`; la nueva redacción hace explícito el
permiso equivalente en React. No significa que se haya abandonado OCP.

El análisis previo de la constitución agrupaba SOLID en una sola fila y cubría
los apartados I–IV. Aquí se desglosan sus reglas, se incluye V y se compara la
versión React vigente. Por eso no se trasladan sin revisión sus conteos de
cinco reglas idénticas y tres adaptadas.

Para cubrir también las reglas de gobernanza de ambos documentos:

| Regla de gobernanza | Evidencia Flutter → React | Clasificación y motivo |
|---|---|---|
| Precedencia y relación con instrucciones del agente | Flutter declara que la constitución prevalece y que `AGENTS.md` no debe contradecirla; React delimita el alcance de sus cinco grupos de principios, sin repetir esa cláusula. | Reemplazada en el texto de gobernanza: no hay una cláusula equivalente expresa de precedencia. |
| Procedimiento de enmienda | Flutter exige registrar el cambio en Sync Impact Report y actualizar versión y fecha; React exige identificar principios afectados, explicar el cambio y actualizar versión y fecha, y requiere instrucción explícita del responsable para agregar o cambiar principios. | Reemplazada: cambia el procedimiento formal y explicita quién autoriza los cambios. |
| Versionado semántico | Ambos usan MAJOR para redefiniciones incompatibles, MINOR para adiciones o ampliaciones y PATCH para aclaraciones sin cambio de significado. | Idéntica: conserva los criterios de versionado. |
| Verificación de cumplimiento | Flutter exige el Constitution Check de cada plan y revisión antes de integrar; React exige revisar cambios contra los principios vigentes y su sección de verificación. | Reemplazada en el procedimiento: conserva la revisión, pero no repite expresamente los mismos momentos y documentos obligatorios. El plan React sí incluye su Constitution Check. |
| Excepciones | Flutter exige justificar por escrito cualquier excepción en el plan; React no incluye un procedimiento equivalente de excepciones. | Reemplazada por omisión de esa cláusula: no debe afirmarse que ambas gobernanzas son textualmente iguales ni inferirse que React autoriza excepciones. |

### 3. ¿Se modificó algún enunciado de la spec para implementar React?

No. La spec React(specs/001-divisor-cuenta/spec.md) conserva el contenido
de la spec Flutter(../divisor_cuenta/specs/001-dividir-cuenta/spec.md), como
demuestra el diff vacío de 8.1. No hay una versión corregida ni un commit
separado de corrección de la spec que enlazar.

Fue posible porque la spec expresa entradas, resultados, validaciones,
redondeos y comportamientos de pantalla, sin exigir `StatefulWidget`,
`setState`, clases Dart ni `flutter_test`. Por ejemplo, FR-007 pide dos
decimales con punto; no impone una función de formato propia de Flutter.
Los nombres Cuenta, Resultado y Modo de redondeo representan conceptos del
problema y no obligan a usar clases concretas.

Las decisiones sobre JSX, `useState`, BigInt y jsdom se incorporaron al
[plan React](specs/001-divisor-cuenta/plan.md), sin mezclarlas con el QUÉ.
También se dejó allí el alcance offline acordado después de cargar recursos.
Si se exigiera además primera apertura remota o recarga sin red, esa capacidad
no quedaría demostrada por las pruebas offline actuales.

### 4. ¿Cambiaron los seis casos de aceptación?

No cambió ningún valor esperado, mensaje ni escenario. La tabla de 8.2
compara los seis casos, y comparacion-casos.json(specs/001-divisor-cuenta/evidencias/comparacion-casos.json)
registra la igualdad de todos sus campos:

- Reparto normal: 100, 4 personas y 10 % → 27.50.
- Sin propina: 90, 3 personas y 0 % → 30.00.
- Cero personas: 50 y 0 personas → `Debe haber al menos una persona`.
- Monto no numérico: NaN → `Monto inválido`.
- Redondeo exacto: 10 entre 3 → 3.33.
- Hacia arriba: 10 entre 3 → 4.00.

`double.nan` en Dart y `NaN` en JavaScript representan la misma entrada de
ese caso. Cambiaron la sintaxis, la estructura de los registros y el runner;
no fue necesario adaptar las reglas del negocio.

Al ejecutar los casos numéricos en React se detectó un error de implementación:
`validarEntrada` suponía que todos los campos eran cadenas y llamaba a `.trim()`
directamente. Se corrigió en src/domain/validarEntrada.js(src/domain/validarEntrada.js)
para aceptar números y texto y rechazar NaN con el mensaje previsto. Se
conservaron los casos y sus expectativas. Ese fallo no justificaba modificar
la spec ni cambiar resultados esperados.

test/division.test.js(test/division.test.js) ejecuta los seis casos y verifica
los errores sin llamar al cálculo; además comprueba la sustitución LSP.
test/pantalla.test.jsx(test/pantalla.test.jsx) verifica 27.50, cero personas
sin resultado y el texto `abc` como monto inválido.

### 5. ¿Qué partes del plan Flutter dejaron de tener sentido en React?

Las referencias concretas al entorno Flutter se sustituyeron por mecanismos
del entorno web. Estos son seis ejemplos de los planes comparados:

| Decisión del plan Flutter | Por qué deja de aplicar directamente | Adaptación React y evidencia |
|---|---|---|
| Dart, SDK Flutter y Material 3 | El proyecto React no compila Dart ni renderiza widgets Material. | JavaScript/JSX, React y Vite; dependencias en package.json(package.json). |
| `PantallaDivisor` como `StatefulWidget`, estado con `setState` y `DivisorController` | El ciclo de vida y el estado de widgets no son las APIs de React. | Componente PantallaDivisor.jsx(src/presentation/PantallaDivisor.jsx) y hook useDivisor.js(src/presentation/useDivisor.js) con `useState` y dependencias recibidas. |
| Código en `lib/` y composición en `main.dart` | Son rutas y punto de entrada del proyecto Dart. | Tres capas en `src/` y composición en src/main.jsx(src/main.jsx). |
| Interfaz Dart y clases que implementan `EstrategiaRedondeo` | JavaScript no utiliza `implements` de Dart. | Contrato JSDoc estrategiaRedondeo.js(src/domain/estrategiaRedondeo.js) y objetos con `aplicar(valor)`, como redondeoExacto.js(src/data/redondeoExacto.js). |
| Pruebas de widgets con `flutter_test` | Ese runner y sus selectores trabajan con widgets Flutter. | Vitest y jsdom; Testing Library interactúa con campos y botones del DOM en pantalla.test.jsx(test/pantalla.test.jsx). |
| Android como plataforma principal y Linux de escritorio para desarrollo | La entrega React se ejecuta en navegador, con recursos de una aplicación web. | Build estático con Vite; offline después de cargar recursos y sin recargar, como indican el plan(specs/001-divisor-cuenta/plan.md) y el quickstart(specs/001-divisor-cuenta/quickstart.md). |

La separación en capas, el cálculo con fracciones y centavos enteros, la
inyección de dependencias y los contratos de redondeo sí conservaron sentido.
El diff del plan(specs/001-divisor-cuenta/evidencias/comparacion-plan.diff)
documenta qué se reescribió; no se usó el número de líneas cambiadas como
medida de calidad.

### 6. ¿Qué artefacto fue el más reusable y cuál el menos reusable?

El más reusable fue `spec.md`. Se copió sin cambiar un solo byte: diff de
0 bytes, mismo tamaño y mismo SHA-256. El análisis de 75 enunciados explica
por qué: describe comportamientos del producto independientes del framework.
Los datos de aceptación(test/casosDePrueba.js) también conservaron el 100 %+de sus seis escenarios, aunque necesitaron otra sintaxis.

**Entre los artefactos de documentación comparados, el menos reusable fue
`plan.md`.** Contiene decisiones sobre lenguaje, dependencias, plataforma,
estado, estructura del código y runner que sí cambian al pasar de Flutter
a React. Su diff guardado(specs/001-divisor-cuenta/evidencias/comparacion-plan.diff)
registra 103 inserciones y 96 eliminaciones, frente al diff vacío de la spec.
Los ejemplos de la respuesta 5 muestran los cambios concretos; no se
concluye que todo el plan fuera descartable, porque se conservaron decisiones
arquitectónicas y aritméticas.

Si se incluye el código ejecutable, la interfaz Flutter y sus pruebas de
widgets son todavía menos trasladables directamente: requieren componentes
React y pruebas de DOM nuevos. La evidencia está en la estructura `lib/`
descrita por el plan Flutter, frente a src/presentation/(src/presentation/)
y las pruebas React. Esto distingue reutilizar un escenario de copiar sin
cambios el archivo que lo ejecuta.

La evidencia de calidad acompaña la comparación de textos: la última suite
React verificada tuvo 126 pruebas aprobadas, y la
validación en navegador(specs/001-divisor-cuenta/evidencias/validacion-browser.json)
registra los mismos resultados y mensajes A1–A7 con y sin red después de la
carga, con cero peticiones durante la operación. Estas comprobaciones apoyan
que las reglas conservadas se implementaron; no reemplazan la comparación
de la spec ni demuestran capacidades offline fuera del alcance acordado.
