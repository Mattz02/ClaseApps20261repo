import 'package:flutter/material.dart';

import 'divisor_controller.dart';

/// La única pantalla de la app: tres campos, el selector de modo, el botón
/// "Calcular" y el resultado.
///
/// Existe para dibujar el estado del `DivisorController` y pasarle las
/// acciones del usuario. No calcula, no valida y no formatea: todo eso lo
/// hace el controller.
class PantallaDivisor extends StatefulWidget {
  /// Qué hace: crea la pantalla con el controller que ya armó `main.dart`.
  /// Por qué existe: la pantalla recibe su dependencia por constructor, no la
  /// crea (DIP).
  /// Recibe: el `DivisorController` y la `key` opcional de Flutter.
  /// Devuelve: el widget.
  /// Errores: ninguno.
  const PantallaDivisor({super.key, required this.controlador});

  /// El controller que guarda el estado de la pantalla.
  final DivisorController controlador;

  /// Qué hace: crea el objeto que guarda el estado mutable de la pantalla.
  /// Por qué existe: Flutter lo exige en todo `StatefulWidget`.
  /// Recibe: nada.
  /// Devuelve: un `_PantallaDivisorState` nuevo.
  /// Errores: ninguno.
  @override
  State<PantallaDivisor> createState() => _PantallaDivisorState();
}

/// Estado de `PantallaDivisor`: el texto de los tres campos.
class _PantallaDivisorState extends State<PantallaDivisor> {
  final _monto = TextEditingController();
  final _personas = TextEditingController();
  final _propina = TextEditingController();

  DivisorController get _controlador => widget.controlador;

  /// Qué hace: libera los controllers de texto al cerrar la pantalla.
  /// Por qué existe: los `TextEditingController` ocupan recursos que Flutter
  /// no libera solo.
  /// Recibe: nada.
  /// Devuelve: nada.
  /// Errores: ninguno.
  @override
  void dispose() {
    _monto.dispose();
    _personas.dispose();
    _propina.dispose();
    super.dispose();
  }

  /// Qué hace: borra el resultado cuando el usuario cambia cualquier campo.
  /// Por qué existe: un resultado viejo no debe quedar en pantalla con datos
  /// nuevos (FR-014).
  /// Recibe: el texto nuevo del campo (no se usa: basta con saber que cambió).
  /// Devuelve: nada.
  /// Errores: ninguno.
  void _alCambiarDato(String _) {
    setState(_controlador.descartarResultado);
  }

  /// Qué hace: le pasa al controller el modo que eligió el usuario.
  /// Por qué existe: es la acción del selector de modo (FR-002).
  /// Recibe: el conjunto de modos seleccionados; siempre trae exactamente uno.
  /// Devuelve: nada.
  /// Errores: ninguno; el selector solo ofrece modos que existen.
  void _alElegirModo(Set<String> seleccion) {
    setState(() => _controlador.seleccionarModo(seleccion.first));
  }

  /// Qué hace: le pide al controller que calcule con el texto de los campos.
  /// Por qué existe: es la acción del botón "Calcular" (FR-003).
  /// Recibe: nada.
  /// Devuelve: nada.
  /// Errores: ninguno.
  void _alTocarCalcular() {
    setState(
      () => _controlador.calcular(
        monto: _monto.text,
        personas: _personas.text,
        propina: _propina.text,
      ),
    );
  }

  /// Qué hace: dibuja la pantalla según el estado actual del controller.
  /// Por qué existe: Flutter la llama cada vez que hay que redibujar.
  /// Recibe: el `BuildContext` de Flutter.
  /// Devuelve: el árbol de widgets de la pantalla.
  /// Errores: ninguno.
  @override
  Widget build(BuildContext context) {
    final montoPorPersona = _controlador.montoPorPersona;
    return Scaffold(
      appBar: AppBar(title: const Text('Divisor de Cuenta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                key: const Key('campo_monto'),
                controller: _monto,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Monto total',
                  border: const OutlineInputBorder(),
                  errorText: _controlador.errorMonto,
                ),
                onChanged: _alCambiarDato,
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('campo_personas'),
                controller: _personas,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Número de personas',
                  border: const OutlineInputBorder(),
                  errorText: _controlador.errorPersonas,
                ),
                onChanged: _alCambiarDato,
              ),
              const SizedBox(height: 16),
              TextField(
                key: const Key('campo_propina'),
                controller: _propina,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Propina (%)',
                  border: const OutlineInputBorder(),
                  errorText: _controlador.errorPropina,
                ),
                onChanged: _alCambiarDato,
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                key: const Key('selector_modo'),
                segments: [
                  for (final modo in _controlador.modos)
                    ButtonSegment(value: modo, label: Text(modo)),
                ],
                selected: {_controlador.modoSeleccionado},
                onSelectionChanged: _alElegirModo,
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('boton_calcular'),
                onPressed: _alTocarCalcular,
                child: const Text('Calcular'),
              ),
              if (montoPorPersona != null) ...[
                const SizedBox(height: 24),
                _construirResultado(context, montoPorPersona),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Qué hace: dibuja la tarjeta con el monto que paga cada persona.
  /// Por qué existe: separa el bloque del resultado para que `build` sea más
  /// fácil de leer.
  /// Recibe: el `BuildContext` (para el tema) y el monto ya formateado.
  /// Devuelve: la tarjeta del resultado.
  /// Errores: ninguno.
  Widget _construirResultado(BuildContext context, String montoPorPersona) {
    final tema = Theme.of(context);
    return Card(
      color: tema.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Cada persona paga', style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              montoPorPersona,
              key: const Key('texto_resultado'),
              style: tema.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
