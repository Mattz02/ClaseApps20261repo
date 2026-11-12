# Investigación de logs sintéticos

Se justifican cuatro hallazgos de seguridad: un cambio de privilegios registrado como no aprobado, una posible credencial escrita en logs, una secuencia de fallos seguida de acceso a `admin` y un patrón de intentos sobre seis cuentas. Los registros sustentan investigar estos casos; no prueban por sí solos la identidad de un atacante, una intrusión completa ni exfiltración.

## Alcance y calidad de la evidencia

Se analizaron los 93 registros de `logs_sinteticos.csv`, con seis columnas y sin campos vacíos o ausentes, desde el 5 de noviembre de 2026 a las 01:01 hasta las 02:29, zona `-05:00`. La numeración citada incluye la cabecera como línea 1. Los registros están ordenados por fecha de manera no decreciente.

Hay 90 registros distintos: las parejas de líneas 19/20, 22/23 y 25/26 son idénticas en todos sus campos. No hay identificadores de evento que permitan decidir si representan duplicación de ingesta o acciones distintas en el mismo minuto. Conservo los 93 registros originales y declaro ambas cuentas cuando corresponde. No atribuyo ubicaciones o reputación a las IP ni considero sospechosa una hora nocturna sin contexto operacional.

## Hallazgos priorizados

| Hallazgo | Evidencia concreta | Interpretación y certeza | Prioridad |
| --- | --- | --- | --- |
| Cambio de privilegios sin aprobación registrada | Línea 57: 01:49, IP `203.0.113.42`, usuario `guest`, `access/denied`, recurso `/admin`. Línea 59: 01:50, misma IP y usuario, `role_change/success`, `role=user->admin; approved=false`. | El log registra un cambio exitoso a administrador sin aprobación. La correlación con la denegación un minuto antes refuerza la sospecha de escalamiento. El campo de usuario dice `guest`, pero el detalle dice `user->admin`: no se debe inventar una transición `guest->admin` ni asumir que el usuario registrado es necesariamente el destinatario del cambio. Falta identificar actor, cuenta afectada y autorización externa. | Alta |
| Posible credencial expuesta en depuración | Línea 33: 01:27, IP `192.0.2.44`, usuario `api_service`, `debug/warning`, detalle `token=[OCULTO]; debug output`. Se comprobó que el campo token contiene un valor no vacío sin mostrarlo. | Evidencia directa de escritura de un valor etiquetado como token en un log. No se ha verificado si es una credencial válida, vigente o accesible a terceros; al ser datos sintéticos no se intentó utilizarla. | Alta si el valor representa una credencial operativa; verificar alcance |
| Fallos repetidos contra `admin` seguidos de éxito | IP `198.51.100.77`: líneas 17, 19, 20, 22, 23, 25, 26 y 27 muestran ocho registros `login/failed`, con `incorrect password`, entre 01:14 y 01:18. Línea 28: `login/success` a las 01:19, `login after multiple failures`. | Patrón compatible con adivinación de contraseña y posible acceso logrado. Al colapsar duplicados quedan cinco registros de fallo diferentes en cuatro minutos, seguidos del éxito un minuto después. No permite confirmar ocho intentos independientes ni que el éxito sea ilegítimo. El mismo usuario y la misma IP hacen justificable la investigación incluso considerando los duplicados. | Alta para revisar el acceso administrativo |
| Intentos sobre varias cuentas desde una IP | IP `203.0.113.89`: líneas 67, 68, 70, 71, 73 y 74, entre 02:01 y 02:03. Seis `login/failed` con `incorrect password`, uno para cada cuenta: `ana`, `carlos`, `luisa`, `diego`, `maria` y `sofia`. | Patrón compatible con ataque distribuido entre cuentas desde un solo origen, por ejemplo password spraying. No se registran contraseñas usadas y por tanto no se puede afirmar que se reutilizó una sola contraseña, ni distinguir con certeza spraying de otros intentos automatizados. No hay éxitos de esa IP en el archivo. | Media |

Los cuatro grupos tienen orígenes y cuentas distintos; el CSV no permite tratarlos como una sola campaña. No hay eventos posteriores que demuestren uso de los privilegios obtenidos o extracción de datos.

## Actividad normal o insuficiente para declarar incidente

- **Corrección de contraseña de `maria`:** IP `192.0.2.25`, líneas 38, 39 y 41, tres fallos a las 01:35, 01:36 y 01:37, todos con `mistyped password`; línea 42, éxito a las 01:38 con `legitimate user`. El contexto favorece un error humano corregido. Las etiquetas son evidencia del propio log, no validación independiente de legitimidad. El patrón aislado de fallos y éxito no basta para declarar intrusión.
- **Monitorización periódica:** `healthbot`, IP `192.0.2.200`, líneas 78, 80, 81, 82, 83 y 84: seis `healthcheck/success`, uno por minuto entre 02:10 y 02:15, con `scheduled monitoring`. La cadencia y el tipo de evento sustentan actividad operacional normal.
- **Actividad ordinaria:** 65 registros con `ordinary login`, de los cuales 54 son éxitos y 11 fallos. No se elevan en bloque a incidente por errores aislados, concurrencia o cambios de IP. Por ejemplo, `diego` falla a las 01:53 y tiene éxito a las 01:54 desde `192.0.2.10` (líneas 60–61). Las etiquetas ordinarias no garantizan benignidad, pero faltan indicadores adicionales para acusar compromiso.
- **Denegación de `/admin`:** por sí sola indica que un control rechazó un acceso; aquí se conserva como contexto del cambio de rol posterior, no como un incidente separado de acceso consumado.

## Siguientes comprobaciones sugeridas

Estas son recomendaciones, no acciones ejecutadas: comprobar la auditoría y autorización del cambio de rol; identificar actor y cuenta afectada; revisar sesión, MFA y acciones posteriores de `admin`; verificar con el responsable si el token representa una credencial y, si corresponde, revocarlo o rotarlo y limitar su exposición en logs; contrastar el patrón multicuenta con tareas autorizadas y controles de autenticación. La validez de una credencial debe verificarse por inventario o administración, sin reutilizar el valor encontrado.

## Integridad y reproducción

SHA-256 inicial y posterior del CSV, iguales:

`7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8`

No se modificó el CSV. Los scripts `analizar.py`, `verificar.py` y `duplicados.py` documentan los procedimientos; sus resultados se conservan en `salida_enmascarada.txt`, `verificacion.txt` y `duplicados.txt`. `traza.md` separa resultados de herramientas de observaciones. No se usaron Internet, servicios externos, skills ni otros agentes, ni se consultaron materiales fuera del directorio asignado.

Tiempo total: no disponible. Tokens consumidos: no disponible.
