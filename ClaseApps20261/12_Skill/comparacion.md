# Misión 5 — Comparación sin skill / con skill

Se realizaron dos ejecuciones independientes de contexto mediante subagentes con
`fork_turns="none"`. Ambas recibieron el mismo CSV y la misma solicitud, sin los
hallazgos anteriores ni la respuesta del otro agente. No se cambió la configuración
de modelo o razonamiento entre condiciones. La ejecución con skill leyó explícitamente
sus archivos locales; la ejecución sin skill recibió únicamente el CSV como material
de entrada y no leyó las instrucciones ni la referencia.

> Investiga los logs sintéticos, identifica incidentes justificables y distingue señales de seguridad de actividad normal. Devuelve evidencia concreta.

Los detalles de aislamiento, instrucciones compartidas y limitaciones se conservan
en [diseño de la comparación](evidencias/diseno_comparacion.md). Las respuestas
originales se preservaron sin editar:

- **Sin skill:** [informe](evidencias/comparacion/sin_skill/informe.md) y
  [traza](evidencias/comparacion/sin_skill/traza.md).
- **Con skill:** [informe](evidencias/comparacion/con_skill/informe.md) y
  [traza](evidencias/comparacion/con_skill/traza.md).

## Tabla de evaluación

| Dimensión | Sin skill | Con skill | Evidencia / comentario |
|---|---|---|---|
| ¿Usó un procedimiento reproducible? | Sí: conservó scripts de lectura, agrupación y verificación, resultados y hashes. Parte de la verificación selecciona las IP observadas en este archivo; no define un criterio general de activación con umbrales y ventanas. | Sí: validó el CSV, leyó la referencia, preservó filas, ordenó por fecha y evaluó ventanas deslizantes inclusivas de 300 s con R1–R4. Después releyó el CSV para verificar cálculos. | Las dos trazas permiten reproducir el procesamiento. Comparar [verificar.py sin skill](evidencias/comparacion/sin_skill/verificar.py) con [analizar.py con skill](evidencias/comparacion/con_skill/analizar.py): el segundo calcula R1/R2 para los grupos presentes según criterios generales; el primero verifica grupos de IP concretos ya seleccionados. |
| ¿Citó filas concretas? | Sí: cita las ocho filas de fallos de `admin`, el éxito de la 28, la 33, la 59 y las seis filas del patrón multicuenta. | Sí: cita las mismas filas y las vincula a una regla, intervalo, conteo y limitación. | Ambos informes usan encabezado = fila 1. No hubo una mejora en presencia de citas; con skill se hizo explícita su relación con R1–R4. |
| Alertas sustentadas | Cuatro grupos: cambio no aprobado, posible token expuesto, fallos contra `admin` seguidos de éxito y patrón contra seis cuentas. No los declara intrusiones confirmadas. | Las mismas cuatro alertas, justificadas mediante R1–R4. R1: 8 registros en 240 s, éxito a +60 s; R2: 6 usuarios en 120 s; R3: fila 33; R4: fila 59. | Coinciden los grupos y las filas en ambos informes. [Verificación con skill](evidencias/comparacion/con_skill/verificacion.json). No se encontraron más alertas gracias al skill. R1 depende de cómo se interpreten los registros idénticos, advertencia que ambos reconocen. |
| Falsos positivos detectados o evitados | No declaró incidente por los tres fallos de `maria` (38, 39, 41) ni por los seis healthchecks. Usó el contexto del detalle y aclaró que sus etiquetas no prueban legitimidad. | Excluyó esos mismos casos por condiciones explícitas: 3 < 6, un usuario < 5 y `healthcheck` distinto de `login/failed`. También evitó inferir posterioridad en pares con timestamp idéntico. | Ambos evitaron los dos casos de control del ejercicio. La diferencia es el criterio: contextual en el primero y ligado a umbrales y coincidencias exactas en el segundo. No se midió una tasa de falsos positivos sobre otros datos. |
| ¿Ocultó posibles tokens? | Sí: usó `[OCULTO]` y `[VALOR_OCULTO]` en informe y salidas. | Sí: usó `token=[REDACTED]` y omitió detalles innecesarios. | Se revisaron los artefactos conservados y no contienen el valor de token del CSV. La prohibición de exponer secretos se dio a ambas condiciones; no puede atribuirse el enmascaramiento exclusivamente al skill. |
| ¿Reconoció incertidumbre? | Sí: identifica los pares 19/20, 22/23 y 25/26, distingue ocho registros de cinco combinaciones distintas, no confirma compromiso ni validez del token y separa actor/usuario del cambio de rol. | Sí: identifica la misma ambigüedad y añade que, si los pares fueran duplicados de ingesta, cinco registros no alcanzarían el umbral de seis de R1. No confirma compromiso, autoría ni privilegios efectivos. | [Duplicados sin skill](evidencias/comparacion/sin_skill/duplicados.txt) y [verificación con skill](evidencias/comparacion/con_skill/verificacion.json). Ambos fueron cautos; el aporte específico fue conectar la incertidumbre con la decisión de una regla concreta. |
| ¿Qué hizo gracias al skill? | Produjo una investigación razonada y documentada por sus propios criterios, pero sin referencia de reglas ni condiciones reutilizables para decidir cuándo alcanza un umbral. | Consultó una referencia explícita, aplicó R1–R4 y sus límites temporales, distinguió la condición de alerta del éxito posterior y produjo el formato de evidencia solicitado por el skill. | La traza con skill registra las lecturas antes del cálculo. El aporte observado es la aplicación de criterios de decisión reproducibles; no una ventaja demostrada en detección, ocultación o cantidad de citas. La carga fue explícita, por lo que aquí no se evalúa activación automática. |

## Qué aportó el skill en concreto

El resultado **no demuestra una mejora en el número de hallazgos ni en los casos
de control evitados**: ambos agentes identificaron los mismos cuatro patrones y
evitaron clasificar los tres fallos y los healthchecks como incidentes.

El aporte sustantivo fue convertir la clasificación en una decisión verificable
contra una referencia: seis fallos por pareja en hasta cinco minutos, cinco
usuarios por IP, condiciones exactas de evento/resultado y asociación del éxito
con el último fallo de una ventana documentada. Sin skill, el agente consideró
la secuencia sospechosa incluso si se reducían los ocho registros a cinco
combinaciones; con skill explicó que esa hipótesis impediría cumplir R1.
La diferencia afecta a la justificación de la alerta, no solo al formato.

El formato uniforme facilita revisar regla, cálculo, filas y limitaciones, pero
por sí solo sería una mejora estética. El agente sin skill ya aportó cautela,
evidencia y observaciones útiles, como la diferencia entre el usuario `guest` y
la transición `user->admin` del detalle. No sería fiel afirmar que el skill mejoró
todas las dimensiones o evitó invenciones que la otra ejecución sí hubiera cometido.

Para comprobar si el beneficio se mantiene, una evaluación posterior podría
usar otros CSV sintéticos y condiciones de borde: seis fallos exactamente en
300 segundos frente a 301, cinco usuarios distintos frente a cuatro, y registros
repetidos sin identificador de evento. Estas pruebas **no se ejecutaron** aquí.
La ambigüedad de duplicados merece conservarse como límite explícito, sin
introducir una deduplicación arbitraria ni modificar el skill a partir de una
sola comparación favorable.

## Evidencia, integridad y límites

Las copias del CSV en ambas ejecuciones coinciden byte por byte con el original.
Las trazas registran el mismo SHA-256 antes y después:

```text
7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8
```

Se conservaron 9 artefactos de la ejecución sin skill y 13 de la ejecución con
skill, incluidos en este último caso los dos archivos del skill efectivamente
suministrados. Sus hashes están en el [manifiesto](evidencias/comparacion/manifest.json).
No se copiaron nuevamente los CSV a las carpetas de evidencia. Los scripts son
artefactos de estas ejecuciones, no recursos nuevos del skill; para reproducirlos
debe usarse una copia temporal de la carpeta de evidencia correspondiente junto
con el CSV original bajo el nombre `logs_sinteticos.csv`.

Los subagentes no heredaron esta conversación, pero comparten entorno y sistema
de archivos; el aislamiento de materiales se estableció por instrucciones y
directorios separados, no por una barrera de permisos. Las trazas disponibles
declaran las lecturas locales realizadas y no muestran uso de los materiales
de la otra condición. No se afirma una auditoría externa de todas las lecturas.

Una ejecución por condición es una **comparación didáctica**, no una prueba
estadística ni una demostración causal general. El prompt principal fue idéntico;
las instrucciones de ejecución solo variaron en la disponibilidad y carga del
skill. Ambas condiciones recibieron la misma protección de secretos.

| Medición | Sin skill | Con skill |
|---|---|---|
| Tiempo total | no disponible | no disponible |
| Tokens | no disponible | no disponible |

No se estimaron métricas a partir de duraciones parciales de herramientas.
