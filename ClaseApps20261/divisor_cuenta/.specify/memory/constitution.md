<!--
Sync Impact Report
- Cambio de versión: (plantilla sin llenar) → 1.0.0
- Principios definidos (antes eran marcadores de la plantilla):
  - [PRINCIPLE_1_NAME] → I. Calidad de código (SOLID)
  - [PRINCIPLE_2_NAME] → II. Arquitectura por capas
  - [PRINCIPLE_3_NAME] → III. Seguridad
  - [PRINCIPLE_4_NAME] → IV. Calidad y pruebas
  - [PRINCIPLE_5_NAME] → V. Regla de la materia: código explicable
- Secciones agregadas: Gobernanza (procedimiento de enmienda, versionado, cumplimiento)
- Secciones eliminadas: [SECTION_2_NAME] y [SECTION_3_NAME] de la plantilla, porque no se
  pidieron principios adicionales.
- Plantillas dependientes: no se modificaron; leen este archivo en tiempo de ejecución.
  - .specify/templates/plan-template.md ✅ su "Constitution Check" se llena a partir de este archivo
  - .specify/templates/spec-template.md ✅ sin cambios necesarios
  - .specify/templates/tasks-template.md ✅ sin cambios necesarios
  - CLAUDE.md ✅ coherente (capas, regla de dependencia, domain sin Flutter)
- TODOs pendientes: ninguno
-->

# Constitución de Divisor de Cuenta

## Principios fundamentales

### I. Calidad de código (SOLID)

El código DEBE respetar los cinco principios SOLID:

- **SRP (responsabilidad única):** cada clase tiene una sola razón de cambio. El cálculo
  de la división NO valida entradas ni formatea montos.
- **OCP (abierto/cerrado):** agregar una nueva regla de redondeo NO DEBE obligar a editar
  las clases que ya existen.
- **LSP (sustitución de Liskov):** cualquier implementación de una interfaz DEBE poder
  sustituir a otra sin que quien la usa tenga que preguntar de qué tipo concreto es.
- **ISP (segregación de interfaces):** las interfaces son pequeñas; ninguna clase depende
  de métodos que no usa.
- **DIP (inversión de dependencias):** `presentation` depende de abstracciones definidas
  en `domain`, nunca de clases concretas de `data`.

### II. Arquitectura por capas

- El código de `lib/` se organiza en tres capas: `presentation`, `domain` y `data`.
- Regla de dependencia: `presentation -> domain <- data`. `domain` NO DEBE importar
  nada de `presentation` ni de `data`.
- `lib/domain/` NO DEBE importar `package:flutter`; es Dart puro.
- `main.dart` es el ÚNICO lugar donde se instancian implementaciones concretas.

### III. Seguridad

- Nunca se DEBEN guardar secretos ni API keys en el repositorio.

### IV. Calidad y pruebas

- Toda funcionalidad crítica DEBE tener pruebas.
- Los criterios de aceptación de cada spec DEBEN convertirse en pruebas ejecutables.

### V. Regla de la materia: código explicable

- El estudiante DEBE poder explicar toda función generada por el agente: qué hace, por
  qué existe, qué recibe, qué devuelve y qué errores produce.

## Gobernanza

- Esta constitución prevalece sobre cualquier otra práctica del proyecto. `CLAUDE.md` da
  las instrucciones operativas del agente y no debe contradecirla.
- **Enmiendas:** se hacen editando este archivo (por ejemplo con `/speckit-constitution`),
  registrando el cambio en el Sync Impact Report y actualizando la versión y la fecha de
  última enmienda.
- **Versionado (semántico):** MAJOR cuando se elimina o redefine un principio de forma
  incompatible; MINOR cuando se agrega un principio o sección, o se amplía de forma
  material; PATCH para aclaraciones y correcciones de redacción.
- **Cumplimiento:** cada plan de implementación (`/speckit-plan`) DEBE verificar estos
  principios en su "Constitution Check", y todo cambio se revisa contra ellos antes de
  integrarse. Cualquier excepción DEBE justificarse por escrito en el plan.

**Versión**: 1.0.0 | **Ratificada**: 2026-09-30 | **Última enmienda**: 2026-09-30
