# Implementation Plan: Dividir la cuenta del restaurante

**Branch**: `sdd` (feature `001-dividir-cuenta`) | **Date**: 2026-09-30 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-dividir-cuenta/spec.md`

**Note**: This template is filled in by the `/speckit-plan` command; its definition describes the execution workflow.

## Summary

App Flutter de una pantalla: el usuario escribe monto, personas y propina, elige un modo de
redondeo ("Exacto" o "Hacia arriba") y, al tocar "Calcular", ve cuánto paga cada persona con 2
decimales, o un mensaje por cada dato inválido.

Enfoque técnico: tres capas (`presentation -> domain <- data`). El dinero se maneja en centavos
enteros y el monto exacto por persona como una fracción entera, para que el redondeo no dependa
de errores de `double` (research R1). Cada modo de redondeo es una implementación de la interfaz
`EstrategiaRedondeo`, y `main.dart` las conecta (research R4 y R5).

## Technical Context

**Language/Version**: Dart 3.13 (SDK `^3.13.4`), Flutter 3.47.5 estable

**Primary Dependencies**: solo el SDK de Flutter (Material 3). Sin paquetes externos.

**Storage**: N/A (todo en memoria, FR-015)

**Testing**: `flutter_test` (incluido en el SDK): pruebas unitarias y de widget

**Target Platform**: Android (principal); Linux de escritorio para desarrollo

**Project Type**: mobile-app (una sola pantalla)

**Performance Goals**: resultado en menos de 1 s después de tocar "Calcular" (SC-003); en la
práctica es instantáneo

**Constraints**: sin conexión, sin persistencia, sin paquetes externos; `lib/domain/` en Dart
puro; estado con `setState`

**Scale/Scope**: 1 pantalla, ~10 clases, 1 usuario local

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principio | Cómo lo cumple el diseño | Estado |
|---|---|---|
| I. SRP | `ValidarEntrada` solo valida y convierte el texto, `CalcularDivision` solo calcula, `FormateadorMoneda` solo formatea y cada estrategia solo redondea | ✅ |
| I. OCP | Un modo nuevo = una clase nueva en `data/` + una entrada en el mapa de `main.dart`; no se edita ninguna clase existente (R5) | ✅ |
| I. LSP | Las dos estrategias cumplen el mismo contrato (mismas precondiciones, devuelven centavos ≥ 0, sin excepciones); ver contracts/dominio.md | ✅ |
| I. ISP | `EstrategiaRedondeo` tiene un solo método | ✅ |
| I. DIP | `DivisorController` recibe `Map<String, EstrategiaRedondeo>`; `presentation` no importa nada de `data/` | ✅ |
| II. Capas y dependencias | `presentation -> domain <- data`; `domain` no importa nada de las otras capas | ✅ |
| II. domain en Dart puro | `lib/domain/` no importa `package:flutter`; se comprueba con `grep` en quickstart.md | ✅ |
| II. main.dart compone | Es el único que crea `RedondeoExacto`, `RedondeoHaciaArriba`, `ValidarEntrada`, `CalcularDivision`, `FormateadorMoneda` y `DivisorController`. Los widgets y `TextEditingController` internos de la pantalla no son implementaciones de nuestras abstracciones | ✅ |
| III. Seguridad | No hay secretos, claves ni red | ✅ |
| IV. Pruebas | Pruebas unitarias de cada clase de domain, data y presentation, y los 6 escenarios de aceptación como pruebas de widget | ✅ (requiere permiso, ver abajo) |
| V. Código explicable | Cada clase y cada función o método (públicos y privados, incluidos `build` y los callbacks con nombre) lleva un comentario `///` que dice qué hace, por qué existe, qué recibe, qué devuelve y qué errores produce; solo se exceptúan los getters de una línea. La aritmética entera de R1 y R4 lleva un ejemplo numérico en el comentario | ✅ |

**Resultado**: pasa antes de la Fase 0 y se volvió a revisar después de la Fase 1, sin
violaciones.

**Conflicto con CLAUDE.md, resuelto el 2026-09-30**: el principio IV exige pruebas y `CLAUDE.md`
decía "no modifiques `test/` a menos que te lo pidan". Ahora `CLAUDE.md` permite modificar `test/`
cuando lo exige una tarea de `tasks.md`, así que se puede reemplazar el `test/widget_test.dart`
de la plantilla y crear las pruebas nuevas.

**Reglas de validación nuevas** (research R2 y R3), confirmadas el 2026-09-30 e incorporadas en
FR-009, FR-011 y FR-012 de la spec:

- Topes técnicos: monto ≤ 999 999 999.99, personas ≤ 1 000 000 y propina ≤ 999.99 %.
- Monto y propina aceptan como máximo 2 decimales.

## Project Structure

### Documentation (this feature)

```text
specs/001-dividir-cuenta/
├── plan.md              # Este archivo
├── research.md          # Fase 0
├── data-model.md        # Fase 1
├── quickstart.md        # Fase 1
├── contracts/
│   ├── dominio.md       # Fase 1: domain + data
│   └── pantalla.md      # Fase 1: presentation + main.dart
├── checklists/
│   └── requirements.md
└── tasks.md             # Fase 2 (/speckit-tasks, todavía no creado)
```

### Source Code (repository root)

```text
lib/
├── main.dart                         # único punto de composición
├── domain/                           # Dart puro
│   ├── cuenta.dart                   # Cuenta
│   ├── resultado.dart                # Resultado
│   ├── error_entrada.dart            # enum ErrorEntrada (mensajes de la spec)
│   ├── resultado_validacion.dart     # ResultadoValidacion
│   ├── estrategia_redondeo.dart      # interfaz EstrategiaRedondeo (1 método)
│   ├── validar_entrada.dart          # ValidarEntrada
│   └── calcular_division.dart        # CalcularDivision
├── data/
│   ├── redondeo_exacto.dart          # RedondeoExacto implements EstrategiaRedondeo
│   └── redondeo_hacia_arriba.dart    # RedondeoHaciaArriba implements EstrategiaRedondeo
└── presentation/
    ├── formateador_moneda.dart       # FormateadorMoneda
    ├── divisor_controller.dart       # DivisorController
    └── pantalla_divisor.dart         # PantallaDivisor (StatefulWidget)

test/
├── domain/
│   ├── validar_entrada_test.dart
│   └── calcular_division_test.dart   # usa una estrategia falsa definida en la prueba (LSP/DIP)
├── data/
│   ├── redondeo_exacto_test.dart
│   └── redondeo_hacia_arriba_test.dart
├── presentation/
│   ├── formateador_moneda_test.dart
│   └── divisor_controller_test.dart
└── aceptacion_test.dart              # los 6 escenarios de la spec + FR-014 (pruebas de widget)
```

`test/widget_test.dart` (el contador de la plantilla) se elimina, con permiso del usuario.

**Structure Decision**: un solo proyecto Flutter con las tres capas pedidas en `lib/`, y `test/`
con la misma estructura. Además de las clases que nombró el usuario, se agregan `ErrorEntrada` y
`ResultadoValidacion` para que `ValidarEntrada` devuelva sus errores sin mezclarlos con el
`Resultado` del cálculo (SRP). Colocar las estrategias en `data/` sigue la regla "domain define la
interfaz, data la implementa", aunque no sean fuentes de datos. No se tocan `android/`, `ios/` ni
`pubspec.yaml`.

## Complexity Tracking

No hay violaciones de la constitución que justificar.
