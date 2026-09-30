import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/calculadora.dart';
import '../models/persona.dart';

final montoInputFormatters = [
  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
];

class PersonaTile extends StatelessWidget {
  const PersonaTile({
    super.key,
    required this.indice,
    required this.persona,
    required this.mostrarConsumo,
    required this.aPagar,
    required this.onNombreChanged,
    required this.onConsumoChanged,
    this.onEliminar,
  });

  final int indice;
  final Persona persona;
  final bool mostrarConsumo;
  final int? aPagar;
  final ValueChanged<String> onNombreChanged;
  final ValueChanged<String> onConsumoChanged;
  final VoidCallback? onEliminar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final consumoInvalido = parsearCentavos(persona.consumoTexto) == null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  initialValue: persona.nombre,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Persona ${indice + 1}',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    isDense: true,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: onNombreChanged,
                ),
                if (mostrarConsumo) ...[
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: persona.consumoTexto,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: montoInputFormatters,
                    decoration: InputDecoration(
                      labelText: 'Consumió',
                      prefixText: '\$ ',
                      isDense: true,
                      border: const OutlineInputBorder(),
                      errorText: consumoInvalido ? 'Monto inválido' : null,
                    ),
                    onChanged: onConsumoChanged,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Paga', style: tema.textTheme.labelSmall),
              Text(
                aPagar == null ? '—' : formatearCentavos(aPagar!),
                style: tema.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: tema.colorScheme.primary,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: 'Quitar persona',
            onPressed: onEliminar,
          ),
        ],
      ),
    );
  }
}
