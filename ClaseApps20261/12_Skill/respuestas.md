# Misión 6 — Plugin Detective

## 1. Skill frente a plugin

`incident-investigator` es un skill porque reúne instrucciones reutilizables:
`SKILL.md` define cuándo usarlo, su procedimiento y la salida esperada, mientras
`references/detection-rules.md` aporta las reglas consultables. No depende de
memorizar este CSV ni de un detector en Python.

Un plugin podría distribuir este skill junto con un manifiesto de identificación
y configuración y, según las capacidades de la plataforma, un comando para
invocarlo, un hook para comprobar automáticamente una salida ante un evento del
entorno, o un servidor MCP que exponga herramientas locales de lectura y validación.
El hook automatiza una acción ante un evento; MCP estandariza el acceso a
capacidades; el skill aporta instrucciones contextuales. El plugin sería el paquete
que los agrupa, no un sinónimo del skill. Los formatos y componentes admitidos
dependen del producto; esta propuesta no presupone una sintaxis de instalación.
Para este trabajo basta el skill local: no se construyó un plugin ni se requiere
conectar servicios externos.

## 2. Ralph Loop con un máximo de tres iteraciones

Aplicaría un ciclo acotado de **analizar → comprobar → corregir**, con un máximo
de **tres ejecuciones de análisis en total**, incluida la primera:

1. Conservar el CSV original y su hash; ejecutar el análisis y guardar el informe
   y la traza reales de esa iteración.
2. Comprobar contra el CSV que las filas existen, los campos coinciden, los
   umbrales y ventanas se calculan correctamente, los secretos están ocultos y
   los tres fallos y los healthchecks no se clasifican como fuerza bruta.
   Verificar también que el hash del original permanece igual.
3. Si falla alguna comprobación, registrar el error y corregir únicamente el
   procedimiento, la instrucción o el informe responsable. Repetir con el mismo
   CSV, conservando la versión anterior y el resultado real de la nueva ejecución.

**Criterio de parada:** detenerse cuando todas las comprobaciones pasen y cada
alerta tenga evidencia verificable, o al completar la tercera ejecución. Si se
agota el límite, informar los fallos pendientes; no declarar éxito. Si cambia el
CSV o se detecta exposición de un secreto en la salida, detener el ciclo para
corregir esa condición antes de continuar. No alterar registros, inventar eventos,
fabricar capturas ni modificar criterios solo para forzar un resultado favorable.
La ambigüedad de duplicados se documenta: no se resuelve inventando intentos.

Es una propuesta de funcionamiento; no se instaló Ralph Loop ni se ejecutó este
ciclo de tres iteraciones como parte de la entrega.
