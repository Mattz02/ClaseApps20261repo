# Reglas de detección para logs sintéticos

Consulta esta referencia antes de clasificar registros o calcular umbrales.
Las reglas se aplican a cualquier CSV compatible; no dependen de nombres,
direcciones, fechas ni números de fila de un archivo particular.

## Convenciones comunes

- Columnas requeridas: `timestamp`, `ip`, `user`, `event`, `result`, `detail`.
  Las coincidencias de `event` y `result` son exactas y sensibles a mayúsculas:
  `login/failed` significa `event == "login"` y `result == "failed"`.
  No conviertas variantes ni espacios extra en coincidencias silenciosamente.
- Usa la IP y el usuario como identificadores literales. No combines valores
  distintos por su parecido ni agrupes identidades ausentes como si fueran una.
  Documenta registros no evaluables para la regla afectada.
- Conserva los números originales antes de ordenar: encabezado = fila 1.
  Nunca cites la posición en una lista ordenada como fila del archivo original.
- Interpreta `timestamp` y ordena por su valor temporal; no dependas del orden
  textual. Para empates puedes conservar el orden original, pero no inferir
  causalidad ni un evento «posterior» a partir de ese orden.
- Si hay zonas horarias explícitas, compara instantes equivalentes. Si todas las
  fechas carecen de zona, declara que se asume una misma zona no especificada.
  No inventes fechas ni zonas para valores ambiguos o incompatibles. Excluye de
  las reglas temporales los registros cuyo tiempo no pueda interpretarse y
  declara el alcance parcial; aún pueden evaluarse reglas sin ventana temporal.
- Evalúa ventanas deslizantes, no bloques fijos del reloj: para cada posible
  comienzo `t`, incluye eventos entre `t` y `t + 5 minutos`, ambos extremos
  incluidos. Una diferencia de exactamente 300 segundos cuenta; una mayor no.
- No elimines duplicados solo porque compartan valores. Si no puede distinguirse
  una repetición de eventos reales, cuenta los registros observados y declara
  que los duplicados podrían afectar los umbrales; no inventes una deduplicación.
- Si varias ventanas justifican el mismo patrón, puedes reunirlas en una alerta
  para evitar repeticiones. Conserva al menos una ventana concreta que cumpla el
  umbral y todas sus filas de evidencia; no sumes períodos inconexos para alcanzarlo.
- Las severidades siguientes son orientativas para priorizar revisión, no una
  escala forense ni una prueba de impacto real.

## R1 — Fuerza bruta probable

**Condición:** al menos 6 registros con `event == "login"` y `result == "failed"`
de la misma pareja `(ip, user)` en una ventana de duración menor o igual a
5 minutos. No sumes fallos de usuarios o IP diferentes.

**Evidencia:** pareja, filas de los fallos, número de registros y timestamps
inicial/final de la ventana que satisface el umbral.

**Éxito posterior, anotado por separado:** busca `event == "login"` y
`result == "success"` para esa misma pareja. Como convención reproducible, toma
el último fallo de la ventana documentada como `t_final`; un éxito cuenta si
`0 < timestamp_exito - t_final <= 5 minutos`. Explicita este punto de referencia,
cita las filas de éxito y calcula la diferencia. Un evento con timestamp idéntico
no demuestra posterioridad. Si reúnes ventanas, indica cuál respalda la asociación.

El éxito no es necesario para activar R1 ni prueba que una cuenta fue comprometida.
Si no se observa, di «sin éxito posterior observado en los registros disponibles»;
no inventes registros ausentes ni supongas cobertura posterior completa.

**Severidad orientativa:** media; alta si se observa el éxito posterior definido.

## R2 — Password spraying probable

**Condición:** desde una misma IP, registros con `event == "login"` y
`result == "failed"` dirigidos a al menos 5 usuarios distintos dentro de una
ventana menor o igual a 5 minutos.

**Evidencia:** IP, usuarios distintos, sus filas y timestamps de la ventana.
Varios fallos del mismo usuario aportan un solo usuario al umbral. No cuentes
valores de usuario vacíos como una identidad adicional.

R1 y R2 pueden compartir evidencia; no fuerces exclusividad ni afirmes que son
dos atacantes o incidentes independientes.

**Severidad orientativa:** media.

## R3 — Token potencialmente expuesto

**Condición:** `detail` contiene la secuencia literal `token=`, sin requisito de
`event`, `result` ni ventana temporal. Es una señal de posible exposición, no
prueba de que el token tenga valor, sea válido o se haya utilizado.

**Evidencia:** fila original, timestamp si es válido y marcador
`token=[REDACTED]`. No imprimas ni siquiera parcialmente el valor; enmascara
todas sus apariciones antes de producir cualquier salida. Si es difícil separar
el valor del resto del texto, sustituye todo el detalle por `[REDACTED]` y declara
únicamente que contenía el marcador. No pruebes credenciales ni intentes usarlas.

**Severidad orientativa:** alta por posible exposición, con validez desconocida.

## R4 — Escalada no autorizada según el registro

**Condición:** `event == "role_change"`, `result == "success"` y el atributo
`approved` en `detail` tiene el valor literal `false` (`approved=false`).
Reconoce el atributo completo según los delimitadores observados: no confundas
`not_approved=false` o `approved=falsehood` con la condición. Si la estructura
es ambigua o tiene valores contradictorios, señala la ambigüedad sin dar el
atributo por confirmado. No requiere ventana temporal.

**Evidencia:** fila, timestamp, IP, usuario y atributo `approved=false`, con
cualquier otro secreto oculto. La alerta expresa lo declarado por el log; no
demuestra privilegios efectivos, identidad del autor ni culpabilidad.

**Severidad orientativa:** alta, sujeta a esas limitaciones.

## Controles contra falsos positivos

- Tres fallos aislados no satisfacen R1: son menos de seis. Tampoco bastan por
  sí solos para R2, que exige cinco usuarios distintos de la misma IP.
- Un `healthcheck` no es un `login/failed`, aunque su detalle mencione errores.
  No contribuye a R1 ni R2; si contiene `token=`, sí puede activar R3.
- Un éxito de autenticación aislado no activa R1 ni demuestra una intrusión.
- Un cambio con `approved=true`, sin aprobación interpretable o con resultado
  distinto de `success` no satisface R4. La ausencia de esta alerta no prueba
  que el cambio haya sido autorizado.
- Cero alertas significa que no se observaron coincidencias con estas reglas
  dentro de la cobertura evaluable, no que no existan otros riesgos.
