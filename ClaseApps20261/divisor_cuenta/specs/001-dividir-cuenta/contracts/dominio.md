# Contrato: domain y data

Firmas públicas y lo que cada una promete. Todo en `lib/domain/` es Dart puro (no importa
`package:flutter`). Los campos están en [data-model.md](../data-model.md).

## `EstrategiaRedondeo` — `lib/domain/estrategia_redondeo.dart`

```dart
abstract interface class EstrategiaRedondeo {
  int redondear({required int numerador, required int denominador});
}
```

- **Recibe**: la fracción exacta `numerador / denominador`, expresada en centavos.
- **Precondiciones**: `numerador >= 0`, `denominador > 0` (las garantiza `CalcularDivision`).
- **Devuelve**: centavos enteros, `>= 0`.
- **Errores**: ninguno cuando se cumplen las precondiciones.
- **LSP**: toda implementación cumple lo anterior, sin excepciones distintas ni efectos
  secundarios. Quien la usa nunca pregunta de qué tipo concreto es.

### Implementaciones — `lib/data/`

| Clase | Archivo | Resultado |
|---|---|---|
| `RedondeoExacto` | `redondeo_exacto.dart` | centavo más cercano; las mitades suben |
| `RedondeoHaciaArriba` | `redondeo_hacia_arriba.dart` | múltiplo de 100 igual o mayor; si ya es múltiplo de 100, no cambia |

## `ValidarEntrada` — `lib/domain/validar_entrada.dart`

```dart
class ValidarEntrada {
  ResultadoValidacion validar({
    required String monto,
    required String personas,
    required String propina,
  });
}
```

- **Recibe**: el texto tal como lo escribió el usuario en cada campo.
- **Devuelve**: `ResultadoValidacion` con una `Cuenta`, o con la lista de `ErrorEntrada`
  (tabla de reglas en data-model.md).
- **Errores**: nunca lanza excepciones; todo problema de entrada es un `ErrorEntrada`.
- **No hace**: no calcula ni formatea (SRP).

## `CalcularDivision` — `lib/domain/calcular_division.dart`

```dart
class CalcularDivision {
  Resultado calcular(Cuenta cuenta, EstrategiaRedondeo estrategia);
}
```

- **Recibe**: una `Cuenta` válida y la estrategia de redondeo elegida.
- **Hace**: arma `numerador = montoCentavos × (10000 + propinaCentesimas)` y
  `denominador = 10000 × personas`, y le pide a la estrategia los centavos.
- **Devuelve**: `Resultado` con `montoPorPersonaCentavos`.
- **Errores**: ninguno con una `Cuenta` válida.
- **No hace**: no valida ni formatea (SRP), y no sabe qué estrategia concreta recibe (DIP).

## `Cuenta`, `Resultado`, `ResultadoValidacion`, `ErrorEntrada`

Clases de datos inmutables (campos `final`, constructor `const` cuando se pueda) y un `enum`.
`ErrorEntrada` expone `String get mensaje` con el texto exacto de la spec.
