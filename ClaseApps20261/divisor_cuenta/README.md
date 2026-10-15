# Divisor de Cuenta

App Flutter de una pantalla para dividir una cuenta entre varias personas,
con propina y dos modos de redondeo. Funciona sin conexión.

## Continuar con Codex y GitHub Spec Kit

Abre Codex en `divisor_cuenta/`. Las instrucciones del proyecto están en
[AGENTS.md](AGENTS.md); Codex es la integración predeterminada de Spec Kit.
`CLAUDE.md` remite al mismo archivo para mantener compatibilidad.

Los documentos existentes se siguen usando directamente:

- [Constitución](.specify/memory/constitution.md): arquitectura y calidad.
- [Especificación](specs/001-dividir-cuenta/spec.md): requisitos y aceptación.
- [Plan](specs/001-dividir-cuenta/plan.md): decisiones de implementación.
- [Tareas](specs/001-dividir-cuenta/tasks.md): trabajo y avance registrado.

Las diez habilidades están en `.agents/skills/`. En Codex CLI o la extensión
IDE, usa `/skills` o escribe `$` para seleccionarlas. Por ejemplo:

```text
$speckit-analyze Revisa la coherencia de specs/001-dividir-cuenta sin modificar archivos.
```

Otros flujos disponibles: `$speckit-specify`, `$speckit-clarify`,
`$speckit-plan`, `$speckit-tasks`, `$speckit-checklist`, `$speckit-implement`,
`$speckit-converge`, `$speckit-constitution` y `$speckit-taskstoissues`.
Las invocaciones antiguas `/speckit-<nombre>` o `/speckit.<nombre>` también
pueden escribirse en una solicitud; `AGENTS.md` indica leer la habilidad
equivalente. La notación nativa de las habilidades de Codex utiliza `$`.

Para continuar la feature actual, revisa los documentos y las tareas
existentes antes de pedir implementación. Regenerar la spec, el plan o las
tareas no es necesario por el cambio de agente. Los análisis manuales del
deber, como `analisis_spec.md`, son documentos separados.

Abre una sesión nueva de Codex para cargar `AGENTS.md`. Si las habilidades
recién instaladas no aparecen, reinicia Codex; también puedes pedirle que lea
directamente `.agents/skills/speckit-analyze/SKILL.md`.

En un checkout nuevo, comprueba el acceso a la feature sin escribir estado local:

```sh
SPECIFY_FEATURE_DIRECTORY=specs/001-dividir-cuenta SPECIFY_FEATURE_NO_PERSIST=1 bash .specify/scripts/bash/check-prerequisites.sh --json --require-spec --require-tasks --include-tasks
```

La adaptación conserva los flujos instalados de Spec Kit 1.0.13, las
plantillas y los scripts existentes. `specify` no estaba disponible en el
PATH del entorno donde se preparó esta adaptación; las habilidades y los
scripts incluidos permiten retomar el trabajo existente. La gestión o
actualización de integraciones mediante la CLI requiere instalar `specify`.

Referencias: [instrucciones de Codex](https://learn.chatgpt.com/docs/agent-configuration/agents-md),
[habilidades de Codex](https://learn.chatgpt.com/docs/build-skills) e
[integraciones de Spec Kit](https://github.com/github/spec-kit/blob/main/docs/reference/integrations.md).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
