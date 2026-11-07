"""Comprueba los contratos de las herramientas con alertas aisladas por prueba."""

import pytest

import server


@pytest.fixture(autouse=True)
def alertas_aisladas(monkeypatch: pytest.MonkeyPatch) -> dict[str, dict]:
    """Usa un almacén nuevo por prueba y restaura el original al terminar."""
    alertas: dict[str, dict] = {}
    monkeypatch.setattr(server, "_ALERTAS", alertas)
    return alertas


def test_listar_casos_devuelve_exactamente_los_tres_casos() -> None:
    """Verifica identificadores, sistemas y cantidades sin conclusiones añadidas."""
    assert server.listar_casos() == [
        {"id": "INC-001", "sistema": "portal_acceso", "cantidad_eventos": 2},
        {"id": "INC-002", "sistema": "portal_acceso", "cantidad_eventos": 6},
        {"id": "INC-003", "sistema": "panel_administracion", "cantidad_eventos": 5},
    ]


def test_consultar_caso_desconocido_lanza_value_error() -> None:
    """Exige un error que identifique el caso inexistente, sin devolver eventos."""
    with pytest.raises(ValueError, match=r"INC-999.*no existe"):
        server.consultar_eventos("INC-999")


@pytest.mark.parametrize("nivel", ["bajo", "medio", "alto"])
def test_registrar_alerta_valida_guarda_la_confirmacion(
    alertas_aisladas: dict[str, dict], nivel: str
) -> None:
    """Comprueba la respuesta y la alerta almacenada para cada nivel permitido."""
    motivo = "Cuatro fallos y un acceso exitoso; requiere investigación"
    resultado = server.registrar_alerta("INC-003", nivel, motivo)
    esperado = {
        "caso_id": "INC-003",
        "nivel": nivel,
        "motivo": motivo,
        "estado": "registrada",
    }

    assert resultado == esperado
    assert alertas_aisladas == {"INC-003": esperado}


def test_alerta_duplicada_se_rechaza_sin_reemplazar_la_original(
    alertas_aisladas: dict[str, dict],
) -> None:
    """Repite el caso en la misma instancia y verifica que conserva su alerta."""
    original = server.registrar_alerta("INC-003", "alto", "Requiere investigación")

    with pytest.raises(ValueError, match=r"duplicada.*INC-003"):
        server.registrar_alerta("INC-003", "medio", "Otro motivo")

    assert alertas_aisladas == {"INC-003": original}


def test_consultar_inc002_devuelve_los_seis_fallos_exactos() -> None:
    """Comprueba horas, usuario, IP y evento de los seis registros del caso."""
    assert server.consultar_eventos("INC-002") == [
        {
            "hora": hora,
            "usuario": "admin",
            "ip": "203.0.113.25",
            "evento": "LOGIN_FAILED",
        }
        for hora in ["02:10", "02:11", "02:12", "02:13", "02:14", "02:15"]
    ]


def test_nivel_invalido_no_guarda_alertas(alertas_aisladas: dict[str, dict]) -> None:
    """Rechaza critico y explica los niveles aceptados sin modificar el almacén."""
    with pytest.raises(ValueError, match=r"nivel.*bajo.*medio.*alto"):
        server.registrar_alerta("INC-002", "critico", "Intentos repetidos")

    assert alertas_aisladas == {}


@pytest.mark.parametrize("motivo", ["", "   ", 123], ids=["vacio", "espacios", "no_texto"])
def test_motivo_invalido_no_guarda_alertas(
    alertas_aisladas: dict[str, dict], motivo: str | int
) -> None:
    """Rechaza motivos vacíos, blancos o que no sean texto sin guardar alertas."""
    with pytest.raises(ValueError, match="motivo"):
        server.registrar_alerta("INC-002", "medio", motivo)

    assert alertas_aisladas == {}


def test_registrar_alerta_para_caso_desconocido_no_modifica_el_estado(
    alertas_aisladas: dict[str, dict],
) -> None:
    """Rechaza alertas de casos inexistentes y mantiene el almacén vacío."""
    with pytest.raises(ValueError, match=r"INC-999.*no existe"):
        server.registrar_alerta("INC-999", "alto", "Requiere investigación")

    assert alertas_aisladas == {}
