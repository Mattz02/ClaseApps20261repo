<!--
Sync Impact Report
- Cambio de versión: 1.0.0 → 2.0.0.
- Motivo del cambio MAJOR: redefinición explícita de OCP solicitada por el usuario;
  se permite registrar nuevas implementaciones en src/main.jsx.
- Principio modificado: I. Calidad de código (SOLID), únicamente el apartado OCP;
  el título y los demás principios se conservan.
- Secciones añadidas: ninguna.
- Secciones eliminadas: ninguna.
- Marcadores pendientes: ninguno.
- Seguimiento documental: actualizar las referencias a constitución v1.0.0 en plan.md
  y tasks.md mediante sus respectivos flujos; esos archivos no se modifican aquí.
Este informe es material temporal de revisión; retirarlo antes de confirmar el archivo en Git.
-->
# Constitución de divisor_cuenta_web

## Core Principles

### I. Calidad de código (SOLID)

El código DEBE respetar los cinco principios SOLID:

- **SRP:** cada función o módulo DEBE tener una sola razón de cambio.
  El cálculo NO DEBE validar ni formatear.
- **OCP:** Agregar una nueva regla de redondeo NO DEBE exigir modificar el cálculo,
  la validación, el hook ni la pantalla. Se permite registrar la nueva
  implementación en `src/main.jsx`, único punto de composición.
- **LSP:** cualquier implementación de la interfaz de redondeo DEBE poder sustituir
  a otra sin que quien la usa pregunte de qué tipo es.
- **ISP:** las interfaces DEBEN ser pequeñas; ningún consumidor DEBE depender
  de funciones que no usa.
- **DIP:** `presentation` DEBE depender de abstracciones de `domain`, nunca de
  implementaciones concretas de `data`.

Estas reglas separan responsabilidades y permiten cambiar el redondeo mediante
implementaciones sustituibles.

### II. Arquitectura por capas

- El código DEBE organizarse en `src/presentation/`, `src/domain/` y `src/data/`.
- Las dependencias DEBEN seguir la dirección `presentation -> domain <- data`.
- `src/domain/` DEBE ser JavaScript puro: NO DEBE importar React ni depender del DOM.
- `src/main.jsx` DEBE ser el ÚNICO lugar donde se instancian implementaciones concretas.

Esta separación mantiene el dominio independiente de la interfaz y concentra la composición
de las implementaciones en un solo lugar.

### III. Seguridad

El repositorio NUNCA DEBE contener secretos ni API keys.

Esta regla evita exponer credenciales a través del código y su historial.

### IV. Calidad y pruebas

- Toda funcionalidad crítica DEBE tener pruebas.
- Los criterios de aceptación de la especificación DEBEN convertirse en pruebas ejecutables.

Las pruebas permiten comprobar el comportamiento crítico y verificar la aceptación de la
funcionalidad descrita en la especificación.

### V. Regla de la materia

Toda función generada por el agente DEBE poder ser explicada por el estudiante, incluyendo:

- Qué hace.
- Por qué existe.
- Qué recibe.
- Qué devuelve.
- Qué errores produce.

Esta regla mantiene la comprensión del código por parte del estudiante.

## Alcance

Esta constitución recoge exclusivamente los cinco grupos de principios indicados para
`divisor_cuenta_web`. Las reglas de arquitectura se aplican a las capas y al punto de
composición indicados; la regla de la materia se aplica a toda función generada por el agente.

## Verificación de cumplimiento

La revisión de los cambios DEBE comprobar los cinco principios anteriores: responsabilidades
SOLID, dirección de dependencias y composición en `src/main.jsx`, ausencia de secretos,
pruebas de funcionalidad crítica y de criterios de aceptación, y capacidad del estudiante
para explicar las funciones generadas por el agente.

## Governance

Las modificaciones de esta constitución DEBEN identificar los principios afectados, explicar
el cambio y actualizar su versión y fecha de modificación. Agregar o cambiar principios
requiere una instrucción explícita del responsable del proyecto.

La versión DEBE seguir el esquema MAJOR.MINOR.PATCH: MAJOR para eliminar o redefinir
principios de forma incompatible; MINOR para añadir principios o ampliar materialmente
las reglas; PATCH para aclaraciones o correcciones que no cambien su significado.

La revisión de cumplimiento DEBE usar los principios vigentes y los criterios de la sección
«Verificación de cumplimiento».

**Version**: 2.0.0 | **Ratified**: 2026-10-14 | **Last Amended**: 2026-10-14
