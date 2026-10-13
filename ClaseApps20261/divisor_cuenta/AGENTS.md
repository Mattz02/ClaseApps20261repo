# Divisor de Cuenta

App Flutter de una sola pantalla para dividir una cuenta entre varias personas.

## Estructura

- `lib/presentation/`: widgets, pantalla y estado de la interfaz.
- `lib/domain/`: entidades y reglas de negocio (cálculo de la división).
- `lib/data/`: fuentes de datos e implementaciones de repositorios.

Regla de dependencia: `presentation -> domain <- data`. `presentation` y `data`
dependen de `domain`; `domain` no depende de ninguna de las dos.
`domain` NO importa nada de `package:flutter` (solo Dart puro).

## Estándares

- Null safety en todo el código.
- Nombres de clases, métodos y variables en español.
- Sin paquetes externos: solo el SDK de Flutter/Dart.

## Qué NO tocar

- No modifiques `test/` a menos que te lo pidan o que lo exija una tarea de
  `specs/*/tasks.md` (la constitución, principio IV, exige pruebas).
- No agregues dependencias a `pubspec.yaml` sin avisar antes.
- No toques `android/` ni `ios/`.

## Comandos

- `flutter pub get`: instalar dependencias.
- `flutter run`: ejecutar la app.
- `flutter analyze`: análisis estático; debe quedar sin problemas.
- `flutter test`: correr los tests.

## Continuidad con GitHub Spec Kit en Codex

Las reglas anteriores se copiaron de `CLAUDE.md`. Conserva ambos archivos
coherentes si cambian las instrucciones compartidas del proyecto.

La raíz de Spec Kit es este directorio (`divisor_cuenta/`), aunque la raíz de
Git esté dos niveles arriba. Ejecuta los scripts desde aquí. Codex y Claude
usan los mismos documentos; no crees copias de las specs para cada agente.

Antes de trabajar en una feature, lee:

1. `.specify/memory/constitution.md`: principios y gobernanza.
2. `specs/<feature>/spec.md`: requisitos y criterios de aceptación.
3. `specs/<feature>/plan.md` y `tasks.md`: diseño, dependencias y avance.
4. `research.md`, `data-model.md`, `contracts/`, `quickstart.md` y
   `checklists/` de esa feature según la tarea.

Para encontrar todas las specs, usa `rg --files specs`. Las plantillas están
en `.specify/templates/` y los scripts en `.specify/scripts/bash/`.
La constitución rige las prácticas del proyecto; las instrucciones explícitas
del usuario delimitan el trabajo autorizado.

### Feature activa y comprobación

Al preparar esta continuidad, la feature es `001-dividir-cuenta`, en
`specs/001-dividir-cuenta/`. `.specify/feature.json` guarda esa selección local
y está ignorado por Git. Para otro checkout o una feature diferente, pasa
`SPECIFY_FEATURE_DIRECTORY=specs/<feature>` al script correspondiente; no
supongas que el nombre de la rama Git determina la feature.

Comprobación de acceso a los documentos existentes (sin implementar tareas):

```sh
bash .specify/scripts/bash/check-prerequisites.sh --json --require-spec --require-tasks --include-tasks
```

Si falta el estado local en un checkout nuevo:

```sh
SPECIFY_FEATURE_DIRECTORY=specs/001-dividir-cuenta bash .specify/scripts/bash/check-prerequisites.sh --json --require-spec --require-tasks --include-tasks
```

### Flujos disponibles

Las diez habilidades de Claude se adaptaron a `.agents/skills/`, la ubicación
local de habilidades de Codex. Cada `SKILL.md` conserva el flujo de Spec Kit
instalado (1.0.13), con metadatos e invocación adaptados para Codex.

| Habilidad de Codex | Uso |
|---|---|
| `$speckit-specify` | Crear o actualizar una especificación |
| `$speckit-clarify` | Aclarar requisitos de la spec |
| `$speckit-plan` | Preparar el plan y los documentos de diseño |
| `$speckit-tasks` | Generar tareas con dependencias |
| `$speckit-analyze` | Revisar coherencia sin modificar documentos |
| `$speckit-checklist` | Crear listas de revisión de requisitos |
| `$speckit-implement` | Ejecutar las tareas autorizadas |
| `$speckit-converge` | Identificar trabajo restante y agregar tareas |
| `$speckit-constitution` | Actualizar la constitución |
| `$speckit-taskstoissues` | Convertir tareas en issues de GitHub cuando se solicite |

Acepta también las invocaciones anteriores `/speckit-<nombre>` y
`/speckit.<nombre>`; lee la habilidad correspondiente antes de ejecutar el flujo.
Si la sesión no las muestra en su catálogo, lee directamente su `SKILL.md`.
La configuración de la CLI de Spec Kit y `.claude/` se conservan: esta
adaptación usa habilidades locales de Codex y los scripts existentes.

### Estado de la transferencia (2026-10-13)

- `tasks.md` deja T038 pendiente: falta la validación manual en un dispositivo.
  Revisa el estado actual antes de retomar y no marques pruebas manuales como
  realizadas por haber pasado pruebas automáticas.
- La solicitud más reciente sobre propina pidió únicamente dos pruebas en
  `test/division_test.dart`: 150 % debe devolver exactamente
  "La propina no puede superar el 100%" y 100 % debe aceptarse. Se agregaron
  esas pruebas sin implementar la regla; la primera falla con el dominio actual.
- Los documentos de `001-dividir-cuenta` todavía especifican el tope anterior
  de 999.99 %. Al retomar esa regla, reconoce esta discrepancia y sigue el
  alcance de la nueva solicitud del usuario; esta transferencia no implementa
  la regla ni cambia los documentos de requisitos.
