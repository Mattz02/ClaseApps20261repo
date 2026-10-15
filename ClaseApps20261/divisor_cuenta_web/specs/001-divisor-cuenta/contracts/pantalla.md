# Contrato de pantalla y hook

## Interfaz pública y eventos

Una pantalla en español: Monto total, Número de personas, Porcentaje de propina, modos Exacto
y Hacia arriba (inicial Exacto), botón Calcular. Campos controlados de texto con inputMode
apropiado y formulario noValidate; etiquetas y errores asociados a cada campo.
Resultado «por persona» sin símbolo, con punto y exactamente dos decimales.

PantallaDivisor({dependencias}) llama useDivisor(dependencias). El hook recibe
`{validarEntrada, calcularDivision, opcionesRedondeo}` sin importar data ni crear proveedores.
Devuelve entradas, opciones id/etiqueta, salida y manejadores de edición, cambio de modo y cálculo.
La pantalla aplica el formateador puro únicamente al éxito.

- Editar no calcula ni muestra errores nuevos; borra cualquier salida previa inmediatamente.
- Calcular evita recarga/navegación, valida los tres campos y solo si son válidos calcula.
- Un error elimina todo monto anterior y muestra los mensajes de todos los campos inválidos.
- Se conservan entradas al mostrar errores o resultados. El modo procede del catálogo.
- Sin red, almacenamiento, historial ni restauración de entradas entre sesiones.

## Alcance sin conexión (FR-015 / SC-004)

Después de cargar los recursos, cálculos, validaciones y cambios de modo funcionan sin red.
La aplicación no realiza peticiones ni persiste datos del formulario. No se garantiza
primera apertura remota ni recarga sin conexión, conforme al alcance confirmado por el usuario.

Con la pantalla cargada, activar Offline sin recargar y ejecutar A1–A7. Los errores, resultados
y la ocultación de salida al editar o cambiar modo deben ser iguales a los del recorrido conectado.
Cambiar de modo sigue sin calcular: se usa el modo elegido en el siguiente submit.

## Matriz ejecutable de aceptación (Vitest/jsdom)

Cada fila completa y envía el formulario real, y comprueba DOM y ausencia/presencia de salida.

| ID | Monto / personas / propina / modo | Esperado | Origen |
|----|---------------------------------|----------|--------|
| A1 | 100.00 / 4 / 10 / exacto | 27.50 por persona | US1.1, SC-001 |
| A2 | 90.00 / 3 / 0 / exacto | 30.00 por persona | US1.2, SC-001 |
| A3 | 50.00 / 0 / 0 / exacto | Debe haber al menos una persona; sin resultado | US2.1, SC-001 |
| A4 | abc / 3 / 0 / exacto | Monto inválido; sin resultado | US2.2, SC-001 |
| A5 | 10.00 / 3 / 0 / exacto | 3.33 por persona | US1.3, SC-001 |
| A6 | 10.00 / 3 / 0 / arriba | 4.00 por persona | US3.1, SC-001 |
| A7 | 90.00 / 3 / 0 / arriba | 30.00 por persona | US3.2 |

## Cobertura de requisitos y bordes

| Requisitos | Verificación prevista |
|------------|-----------------------|
| FR-001/002/003 | Tres campos; modo inicial; escribir no llama al cálculo, enviar sí |
| FR-004/005/006/007 | A1/A2/A5/A6/A7 y tabla de precisión de dominio; formato fijo |
| FR-008 | 12,50 / 2 / 10,5 % da 6.91; lo mismo con punto |
| FR-009 | Vacío/abc/0/negativo/>2 decimales; máximo aceptado y máximo+0.01 rechazado |
| FR-010/011 | 0/negativos vs vacío/dos/2.5/2,5/2.0; 1000000 aceptado, 1000001 rechazado |
| FR-012 | Vacía equivale a 0; negativa/abc/>2 decimales; 999.99 aceptado, 1000 rechazado |
| FR-013, SC-005 | Múltiples errores; jamás monto visible con inválidos, incluso tras éxito |
| FR-014 | Cada campo/modo borra éxito y errores; no recalcula antes del siguiente submit |
| FR-015 | Tras cargar recursos, cálculos/validaciones/modos sin peticiones ni persistencia |

Parametrizar entradas inválidas en unitarias y comprobar mensajes/ausencia de resultado en
integración. Agregar cálculo con 3.335 -> 3.34 y caso sin reparto: 10/3 sigue mostrando 3.33.

## Entornos y mediciones

Domain/data/formateador usan entorno Node. Hook/UI usan jsdom, createRoot y act de React;
habilitar IS_REACT_ACT_ENVIRONMENT, desmontar y limpiar tras cada test. Los eventos deben
activar el onChange controlado real; asignar value sin evento no demuestra interacción.
Probar invalidación también bajo StrictMode, como en main.

Tests de aislamiento bloquean accesos de aplicación a fetch, XHR y almacenamiento.
Navegador build complementa SC-002/003/004 según [quickstart](../quickstart.md).
jsdom no prueba pintura visible ni usabilidad de primer uso.
