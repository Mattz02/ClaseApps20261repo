# Contrato: presentation (pantalla y controller)

## `FormateadorMoneda` — `lib/presentation/formateador_moneda.dart`

```dart
class FormateadorMoneda {
  String formatear(int centavos);
}
```

- Devuelve el monto con exactamente 2 decimales, punto decimal y sin símbolo de moneda
  (FR-007): `2750 → "27.50"`, `400 → "4.00"`, `5 → "0.05"`.

## `DivisorController` — `lib/presentation/divisor_controller.dart`

Clase Dart simple, sin `ChangeNotifier`. Recibe todas sus dependencias por constructor y no
instancia ninguna clase concreta.

```dart
class DivisorController {
  DivisorController({
    required ValidarEntrada validador,
    required CalcularDivision calculadora,
    required Map<String, EstrategiaRedondeo> estrategias, // no vacío; el primero es el inicial
    required FormateadorMoneda formateador,
  });

  List<String> get modos;             // claves del mapa, en orden
  String get modoSeleccionado;
  String? get montoPorPersona;        // por ejemplo "27.50"; null si no hay resultado
  String? get errorMonto;             // mensaje de ErrorEntrada o null
  String? get errorPersonas;
  String? get errorPropina;

  void seleccionarModo(String modo);  // cambia el modo y llama a descartarResultado()
  void calcular({required String monto, required String personas, required String propina});
  void descartarResultado();          // borra resultado y errores (FR-014)
}
```

- `calcular`: valida. Si hay errores, los guarda y deja `montoPorPersona` en null (FR-013). Si
  no hay errores, calcula con la estrategia del modo elegido, formatea el resultado y borra los
  errores anteriores.
- `seleccionarModo` con un modo que no está en `modos`: lanza `ArgumentError` (error de
  programación, no del usuario).

## `PantallaDivisor` — `lib/presentation/pantalla_divisor.dart`

`StatefulWidget` que recibe el `DivisorController` por constructor. Cada acción del usuario llama
al controller dentro de `setState`.

| Elemento | Key (para las pruebas) | Texto o etiqueta | Comportamiento |
|---|---|---|---|
| Campo monto | `campo_monto` | "Monto total" | teclado numérico decimal; `errorText` = `errorMonto` |
| Campo personas | `campo_personas` | "Número de personas" | teclado numérico; `errorText` = `errorPersonas` |
| Campo propina | `campo_propina` | "Propina (%)" | teclado numérico decimal; `errorText` = `errorPropina` |
| Selector de modo | `selector_modo` | una opción por cada elemento de `modos` | `SegmentedButton`; al cambiar llama a `seleccionarModo` |
| Botón | `boton_calcular` | "Calcular" | llama a `calcular` con el texto de los 3 campos |
| Resultado | `texto_resultado` | "Cada persona paga" + monto (por ejemplo "27.50") | solo visible si `montoPorPersona != null` |

- Cambiar el texto de cualquier campo (`onChanged`) llama a `descartarResultado` (FR-014).
- No hay red, almacenamiento ni navegación (FR-001, FR-015).

## `main.dart` — único punto de composición

```dart
Widget construirApp();          // arma todas las dependencias y devuelve el MaterialApp
void main() => runApp(construirApp());
```

Las pruebas de aceptación usan `construirApp()` para probar la misma composición que la app.

Es el único lugar que crea objetos concretos: `ValidarEntrada`, `CalcularDivision`,
`FormateadorMoneda`, `RedondeoExacto`, `RedondeoHaciaArriba` y `DivisorController`. Arma el mapa
`{'Exacto': ..., 'Hacia arriba': ...}` y le pasa el controller a `PantallaDivisor`.
