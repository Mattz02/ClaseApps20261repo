# Analisis de constitution.md
## Principios fundamentales
### I. Calidad de codigo (SOLID)
Enunciado
El código DEBE respetar los cinco principios SOLID
Tipo
QUE
Viaja a React?
Si
Por que
la calidad del codigo tiene que ser consistente y respetar los principios SOLID independientemente del lenguaje o la tecnologia

### II. Arquitectura por capas
Enunciado
- El código de `lib/` se organiza en tres capas: `presentation`, `domain` y `data`.
- Regla de dependencia: `presentation -> domain <- data`. `domain` NO DEBE importar
  nada de `presentation` ni de `data`.
- `lib/domain/` NO DEBE importar `package:flutter`; es Dart puro.
- `main.dart` es el ÚNICO lugar donde se instancian implementaciones concretas.
Tipo
Mixto
Viaja a React?
Sí, con adaptación
Por que
La organización por capas y la regla de dependencia se conservan. Los nombres
`lib/`, `package:flutter` y `main.dart` deben adaptarse: en React se mantiene
un dominio independiente del framework y un único punto de composición, con
las rutas y el archivo de entrada que se definan en el plan.

### III. Seguridad
Enunciado
- Nunca se DEBEN guardar secretos ni API keys en el repositorio.
Tipo
QUE
Viaja a React?
Si
Por Que
el no compartir API keys y secretos es algo que se tiene que cumplir en todo lado independientemente de que teconologia se use

### IV. Calidad y pruebas
Enunciado
- Toda funcionalidad crítica DEBE tener pruebas.
- Los criterios de aceptación de cada spec DEBEN convertirse en pruebas ejecutables.
Tipo
QUE
Viaja a React?
Si
Por que
el crear pruebas basado en los criterios de los specs es algo que se tiene que hacer independientemente de la tecnologia que se usa

## Desglose y conteo de los enunciados analizados de la constitución

Este conteo corresponde a los enunciados de los apartados I a IV incluidos
en el análisis anterior. La regla general de SOLID cuenta como un enunciado;
las cuatro reglas de arquitectura cuentan por separado y las dos reglas de
pruebas también. No se cuentan líneas físicas ni apartados como unidades.

| Enunciado | Tipo (QUÉ/CÓMO/MIXTO) | Decisión para React | Justificación |
|---|---|---|---|
| C1. El código debe respetar los cinco principios SOLID. | QUÉ | Idéntica | Los principios de calidad siguen siendo válidos al cambiar de framework. |
| C2. El código de `lib/` se organiza en tres capas: `presentation`, `domain` y `data`. | MIXTO | Adaptada en redacción | Se conservan las tres capas; la ruta `lib/` se sustituye por la estructura del proyecto React. |
| C3. La dependencia es `presentation -> domain <- data` y el dominio no depende de las otras capas. | QUÉ | Idéntica | Ambas expresiones describen la misma restricción de dependencia, independiente del framework. |
| C4. `lib/domain/` no importa `package:flutter`; es Dart puro. | MIXTO | Adaptada en redacción | La idea es mantener el dominio independiente del framework; en React se expresa sin referencias a Flutter ni a Dart. |
| C5. `main.dart` es el único lugar donde se instancian implementaciones concretas. | MIXTO | Adaptada en redacción | Se mantiene un único punto de composición; el nombre y la ubicación del archivo se definen para React. |
| C6. Nunca se guardan secretos ni API keys en el repositorio. | QUÉ | Idéntica | La restricción de seguridad no depende de la tecnología. |
| C7. Toda funcionalidad crítica debe tener pruebas. | QUÉ | Idéntica | La obligación de verificar la funcionalidad crítica se conserva. |
| C8. Los criterios de aceptación de cada spec deben convertirse en pruebas ejecutables. | QUÉ | Idéntica | Los criterios se mantienen aunque se use otra herramienta para ejecutar las pruebas. |

| Clasificación | Cantidad |
|---|---:|
| QUÉ | 5 |
| CÓMO | 0 |
| MIXTO | 3 |
| Total de enunciados incluidos en este análisis de la constitución | 8 |

Decisiones para React: **5 idénticas, 3 adaptadas en redacción y 0 reemplazadas**.
Los tres MIXTOS se reportan aparte. Este conteo no se suma al denominador del
porcentaje de CÓMO de la spec ni se evalúa con su umbral pedagógico del 30 %.

## Adaptaciones propuestas para React de las reglas MIXTAS

| Enunciado original | Redacción propuesta para React | Motivo |
|---|---|---|
| El código de `lib/` se organiza en tres capas: `presentation`, `domain` y `data`. | El código de la aplicación se organiza en las capas `presentation`, `domain` y `data`, dentro de la estructura del proyecto React. | `lib/` corresponde a la estructura actual; la separación por capas se conserva. |
| `lib/domain/` no debe importar `package:flutter`; es Dart puro. | El dominio no debe importar `react` ni depender de la interfaz; contiene lógica independiente del framework. | El principio se conserva, pero las referencias a Flutter y Dart dejan de corresponder a React. |
| `main.dart` es el único lugar donde se instancian implementaciones concretas. | Las implementaciones concretas se conectan en un único punto de composición de la aplicación React. | Se conserva la centralización de dependencias y se adapta el archivo de entrada. |

Estas son propuestas documentadas en este análisis. No se han aplicado a
`constitution.md` ni a `spec.md`. La clasificación MIXTO indica que el principio
viaja con adaptación, no que deba descartarse.

# Analisis de spec.md

## Criterio de análisis

Archivo analizado: `specs/001-dividir-cuenta/spec.md`.

Para cada enunciado se pregunta: **¿Seguiría siendo válido si la app estuviera
hecha en React?** Se usan los mismos campos del análisis anterior: Enunciado,
Tipo, Viaja a React y Por qué, organizados en una tabla de cuatro columnas.

Cada fila contiene una regla o un criterio independiente. Las reglas repetidas
entre la descripción, las aclaraciones, las historias, los casos límite y los
requisitos se agrupan en una sola fila, indicando sus referencias. Los ejemplos
numéricos se incluyen como criterios verificables concretos. Los títulos, las
fechas, la rama, el estado del documento y las explicaciones de prioridad no se
cuentan como requisitos. Las pruebas independientes de las historias se cubren
con sus reglas y escenarios, pues no introducen una regla adicional.

Se separan las ideas independientes de los requisitos compuestos: por ejemplo,
mostrar un mensaje de error y no mostrar un resultado se analizan por separado.
Condiciones que expresan una misma regla, como monto cero o negativo
(monto no mayor que cero), se mantienen juntas.

**Intacto** significa que el enunciado sigue siendo válido tal como está,
aunque cambie el código necesario para cumplirlo.

## Pantalla, cálculo y presentación del resultado

| Enunciado | Tipo (QUÉ/CÓMO/MIXTO) | ¿Viaja a React? | Por qué |
|---|---|---|---|
| 1. La app debe tener una sola pantalla (Input; FR-001). | QUÉ | Sí, intacto | Define el alcance visible de la app; React puede presentar la misma pantalla. |
| 2. La pantalla debe incluir un campo para el monto total (Input; FR-001; US1). | QUÉ | Sí, intacto | Es un dato que ingresa el usuario, independiente de cómo se construya el campo. |
| 3. La pantalla debe incluir un campo para el número de personas (Input; FR-001; US1). | QUÉ | Sí, intacto | React necesita el mismo dato para realizar la división. |
| 4. La pantalla debe incluir un campo para el porcentaje de propina (Input; FR-001; US1). | QUÉ | Sí, intacto | Describe una entrada del sistema y no una clase o un widget. |
| 5. El usuario debe poder elegir entre los modos "Exacto" y "Hacia arriba" (Input; FR-002; US3). | QUÉ | Sí, intacto | Los modos son opciones funcionales que se pueden ofrecer con cualquier framework. |
| 6. El modo inicial debe ser "Exacto" (FR-002; US1). | QUÉ | Sí, intacto | Es el comportamiento inicial de la app, no una decisión sobre su implementación. |
| 7. El resultado debe calcularse solo cuando el usuario toca el botón "Calcular" (FR-003; US1). | QUÉ | Sí, intacto | El evento que inicia el cálculo sigue siendo válido con un botón de React. |
| 8. El monto por persona se obtiene sumando al monto total la propina y dividiendo entre el número de personas (FR-004). | QUÉ | Sí, intacto | Es una regla de negocio: (monto + monto × porcentaje / 100) / personas. |
| 9. En modo exacto se redondea al centavo más cercano (FR-005). | QUÉ | Sí, intacto | La precisión monetaria exigida no depende del lenguaje ni del framework. |
| 10. En modo exacto, las mitades se redondean hacia arriba (FR-005; Edge Cases). | QUÉ | Sí, intacto | Define cómo resolver un empate de redondeo y puede verificarse en React. |
| 11. En modo hacia arriba se redondea al entero más cercano que no sea menor que el monto calculado (FR-006; US3). | QUÉ | Sí, intacto | Es la regla matemática del modo, independientemente de la función usada para implementarla. |
| 12. En modo hacia arriba, un monto que ya es entero no cambia (FR-006; US3). | QUÉ | Sí, intacto | Es un caso de la regla de redondeo que debe cumplirse en ambas tecnologías. |
| 13. El monto por persona se muestra siempre con exactamente dos decimales (Input; FR-007; US1; US3). | QUÉ | Sí, intacto | Es un criterio verificable de presentación, incluso para resultados como 4.00. |
| 14. El resultado usa punto como separador decimal (FR-007). | QUÉ | Sí, intacto | El formato visible debe ser el mismo, aunque React utilice otra herramienta para formatearlo. |
| 15. El monto ingresado acepta punto como separador decimal (FR-008). | QUÉ | Sí, intacto | Es un formato de entrada permitido para el usuario. |
| 16. El monto ingresado acepta coma como separador decimal (FR-008; Edge Cases). | QUÉ | Sí, intacto | La aceptación de la coma no depende del tipo de componente de la interfaz. |
| 17. La propina ingresada acepta punto como separador decimal (FR-008). | QUÉ | Sí, intacto | Es una regla de entrada que puede mantenerse en React. |
| 18. La propina ingresada acepta coma como separador decimal (FR-008). | QUÉ | Sí, intacto | React puede aceptar y validar el mismo formato. |

## Validación y actualización de la pantalla

| Enunciado | Tipo (QUÉ/CÓMO/MIXTO) | ¿Viaja a React? | Por qué |
|---|---|---|---|
| 19. Si el monto está vacío, se muestra "Monto inválido" (FR-009; Edge Cases). | QUÉ | Sí, intacto | Define el mensaje esperado ante una entrada vacía. |
| 20. Si el monto no es un número, se muestra "Monto inválido" (FR-009; US2). | QUÉ | Sí, intacto | La validación de una entrada no numérica sigue siendo necesaria en React. |
| 21. Si el monto tiene más de dos decimales, se muestra "Monto inválido" (Clarifications; FR-009; Edge Cases). | QUÉ | Sí, intacto | El máximo de decimales es una restricción verificable de los datos de entrada. |
| 22. Si el monto es cero o negativo, se muestra "Monto inválido" (Clarifications; FR-009; Edge Cases). | QUÉ | Sí, intacto | Exige que el monto sea mayor que cero; es una regla funcional. |
| 23. Si el monto supera 999 999 999.99, se muestra "Monto inválido" (Clarifications; FR-009; Edge Cases). | QUÉ | Sí, intacto | El límite de entrada sigue siendo válido en React, aunque cambie la representación interna del dinero. |
| 24. Si el número de personas es un entero menor que uno, se muestra "Debe haber al menos una persona" (FR-010; Edge Cases). | QUÉ | Sí, intacto | El mínimo de personas y su mensaje son reglas del dominio. |
| 25. Si el campo de personas está vacío, se muestra "Número de personas inválido" (Clarifications; FR-011; Edge Cases). | QUÉ | Sí, intacto | Es el comportamiento esperado para un campo obligatorio sin valor. |
| 26. Si el número de personas no es un entero, se muestra "Número de personas inválido" (Clarifications; FR-011; Edge Cases). | QUÉ | Sí, intacto | Las personas se cuentan en enteros; esto no depende de Flutter. |
| 27. Si el número de personas supera 1 000 000, se muestra "Número de personas inválido" (Clarifications; FR-011; Edge Cases). | QUÉ | Sí, intacto | El tope es una restricción de entrada que puede conservarse en React. |
| 28. El mensaje para personas vacías, con decimales o no numéricas es distinto del mensaje para cero personas (Clarifications). | QUÉ | Sí, intacto | Distingue dos clases de errores visibles y sigue siendo verificable en React. |
| 29. Si la propina está vacía, se toma como 0 % y se calcula sin propina (Clarifications; FR-012; Edge Cases). | QUÉ | Sí, intacto | Define el significado de una entrada vacía; calcular sin propina es la consecuencia del valor cero. |
| 30. Si la propina es negativa, se muestra "Propina inválida" (FR-012; Edge Cases). | QUÉ | Sí, intacto | El porcentaje no negativo es una regla funcional. |
| 31. Si la propina no es un número, se muestra "Propina inválida" (FR-012; Edge Cases). | QUÉ | Sí, intacto | El mensaje y la condición de validación son independientes del framework. |
| 32. Si la propina tiene más de dos decimales, se muestra "Propina inválida" (Clarifications; FR-012; Edge Cases). | QUÉ | Sí, intacto | La precisión permitida en la entrada sigue siendo la misma. |
| 33. Si la propina supera 999.99 %, se muestra "Propina inválida" (Clarifications; FR-012; Edge Cases). | QUÉ | Sí, intacto | Es el límite de la spec actual y sigue siendo válido en React; cambiar de framework no lo convierte en 100 %. |
| 34. Cuando hay campos inválidos, se muestra el mensaje de cada uno de ellos (FR-013; Edge Cases; US2). | QUÉ | Sí, intacto | Describe cómo informar errores, también cuando hay varios al mismo tiempo. |
| 35. Cuando hay al menos un dato inválido, no se muestra ningún resultado (FR-013; Edge Cases; US2). | QUÉ | Sí, intacto | Impide mostrar un monto calculado con datos inválidos, sin importar la tecnología. |
| 36. Si el usuario modifica un dato después de calcular, se oculta el resultado anterior (Clarifications; FR-014; Edge Cases). | QUÉ | Sí, intacto | Evita que la interfaz muestre un resultado que ya no corresponde a los datos. |
| 37. Si el usuario cambia el modo después de calcular, se oculta el resultado anterior (Clarifications; FR-014; Edge Cases). | QUÉ | Sí, intacto | El resultado anterior deja de corresponder al modo seleccionado. |
| 38. Si el usuario modifica un dato después de calcular, se ocultan los mensajes de error (Clarifications; FR-014; Edge Cases). | QUÉ | Sí, intacto | Los errores anteriores pueden dejar de corresponder a la entrada actual. |
| 39. Si el usuario cambia el modo después de calcular, se ocultan los mensajes de error (Clarifications; FR-014; Edge Cases). | QUÉ | Sí, intacto | Es una regla de actualización de la pantalla que React puede cumplir. |
| 40. Después de ocultar el resultado o los errores, solo se vuelve a presentar la evaluación al tocar "Calcular" (Clarifications; FR-003; FR-014). | QUÉ | Sí, intacto | Define cuándo se vuelve a evaluar la entrada y mostrar su estado actualizado. |

## Funcionamiento sin conexión, alcance y entidades

| Enunciado | Tipo (QUÉ/CÓMO/MIXTO) | ¿Viaja a React? | Por qué |
|---|---|---|---|
| 41. La app debe funcionar completamente sin conexión (Input; FR-015). | QUÉ | Sí, intacto | Es una capacidad del producto; una app hecha en React también puede funcionar sin conexión. |
| 42. La app no usa red (Input; FR-015). | QUÉ | Sí, intacto | Es una restricción de funcionamiento que puede cumplirse sin peticiones de red en React. |
| 43. La app no usa una base de datos (Input). | QUÉ | Sí, intacto | Es una restricción del alcance; no obliga a usar una tecnología concreta. |
| 44. Los datos no se guardan entre sesiones (FR-015; Assumptions). | QUÉ | Sí, intacto | Define la ausencia de persistencia, independientemente del framework. |
| 45. Al cerrar la app se pierden los datos ingresados (Assumptions). | QUÉ | Sí, intacto | Es un comportamiento visible relacionado con el cierre de la sesión. |
| 46. El monto se muestra sin símbolo de moneda (Assumptions). | QUÉ | Sí, intacto | Es una decisión sobre lo que ve el usuario, no sobre una librería de formato. |
| 47. Todas las personas pagan la misma parte (Assumptions). | QUÉ | Sí, intacto | Es una regla de distribución de la cuenta. |
| 48. Dividir por consumo individual queda fuera del alcance (Assumptions). | QUÉ | Sí, intacto | Delimita qué problema resuelve la app y sigue aplicándose en React. |
| 49. La propina se calcula sobre el monto total ingresado (Assumptions; FR-004). | QUÉ | Sí, intacto | Especifica la base del porcentaje, independientemente de la implementación. |
| 50. La propina puede tener decimales, por ejemplo 12.5 % (Assumptions). | QUÉ | Sí, intacto | Es un valor de entrada permitido; React puede admitirlo con la misma validación. |
| 51. La interfaz está en español (Assumptions). | QUÉ | Sí, intacto | El idioma de la interfaz no depende del framework. |
| 52. Cuenta representa monto total, número de personas, porcentaje de propina y modo de redondeo (Key Entities). | QUÉ | Sí, intacto | Describe los datos del problema; no exige una clase Dart ni una forma concreta de almacenarlos. |
| 53. Modo de redondeo representa las opciones "Exacto" y "Hacia arriba" (Key Entities). | QUÉ | Sí, intacto | Es un concepto funcional que conserva su significado en React. |
| 54. Resultado representa el monto por persona cuando los datos son válidos (Key Entities). | QUÉ | Sí, intacto | Define la salida del sistema sin imponer su tipo o estructura en código. |
| 55. Si los datos son inválidos, la salida incluye la lista de mensajes de error (Key Entities). | QUÉ | Sí, intacto | Define la información que debe devolver la evaluación de las entradas. |
| 56. La suma de los montos individuales puede diferir del total por el redondeo (Edge Cases). | QUÉ | Sí, intacto | Es un comportamiento permitido explícitamente por la spec. |
| 57. La app muestra un único monto por persona (Edge Cases). | QUÉ | Sí, intacto | Define qué resultado ve el grupo, independientemente de la tecnología. |
| 58. La app no reparte los centavos sobrantes (Edge Cases). | QUÉ | Sí, intacto | Es una regla de distribución que se conserva al cambiar de framework. |

## Escenarios y ejemplos verificables

| Enunciado | Tipo (QUÉ/CÓMO/MIXTO) | ¿Viaja a React? | Por qué |
|---|---|---|---|
| 59. Con monto 100.00, cuatro personas, propina 10 % y modo exacto, tocar "Calcular" muestra 27.50 por persona (Input; US1, escenario 1). | QUÉ | Sí, intacto | Es un criterio de aceptación con entradas y salida concretas. |
| 60. Con monto 90.00, tres personas, propina 0 % y modo exacto, tocar "Calcular" muestra 30.00 por persona (Input; US1, escenario 2). | QUÉ | Sí, intacto | El resultado matemático esperado es el mismo en React. |
| 61. Con monto 10.00, tres personas, propina 0 % y modo exacto, tocar "Calcular" muestra 3.33 por persona (Input; US1, escenario 3). | QUÉ | Sí, intacto | Comprueba el redondeo al centavo con una división no exacta. |
| 62. Con monto 50.00 y cero personas, tocar "Calcular" muestra "Debe haber al menos una persona" (Input; US2, escenario 1). | QUÉ | Sí, intacto | Es un criterio de aceptación del mensaje de validación. |
| 63. Con monto 50.00 y cero personas, tocar "Calcular" no muestra resultado (Input; US2, escenario 1). | QUÉ | Sí, intacto | Es un criterio independiente del texto del mensaje: no debe aparecer un monto. |
| 64. Si el monto dice "abc", tocar "Calcular" muestra "Monto inválido" (Input; US2, escenario 2). | QUÉ | Sí, intacto | Comprueba una entrada no numérica y su mensaje exacto. |
| 65. Si el monto dice "abc", tocar "Calcular" no muestra resultado (US2, escenario 2). | QUÉ | Sí, intacto | Comprueba que una entrada inválida impida mostrar el monto. |
| 66. Con monto 10.00, tres personas, propina 0 % y modo hacia arriba, tocar "Calcular" muestra 4.00 por persona (Input; US3, escenario 1). | QUÉ | Sí, intacto | Es un criterio numérico que verifica el redondeo al entero superior. |
| 67. Con monto 90.00, tres personas, propina 0 % y modo hacia arriba, tocar "Calcular" muestra 30.00 por persona (US3, escenario 2). | QUÉ | Sí, intacto | Verifica que un monto que ya es entero no aumente. |
| 68. El monto ingresado "12,50" se acepta igual que "12.50" (Edge Cases). | QUÉ | Sí, intacto | Es un ejemplo verificable de equivalencia entre los separadores permitidos. |
| 69. En modo exacto, un monto calculado de 3.335 se redondea a 3.34 (Edge Cases). | QUÉ | Sí, intacto | Es un ejemplo verificable de la regla de que las mitades suben. |
| 70. Para una cuenta de 10.00 entre tres personas, que 3 × 3.33 sea 9.99 es un resultado esperado (Edge Cases). | QUÉ | Sí, intacto | Es un ejemplo concreto de la diferencia admitida al sumar montos redondeados. |

## Criterios de éxito

| Enunciado | Tipo (QUÉ/CÓMO/MIXTO) | ¿Viaja a React? | Por qué |
|---|---|---|---|
| 71. Los seis escenarios de aceptación de la descripción deben producir exactamente el monto o mensaje esperado: seis de seis (SC-001). | QUÉ | Sí, intacto | Es un criterio medible de cumplimiento funcional que puede probarse en React. |
| 72. Un usuario que abre la app por primera vez obtiene el monto por persona en menos de 30 segundos (SC-002). | QUÉ | Sí, intacto | Mide la facilidad de uso del producto, no el framework que lo implementa. |
| 73. El resultado aparece en menos de un segundo después de tocar "Calcular" (SC-003). | QUÉ | Sí, intacto | Es un requisito de tiempo de respuesta que mantiene el mismo umbral en React. |
| 74. El 100 % de los cálculos se completa sin conexión, con el dispositivo en modo avión (SC-004). | QUÉ | Sí, intacto | Es una condición verificable de funcionamiento sin red, también para una app de React disponible sin conexión. |
| 75. Ninguna entrada inválida produce un monto por persona en pantalla: cero casos (SC-005). | QUÉ | Sí, intacto | Es un criterio medible de validación independiente de la tecnología. |

## Conteo y porcentaje de CÓMO

El conteo corresponde únicamente a la especificación; no incluye el análisis
de la constitución.

| Clasificación | Cantidad |
|---|---:|
| QUÉ | 75 |
| CÓMO | 0 |
| MIXTO | 0 |
| Total de enunciados analizados | 75 |

```text
% CÓMO = (cantidad de CÓMO / total de enunciados analizados) × 100
% CÓMO = (0 / 75) × 100 = 0 %
```

Los MIXTOS se reportan aparte y no se suman a CÓMO. En esta especificación
no se encontraron enunciados MIXTOS.

El resultado es **0 %**, por debajo del umbral del 30 % establecido en el deber.
Con este criterio, la spec no está contaminada de decisiones técnicas.
El 30 % es un umbral pedagógico del ejercicio, no una regla universal de SDD.

## Enunciados que habría que modificar para React

No se encontró ningún enunciado que deba cambiar exclusivamente por pasar a
React. La spec no exige widgets, clases Dart, carpetas de Flutter ni librerías
concretas. Los nombres Cuenta, Modo de redondeo y Resultado describen conceptos
del problema, no clases obligatorias.

Las reglas de funcionar sin conexión, no usar red ni base de datos y no guardar
datos entre sesiones siguen siendo válidas. React requeriría decisiones de
implementación para cumplirlas, que deben resolverse en el plan. La condición
de modo avión también se conserva al probar una app disponible sin conexión.

Los topes de monto, personas y propina también siguen siendo válidos aunque
su origen haya sido técnico: aquí son límites verificables de entrada y no
instrucciones sobre cómo programarlos. La spec actual establece una propina
máxima de **999.99 %**; no pide cambiarla a 100 % para React.

## Respuesta para la pregunta 3

La especificación analizada contiene
75 enunciados independientes, todos QUÉ, con 0 CÓMO y 0 MIXTOS. El porcentaje
CÓMO es 0 %, por lo que no supera el umbral del 30 % del deber. No se requieren
cambios en la spec por el cambio de framework; las decisiones propias de React
corresponden al plan de implementación.

En los ocho enunciados incluidos en el análisis de la constitución, cinco se
conservan idénticos y tres requieren adaptar la redacción. Las referencias
concretas a `lib/`, `package:flutter`, Dart y `main.dart` se documentaron con
propuestas para React, manteniendo los principios de arquitectura. Estas
adaptaciones pertenecen a la constitución y no implican que haya decisiones
CÓMO en la spec. En la Parte 5 se podrá contrastar este resultado con el informe
de `/speckit-analyze`; todavía no se ha ejecutado ese análisis.
