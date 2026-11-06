# Preparación del Deber 5

Se preparó el entorno y se implementó el servidor de la Parte 1.

## Estado

- Enunciado original: `/home/matt/Downloads/Deber5.md`.
- Rama de trabajo: `deber5`, creada desde `main` actualizado.
- Raíz Git: `/home/matt/PrograAppsRepo/ClaseApps20261repo`.
- Carpeta del deber: `ClaseApps20261/Deber5_MCP/`. Las rutas del enunciado
  se resuelven desde esta carpeta, según lo indicado por el usuario.
- Repositorio público verificado en la API de GitHub.
- Python 3.13.16, Node.js v24.22.1 y npx 11.19.1 disponibles.
- Entorno virtual local: `.venv-deber5/` (excluido de Git).
- MCP 2.3.0 y pytest 9.2.0 instalados; `mcp version`, importación de
  `MCPServer` y `pip check` comprobados.
- `mcp-detective/requirements.txt` fija las versiones instaladas.
- `mcp-detective/casos.json` contiene los tres casos exactos del enunciado.
- `mcp-detective/server.py` expone las tres herramientas por stdio, con
  validaciones y alertas en memoria. Las funciones de lógica reciben los datos
  y el almacenamiento explícitamente para permitir pruebas aisladas.
- `ErrorValidacion` hereda de `ValueError` y de `ToolError` del SDK: conserva
  la validación exigida y permite que MCP 2.3 entregue el motivo del error al
  cliente, en lugar de ocultarlo como un fallo inesperado.
- `evidencias/` está en la raíz del deber y contiene únicamente `.gitkeep`.
- Verificación técnica realizada con un cliente MCP local por stdio desde
  `/tmp`: descubrimiento de las tres herramientas, consultas, registro válido,
  errores comprensibles para entradas inválidas y duplicados, y pérdida de
  alertas al reiniciar el proceso. Esto no sustituye las pruebas de entrega,
  el Inspector ni las capturas pendientes.

## Activar el entorno

Desde cualquier terminal:

```bash
cd /home/matt/PrograAppsRepo/ClaseApps20261repo/ClaseApps20261/Deber5_MCP
source .venv-deber5/bin/activate
python --version
mcp version
python -m pytest --version
```

Para reinstalar las dependencias en este entorno:

```bash
python -m pip install -r mcp-detective/requirements.txt
```

## Pendiente de las siguientes partes

Crear las pruebas de entrega; ejecutar el Inspector;
conectar el servidor al agente; obtener las capturas en `evidencias/` y escribir
`respuestas.md` en esta carpeta (`Deber5_MCP/`).
La conexión del servidor al agente sigue pendiente para la Parte 3.
El Inspector descargará su paquete mediante npx al usarlo.

Los comandos siguientes son referencias para después de implementar el servidor;
todavía no se han ejecutado:

```bash
mcp dev mcp-detective/server.py
python -m pytest mcp-detective -q
```

Para la Parte 3, abrir una conversación nueva y obtener los eventos exclusivamente
mediante las herramientas MCP, como exige el enunciado.

No se han creado commits, hecho push ni abierto un pull request.
