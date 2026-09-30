# Feature Specification: Dividir la cuenta del restaurante

**Feature Branch**: `sdd` (no se creó una rama específica para esta feature)

**Created**: 2026-09-30

**Status**: Draft

**Input**: User description: "Una app de una sola pantalla para dividir la cuenta de un
restaurante entre varias personas. El usuario ingresa el monto total, el número de personas y
el porcentaje de propina, y al tocar \"Calcular\" ve cuánto paga cada persona con dos
decimales. Hay dos modos de redondeo que el usuario elige: exacto, o hacia arriba al entero más
cercano. La app funciona sin conexión: no hay red ni base de datos. Escenarios de aceptación:
1. 100.00, 4 personas, 10% de propina, modo exacto -> 27.50 por persona; 2. 90.00, 3 personas,
0% de propina, modo exacto -> 30.00 por persona; 3. 50.00 y 0 personas -> mensaje \"Debe haber
al menos una persona\", y NO se muestra resultado; 4. el monto dice \"abc\" -> mensaje \"Monto
inválido\"; 5. 10.00, 3 personas, 0%, modo exacto -> 3.33 por persona; 6. 10.00, 3 personas,
0%, modo hacia arriba -> 4.00 por persona"

## Clarifications

### Session 2026-09-30

- Q: ¿Qué pasa si el campo de personas está vacío, tiene decimales o no es un número? → A: Se
  muestra "Número de personas inválido", un mensaje distinto al de 0 personas.
- Q: ¿Un monto total de 0 se acepta como válido? → A: No; se muestra "Monto inválido" y no
  hay resultado.
- Q: ¿Qué pasa si el campo de propina queda vacío al tocar "Calcular"? → A: Cuenta como 0 %
  y se calcula sin propina.
- Q: ¿Qué pasa con el resultado mostrado si el usuario cambia un dato o el modo sin volver a
  tocar "Calcular"? → A: Se oculta hasta el siguiente toque en "Calcular".

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Calcular cuánto paga cada persona (Priority: P1)

Al terminar de comer, una persona del grupo abre la app, escribe el monto total de la cuenta,
cuántas personas van a pagar y el porcentaje de propina, deja el modo "Exacto" y toca
"Calcular". La app le muestra cuánto paga cada persona, con dos decimales, para que el grupo
pueda pagar sin hacer cuentas a mano.

**Why this priority**: Es el propósito de la app. Sin este cálculo no hay nada que entregar; con
él solo, la app ya es útil.

**Independent Test**: Ingresar monto, personas y propina válidos en modo exacto, tocar
"Calcular" y comparar el monto por persona mostrado con el esperado.

**Acceptance Scenarios**:

1. **Given** monto 100.00, 4 personas, propina 10 % y modo exacto, **When** el usuario toca
   "Calcular", **Then** la app muestra 27.50 por persona.
2. **Given** monto 90.00, 3 personas, propina 0 % y modo exacto, **When** el usuario toca
   "Calcular", **Then** la app muestra 30.00 por persona.
3. **Given** monto 10.00, 3 personas, propina 0 % y modo exacto, **When** el usuario toca
   "Calcular", **Then** la app muestra 3.33 por persona.

---

### User Story 2 - Avisar cuando los datos no son válidos (Priority: P2)

Si el usuario escribe algo que no se puede usar para calcular (un monto que no es un número o
cero personas), la app le dice qué está mal con un mensaje claro y no muestra ningún resultado,
para que nadie pague un monto calculado con datos erróneos.

**Why this priority**: Evita resultados engañosos. Depende de que exista el cálculo (P1), pero
es lo siguiente más importante para que la app sea confiable.

**Independent Test**: Ingresar datos inválidos, tocar "Calcular" y comprobar que aparece el
mensaje esperado y que no se muestra ningún monto por persona.

**Acceptance Scenarios**:

1. **Given** monto 50.00 y 0 personas, **When** el usuario toca "Calcular", **Then** la app
   muestra el mensaje "Debe haber al menos una persona" y NO muestra resultado.
2. **Given** el monto dice "abc", **When** el usuario toca "Calcular", **Then** la app muestra
   el mensaje "Monto inválido" y NO muestra resultado.

---

### User Story 3 - Redondear hacia arriba (Priority: P3)

Para no andar con monedas, el grupo prefiere que cada persona pague un número entero. El usuario
elige el modo "Hacia arriba" y, al tocar "Calcular", la app muestra el monto por persona
redondeado hacia arriba al entero más cercano, todavía con dos decimales.

**Why this priority**: Es una comodidad sobre el cálculo básico; la app ya es útil sin ella.

**Independent Test**: Con los mismos datos, calcular en modo exacto y luego en modo hacia arriba,
y comprobar que el segundo resultado es el entero inmediatamente superior (o el mismo valor si ya
era entero).

**Acceptance Scenarios**:

1. **Given** monto 10.00, 3 personas, propina 0 % y modo hacia arriba, **When** el usuario toca
   "Calcular", **Then** la app muestra 4.00 por persona.
2. **Given** monto 90.00, 3 personas, propina 0 % y modo hacia arriba, **When** el usuario toca
   "Calcular", **Then** la app muestra 30.00 por persona (un monto que ya es entero no cambia).

---

### Edge Cases

- **Monto vacío, negativo o cero**: se muestra "Monto inválido" y no hay resultado.
- **Monto con coma decimal** (por ejemplo "12,50"): se acepta igual que "12.50".
- **Número de personas negativo**: se muestra "Debe haber al menos una persona".
- **Número de personas vacío, con decimales o no numérico** (por ejemplo "2.5" o "dos"): se
  muestra "Número de personas inválido".
- **Propina vacía**: se toma como 0 %.
- **Propina negativa o no numérica**: se muestra "Propina inválida".
- **Varios campos inválidos a la vez**: se muestra el mensaje de cada campo inválido y no hay
  resultado.
- **El usuario cambia un dato o el modo después de calcular**: el resultado anterior deja de
  mostrarse hasta que vuelva a tocar "Calcular", para no mostrar un monto que ya no corresponde
  a los datos.
- **Monto exacto con más de dos decimales** (por ejemplo 3.335): en modo exacto se redondea al
  centavo más cercano, y las mitades suben (3.335 → 3.34).
- **La suma de lo que paga cada persona no coincide con el total** (por ejemplo 3 × 3.33 = 9.99
  para una cuenta de 10.00): es el comportamiento esperado; la app muestra un único monto por
  persona y no reparte los centavos sobrantes.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: La app MUST tener una sola pantalla con tres campos de entrada: monto total,
  número de personas y porcentaje de propina.
- **FR-002**: El usuario MUST poder elegir entre dos modos de redondeo: "Exacto" y "Hacia
  arriba". El modo inicial es "Exacto".
- **FR-003**: La app MUST calcular el resultado solo cuando el usuario toca el botón
  "Calcular".
- **FR-004**: La app MUST calcular el monto por persona como: monto total más la propina
  (monto × porcentaje / 100), dividido entre el número de personas.
- **FR-005**: En modo exacto, la app MUST mostrar el monto por persona redondeado al centavo
  más cercano (las mitades suben).
- **FR-006**: En modo hacia arriba, la app MUST mostrar el monto por persona redondeado hacia
  arriba al entero más cercano; si el monto ya es entero, no cambia.
- **FR-007**: La app MUST mostrar el monto por persona siempre con exactamente dos decimales y
  punto como separador decimal (por ejemplo 27.50 o 4.00).
- **FR-008**: La app MUST aceptar el monto y la propina con punto o coma como separador
  decimal.
- **FR-009**: Si el monto está vacío, no es numérico o no es mayor que cero, la app MUST
  mostrar "Monto inválido".
- **FR-010**: Si el número de personas es un entero menor que 1, la app MUST mostrar "Debe
  haber al menos una persona".
- **FR-011**: Si el número de personas está vacío, no es numérico o no es un entero, la app
  MUST mostrar "Número de personas inválido".
- **FR-012**: Si la propina está vacía, la app MUST tomarla como 0 %; si es negativa o no
  numérica, MUST mostrar "Propina inválida".
- **FR-013**: Cuando hay al menos un dato inválido, la app MUST mostrar el mensaje de cada campo
  inválido y MUST NOT mostrar ningún resultado.
- **FR-014**: Si el usuario modifica cualquier dato o el modo de redondeo después de calcular, la
  app MUST ocultar el resultado anterior hasta el siguiente toque en "Calcular".
- **FR-015**: La app MUST funcionar completamente sin conexión: no usa red ni guarda datos entre
  sesiones.

### Key Entities *(include if feature involves data)*

- **Cuenta**: los datos que ingresa el usuario: monto total, número de personas, porcentaje de
  propina y modo de redondeo.
- **Modo de redondeo**: cómo se ajusta el monto por persona: "Exacto" (al centavo) o "Hacia
  arriba" (al entero superior).
- **Resultado**: el monto que paga cada persona, o, si los datos no son válidos, la lista de
  mensajes de error.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Los 6 escenarios de aceptación de la descripción dan exactamente el monto o el
  mensaje esperado (6 de 6).
- **SC-002**: Un usuario que abre la app por primera vez obtiene el monto por persona en menos
  de 30 segundos.
- **SC-003**: El resultado aparece en menos de 1 segundo después de tocar "Calcular".
- **SC-004**: La app funciona igual con el dispositivo en modo avión: 100 % de los cálculos se
  completan sin conexión.
- **SC-005**: Ninguna entrada inválida produce un monto por persona en pantalla (0 casos).

## Assumptions

- La app no maneja una moneda específica: el monto se muestra sin símbolo de moneda.
- Todas las personas pagan la misma parte; dividir por consumo individual queda fuera del
  alcance.
- La propina se calcula sobre el monto total ingresado y no tiene un límite superior.
- La propina puede tener decimales (por ejemplo 12.5 %).
- El número de personas no tiene un límite superior.
- Los datos no se guardan: al cerrar la app se pierden.
- La interfaz está en español.
