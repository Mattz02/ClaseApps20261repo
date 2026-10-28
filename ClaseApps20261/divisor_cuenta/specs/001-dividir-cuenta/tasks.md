---

description: "Lista de tareas para implementar Dividir la cuenta del restaurante"
---

# Tasks: Dividir la cuenta del restaurante

**Input**: Design documents from `specs/001-dividir-cuenta/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/dominio.md,
contracts/pantalla.md, quickstart.md

**Tests**: Se incluyen porque la constitución (principio IV) exige pruebas para la
funcionalidad crítica y que los criterios de aceptación se conviertan en pruebas ejecutables. Se
escriben primero y deben fallar antes de implementar.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

Proyecto Flutter único: código en `lib/{domain,data,presentation}/` y `lib/main.dart`; pruebas en
`test/{domain,data,presentation}/` y `test/aceptacion_test.dart`. Todas las rutas son relativas
a `divisor_cuenta/`.

## Reglas para todas las tareas

- **Principio V**: cada clase y cada función o método nuevos (públicos y privados, incluidos
  `build` y los callbacks con nombre; solo se exceptúan los getters de una línea) llevan un
  comentario `///` que dice qué hace, por qué existe, qué recibe, qué devuelve y qué errores
  produce. La aritmética entera lleva un
  ejemplo numérico en el comentario.
- `lib/domain/` no importa `package:flutter`; `lib/presentation/` no importa nada de `lib/data/`.
- Solo `lib/main.dart` crea instancias de `RedondeoExacto`, `RedondeoHaciaArriba`,
  `ValidarEntrada`, `CalcularDivision`, `FormateadorMoneda` y `DivisorController`.
- Nombres en español, null safety, sin paquetes externos. No tocar `android/`, `ios/` ni
  `pubspec.yaml`.

## Decisiones del usuario (confirmadas el 2026-09-30)

- **D1 – Topes** (research R2): monto ≤ 999 999 999.99, personas ≤ 1 000 000,
  propina ≤ 999.99 %. ✅ Confirmada; está en FR-009, FR-011 y FR-012 de la spec.
- **D2 – Máximo 2 decimales** en monto y propina (research R3). ✅ Confirmada; está en FR-009 y
  FR-012 de la spec.
- **D3 – Permiso para modificar `test/`**: ✅ aprobado (CLAUDE.md actualizado).

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Estructura de carpetas y limpieza de la plantilla

- [X] T001 Crear las carpetas `lib/domain/`, `lib/data/`, `lib/presentation/`, `test/domain/`, `test/data/` y `test/presentation/` según la estructura de plan.md
- [X] T002 Eliminar `test/widget_test.dart` (prueba del contador de la plantilla, que dejará de compilar al cambiar `lib/main.dart`). Aprobado por D3
- [x] T003 [P] Actualizar `specs/001-dividir-cuenta/spec.md` (FR-009, FR-011, FR-012, Edge Cases y Assumptions) con los topes de D1 y el máximo de 2 decimales de D2. Hecho el 2026-09-30 tras `/speckit-analyze`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Tipos de `domain` que usan todas las historias. Dart puro, clases inmutables (campos `final`, constructor `const`).

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T004 [P] Crear la clase `Cuenta` en `lib/domain/cuenta.dart` con `final int montoCentavos` ("1 ≤ valor ≤ 99 999 999 999 (es decir, 0.01 a 999 999 999.99)"), `final int personas` ("1 ≤ valor ≤ 1 000 000") y `final int propinaCentesimas` ("0 ≤ valor ≤ 99 999 (0 % a 999.99 %; 10 % = 1000)"), con constructor `const` y parámetros nombrados `required`
- [X] T005 [P] Crear la clase `Resultado` en `lib/domain/resultado.dart` con `final int montoPorPersonaCentavos` ("≥ 0; ya redondeado según la estrategia elegida") y constructor `const`
- [X] T006 [P] Crear `enum ErrorEntrada` en `lib/domain/error_entrada.dart` con los valores y el `final String mensaje` exacto: `montoInvalido('Monto inválido')`, `personasMenorQueUno('Debe haber al menos una persona')`, `personasInvalido('Número de personas inválido')`, `propinaInvalida('Propina inválida')`
- [X] T007 [P] Crear `abstract interface class EstrategiaRedondeo` en `lib/domain/estrategia_redondeo.dart` con un único método `int redondear({required int numerador, required int denominador})`. El comentario `///` documenta el contrato de contracts/dominio.md: recibe centavos exactos = numerador / denominador, precondiciones `numerador >= 0` y `denominador > 0`, devuelve centavos `>= 0` y no lanza errores
- [X] T008 Crear la clase `ResultadoValidacion` en `lib/domain/resultado_validacion.dart` con `final Cuenta? cuenta` ("no nulo si y solo si `errores` está vacío"), `final List<ErrorEntrada> errores` ("en orden: monto, personas, propina") y el getter `bool get esValida => errores.isEmpty` (depende de T004 y T006)

**Checkpoint**: domain listo; las historias pueden empezar.

---

## Phase 3: User Story 1 - Calcular cuánto paga cada persona (Priority: P1) 🎯 MVP

**Goal**: Con datos válidos y modo "Exacto", al tocar "Calcular" se muestra el monto por persona con 2 decimales.

**Independent Test**: `flutter test test/aceptacion_test.dart` pasa los escenarios 1, 2 y 5 (27.50, 30.00, 3.33) y FR-014.

### Tests for User Story 1 ⚠️

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T009 [P] [US1] Pruebas de `RedondeoExacto` en `test/data/redondeo_exacto_test.dart`: `(110000000, 40000) → 2750`, `(90000000, 30000) → 3000`, `(10000000, 30000) → 333`, mitad hacia arriba `(667, 2) → 334`, `(0, 1) → 0`
- [X] T010 [P] [US1] Pruebas de `CalcularDivision` en `test/domain/calcular_division_test.dart` con una estrategia falsa definida en la prueba que guarda los argumentos recibidos: `Cuenta(montoCentavos: 10000, personas: 4, propinaCentesimas: 1000)` debe pasarle `numerador 110000000` y `denominador 40000`, y devolver `Resultado` con los centavos que retorne la estrategia falsa
- [X] T011 [P] [US1] Grupo "entradas válidas" en `test/domain/validar_entrada_test.dart`: `('100.00','4','10') → Cuenta(10000, 4, 1000)`, `'12,50' → 1250 centavos`, `' 90 '` con espacios → 9000, propina `'12.5' → 1250`, propina con coma `'12,5' → 1250`, propina `'' → 0`, `esValida == true` y `errores` vacío
- [X] T012 [P] [US1] Pruebas de `FormateadorMoneda` en `test/presentation/formateador_moneda_test.dart`: `2750 → '27.50'`, `400 → '4.00'`, `5 → '0.05'`, `0 → '0.00'`, `123456 → '1234.56'`
- [X] T013 [P] [US1] Grupo "cálculo" en `test/presentation/divisor_controller_test.dart`, con una estrategia falsa y `ValidarEntrada`, `CalcularDivision` y `FormateadorMoneda` reales: `modos` respeta el orden del mapa; `modoSeleccionado` inicial es el primero; `calcular('100.00','4','10')` deja `montoPorPersona` según la estrategia; `descartarResultado()` y `seleccionarModo(...)` lo dejan en `null`; `seleccionarModo('inexistente')` lanza `ArgumentError`
- [X] T014 [P] [US1] Pruebas de widget en `test/aceptacion_test.dart` que usan `construirApp()` de `lib/main.dart` y las Keys de contracts/pantalla.md (`campo_monto`, `campo_personas`, `campo_propina`, `boton_calcular`, `texto_resultado`): escenario 1 (100.00, 4, 10 → '27.50'), escenario 2 (90.00, 3, 0 → '30.00'), escenario 5 (10.00, 3, 0 → '3.33'), FR-003 (antes de tocar "Calcular" no aparece `texto_resultado`, aunque los datos sean válidos) y FR-014 (después de calcular, cambiar un campo oculta `texto_resultado`)

### Implementation for User Story 1

- [X] T015 [P] [US1] Implementar `RedondeoExacto implements EstrategiaRedondeo` en `lib/data/redondeo_exacto.dart`: `(2 * numerador + denominador) ~/ (2 * denominador)`, con un ejemplo en el comentario (`10000000 / 30000 → 333`)
- [X] T016 [P] [US1] Implementar `CalcularDivision.calcular(Cuenta cuenta, EstrategiaRedondeo estrategia)` en `lib/domain/calcular_division.dart`: `numerador = montoCentavos * (10000 + propinaCentesimas)`, `denominador = 10000 * personas`; devuelve `Resultado(montoPorPersonaCentavos: estrategia.redondear(...))`. No valida ni formatea
- [X] T017 [P] [US1] Implementar `ValidarEntrada.validar({required String monto, required String personas, required String propina})` en `lib/domain/validar_entrada.dart` para entradas válidas: recorta espacios; monto y propina con `^\d+([.,]\d{1,2})?$` (D2), convertidos a centavos o centésimas a partir de los dígitos del texto, sin `double`; personas con `^-?\d+$` e `int.tryParse`, y un entero < 1 da `personasMenorQueUno` (así `CalcularDivision` nunca divide entre 0); propina vacía = 0. Si un campo no cumple su expresión, agrega el `ErrorEntrada` de ese campo (`montoInvalido`, `personasInvalido` o `propinaInvalida`); las reglas finas se completan en T026. Nunca lanza excepciones
- [X] T018 [P] [US1] Implementar `FormateadorMoneda.formatear(int centavos)` en `lib/presentation/formateador_moneda.dart`: `'${centavos ~/ 100}.${(centavos % 100).toString().padLeft(2, '0')}'`, sin símbolo de moneda
- [X] T019 [US1] Implementar `DivisorController` en `lib/presentation/divisor_controller.dart` según contracts/pantalla.md: constructor con `validador`, `calculadora`, `estrategias` (`Map<String, EstrategiaRedondeo>`, no vacío) y `formateador`; `modos`, `modoSeleccionado`, `montoPorPersona`, `seleccionarModo` (lanza `ArgumentError` si el modo no existe; llama a `descartarResultado`), `calcular` (valida; si es válida, calcula con la estrategia del modo elegido y formatea) y `descartarResultado`. No importa nada de `lib/data/` (depende de T016, T017, T018)
- [X] T020 [US1] Implementar `PantallaDivisor` (`StatefulWidget`) en `lib/presentation/pantalla_divisor.dart` según la tabla de contracts/pantalla.md: 3 `TextField` con sus Keys y etiquetas ("Monto total", "Número de personas", "Propina (%)"), `SegmentedButton` `selector_modo` construido desde `controlador.modos`, `FilledButton` `boton_calcular` "Calcular" y el resultado `texto_resultado` ("Cada persona paga" + monto) visible solo si `montoPorPersona != null`. Cada acción llama al controller dentro de `setState`; el `onChanged` de cada campo llama a `descartarResultado`; los `TextEditingController` se liberan en `dispose` (depende de T019)
- [X] T021 [US1] Reemplazar `lib/main.dart` por el punto de composición: función `Widget construirApp()` que crea `ValidarEntrada`, `CalcularDivision`, `FormateadorMoneda`, el mapa `{'Exacto': RedondeoExacto()}` y el `DivisorController`, y devuelve `MaterialApp(title: 'Divisor de Cuenta', home: PantallaDivisor(controlador: ...))`; `void main() => runApp(construirApp());` (depende de T015, T020)
- [X] T022 [US1] Ejecutar `flutter test` y `flutter analyze` y dejar en verde todas las pruebas de T009 a T014

**Checkpoint**: MVP: la app calcula en modo exacto y pasa los escenarios 1, 2 y 5.

---

## Phase 4: User Story 2 - Avisar cuando los datos no son válidos (Priority: P2)

**Goal**: Cada campo inválido muestra su mensaje exacto y no se muestra ningún resultado.

**Independent Test**: `flutter test test/aceptacion_test.dart` pasa los escenarios 3 ("Debe haber al menos una persona") y 4 ("Monto inválido"), sin `texto_resultado`.

### Tests for User Story 2 ⚠️

- [X] T023 [P] [US2] Grupo "entradas inválidas" en `test/domain/validar_entrada_test.dart`. Monto `'abc'`, `''`, `'0'`, `'0.00'`, `'-5'`, `'1e5'`, `'12.345'` (D2) y `'1000000000'` (D1) → `montoInvalido`. Personas `'0'` y `'-3'` → `personasMenorQueUno`. Personas `''`, `'2.5'`, `'dos'` y `'1000001'` (D1) → `personasInvalido`. Propina `'-1'`, `'abc'` y `'1000'` (D1) → `propinaInvalida`. Con los tres campos inválidos, `errores` sale en orden monto, personas, propina y `cuenta == null`
- [X] T024 [P] [US2] Grupo "errores" en `test/presentation/divisor_controller_test.dart`: después de `calcular('abc','0','x')`, `errorMonto`, `errorPersonas` y `errorPropina` tienen sus mensajes y `montoPorPersona == null`; un `calcular` válido posterior borra los errores; `descartarResultado()` también los borra
- [X] T025 [P] [US2] Agregar a `test/aceptacion_test.dart`: escenario 3 (50.00 y 0 personas → 'Debe haber al menos una persona', sin `texto_resultado`), escenario 4 (monto 'abc' → 'Monto inválido', sin `texto_resultado`), varios campos inválidos a la vez (se muestran los 3 mensajes) y recuperación (corregir y volver a calcular muestra el resultado)

### Implementation for User Story 2

- [X] T026 [US2] Completar las reglas de `ValidarEntrada` en `lib/domain/validar_entrada.dart` según la tabla ErrorEntrada de data-model.md. Monto igual a 0 o mayor que 99 999 999 999 centavos (D1) → `montoInvalido`. Personas: vacío, no entero o > 1 000 000 (D1) → `personasInvalido`; los números demasiado largos para `int` también dan `personasInvalido`. Propina > 99 999 centésimas (D1) → `propinaInvalida`. Siempre valida los 3 campos, con como máximo un error por campo
- [X] T027 [US2] Agregar a `DivisorController` en `lib/presentation/divisor_controller.dart` los getters `errorMonto`, `errorPersonas` y `errorPropina` (el `mensaje` del `ErrorEntrada` de cada campo, o `null`): `calcular` con errores los guarda y deja `montoPorPersona` en `null`; un `calcular` válido borra los errores; `descartarResultado` borra resultado y errores
- [X] T028 [US2] En `lib/presentation/pantalla_divisor.dart`, mostrar `errorText` en cada `TextField` desde `errorMonto`, `errorPersonas` y `errorPropina`
- [X] T029 [US2] Ejecutar `flutter test` y `flutter analyze` y dejar en verde las pruebas de T023 a T025 sin romper las de US1

**Checkpoint**: US1 y US2 funcionan; ninguna entrada inválida produce un resultado (SC-005).

---

## Phase 5: User Story 3 - Redondear hacia arriba (Priority: P3)

**Goal**: El modo "Hacia arriba" muestra el monto por persona redondeado al entero superior. Se agrega **sin editar ninguna clase existente** (OCP): una clase nueva en `data/` y una línea en `main.dart`.

**Independent Test**: `flutter test test/aceptacion_test.dart` pasa el escenario 6 (10.00, 3, 0 → '4.00') y 90.00, 3, 0 → '30.00' en modo hacia arriba.

### Tests for User Story 3 ⚠️

- [X] T030 [P] [US3] Pruebas de `RedondeoHaciaArriba` en `test/data/redondeo_hacia_arriba_test.dart`: `(10000000, 30000) → 400`, `(90000000, 30000) → 3000` (un entero no sube), `(110000000, 40000) → 2800`, `(1, 1) → 100`, `(0, 1) → 0`
- [X] T031 [P] [US3] Agregar a `test/aceptacion_test.dart`: el `selector_modo` muestra "Exacto" y "Hacia arriba"; escenario 6 (10.00, 3, 0, Hacia arriba → '4.00'); 90.00, 3, 0, Hacia arriba → '30.00'; cambiar de modo después de calcular oculta `texto_resultado`

### Implementation for User Story 3

- [X] T032 [US3] Implementar `RedondeoHaciaArriba implements EstrategiaRedondeo` en `lib/data/redondeo_hacia_arriba.dart`: con `d = 100 * denominador`, devolver `((numerador + d - 1) ~/ d) * 100`, con un ejemplo en el comentario (`10000000 / 30000 → 400`)
- [X] T033 [US3] En `lib/main.dart`, agregar `'Hacia arriba': RedondeoHaciaArriba()` al mapa de estrategias, después de `'Exacto'`. No editar `DivisorController` ni `PantallaDivisor` (depende de T032)
- [X] T034 [US3] Ejecutar `flutter test` y `flutter analyze` y dejar en verde las pruebas de T030 y T031 sin romper US1 ni US2

**Checkpoint**: las 3 historias funcionan; los 6 escenarios de aceptación pasan (SC-001).

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Comprobaciones de la constitución y del quickstart

- [X] T035 [P] Revisar que cada clase y cada función o método de `lib/` (públicos y privados, salvo getters de una línea) tenga el comentario `///` del principio V (qué hace, por qué existe, qué recibe, qué devuelve, qué errores produce) y completar los que falten
- [X] T036 [P] Ejecutar `dart format lib test` y `flutter analyze` y dejarlo en "No issues found!"
- [X] T037 Ejecutar las 3 comprobaciones de arquitectura con `grep` de `specs/001-dividir-cuenta/quickstart.md` y corregir cualquier violación (domain sin Flutter, presentation sin data, instancias concretas solo en `lib/main.dart`)
- [ ] T038 Ejecutar `flutter test` completo y luego los escenarios manuales de `specs/001-dividir-cuenta/quickstart.md` con `flutter run`. Parcial (2026-09-30): `flutter test` pasa (70 pruebas) y `flutter build linux` compila; faltan los escenarios manuales en un dispositivo

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: sin dependencias. T003 ya está hecha.
- **Foundational (Phase 2)**: depende de T001. Bloquea todas las historias.
- **US1 (Phase 3)**: depende de la Fase 2.
- **US2 (Phase 4)**: depende de la Fase 2 y de US1, porque extiende `ValidarEntrada`, `DivisorController`, `PantallaDivisor` y `test/aceptacion_test.dart`, que se crean en US1.
- **US3 (Phase 5)**: depende de la Fase 2 y de US1 (necesita `lib/main.dart` y la pantalla). **No depende de US2.**
- **Polish (Phase 6)**: depende de las historias que se vayan a entregar.

### User Story Dependencies

- **US1 (P1)**: solo de la Fase 2.
- **US2 (P2)**: de US1 (mismos archivos); sus pruebas se pueden verificar por separado.
- **US3 (P3)**: de US1; se puede hacer antes, después o en paralelo con US2, excepto por `test/aceptacion_test.dart`, que se edita en ambas.

### Within Each User Story

- Pruebas primero; deben fallar (aunque sea porque todavía no compilan) antes de implementar.
- domain → data → presentation → `main.dart`.
- Cerrar cada historia con `flutter test` y `flutter analyze` en verde.

### Parallel Opportunities

- Fase 2: T004, T005, T006 y T007 en paralelo; T008 después de T004 y T006.
- US1: las 6 pruebas (T009 a T014) en paralelo; luego T015, T016, T017 y T018 en paralelo; después T019 → T020 → T021.
- US2: T023, T024 y T025 en paralelo; luego T026 → T027 → T028.
- US3: T030 y T031 en paralelo; luego T032 → T033.
- Polish: T035 y T036 en paralelo.

---

## Parallel Example: User Story 1

```bash
# Las pruebas de US1, todas juntas (archivos distintos):
Task: "Pruebas de RedondeoExacto en test/data/redondeo_exacto_test.dart"
Task: "Pruebas de CalcularDivision en test/domain/calcular_division_test.dart"
Task: "Grupo 'entradas válidas' en test/domain/validar_entrada_test.dart"
Task: "Pruebas de FormateadorMoneda en test/presentation/formateador_moneda_test.dart"
Task: "Grupo 'cálculo' en test/presentation/divisor_controller_test.dart"
Task: "Escenarios 1, 2, 5, FR-003 y FR-014 en test/aceptacion_test.dart"

# Las piezas independientes de US1, todas juntas:
Task: "RedondeoExacto en lib/data/redondeo_exacto.dart"
Task: "CalcularDivision en lib/domain/calcular_division.dart"
Task: "ValidarEntrada (entradas válidas) en lib/domain/validar_entrada.dart"
Task: "FormateadorMoneda en lib/presentation/formateador_moneda.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Fase 1 (Setup) y Fase 2 (Foundational).
2. Fase 3 (US1).
3. **Parar y validar**: los escenarios 1, 2 y 5 pasan y la app calcula en modo exacto.

### Incremental Delivery

1. Setup + Foundational → domain listo.
2. US1 → MVP (cálculo exacto).
3. US2 → mensajes de error (escenarios 3 y 4).
4. US3 → modo "Hacia arriba" (escenario 6), agregado solo con una clase nueva y una línea en `main.dart` (demuestra OCP).
5. Polish → constitución y quickstart verificados.

---

## Notes

- [P] = archivos distintos, sin dependencias pendientes.
- [USn] vincula la tarea con su historia de la spec.
- `ValidarEntrada`, `DivisorController`, `PantallaDivisor` y `test/aceptacion_test.dart` se tocan en más de una historia: esas tareas son secuenciales entre historias.
- Hacer commit al cerrar cada fase o historia.
