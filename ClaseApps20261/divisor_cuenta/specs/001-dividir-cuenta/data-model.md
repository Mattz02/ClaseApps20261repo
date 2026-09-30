# Data Model: Dividir la cuenta del restaurante

Todo vive en memoria; no hay persistencia (FR-015). Los montos son enteros (ver research R1).

## Cuenta (domain)

Los datos de entrada ya validados. Solo `ValidarEntrada` la construye a partir del texto del
usuario.

| Campo | Tipo | Regla |
|---|---|---|
| `montoCentavos` | `int` | 1 ≤ valor ≤ 99 999 999 999 (es decir, 0.01 a 999 999 999.99) |
| `personas` | `int` | 1 ≤ valor ≤ 1 000 000 |
| `propinaCentesimas` | `int` | 0 ≤ valor ≤ 99 999 (0 % a 999.99 %; 10 % = 1000) |

El modo de redondeo no es un campo de `Cuenta`: se representa con la `EstrategiaRedondeo` que se
le pasa a `CalcularDivision` (ver research R4 y R5).

## ErrorEntrada (domain, `enum`)

| Valor | Mensaje | Campo | Cuándo |
|---|---|---|---|
| `montoInvalido` | "Monto inválido" | monto | vacío; no cumple `^\d+([.,]\d{1,2})?$`; igual a 0; mayor que 999 999 999.99 |
| `personasMenorQueUno` | "Debe haber al menos una persona" | personas | entero ≤ 0 (incluye negativos) |
| `personasInvalido` | "Número de personas inválido" | personas | vacío; no es entero; mayor que 1 000 000 |
| `propinaInvalida` | "Propina inválida" | propina | no cumple `^\d+([.,]\d{1,2})?$` (incluye negativos); mayor que 999.99 |

Una propina vacía no es un error: vale 0 (FR-012). Cada campo produce como máximo un error, y los
tres campos se validan siempre, para mostrar todos los errores a la vez (FR-013).

## ResultadoValidacion (domain)

Lo que devuelve `ValidarEntrada`.

| Campo | Tipo | Regla |
|---|---|---|
| `cuenta` | `Cuenta?` | no nulo si y solo si `errores` está vacío |
| `errores` | `List<ErrorEntrada>` | en orden: monto, personas, propina |
| `esValida` | `bool` (getter) | `errores.isEmpty` |

## Resultado (domain)

Lo que devuelve `CalcularDivision`.

| Campo | Tipo | Regla |
|---|---|---|
| `montoPorPersonaCentavos` | `int` | ≥ 0; ya redondeado según la estrategia elegida |

## EstrategiaRedondeo (domain, interfaz) y sus implementaciones (data)

- `EstrategiaRedondeo`: un solo método que convierte la fracción exacta
  `numerador / denominador` (en centavos) en centavos enteros.
- `RedondeoExacto`: al centavo más cercano; las mitades suben.
- `RedondeoHaciaArriba`: al entero superior (múltiplo de 100 centavos); si ya es entero, no
  cambia.

Contrato completo: [contracts/dominio.md](contracts/dominio.md).

## Estado de la pantalla (presentation, dentro de `DivisorController`)

| Estado | Contenido | Pasa a |
|---|---|---|
| Sin calcular (inicial) | sin resultado, sin errores, modo = primero del mapa | Con resultado o Con errores, al tocar "Calcular" |
| Con resultado | `montoPorPersona` = texto, por ejemplo "27.50" | Sin calcular, al cambiar un dato o el modo (FR-014) |
| Con errores | un mensaje por cada campo inválido; sin resultado | Sin calcular, al cambiar un dato o el modo |

Tocar "Calcular" desde cualquier estado vuelve a validar y calcular con los datos actuales.

## Ejemplos (de los escenarios de aceptación)

| Entrada (monto, personas, propina, modo) | numerador / denominador | Centavos | Pantalla |
|---|---|---|---|
| 100.00, 4, 10, Exacto | 110 000 000 / 40 000 | 2750 | 27.50 |
| 90.00, 3, 0, Exacto | 90 000 000 / 30 000 | 3000 | 30.00 |
| 10.00, 3, 0, Exacto | 10 000 000 / 30 000 | 333 | 3.33 |
| 10.00, 3, 0, Hacia arriba | 10 000 000 / 30 000 | 400 | 4.00 |
| 90.00, 3, 0, Hacia arriba | 90 000 000 / 30 000 | 3000 | 30.00 |
| 50.00, 0, —, — | — | — | "Debe haber al menos una persona" |
| "abc", —, —, — | — | — | "Monto inválido" |
