# Implementation Plan: Dividir la cuenta del restaurante

**Branch**: `sdd` | **Date**: 2026-10-14 | **Spec**: [spec.md](spec.md)

**Input**: `specs/001-divisor-cuenta/spec.md`, leída sin modificaciones.
El identificador devuelto por setup es `001-divisor-cuenta`; la rama Git real es `sdd`.

## Summary

Una pantalla React para dividir monto y propina entre personas. Validar todos los campos
al enviar «Calcular», aplicar el redondeo elegido y mostrar dos decimales sin símbolo.
Editar cualquier campo o modo oculta inmediatamente el resultado y los errores anteriores.

JavaScript con Vite, estado local con useState, tres capas e inyección de dependencias.
La aritmética usa BigInt y fracciones en centavos para preservar las mitades y los máximos.
Las estrategias comparten el contrato aplicar(valor). Decisiones: [research.md](research.md).

## Technical Context

**Language/Version**: JavaScript ESM, JSX y BigInt; herramientas con Node 24 LTS >=24.15.0.

**Primary Dependencies**: conservar React/ReactDOM ^19.2.8, Vite ^8.3.0 y plugin React existentes.
Sin bibliotecas de estado externas ni nuevas dependencias de producción.

**Storage**: ninguno; sin backend, base de datos, peticiones ni persistencia del formulario.

**Testing**: Vitest 5 y jsdom 30 como devDependencies, resueltas en lockfile al implementar.
Unitarias en Node; hook y pantalla en jsdom con act de React y createRoot.

**Target Platform**: navegador moderno con BigInt; recursos locales o ya cargados.

**Project Type**: aplicación web estática de una sola pantalla.

**Performance Goals**: resultado visible <1 s; primer uso <30 s (SC-002 y SC-003).

**Constraints**: mensajes en español; punto y dos decimales sin símbolo; coma en entradas;
límites FR-009/011/012; cálculo solo al enviar; sin datos entre sesiones. Después de cargar
los recursos, cálculos, validaciones y cambios de modo funcionan sin red, sin peticiones de
la aplicación ni persistencia del formulario. No se garantiza la primera apertura remota
ni la recarga sin conexión. Sin incorporar PWA ni caché persistente.

**Scale/Scope**: tres campos, dos modos y un monto por persona; sin reparto de sobrantes.

## Constitution Check

Evaluación previa a investigación y posterior al diseño contra la constitución v2.0.0:

| Principio | Evidencia del diseño y verificación prevista | Previo | Posterior |
|-----------|---------------------------------------------|--------|-----------|
| SRP | Validación, cálculo, redondeo y formato separados | PASS | PASS |
| OCP | Añadir proveedor y registrarlo en main; sin editar cálculo, validación, hook ni pantalla | PASS | PASS |
| LSP / ISP | Solo aplicar, mismas unidades/precondiciones; suite compartida | PASS | PASS |
| DIP / capas | presentation -> domain <- data; presentación no importa data | PASS | PASS |
| Dominio puro | Sin React, DOM, efectos ni formato en domain | PASS | PASS |
| Composición | Solo main crea proveedores y conecta dependencias | PASS | PASS |
| Seguridad | Sin secretos ni API keys; no se necesita ningún servicio | PASS | PASS |
| Pruebas | Matriz de FR/aceptación en contratos y quickstart; Vitest | PASS | PASS |
| Regla de la materia | Explicar propósito, entradas, salida y errores de cada función | PASS | PASS |

Estos PASS corresponden al diseño, no a código implementado ni a pruebas ejecutadas.
Sin excepciones constitucionales ni decisiones pendientes para elaborar tareas.

La constitución 2.0.0 permite explícitamente el registro de nuevas implementaciones en
`src/main.jsx`. El catálogo admite nuevos ids sin enumeraciones cerradas en el validador;
los dos modos de esta feature son sus entradas iniciales. La revisión de extensión comprueba
el uso de un nuevo id/estrategia inyectado sin modificar los cuatro consumidores protegidos.
El alcance offline anterior queda definido por instrucción explícita del usuario para
FR-015/SC-004; se refleja en investigación, contratos y quickstart, conservando spec.md intacta.

## Project Structure

### Documentation (this feature)

```text
specs/001-divisor-cuenta/
├── spec.md                  # Entrada intacta
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
    ├── dominio.md
    └── pantalla.md
```

`tasks.md` corresponde al siguiente comando, $speckit-tasks.

### Source Code (repository root)

Estructura prevista para implementación; esta fase no crea código:

```text
src/
├── domain/
│   ├── cuenta.js
│   ├── resultado.js
│   ├── calcularDivision.js
│   ├── validarEntrada.js
│   └── estrategiaRedondeo.js
├── data/
│   ├── redondeoExacto.js
│   └── redondeoHaciaArriba.js
├── presentation/
│   ├── useDivisor.js
│   ├── formateadorMoneda.js
│   └── PantallaDivisor.jsx
├── main.jsx
└── index.css
tests/
├── unit/
│   ├── validarEntrada.test.js
│   ├── calcularDivision.test.js
│   ├── redondeo.test.js
│   └── formateadorMoneda.test.js
├── contract/
│   └── estrategiaRedondeo.test.js
└── integration/
    ├── useDivisor.test.jsx
    └── PantallaDivisor.test.jsx
vite.config.js
package.json
package-lock.json
```

**Structure Decision**: cuenta.js y resultado.js definen datos y contratos JSDoc.
validarEntrada valida/normaliza texto; calcularDivision recibe Cuenta válida y estrategia.
estrategiaRedondeo documenta la única operación aplicar. Main crea una vez ambos proveedores
y el catálogo de opciones, e inyecta validación/cálculo/catálogo en pantalla y hook.
El formateador puro pertenece a presentación. El hook no importa data ni crea proveedores.
La pantalla genera los modos desde el catálogo, sin switches por tipo concreto.
Los modelos son registros de datos, no instancias de servicios.

Flujo: texto -> validarEntrada -> Cuenta -> calcularDivision(cuenta, estrategia)
-> Resultado -> formateadorMoneda -> pantalla. Un error impide llamar al cálculo.
Firmas/unidades: [contrato de dominio](contracts/dominio.md).

Al implementar: reemplazar el montaje del ejemplo Vite por PantallaDivisor y retirar recursos
de demostración sin uso; mantener ESM, plugin React y lint. Añadir Vitest/jsdom y scripts
`test` (vitest run) y `test:watch` (vitest). Cada función debe ser explicable por el estudiante.

## Complexity Tracking

Sin violaciones que justificar. BigInt evita pérdida de precisión dentro de los límites;
cociente y resto bastan, sin biblioteca decimal, contenedor de inyección ni store global.
