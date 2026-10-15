# Contratos de dominio y proveedores

## Responsabilidades y firmas

| Módulo | Contrato |
|--------|----------|
| domain/cuenta.js | Forma JSDoc de Cuenta válida y unidades |
| domain/resultado.js | Formas excluyentes de éxito/error |
| domain/validarEntrada.js | validarEntrada(entrada) -> ValidacionEntrada |
| domain/calcularDivision.js | calcularDivision(cuenta, estrategia) -> Resultado de éxito |
| domain/estrategiaRedondeo.js | Contrato mínimo aplicar(valor) -> bigint centavos |
| data/redondeoExacto.js | crearRedondeoExacto() -> estrategia sin estado |
| data/redondeoHaciaArriba.js | crearRedondeoHaciaArriba() -> estrategia sin estado |
| presentation/formateadorMoneda.js | formateadorMoneda(centavos) -> string fijo |

Son contratos de diseño, no implementación. Cada función debe poder explicarse por propósito,
entradas, salida y errores. El cálculo no valida ni formatea; los modelos solo definen datos.

## Validación

Validar todos los campos; no lanzar excepciones por datos del usuario ni producir Cuenta
cuando haya errores. La selección de modo proviene siempre del catálogo controlado.

| Condición | Mensaje/normalización | Requisito |
|-----------|----------------------|-----------|
| Monto vacío, no decimal, <=0, >999999999.99 o >2 decimales | Monto inválido | FR-009 |
| Personas con sintaxis entera y valor <1 | Debe haber al menos una persona | FR-010 |
| Personas vacío, sintaxis no entera o >1000000 | Número de personas inválido | FR-011 |
| Propina vacía | 0n | FR-012 |
| Propina no decimal, <0, >999.99 o >2 decimales | Propina inválida | FR-012 |
| Coma/punto en monto o propina | Aceptar y convertir a entero escalado sin Number | FR-008 |
| Varios inválidos | Un mensaje por campo; sin cuenta ni cálculo | FR-013 |

Recortar espacios exteriores; admitir signo opcional, ceros iniciales y decimales ordinarios
como .5 y 12. Rechazar exponentes, hexadecimal, miles o separadores mezclados.
Personas exige sintaxis entera: 2.0 y 2,0 son inválidos. Los textos se validan por completo;
no usar parseFloat ni redondear entradas para hacerlas válidas.

## Cálculo y redondeo

Precondiciones: Cuenta válida y estrategia compatible. Todo valor aritmético es BigInt.

1. N = montoCentavos * (10000n + propinaCentesimas).
2. D = 10000n * personas.
3. Llamar una sola vez a estrategia.aplicar({numerador: N, denominador: D}).
4. Devolver éxito con montoPorPersonaCentavos igual al retorno de aplicar.

aplicar recibe N>=0 y D>0, devuelve centavos BigInt no negativos, no muta el argumento y no
realiza efectos externos. Cálculo y consumidores no preguntan el tipo concreto.

- Exacto: q=N/D, r=N%D; devolver q+1n si 2n*r>=D, o q en otro caso.
- Hacia arriba: techo de N/(100n*D), multiplicado por 100n; si es entero no cambia.
  No redondear a centavos antes de obtener el techo.
- Formato: dividir centavos finales entre 100n, completar el resto a dos cifras y unir con punto.
  Sin Number, símbolo ni separadores de miles.

Una dependencia ausente o denominador inválido es una violación del contrato de programación,
no una entrada admisible ni un mensaje de campo. No ocultarla convirtiéndola en un monto.

## Inyección y extensión

Solo main llama las fábricas de data y forma el catálogo `{id, etiqueta, estrategia}` con
exacto/Exacto y arriba/Hacia arriba. Entrega catálogo, validarEntrada y calcularDivision a
PantallaDivisor y al hook. El formateador es una función pura de presentación.

El hook busca estrategia por id, sin instanceof ni switches por modo. Añadir una regla
requiere su proveedor y registro en `src/main.jsx`, permitido por la constitución 2.0.0,
sin editar cálculo, validación, hook ni pantalla. validarEntrada conserva el id procedente
del catálogo, sin enumerar los modos admitidos ni conocer implementaciones concretas.
Las instancias de tests son fixtures; la composición de producción sigue estando solo en main.

La comprobación OCP inyecta un catálogo con un tercer id/proveedor y verifica que usa aplicar
sin cambios en esos cuatro consumidores. Los modos de la entrega siguen siendo Exacto y Hacia arriba.

## Operación sin conexión

Después de cargar los recursos de la aplicación, la validación y el cálculo con cualquiera
de las estrategias se ejecutan sin red. Estos módulos no realizan peticiones ni persisten
datos del formulario. El contrato de la aplicación no garantiza primera apertura remota
ni recarga sin conexión; el procedimiento se define en [quickstart](../quickstart.md).

## Pruebas de contrato y precisión

Suite compartida para ambos proveedores: retorno BigInt no negativo, no mutación, cero y
valor de una unidad. Añadir expectativas propias de cada modo. Probar con estrategia ficticia
que el cálculo entrega la fracción correcta y utiliza su retorno sin preguntar el tipo.

| Monto | Personas | Propina % | Exacto | Hacia arriba |
|-------|----------|-----------|--------|--------------|
| 100.00 | 4 | 10 | 27.50 | 28.00 |
| 90.00 | 3 | 0 | 30.00 | 30.00 |
| 10.00 | 3 | 0 | 3.33 | 4.00 |
| 6.67 | 2 | 0 | 3.34 | 4.00 |
| 1.00 | 1 | 0.01 | 1.00 | 2.00 |
| 0.01 | 1000000 | 0 | 0.00 | 1.00 |
| 999999999.99 | 1 | 999.99 | 10999899999.89 | 10999900000.00 |

Últimas cuatro filas: mitad ascendente, ausencia de redondeo previo, valor diminuto y máximos.
