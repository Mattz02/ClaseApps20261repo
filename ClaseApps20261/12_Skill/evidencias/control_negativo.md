# Prueba C — Control negativo

Ejecución UTC: 2026-11-12T15:32:15.278967+00:00

Solicitud: «Muéstrame cuántos eventos hay por hora en este CSV; no investigues incidentes ni clasifiques amenazas.»

Archivo: `logs_sinteticos.csv`.
Método: lectura CSV y agrupación exclusiva por timestamp, en intervalos de una hora [inicio, siguiente hora), conservando el desplazamiento horario registrado.

| Inicio de la hora | Eventos |
|---|---:|
| 2026-11-05T01:00:00-05:00 | 63 |
| 2026-11-05T02:00:00-05:00 | 30 |
| **Total con fecha válida** | **93** |

Filas con fecha inválida: ninguna.

## Comportamiento observado

En este turno no se abrió SKILL.md ni detection-rules.md, no se aplicaron reglas de detección y no se clasificaron amenazas. Solo se realizó el conteo descriptivo solicitado.
Las instrucciones del skill ya estaban presentes en el contexto de los turnos anteriores; esta evidencia muestra que no se volvió a leer ni se ejecutó su flujo de investigación, no una prueba aislada del selector interno.

## Integridad
SHA-256 antes: 7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8
SHA-256 después: 7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8
CSV sin modificaciones: igualdad byte por byte verificada.
