import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/calculadora.dart';
import '../models/persona.dart';
import '../widgets/persona_tile.dart';

class DivisorScreen extends StatefulWidget {
  const DivisorScreen({super.key});

  @override
  State<DivisorScreen> createState() => _DivisorScreenState();
}

class _DivisorScreenState extends State<DivisorScreen> {
  static const _propinasRapidas = [0, 10, 15, 20];
  static const _propinaInicial = 10;

  final _totalController = TextEditingController();
  ModoDivision _modo = ModoDivision.partesIguales;
  int _propina = _propinaInicial;
  int _siguienteId = 0;
  late List<Persona> _personas = [_nuevaPersona(), _nuevaPersona()];

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  Persona _nuevaPersona() => Persona(id: _siguienteId++);

  String _nombreDe(int i) {
    final nombre = _personas[i].nombre.trim();
    return nombre.isEmpty ? 'Persona ${i + 1}' : nombre;
  }

  ResultadoDivision? _calcular() {
    if (_modo == ModoDivision.partesIguales) {
      final subtotal = parsearCentavos(_totalController.text);
      if (subtotal == null) return null;
      return dividirPartesIguales(
        subtotal: subtotal,
        personas: _personas.length,
        propinaPorcentaje: _propina,
      );
    }
    final consumos = <int>[];
    for (final persona in _personas) {
      final consumo = parsearCentavos(persona.consumoTexto);
      if (consumo == null) return null;
      consumos.add(consumo);
    }
    return dividirPorConsumo(consumos: consumos, propinaPorcentaje: _propina);
  }

  void _reiniciar() {
    setState(() {
      _totalController.clear();
      _modo = ModoDivision.partesIguales;
      _propina = _propinaInicial;
      _personas = [_nuevaPersona(), _nuevaPersona()];
    });
  }

  Future<void> _copiarResumen(ResultadoDivision resultado) async {
    final lineas = [
      'Cuenta dividida',
      'Subtotal: ${formatearCentavos(resultado.subtotal)}',
      'Propina ($_propina%): ${formatearCentavos(resultado.propina)}',
      'Total: ${formatearCentavos(resultado.total)}',
      '',
      for (var i = 0; i < _personas.length; i++)
        '${_nombreDe(i)}: ${formatearCentavos(resultado.porPersona[i])}',
    ];
    await Clipboard.setData(ClipboardData(text: lineas.join('\n')));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Resumen copiado')));
  }

  @override
  Widget build(BuildContext context) {
    final resultado = _calcular();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Divisor de Cuenta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            tooltip: 'Reiniciar',
            onPressed: _reiniciar,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _selectorModo(),
                  const SizedBox(height: 16),
                  if (_modo == ModoDivision.partesIguales) ...[
                    _campoTotal(),
                    const SizedBox(height: 16),
                  ],
                  _seccionPropina(),
                  const SizedBox(height: 16),
                  _seccionPersonas(resultado),
                  const SizedBox(height: 16),
                  _seccionResumen(resultado),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectorModo() {
    return SegmentedButton<ModoDivision>(
      segments: const [
        ButtonSegment(
          value: ModoDivision.partesIguales,
          label: Text('Partes iguales'),
          icon: Icon(Icons.pie_chart_outline),
        ),
        ButtonSegment(
          value: ModoDivision.porConsumo,
          label: Text('Por consumo'),
          icon: Icon(Icons.receipt_long),
        ),
      ],
      selected: {_modo},
      onSelectionChanged: (seleccion) =>
          setState(() => _modo = seleccion.first),
    );
  }

  Widget _campoTotal() {
    final invalido = parsearCentavos(_totalController.text) == null;
    return TextField(
      controller: _totalController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: montoInputFormatters,
      style: Theme.of(context).textTheme.headlineSmall,
      decoration: InputDecoration(
        labelText: 'Total de la cuenta',
        helperText: 'Sin incluir la propina',
        prefixText: '\$ ',
        border: const OutlineInputBorder(),
        errorText: invalido ? 'Ingresa un monto válido' : null,
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _seccionPropina() {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Propina', style: tema.textTheme.titleMedium),
                const Spacer(),
                Text(
                  '$_propina %',
                  style: tema.textTheme.titleMedium?.copyWith(
                    color: tema.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final p in _propinasRapidas)
                  ChoiceChip(
                    label: Text('$p %'),
                    selected: _propina == p,
                    onSelected: (_) => setState(() => _propina = p),
                  ),
              ],
            ),
            Slider(
              value: _propina.toDouble(),
              max: 30,
              divisions: 30,
              label: '$_propina %',
              onChanged: (v) => setState(() => _propina = v.round()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionPersonas(ResultadoDivision? resultado) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Personas (${_personas.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _personas.length; i++)
              PersonaTile(
                key: ValueKey(_personas[i].id),
                indice: i,
                persona: _personas[i],
                mostrarConsumo: _modo == ModoDivision.porConsumo,
                aPagar: resultado?.porPersona[i],
                onNombreChanged: (v) => setState(() => _personas[i].nombre = v),
                onConsumoChanged: (v) =>
                    setState(() => _personas[i].consumoTexto = v),
                onEliminar: _personas.length > 1
                    ? () => setState(() => _personas.removeAt(i))
                    : null,
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Agregar persona'),
              onPressed: () => setState(() => _personas.add(_nuevaPersona())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccionResumen(ResultadoDivision? resultado) {
    final tema = Theme.of(context);
    final colores = tema.colorScheme;

    if (resultado == null) {
      return Card(
        color: colores.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Revisa los montos ingresados para ver el resumen.',
            style: TextStyle(color: colores.onErrorContainer),
          ),
        ),
      );
    }

    final partes = resultado.porPersona;
    final minimo = partes.reduce((a, b) => a < b ? a : b);
    final maximo = partes.reduce((a, b) => a > b ? a : b);

    return Card(
      color: colores.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: colores.onPrimaryContainer),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_modo == ModoDivision.partesIguales) ...[
                Text('Cada persona paga', style: tema.textTheme.labelLarge),
                Text(
                  formatearCentavos(maximo),
                  style: tema.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colores.onPrimaryContainer,
                  ),
                ),
                if (minimo != maximo)
                  Text(
                    'Algunos pagan ${formatearCentavos(minimo)} para que '
                    'cuadren los centavos.',
                    style: tema.textTheme.bodySmall,
                  ),
                const Divider(height: 24),
              ],
              _filaResumen('Subtotal', resultado.subtotal),
              _filaResumen('Propina ($_propina %)', resultado.propina),
              const Divider(height: 24),
              _filaResumen('Total', resultado.total, destacado: true),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.copy),
                label: const Text('Copiar resumen'),
                onPressed: () => _copiarResumen(resultado),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filaResumen(String etiqueta, int centavos, {bool destacado = false}) {
    final estilo = destacado
        ? Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          )
        : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(etiqueta, style: estilo),
          const Spacer(),
          Text(formatearCentavos(centavos), style: estilo),
        ],
      ),
    );
  }
}
