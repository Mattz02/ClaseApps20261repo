# Quickstart: validar "Dividir la cuenta del restaurante"

Cómo comprobar que la feature cumple la spec una vez implementada.

## Requisitos

- Flutter estable (probado con 3.47.5 / Dart 3.13.4), sin paquetes externos.
- Un emulador o dispositivo Android, o Linux de escritorio (`flutter run -d linux`).

## Comandos

Desde `divisor_cuenta/`:

```sh
flutter pub get
flutter analyze            # debe terminar con "No issues found!"
flutter test               # unitarias + escenarios de aceptación
flutter run                # probar a mano
```

## Comprobación automática de la arquitectura

```sh
grep -rn "package:flutter" lib/domain/          # no debe imprimir nada (principio II)
grep -rn "lib/data\|/data/" lib/presentation/   # no debe imprimir nada (DIP)
grep -rln "Redondeo\(Exacto\|HaciaArriba\)()" lib/ | grep -v "^lib/data/"   # solo lib/main.dart
```

## Escenarios manuales

Se ingresan los datos en la pantalla, se elige el modo y se toca "Calcular".

| # | Monto | Personas | Propina | Modo | Resultado esperado |
|---|---|---|---|---|---|
| 1 | 100.00 | 4 | 10 | Exacto | Cada persona paga 27.50 |
| 2 | 90.00 | 3 | 0 | Exacto | Cada persona paga 30.00 |
| 3 | 50.00 | 0 | (cualquiera) | (cualquiera) | "Debe haber al menos una persona"; sin resultado |
| 4 | abc | (cualquiera) | (cualquiera) | (cualquiera) | "Monto inválido"; sin resultado |
| 5 | 10.00 | 3 | 0 | Exacto | Cada persona paga 3.33 |
| 6 | 10.00 | 3 | 0 | Hacia arriba | Cada persona paga 4.00 |

Comprobaciones adicionales (spec y clarificaciones):

- 90.00 / 3 / 0 en modo hacia arriba → 30.00 (un monto entero no sube).
- Propina vacía → se calcula como 0 %.
- Monto 0 → "Monto inválido".
- Personas "2.5" o vacío → "Número de personas inválido".
- Calcular, luego cambiar cualquier campo o el modo → el resultado desaparece hasta volver a
  tocar "Calcular".
- Con el dispositivo en modo avión, todo funciona igual (FR-015).

## Dónde viven las pruebas

Detalle de clases y firmas: [contracts/dominio.md](contracts/dominio.md) y
[contracts/pantalla.md](contracts/pantalla.md). Estructura de `test/` en [plan.md](plan.md).
