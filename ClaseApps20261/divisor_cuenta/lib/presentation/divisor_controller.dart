import '../domain/calcular_division.dart';
import '../domain/error_entrada.dart';
import '../domain/estrategia_redondeo.dart';
import '../domain/validar_entrada.dart';
import 'formateador_moneda.dart';

/// Guarda el estado de la pantalla y coordina validar, calcular y formatear.
///
/// Existe para que la lógica de la pantalla se pueda probar sin Flutter y
/// para que `PantallaDivisor` solo se encargue de dibujar. Recibe todas sus
/// dependencias por constructor y conoce los modos de redondeo solo a través
/// de `EstrategiaRedondeo` (DIP): nunca importa nada de `data/`.
class DivisorController {
  /// Qué hace: crea el controller con sus dependencias y elige como modo
  /// inicial el primero del mapa (FR-002).
  /// Por qué existe: `main.dart` es el único lugar que arma las piezas
  /// concretas; aquí solo se reciben.
  /// Recibe: el validador, la calculadora, el mapa ordenado
  /// "nombre visible → estrategia" y el formateador.
  /// Devuelve: la instancia de `DivisorController`.
  /// Errores: lanza `ArgumentError` si `estrategias` está vacío (error de
  /// programación: la pantalla necesita al menos un modo).
  ///
  /// Los parámetros `this._campo` se pasan sin guion bajo
  /// (`validador: ...`) y guardan el valor directo en el campo privado.
  DivisorController({
    required this._validador,
    required this._calculadora,
    required Map<String, EstrategiaRedondeo> estrategias,
    required this._formateador,
  }) : _estrategias = Map.unmodifiable(estrategias),
       _modoSeleccionado = estrategias.isEmpty
           ? throw ArgumentError.value(
               estrategias,
               'estrategias',
               'debe tener al menos un modo de redondeo',
             )
           : estrategias.keys.first;

  final ValidarEntrada _validador;
  final CalcularDivision _calculadora;
  final Map<String, EstrategiaRedondeo> _estrategias;
  final FormateadorMoneda _formateador;

  /// Nombre del modo de redondeo elegido; siempre es una clave del mapa.
  String _modoSeleccionado;

  /// Último resultado formateado, o `null` si no hay nada que mostrar.
  String? _montoPorPersona;

  /// Errores del último cálculo; vacío si no hubo errores o se descartaron.
  List<ErrorEntrada> _errores = const [];

  /// Los nombres de los modos, en el orden del mapa recibido.
  List<String> get modos => _estrategias.keys.toList();

  /// El modo de redondeo elegido.
  String get modoSeleccionado => _modoSeleccionado;

  /// El monto por persona ya formateado (por ejemplo "27.50"), o `null` si no
  /// hay resultado para mostrar.
  String? get montoPorPersona => _montoPorPersona;

  /// Mensaje de error del campo monto, o `null` si no hay error.
  String? get errorMonto => _mensajeDe(const [ErrorEntrada.montoInvalido]);

  /// Mensaje de error del campo personas, o `null` si no hay error.
  String? get errorPersonas => _mensajeDe(const [
    ErrorEntrada.personasMenorQueUno,
    ErrorEntrada.personasInvalido,
  ]);

  /// Mensaje de error del campo propina, o `null` si no hay error.
  String? get errorPropina => _mensajeDe(const [ErrorEntrada.propinaInvalida]);

  /// Qué hace: cambia el modo de redondeo y borra el resultado anterior.
  /// Por qué existe: el usuario elige el modo (FR-002), y un resultado
  /// calculado con otro modo ya no sirve (FR-014).
  /// Recibe: el nombre de un modo de `modos`.
  /// Devuelve: nada.
  /// Errores: lanza `ArgumentError` si el modo no existe (error de
  /// programación, no del usuario).
  void seleccionarModo(String modo) {
    if (!_estrategias.containsKey(modo)) {
      throw ArgumentError.value(modo, 'modo', 'no es un modo de redondeo');
    }
    _modoSeleccionado = modo;
    descartarResultado();
  }

  /// Qué hace: valida los datos y, si son válidos, calcula con el modo
  /// elegido y guarda el monto por persona formateado.
  /// Por qué existe: es la acción del botón "Calcular" (FR-003).
  /// Recibe: el texto de los tres campos, tal como está en pantalla.
  /// Devuelve: nada; el resultado queda en `montoPorPersona` y los errores en
  /// `errorMonto`, `errorPersonas` y `errorPropina`.
  /// Errores: ninguno; si los datos no son válidos, `montoPorPersona` queda
  /// en `null` y se guarda un mensaje por cada campo inválido (FR-013).
  void calcular({
    required String monto,
    required String personas,
    required String propina,
  }) {
    final validacion = _validador.validar(
      monto: monto,
      personas: personas,
      propina: propina,
    );
    _errores = validacion.errores;
    final cuenta = validacion.cuenta;
    if (cuenta == null) {
      _montoPorPersona = null;
      return;
    }
    final resultado = _calculadora.calcular(
      cuenta,
      _estrategias[_modoSeleccionado]!,
    );
    _montoPorPersona = _formateador.formatear(
      resultado.montoPorPersonaCentavos,
    );
  }

  /// Qué hace: borra el resultado y los mensajes de error mostrados.
  /// Por qué existe: si el usuario cambia un dato o el modo, el resultado y
  /// los errores anteriores ya no corresponden (FR-014).
  /// Recibe: nada.
  /// Devuelve: nada.
  /// Errores: ninguno.
  void descartarResultado() {
    _montoPorPersona = null;
    _errores = const [];
  }

  /// Qué hace: busca, entre los errores guardados, el primero que pertenece
  /// a un campo y devuelve su mensaje.
  /// Por qué existe: los tres getters de error hacen la misma búsqueda, cada
  /// uno con los errores de su campo.
  /// Recibe: los `ErrorEntrada` que puede producir el campo.
  /// Devuelve: el mensaje del error encontrado, o `null` si el campo no tiene
  /// error. `ValidarEntrada` da como máximo un error por campo.
  /// Errores: ninguno.
  String? _mensajeDe(List<ErrorEntrada> erroresDelCampo) {
    for (final error in _errores) {
      if (erroresDelCampo.contains(error)) return error.mensaje;
    }
    return null;
  }
}
