# Modelo de datos

Registros JavaScript con contratos JSDoc. Sin persistencia ni serialización JSON de BigInt.

## EntradaFormulario

| Campo | Tipo | Inicial |
|-------|------|---------|
| monto | string | vacío |
| personas | string | vacío |
| propina | string | vacío, equivale a cero al calcular |
| modo | string | exacto |

Conservar texto hasta validarlo. Modos publicados: exacto y arriba. Catálogo de main:
entradas con id, etiqueta y estrategia; no forma parte de Cuenta ni se guarda entre sesiones.

## Cuenta (cuenta.js)

| Campo | Tipo/unidad | Restricción |
|-------|-------------|-------------|
| montoCentavos | bigint, centavos | 1..99999999999 |
| personas | bigint, personas | 1..1000000 |
| propinaCentesimas | bigint, centésimas de porcentaje | 0..99999 |
| modo | string, id del catálogo | exacto o arriba en esta feature |

Se produce solo tras validar con éxito. No contiene React ni texto monetario formateado.
La estrategia se resuelve por id en el catálogo inyectado y se pasa separada al cálculo.
La restricción «exacto o arriba en esta feature» describe los ids iniciales publicados.
El contrato de modo sigue siendo string: validarEntrada conserva el id, sin una enumeración
cerrada ni reglas por estrategia; el hook lo resuelve genéricamente desde el catálogo recibido.
Esto permite registrar otra implementación en main sin cambiar los consumidores, según OCP 2.0.0.

## ValidacionEntrada

validarEntrada devuelve `{valida: true, cuenta}` o `{valida: false, errores}`.
Errores es un mapa por campo que solo incluye los inválidos, con mensajes exactos.
Normalizar no redondea: más de dos decimales es inválido. Reglas: [dominio](contracts/dominio.md).

## ValorDivision (estrategiaRedondeo.js)

| Campo | Tipo | Significado |
|-------|------|-------------|
| numerador | bigint >=0 | montoCentavos*(10000+propinaCentesimas) |
| denominador | bigint >0 | 10000*personas |

Fracción exacta en centavos; no convertir a Number. aplicar(valor) devuelve centavos BigInt.

## Resultado (resultado.js)

- Éxito: `{estado: 'exito', montoPorPersonaCentavos: bigint}`.
- Error: `{estado: 'error', errores: {monto?, personas?, propina?}}`, mensajes string.

Estados excluyentes: errores nunca conservan monto anterior. Un resultado exacto puede ser
cero por centavos inferiores a la mitad. No contiene formato ni reparto de sobrantes.
El cálculo produce el éxito; el hook representa los errores de validación con la forma de
error. Son registros de datos, no instancias de proveedores concretos.

## Estado de pantalla

useState mantiene `{entrada: EntradaFormulario, salida: Resultado | null}`.

| Evento | Entrada | Salida |
|--------|---------|--------|
| Montaje | campos vacíos, exacto | null |
| Editar campo o modo | actualizar valor editado | null |
| Calcular con inválidos | conservar texto | todos los errores |
| Calcular con válidos | conservar texto | éxito |
| Cerrar/abrir nueva sesión | iniciales | null |

Sin estado de carga, historial, peticiones ni efectos de sincronización. Editar borra salida
en el mismo manejador, sin esperar otro cálculo.
