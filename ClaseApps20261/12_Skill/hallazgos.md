# Hallazgos — Misión 3

## Prueba A — Invocación explícita

**Solicitud recibida:** «Utiliza `incident-investigator` para investigar
`logs_sinteticos.csv` y entrega hallazgos con filas de evidencia.»

**Ejecución:** 12 de noviembre de 2026. Se utilizó el skill del propio trabajo,
leyendo `incident-investigator/SKILL.md` y después
`incident-investigator/references/detection-rules.md` antes de clasificar eventos.

**Evidencia de uso:** [registro textual de la prueba explícita](evidencias/activacion_explicita.md).
Contiene las lecturas reales de ambos archivos, sus hashes, una vista del CSV con
detalles restringidos, los cálculos de las reglas y una relectura de las filas de
verificación. Demuestra lectura y aplicación explícita de instrucciones; no es
una traza interna de selección automática. No se fabricaron capturas.

## Entrada y método

- Archivo: `logs_sinteticos.csv`, datos sintéticos del enunciado.
- Formato: CSV separado por comas, decodificado como UTF-8; columnas `timestamp`,
  `ip`, `user`, `event`, `result`, `detail`.
- Cobertura: **93 registros**, filas **2–94**, desde
  `2026-11-05T01:01:00-05:00` hasta `2026-11-05T02:29:00-05:00`.
- Todas las fechas son interpretables y contienen el desplazamiento `-05:00`.
  Las horas de las tablas siguientes corresponden al **5 de noviembre de 2026,
  UTC−05:00**, no a la fecha de ejecución.
- Encabezado = fila 1. Se asignaron números antes de ordenar por timestamp;
  se comprobó que cada registro ocupa una línea física en este archivo.
- Se usaron lecturas locales y cálculos puntuales con la biblioteca estándar de
  Python (`csv`, `datetime`, agrupaciones en memoria), sin crear un detector ni
  ejecutar `scripts/analyze_logs.py`.
- Coincidencias exactas de evento/resultado; ventanas deslizantes de hasta
  300 segundos inclusive. R1 agrupa por IP y usuario; R2 por IP y cuenta usuarios
  distintos. Las ventanas solapadas del mismo patrón se presentan una sola vez.
- Se conservaron todos los registros, sin deduplicación inferida. R3 y R4 no
  requieren ventana temporal. Los detalles se ocultaron antes de mostrarlos,
  salvo los marcadores necesarios, siempre con el token enmascarado.

## Alertas justificadas

| Alerta | Severidad orientativa | Regla | Timestamp o intervalo | IP | Usuario(s) | Filas / evidencia | Limitaciones |
|---|---|---|---|---|---|---|---|
| Fuerza bruta probable con éxito posterior observado | Alta | R1 | Fallos 01:14–01:18; éxito 01:19 | `198.51.100.77` | `admin` | **17, 19, 20, 22, 23, 25, 26, 27**: 8 registros `login/failed` en 240 s. **28**: `login/success`, 60 s después del último fallo. | Hay tres pares de filas idénticas; el umbral se cumple contando registros, pero no puede confirmarse que sean 8 intentos distintos. El éxito no demuestra compromiso. |
| Password spraying probable | Media | R2 | 02:01–02:03 | `203.0.113.89` | `ana`, `carlos`, `luisa`, `diego`, `maria`, `sofia` | **67, 68, 70, 71, 73, 74**: 6 usuarios distintos con `login/failed` en 120 s; supera el umbral de 5. | El patrón no acredita autoría ni compromiso de cuentas. |
| Token potencialmente expuesto | Alta | R3 | 01:27 | `192.0.2.44` | `api_service` | **33**: `debug/warning`; el campo `detail` contiene `token=[REDACTED]`. | No se comprobó validez ni uso del posible token. No se muestra su valor. |
| Escalada no autorizada según el registro | Alta | R4 | 01:50 | `203.0.113.42` | `guest` | **59**: `role_change/success` y atributo completo `approved=false`. | Se informa lo declarado por el log; no se prueba culpabilidad ni el efecto real sobre privilegios. |

### Éxito posterior de R1

La asociación usa la misma IP y el mismo usuario. El último fallo de la ventana
documentada está en la fila **27**, a las **01:18**; el éxito de la fila **28**
ocurre a las **01:19**. La diferencia es **60 segundos**, por lo que satisface
`0 < diferencia <= 300 segundos`. Se registra como evidencia adicional, no como
una segunda intrusión ni como prueba de acceso malicioso.

## Verificación directa contra el CSV original

Se reabrió el CSV y se extrajeron nuevamente las filas de R1, sin usar como fuente
el resumen de alertas.

| Fila original | Hora | IP | Usuario | Evento | Resultado |
|---|---|---|---|---|---|
| 17 | 01:14 | `198.51.100.77` | `admin` | `login` | `failed` |
| 19 | 01:15 | `198.51.100.77` | `admin` | `login` | `failed` |
| 20 | 01:15 | `198.51.100.77` | `admin` | `login` | `failed` |
| 22 | 01:16 | `198.51.100.77` | `admin` | `login` | `failed` |
| 23 | 01:16 | `198.51.100.77` | `admin` | `login` | `failed` |
| 25 | 01:17 | `198.51.100.77` | `admin` | `login` | `failed` |
| 26 | 01:17 | `198.51.100.77` | `admin` | `login` | `failed` |
| 27 | 01:18 | `198.51.100.77` | `admin` | `login` | `failed` |
| 28 | 01:19 | `198.51.100.77` | `admin` | `login` | `success` |

La lectura permite comprobar **8 registros ≥ 6** y
**01:18 − 01:14 = 4 minutos ≤ 5 minutos**. Las filas **19/20**, **22/23** y
**25/26** son idénticas en las seis columnas originales. Sin identificador de
evento no puede decidirse si son duplicados de registro o intentos repetidos
con igual timestamp. No se eliminaron. Si fueran duplicados, quedarían cinco
registros distintos por contenido y R1 no alcanzaría seis; por eso esta alerta
debe interpretarse con esa incertidumbre explícita.

## Casos que no justifican estas alertas

- **Tres fallos aislados:** filas **38, 39 y 41**, de `192.0.2.25` para `maria`,
  a las **01:35, 01:36 y 01:37**. Aunque caben en cinco minutos, son **3 < 6**:
  no activan R1. Afectan a un solo usuario, por lo que tampoco activan R2.
  El éxito de la fila **42**, a las **01:38**, no convierte esos tres fallos
  en fuerza bruta. Se verificaron estas cuatro filas mediante relectura.
- **Healthchecks:** filas **78, 80, 81, 82, 83 y 84**, de `192.0.2.200` para
  `healthbot`, entre **02:10 y 02:15**. Son `healthcheck/success`, no
  `login/failed`; no cuentan para R1 ni R2. Tampoco contienen el marcador de R3.
- **Acceso denegado:** la fila **57** es `access/denied` del mismo par IP/usuario
  que la fila 59. Puede citarse como contexto, pero no satisface R1, R2 ni R4
  y no demuestra una relación causal con el cambio de rol posterior.

Estos casos no se clasifican como incidentes bajo las reglas aplicadas; eso no
equivale a demostrar que toda actividad sea legítima.

## Integridad y alcance de las conclusiones

El SHA-256 del CSV antes y después de la investigación fue:

```text
7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8
```

Se comprobó igualdad byte por byte. No se modificó el CSV, no se consultaron IP
ni servicios externos y no se expusieron tokens en informes o trazas.
Los hechos comprobados son los valores y tiempos registrados; las cuatro
clasificaciones son **alertas justificadas**, no conclusiones forenses ni
atribuciones. No se conoce la cobertura fuera del intervalo del archivo.

## Prueba B — Solicitud contextual

**Solicitud recibida:** «Revisa estos registros de autenticación. ¿Ves intentos
sospechosos, cambios no aprobados o posibles secretos expuestos? Cita las filas
que respaldan cada alerta.»

**Ejecución:** 12 de noviembre de 2026, iniciada a las 15:27:40 UTC.
**Evidencia:** [registro textual de la prueba contextual](evidencias/activacion_contextual.md).
La prueba A y su registro se conservaron.

### Uso observado del skill y papel de la description

**Sí se utilizó `incident-investigator`.** Antes del análisis se anunció su uso
y se volvieron a leer realmente `incident-investigator/SKILL.md` y
`incident-investigator/references/detection-rules.md`. El registro guarda el
contenido leído, sus hashes y las comprobaciones ejecutadas sobre el CSV.

La `description` coincide con las señales del prompt: investigar accesos
sospechosos, cambios de rol no aprobados y posibles secretos expuestos en logs
CSV sintéticos. Esa correspondencia justifica aplicar el skill y sus reglas.
La solicitud no es un conteo ni una visualización descriptiva.


### Hallazgos de la nueva revisión

Se volvió a leer el CSV completo, se validaron sus 93 registros y se recalcularon
las reglas con las mismas convenciones de filas, tiempos y ventanas descritas
arriba. Las cuatro alertas coinciden con A; no se contabilizan como cuatro
incidentes adicionales. Horas del **2026-11-05, UTC−05:00**.

| Alerta | Severidad orientativa | Regla | Timestamp o intervalo | IP | Usuario(s) | Filas / evidencia | Limitaciones |
|---|---|---|---|---|---|---|---|
| Fuerza bruta probable con éxito posterior | Alta | R1 | 01:14–01:18; éxito 01:19 | `198.51.100.77` | `admin` | **17, 19, 20, 22, 23, 25, 26, 27**: 8 registros `login/failed` en 240 s. **28**: `login/success`, 60 s después. | Los pares 19/20, 22/23 y 25/26 son idénticos. Se cuentan registros sin deduplicar, no 8 intentos inequívocamente distintos. El éxito no confirma compromiso. |
| Password spraying probable | Media | R2 | 02:01–02:03 | `203.0.113.89` | `ana`, `carlos`, `luisa`, `diego`, `maria`, `sofia` | **67, 68, 70, 71, 73, 74**: 6 usuarios distintos con `login/failed` en 120 s. | Señal compatible con spraying, sin atribución de autoría ni prueba de compromiso. |
| Token potencialmente expuesto | Alta | R3 | 01:27 | `192.0.2.44` | `api_service` | **33**: `detail` contiene `token=[REDACTED]`. | Validez y uso desconocidos; valor oculto. |
| Escalada no autorizada según el registro | Alta | R4 | 01:50 | `203.0.113.42` | `guest` | **59**: `role_change/success` y `approved=false`. | Describe el registro; no acredita efectos reales ni culpabilidad. |

### Comprobación directa y controles

Se reabrió el CSV para verificar R2 contra sus filas originales:

| Fila | Hora | IP | Usuario | Evento / resultado |
|---|---|---|---|---|
| 67 | 02:01 | `203.0.113.89` | `ana` | `login/failed` |
| 68 | 02:01 | `203.0.113.89` | `carlos` | `login/failed` |
| 70 | 02:02 | `203.0.113.89` | `luisa` | `login/failed` |
| 71 | 02:02 | `203.0.113.89` | `diego` | `login/failed` |
| 73 | 02:03 | `203.0.113.89` | `maria` | `login/failed` |
| 74 | 02:03 | `203.0.113.89` | `sofia` | `login/failed` |

Son **6 usuarios distintos ≥ 5**, todos desde la misma IP, en
**02:03 − 02:01 = 120 segundos ≤ 300**. Esta verificación fue realizada por
el agente mediante relectura; no se presenta como una revisión del estudiante.

Se volvieron a identificar las filas **38, 39 y 41** como los tres fallos de
`maria` desde `192.0.2.25`: **3 < 6**, por lo que no activan fuerza bruta;
un solo usuario tampoco cumple spraying. Los `healthcheck` de las filas
**78, 80, 81, 82, 83 y 84** no son `login/failed` y se excluyen de R1/R2.

La ambigüedad de duplicados de R1 persiste: si los tres pares idénticos fueran
duplicados del registro, quedarían cinco entradas distintas y el umbral no se
cumpliría. No se deduplicó sin evidencia ni se afirmó que esta hipótesis sea un
hecho. Ninguna de las cuatro alertas constituye una conclusión forense.

### Integridad de la prueba B

El CSV se mantuvo idéntico byte por byte y conservó el SHA-256
`7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8`.
No se consultó Internet ni se expusieron valores de tokens. La traza contextual
contiene resultados reales de esta ejecución, no una copia de la traza A.
