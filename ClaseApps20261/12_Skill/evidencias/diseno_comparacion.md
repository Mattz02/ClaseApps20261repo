# Misión 5 — Diseño y registro de las dos ejecuciones

## Separación de las condiciones

Se iniciaron dos subagentes con `fork_turns="none"`: no recibieron el historial
de la conversación principal ni la respuesta del otro subagente. No se les
comunicaron hallazgos esperados, números de fila, umbrales ni la tabla de evaluación.

| Condición | Subagente | Directorio de ejecución |
|---|---|---|
| Sin skill | `/root/evaluacion_sin_skill` | `/tmp/semana12-comparacion-4ma4wpdg/sin_skill` |
| Con skill | `/root/evaluacion_con_skill` | `/tmp/semana12-comparacion-4ma4wpdg/con_skill` |

En ambas llamadas se omitieron cambios de modelo y esfuerzo de razonamiento:
se utilizó la configuración heredada del agente principal. No se registra un
identificador de modelo específico que la herramienta no haya proporcionado.

Cada directorio recibió una copia idéntica de `logs_sinteticos.csv`. Solo el
directorio de la condición con skill recibió `incident-investigator/SKILL.md`
y `incident-investigator/references/detection-rules.md`. No se proporcionó un
detector ni otros resultados a ninguna condición.

SHA-256 del CSV suministrado a ambas condiciones:

```text
7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8
```

## Solicitud idéntica de investigación

> Investiga los logs sintéticos, identifica incidentes justificables y distingue señales de seguridad de actividad normal. Devuelve evidencia concreta.

## Instrucciones de ejecución compartidas

A ambos subagentes se les indicó trabajar solo dentro de su directorio, sin
consultar al otro agente, otras conversaciones, el repositorio original ni una
rúbrica. Se permitió usar herramientas locales generales y la biblioteca estándar.
Se prohibieron red, servicios externos, modificación del CSV, delegación y
exposición de posibles secretos incluso en salidas de herramientas.

Se pidió a ambos guardar `informe.md`, una traza auténtica en `traza.md`, comandos
o scripts de apoyo reproducibles si los utilizaban, y hashes antes/después.
También se pidió distinguir observaciones de salidas de herramientas y no inventar
mediciones de tiempo o tokens.

La diferencia deliberada fue:

- **Sin skill:** no usar skills ni leer `SKILL.md`, `detection-rules.md`, scripts
  auxiliares proporcionados ni resultados ajenos.
- **Con skill:** leer explícitamente el `SKILL.md` local y aplicar sus recursos
  según las instrucciones del propio skill.

## Límites del experimento

Esta prueba compara dos ejecuciones sin historial compartido mediante subagentes,
no dos procesos de Codex con una separación de permisos a nivel de sistema operativo.
Comparten el entorno de herramientas y el sistema de archivos; la restricción
de lectura a cada directorio se establece mediante instrucciones y se revisa
contra las trazas disponibles.

La condición con skill utiliza carga explícita del archivo local. Evalúa el
procedimiento y las reglas, no el descubrimiento automático por `description`.
La ocultación de secretos se pidió a ambas condiciones como protección común;
por ello su cumplimiento no puede atribuirse exclusivamente al skill.

Una ejecución por condición constituye una comparación didáctica, sin evidencia
estadística de superioridad. Tiempo y tokens: **no disponible** salvo una medición
fiable comunicada expresamente por el entorno de ejecución.
