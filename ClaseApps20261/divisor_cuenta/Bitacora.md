# Bitácora — migración de Flutter a React

Actualizada el 14 de octubre de 2026, zona horaria America/Guayaquil.
Las mediciones actuales se realizaron sobre la versión ya implementada.
Los tiempos históricos se distinguen de las duraciones de ejecución medidas hoy.

| Métrica | Flutter (laboratorio) | React (este deber) |
|---|---|---|
| Minutos hasta la primera versión que compila | No se registró el instante del primer build. T038 documenta que `flutter build linux` compiló. | No se registró el instante del primer build. Verificación actual: `npm run build` aprobado en **0,716 s (0,0119 min)**; esto mide ejecutar el build, no desarrollar la primera versión. |
| **Minutos hasta que pasan los 6 casos** | Cronómetro original no disponible. Referencia histórica: **194,55 min** entre el commit base y el de la app con pruebas. | Cronómetro original no disponible. Referencia histórica: **77,57 min** entre el commit base y el que registra los seis casos aprobados. Verificación actual: suite completa aprobada en **3,055 s (0,0509 min)**. |
| Iteraciones con el agente | No disponible: no se conserva aquí el historial de conversación del laboratorio ni su regla de conteo. | **27 mensajes de usuario visibles**, con la convención detallada abajo. No se pueden equiparar a iteraciones del laboratorio sin conocer su definición original. |
| Líneas de código escritas a mano | No registrado; no se puede reconstruir con fiabilidad desde Git. | No registrado; no se atribuyen a escritura manual las líneas generadas por el agente o copiadas de las instrucciones. |
| Enunciados modificados en la spec | —; documento original de referencia. | **0 de 75**: 100 % intactos, 0 % adaptados y 0 % no reutilizados. Diff vacío y SHA-256 idéntico. |
| Enunciados modificados en la Constitution | —; se compara la constitución Flutter 1.0.1. | **8 de 14 reglas principales**: 7 adaptadas en redacción y 1 reemplazada/redefinida (OCP); 6 idénticas. La gobernanza se compara aparte. Constitución React 2.0.0. |
| Líneas modificadas en el plan | —; plan original de referencia. | **103 agregadas y 96 eliminadas**, 199 operaciones de línea en el diff. No equivale a 199 requisitos diferentes ni a 199 líneas escritas a mano. |
| Casos de aceptación que pasan (0–6) | **6/6 documentados** en el checkpoint de la fase 5 de `tasks.md`; no se reejecutaron en esta actualización. | **6/6 comprobados** por `test/division.test.js`. La suite actual completa aprueba **126/126 pruebas en 9 archivos**. |

## Cómo se obtuvieron los tiempos

### Referencias del historial de Git

Se tomó como referencia reproducible el commit del proyecto base y el commit
que registra la implementación con pruebas. Es una referencia alternativa:
la plantilla menciona un «inicio definido arriba», pero ese inicio y el
cronómetro original no aparecen en los archivos disponibles.

| Proyecto | Commit base y fecha local | Commit de implementación con pruebas y fecha local | Diferencia |
|---|---|---|---:|
| Flutter | `a6486aa`, 2026-09-30 14:30:15 −05:00, «proyecto base de flutter, sin tocar» | `176c421`, 2026-09-30 17:44:48 −05:00, «app divisor de cuenta - rama sdd, con pruebas» | 3 h 14 min 33 s = **194,55 min** |
| React | `4e75f57`, 2026-10-14 20:05:06 −05:00, «proyecto react base, sin tocar» | `2eac75f`, 2026-10-14 21:22:40 −05:00, «divisor de cuenta en react, los 6 casos pasan» | 1 h 17 min 34 s = **77,57 min** |

Comandos para consultar los hitos:

```bash
git show -s --format='%h %aI %s' a6486aa 176c421 4e75f57 2eac75f
```

Las diferencias se calcularon restando las fechas de autor de los commits.
Incluyen posibles pausas y tiempo anterior a confirmar cambios. No identifican
el instante del primer build ni la primera ejecución verde, y no permiten
afirmar una reducción exacta del tiempo de desarrollo entre tecnologías.

### Mediciones actuales de React

Se ejecutaron secuencialmente, desde `divisor_cuenta_web/`, sin modificar el
código ni las pruebas:

```bash
npm run build
npm test
```

Un cronómetro monotónico de Python (`time.perf_counter`) midió desde el inicio
hasta el final de cada proceso, incluyendo el arranque de npm:

| Comando | Duración real del proceso | Tiempo informado por la herramienta | Resultado |
|---|---:|---:|---|
| `npm run build` | 0,716 s | Vite: 229 ms | Código de salida 0; build generado. |
| `npm test` | 3,055 s | Vitest: 2,37 s | Código de salida 0; 126 pruebas aprobadas en 9 archivos. |

Son una ejecución puntual sobre este equipo, no un promedio ni el tiempo
necesario para implementar la aplicación. Las salidas completas, las
duraciones y los hitos Git están en
[bitacora-mediciones.json](../divisor_cuenta_web/specs/001-divisor-cuenta/evidencias/bitacora-mediciones.json).

El tiempo de unos cinco segundos comunicado por el estudiante corresponde al
primer uso de la pantalla. Es contexto de usabilidad; no es el tiempo de
migración ni la duración de los comandos anteriores.

## Convención del conteo de interacciones

Al no estar disponible la «regla anterior» mencionada en la plantilla, se
registra un conteo explícito del historial visible de esta sesión: un mensaje
de usuario cuenta una vez, incluyendo dudas, confirmaciones, la petición
duplicada de tareas y la solicitud interrumpida. Se excluye el mensaje técnico
`environment_context`. Se incluye la solicitud de completar esta bitácora.

Los 27 mensajes contados son:

1. Problema con `specify init .`.
2. Problema al importar `spec.md`.
3. Equivalente de `speckit-constitution` en Codex.
4. Creación de la constitución React.
5. Plan inicial React.
6. Generación inicial de tareas.
7. Análisis inicial.
8. Propuesta de cambios para C1 y A1.
9. Cómo implementar esos cambios.
10. Enmienda OCP y constitución 2.0.0.
11. Actualización del plan y alcance offline.
12. Regeneración de tareas con verificación offline.
13. Repetición de esa solicitud de tareas.
14. Nuevo análisis.
15. Implementación.
16. Tiempo de primer uso: unos cinco segundos.
17. Confirmación de poder explicar las funciones.
18. Convergencia.
19. Configuración de Vitest en Vite.
20. Setup y scripts de pruebas.
21. Creación de las pruebas de dominio a partir de los seis casos.
22. Creación de tres pruebas de pantalla con Testing Library.
23. Consulta interrumpida sobre ejecutar la ruta de `spec.md`.
24. Problema con el comando de comparación de specs.
25. Creación de `respuestas.md` para la Parte 8.
26. Incorporación de las respuestas a las seis preguntas.
27. Búsqueda y actualización de esta bitácora.

Este número mide mensajes visibles, no solo ciclos de corrección de código,
y no sustituye una definición distinta del deber. No se inventó un conteo
equivalente para Flutter ni un número de líneas escritas manualmente.

## Evidencia de la reutilización

- **Spec:** el [análisis original](analisis_spec.md) identifica 75 enunciados
  QUÉ. El [diff vacío](../divisor_cuenta_web/specs/001-divisor-cuenta/evidencias/comparacion-spec.diff)
  y el [registro de hashes](../divisor_cuenta_web/specs/001-divisor-cuenta/evidencias/comparacion-spec.json)
  confirman que ambos archivos siguen idénticos.
- **Constitution:** se comparan la [Flutter 1.0.1](.specify/memory/constitution.md)
  y la [React 2.0.0](../divisor_cuenta_web/.specify/memory/constitution.md).
  El denominador de 14 cuenta la obligación general de SOLID, sus cinco reglas,
  las cuatro de arquitectura, seguridad, las dos de pruebas y la regla de la
  materia. Las siete adaptaciones son SRP, LSP, ISP, DIP, rutas de las capas,
  dominio puro y archivo de composición. OCP redefine el alcance y permite
  registrar estrategias en `src/main.jsx`. La gobernanza se analiza por
  separado en `respuestas.md`: cuatro cláusulas reemplazadas u omitidas y una
  conservada; no se suman al denominador de las reglas principales.
- **Plan:** el [diff completo](../divisor_cuenta_web/specs/001-divisor-cuenta/evidencias/comparacion-plan.diff)
  registra 103 inserciones y 96 eliminaciones. Cambian framework, lenguaje,
  estado, runner y plataforma; se conservan capas, contratos y reglas de negocio.
- **Casos:** la [comparación semántica](../divisor_cuenta_web/specs/001-divisor-cuenta/evidencias/comparacion-casos.json)
  confirma seis escenarios equivalentes, con los mismos resultados y mensajes.
  [division.test.js](../divisor_cuenta_web/test/division.test.js) los ejecuta
  con Vitest y agrega una prueba LSP. Para Flutter, el checkpoint de la fase 5
  y T038 de [tasks.md](specs/001-dividir-cuenta/tasks.md) documentan los seis
  escenarios y una ejecución histórica de 70 pruebas con build Linux aprobado;
  T038 deja pendientes comprobaciones manuales, que no se dan por realizadas.
- **Alcance offline React:** operación sin red después de cargar recursos,
  sin recargar y sin persistencia del formulario; no se garantiza primera
  apertura remota o recarga offline. Los resultados A1–A7 están en la
  [evidencia de navegador](../divisor_cuenta_web/specs/001-divisor-cuenta/evidencias/validacion-browser.json).

Las respuestas y la clasificación detallada de reglas se encuentran en
[respuestas.md](../divisor_cuenta_web/respuestas.md).
