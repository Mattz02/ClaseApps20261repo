# Research: Dividir la cuenta del restaurante

Decisiones técnicas tomadas antes del diseño. No quedan puntos marcados como NEEDS CLARIFICATION.

## R1. Cómo representar el dinero: enteros, no `double`

- **Decision**: El monto se guarda en **centavos** (`int`) y la propina en **centésimas de
  porcentaje** (`int`; 10 % = 1000). El monto exacto por persona nunca se calcula como
  `double`: se expresa como una fracción entera `numerador / denominador` (en centavos), y la
  estrategia de redondeo la convierte en centavos enteros.
  - `numerador = montoCentavos × (10000 + propinaCentesimas)`
  - `denominador = 10000 × personas`
- **Rationale**: Con `double`, `100 * 1.1 / 4` da `27.500000000000004` (se comprobó con
  `dart run`). Al redondear hacia arriba, un error así puede hacer que un monto que ya es entero
  suba un peso, lo que viola FR-006 ("si el monto ya es entero, no cambia"). Con enteros la
  división es exacta y los 6 escenarios dan siempre el mismo resultado.
- **Alternatives considered**:
  - `double` con una tolerancia (épsilon): más difícil de explicar y de justificar el valor de
    la tolerancia (principio V).
  - `BigInt`: elimina cualquier límite, pero hace el código y las pruebas más difíciles de leer
    (`BigInt.from(10000)` en todas partes) para un caso que no aparece en uso real.

## R2. Límites para que los enteros no se desborden

- **Decision**: `ValidarEntrada` rechaza valores que harían desbordar los cálculos:
  - Monto mayor que 999 999 999.99 → "Monto inválido".
  - Propina mayor que 999.99 % → "Propina inválida".
  - Personas mayor que 1 000 000 → "Número de personas inválido".
  Con esos topes el numerador máximo es ≈ 1.1 × 10¹⁶, muy por debajo del máximo de `int` en
  Android (≈ 9.2 × 10¹⁸).
- **Rationale**: Se comprobó que en Dart `(1e22).round()` no falla: devuelve el máximo de `int`
  en silencio, así que un monto enorme daría un resultado falso sin aviso. Rechazarlo muestra un
  mensaje claro (FR-013) en vez de un número equivocado.
- **Alternatives considered**: `BigInt` (ver R1); no poner límites y aceptar resultados
  erróneos con montos absurdos.
- **Nota**: confirmado el 2026-09-30 e incorporado en FR-009, FR-011 y FR-012 de la spec.

## R3. Qué textos se aceptan como números

- **Decision**: `ValidarEntrada` recorta espacios y usa expresiones regulares en vez de confiar
  solo en `double.tryParse` / `int.tryParse`:
  - Monto y propina: `^\d+([.,]\d{1,2})?$`, es decir, dígitos con **como máximo 2 decimales**,
    con punto o coma (FR-008). Así "1e5", "NaN", "-5", "+5" y "12.345" son inválidos.
  - Personas: `^-?\d+$`. Un entero negativo o 0 da "Debe haber al menos una persona" (FR-010);
    cualquier otra cosa, "Número de personas inválido" (FR-011).
  - La conversión a centavos se hace con los dígitos del texto (parte entera × 100 + decimales),
    sin pasar por `double`.
- **Rationale**: `double.tryParse` acepta formatos que un usuario no quiere decir ("1e5",
  "Infinity") y obliga a volver a `double`. Más de 2 decimales en dinero no tiene sentido, y
  rechazarlos es más simple y explícito que redondear la entrada sin avisar.
- **Alternatives considered**: redondear la entrada a 2 decimales (cambia en silencio lo que
  escribió el usuario).
- **Nota**: confirmado el 2026-09-30 e incorporado en FR-009 y FR-012 de la spec.

## R4. Modos de redondeo con el patrón Estrategia

- **Decision**: `EstrategiaRedondeo` (domain) es una interfaz abstracta con un solo método,
  `int redondear({required int numerador, required int denominador})`, que devuelve centavos.
  `RedondeoExacto` y `RedondeoHaciaArriba` (data) la implementan solo con aritmética entera:
  - Exacto, al centavo con las mitades hacia arriba: `(2 × numerador + denominador) ~/ (2 × denominador)`.
  - Hacia arriba, al entero (múltiplo de 100 centavos): `techo(numerador / (100 × denominador)) × 100`,
    calculado con `(numerador + d − 1) ~/ d`, donde `d = 100 × denominador`.
- **Rationale**: Cumple OCP (una regla nueva es una clase nueva), ISP (un método) y LSP (las dos
  cumplen el mismo contrato). Comprobado a mano con los escenarios: 10.00 / 3 → 333 centavos en
  modo exacto y 400 hacia arriba; 90.00 / 3 hacia arriba → 3000.
- **Alternatives considered**: un `enum` con un `switch` dentro de `CalcularDivision` (agregar un
  modo obligaría a editar esa clase, lo que viola OCP).

## R5. Cómo elige la pantalla el modo sin conocer las clases concretas

- **Decision**: `main.dart` arma un `Map<String, EstrategiaRedondeo>` ordenado, cuya clave es el
  texto que se muestra: `{'Exacto': RedondeoExacto(), 'Hacia arriba': RedondeoHaciaArriba()}`,
  y se lo pasa a `DivisorController`. La pantalla construye el selector recorriendo el mapa; el
  primer elemento es el modo inicial (FR-002).
- **Rationale**: `presentation` solo ve la abstracción (DIP). Agregar un modo = una clase en
  `data/` + una línea en `main.dart`, sin editar el controller ni la pantalla (OCP). Los mapas
  literales de Dart conservan el orden de inserción.
- **Alternatives considered**: dos parámetros fijos `exacto` y `haciaArriba` en el controller
  (un tercer modo obligaría a editarlo).

## R6. Estado de la pantalla

- **Decision**: `PantallaDivisor` es un `StatefulWidget`. Sus acciones llaman al
  `DivisorController` dentro de `setState`. El controller es una clase Dart simple (no
  `ChangeNotifier`) que guarda el modo elegido, el último resultado formateado y los errores.
  Los `TextEditingController` de los tres campos viven en el `State` de la pantalla.
- **Rationale**: Es lo que pidió el usuario (setState, una sola pantalla), sin paquetes
  externos, y el controller se prueba sin Flutter.
- **Alternatives considered**: `ChangeNotifier` + `ListenableBuilder` (innecesario para una
  pantalla).

## R7. Mensajes de error

- **Decision**: `domain` define `enum ErrorEntrada` con el texto de cada mensaje de la spec
  ("Monto inválido", "Debe haber al menos una persona", "Número de personas inválido",
  "Propina inválida"). La pantalla muestra cada error debajo de su campo (`errorText`).
- **Rationale**: Los textos son reglas de la spec, así que las pruebas comparan valores del
  `enum` y no cadenas sueltas. Mostrar el error junto a su campo le dice al usuario qué
  corregir.
- **Nota**: al cambiar cualquier dato o el modo, el controller borra el resultado y los errores
  (FR-014), para no dejar un "Monto inválido" que ya se corrigió.

## R8. Pruebas

- **Decision**: Solo `flutter_test` (viene con el SDK). Pruebas unitarias por capa y pruebas de
  widget con los 6 escenarios de aceptación de la spec (principio IV).
- **Nota sobre CLAUDE.md**: resuelto el 2026-09-30. `CLAUDE.md` ahora permite modificar `test/`
  cuando lo exige una tarea de `tasks.md`, así que se puede reemplazar el `test/widget_test.dart`
  de la plantilla (prueba del contador) y crear las pruebas nuevas.
