# Deber 5 — MCP Detective

## 1. Arquitectura

El LLM interpretó mis instrucciones, eligió las herramientas y sus argumentos, y explicó los resultados. El harness o host, en este caso Codex dentro de VSCodium, coordinó las llamadas y el inicio del servidor. El cliente MCP descubrió las herramientas y envió las solicitudes al servidor mediante el protocolo MCP por stdio. El servidor MCP consultó los datos, validó las entradas y guardó las alertas en memoria. Quien ejecutó realmente las funciones Python fue el proceso del servidor, iniciado con el Python del entorno virtual; el LLM propuso las llamadas y razonó sobre sus respuestas.

## 2. Evidencia

INC-003 merece investigación porque registra cuatro intentos fallidos de acceso del usuario admin, entre las 03:00 y las 03:03, seguidos de un acceso exitoso a las 03:04. Todos vienen de la IP 192.0.2.50 y corresponden al panel de administración. El patrón es sospechoso y justifica una alerta de prioridad alta, pero también podría deberse a una persona autorizada que se equivocó varias veces antes de ingresar correctamente. Los registros no identifican quién estaba usando la cuenta ni muestran qué hizo después del acceso, por lo que no permiten asegurar que ocurrió una intrusión.

## 3. Validación y seguridad

El servidor MCP rechaza INC-999 porque ese caso no existe. También valida que el nivel sea bajo, medio o alto, que el motivo sea texto con contenido y que no exista una alerta previa para el mismo caso. Ante una entrada inválida lanza una excepción y el SDK comunica el error al cliente; no devuelve una confirmación falsa. No es seguro confiar solo en el modelo porque puede equivocarse, inventar un identificador o enviar argumentos que no cumplan el contrato. La validación del servidor aplica las mismas reglas en cada llamada, independientemente de lo que proponga el LLM, y evita modificar el estado cuando los datos son inválidos.

## 4. Uso del agente y como se conecto al mcp
Como agente use codex con el modelo gpt6.1 Sol y al mismo agente le pregunte como conecto el mcp a este y corri el comando codex mcp add mcp-detective -- \
  "$PWD/.venv-deber5/bin/python" \
  "$PWD/mcp-detective/server.py"
Despues abri otra sesion y corri /mcp para comprobar que estaba conectado y le di este prompt:
Usa exclusivamente las herramientas MCP de mcp-detective. No leas casos.json. Descubre qué casos hay, consulta los eventos de cada uno y muéstrame la evidencia.