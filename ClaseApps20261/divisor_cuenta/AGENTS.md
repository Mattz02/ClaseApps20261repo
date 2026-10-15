# Divisor de Cuenta — instrucciones para Codex

App Flutter de una pantalla para dividir una cuenta entre varias personas.
Trabaja desde `divisor_cuenta/`: esta es la raíz de Spec Kit y de Flutter,
aunque la raíz del repositorio Git está dos niveles más arriba.

## Reglas del proyecto

- Lee `.specify/memory/constitution.md` antes de cambiar el proyecto. Sus
  principios rigen la arquitectura, la calidad, la seguridad y las pruebas;
  las instrucciones explícitas del usuario delimitan el trabajo autorizado.
- Mantén `presentation -> domain <- data`. `lib/domain/` es Dart puro y no
  importa Flutter ni las otras capas. `presentation` depende de las
  abstracciones de `domain`; `lib/main.dart` conecta las implementaciones.
- `lib/data/` contiene las estrategias de redondeo. La app actual funciona
  sin red ni base de datos.
- Usa null safety y nombres de clases, métodos y variables en español.
- Cada clase y función nueva debe explicar qué hace, por qué existe, qué
  recibe, qué devuelve y qué errores produce, según la constitución y las
  tareas. Conserva ejemplos numéricos donde aclaren la aritmética entera.
- Conserva la restricción de no agregar paquetes externos a la app; no
  agregues dependencias a `pubspec.yaml` sin avisar antes.
- Modifica `test/` cuando el usuario lo solicite o lo exija una tarea de
  `specs/*/tasks.md`. No cambies expectativas solo para ocultar un fallo.
- No modifiques `android/` ni `ios/` salvo instrucción explícita del usuario.
- Nunca guardes secretos ni API keys en el repositorio.

## Continuidad de GitHub Spec Kit

Usa los documentos existentes, compartidos por todos los agentes:

1. `.specify/memory/constitution.md`: principios y gobernanza.
2. `specs/<feature>/spec.md`: requisitos y criterios de aceptación.
3. `specs/<feature>/plan.md` y `tasks.md`: diseño, dependencias y avance.
4. `research.md`, `data-model.md`, `contracts/`, `quickstart.md` y
   `checklists/` según la tarea.

La feature existente es `specs/001-dividir-cuenta/`. Comprueba el estado
actual antes de retomar; conserva los identificadores y las tareas marcadas
como completas. No marques una validación manual como realizada porque
pasaron pruebas automáticas. No regeneres los documentos al cambiar de agente.
Las referencias históricas a `CLAUDE.md` en el plan, la investigación y las
tareas corresponden a las reglas operativas ahora recogidas en este archivo.

`.specify/feature.json` guarda la selección local y está ignorado por Git.
En otro checkout, selecciona la feature existente explícitamente:

```sh
SPECIFY_FEATURE_DIRECTORY=specs/001-dividir-cuenta bash .specify/scripts/bash/check-prerequisites.sh --json --require-spec --require-tasks --include-tasks
```

El directorio de la feature es independiente del nombre de la rama Git.
Para análisis de solo lectura, añade `SPECIFY_FEATURE_NO_PERSIST=1` para
evitar que el script escriba la selección local.

## Habilidades de Spec Kit

Codex usa `.agents/skills/speckit-<nombre>/SKILL.md`. Lee la habilidad
correspondiente cuando el usuario invoque el flujo, también si conserva la
notación de Claude `/speckit-<nombre>` o `/speckit.<nombre>`.
La invocación nativa de Codex es `$speckit-<nombre>`.
Si no aparece en el catálogo de esta sesión, lee su `SKILL.md` directamente.

| Habilidad | Propósito |
|---|---|
| `$speckit-specify` | Crear o actualizar una especificación |
| `$speckit-clarify` | Aclarar requisitos |
| `$speckit-plan` | Preparar el plan y los documentos de diseño |
| `$speckit-tasks` | Generar tareas con dependencias |
| `$speckit-analyze` | Analizar la coherencia sin modificar documentos |
| `$speckit-checklist` | Crear listas de revisión de requisitos |
| `$speckit-implement` | Ejecutar las tareas autorizadas |
| `$speckit-converge` | Identificar trabajo pendiente y añadir tareas |
| `$speckit-constitution` | Actualizar la constitución |
| `$speckit-taskstoissues` | Crear issues de GitHub cuando se solicite |

Los flujos proceden de Spec Kit 1.0.13. Codex es la integración predeterminada
en `.specify/integration.json`; la instalación de Claude se conserva para
compatibilidad. Las plantillas y los scripts compartidos están en `.specify/`.

## Comprobación

- `flutter pub get`: resolver dependencias cuando sea necesario.
- `flutter run`: ejecutar la app.
- `flutter analyze`: comprobar el análisis estático.
- `flutter test`: ejecutar las pruebas.
- Al cambiar solo documentación o habilidades, comprueba sus metadatos,
  referencias y el acceso a los documentos de Spec Kit.

## Estado al retomar

La rama `sdd` conserva una restauración local al estado de `176c421`, solicitada
por el usuario, que retira las pruebas del límite de propina del 100 %.
Los requisitos de esta feature mantienen el límite de 999.99 %.
Revisa `git status` y el contenido actual antes de trabajar; esta nota no
autoriza a implementar de nuevo el límite de 100 % ni a deshacer la restauración.
