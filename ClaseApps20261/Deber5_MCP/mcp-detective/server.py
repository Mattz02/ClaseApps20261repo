"""Expone tres herramientas MCP para consultar casos y guardar alertas en memoria."""

import json
from pathlib import Path

from mcp.server import MCPServer
from mcp.server.mcpserver.exceptions import ToolError


class ErrorValidacion(ValueError, ToolError):
    """ValueError cuyo mensaje el SDK MCP v2 puede comunicar al cliente.

    ToolError identifica una validación esperada; un ValueError común se
    considera un fallo inesperado y su mensaje se oculta en MCP 2.3.
    """


_CASOS: dict = json.loads(
    Path(__file__).resolve().with_name("casos.json").read_text(encoding="utf-8")
)
_ALERTAS: dict[str, dict] = {}

mcp = MCPServer("MCP Detective")


def validar_caso(casos: dict, caso_id: str) -> None:
    """Valida que el identificador sea texto y exista; si falla, lanza ValueError."""
    if not isinstance(caso_id, str):
        raise ErrorValidacion("El caso_id debe ser texto.")
    if caso_id not in casos:
        raise ErrorValidacion(f"El caso '{caso_id}' no existe.")


def resumir_casos(casos: dict) -> list[dict]:
    """Devuelve id, sistema y cantidad de eventos de cada caso, sin clasificarlos."""
    return [
        {
            "id": caso_id,
            "sistema": caso["sistema"],
            "cantidad_eventos": len(caso["eventos"]),
        }
        for caso_id, caso in casos.items()
    ]


def obtener_eventos(casos: dict, caso_id: str) -> list[dict]:
    """Devuelve copias de los eventos del caso; lanza ValueError si no existe."""
    validar_caso(casos, caso_id)
    return [evento.copy() for evento in casos[caso_id]["eventos"]]


def guardar_alerta(
    casos: dict,
    alertas: dict[str, dict],
    caso_id: str,
    nivel: str,
    motivo: str,
) -> dict:
    """Guarda una alerta en el diccionario recibido y devuelve su confirmación.

    Lanza ValueError si el caso no existe, los argumentos son inválidos o ya
    existe una alerta para ese caso. No modifica el estado cuando rechaza datos.
    """
    validar_caso(casos, caso_id)
    if not isinstance(nivel, str) or nivel not in {"bajo", "medio", "alto"}:
        raise ErrorValidacion("El nivel debe ser exclusivamente 'bajo', 'medio' o 'alto'.")
    if not isinstance(motivo, str) or not motivo.strip():
        raise ErrorValidacion(
            "El motivo debe ser texto y no puede estar vacío ni contener solo espacios."
        )
    if caso_id in alertas:
        raise ErrorValidacion(f"Alerta duplicada: ya existe una alerta para el caso '{caso_id}'.")

    alerta = {
        "caso_id": caso_id,
        "nivel": nivel,
        "motivo": motivo,
        "estado": "registrada",
    }
    alertas[caso_id] = alerta
    return alerta.copy()


@mcp.tool()
def listar_casos() -> list[dict]:
    """Lista id, sistema y cantidad de eventos de cada caso, sin conclusiones."""
    return resumir_casos(_CASOS)


@mcp.tool()
def consultar_eventos(caso_id: str) -> list[dict]:
    """Consulta los eventos exactos de un caso; lanza ValueError si no existe."""
    return obtener_eventos(_CASOS, caso_id)


@mcp.tool()
def registrar_alerta(caso_id: str, nivel: str, motivo: str) -> dict:
    """Registra una única alerta por caso en la memoria de esta instancia.

    Acepta un caso existente, nivel bajo/medio/alto y motivo de texto no blanco.
    Devuelve caso_id, nivel, motivo y estado registrada. Lanza ValueError ante
    argumentos inválidos o duplicados. Las alertas se pierden al reiniciar.
    """
    return guardar_alerta(_CASOS, _ALERTAS, caso_id, nivel, motivo)


if __name__ == "__main__":
    mcp.run(transport="stdio")
