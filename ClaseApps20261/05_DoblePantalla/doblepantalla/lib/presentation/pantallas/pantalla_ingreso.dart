import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/sesion_provider.dart';
import 'pantalla_usuarios.dart';

class PantallaIngreso extends StatefulWidget {
  const PantallaIngreso({super.key});

  @override
  State<PantallaIngreso> createState() => _PantallaIngresoState();
}

class _PantallaIngresoState extends State<PantallaIngreso> {
  final _correoController = TextEditingController();
  final _claveController = TextEditingController();
  final _nombreController = TextEditingController();
  bool _navegando = false;

  @override
  void dispose() {
    _correoController.dispose();
    _claveController.dispose();
    _nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sesion = context.watch<SesionProvider>();

    if (sesion.idUsuario != null && !_navegando) {
      _navegando = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (sesion.idUsuario == null) {
          _navegando = false;
          return;
        }
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (_) => const PantallaUsuarios()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ingreso')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Correo'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _claveController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Clave'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 24),
                if (sesion.cargando) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                ],
                if (sesion.error != null) ...[
                  Text(
                    sesion.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                ],
                ElevatedButton(
                  onPressed: sesion.cargando
                      ? null
                      : () => context.read<SesionProvider>().ingresar(
                          _correoController.text,
                          _claveController.text,
                        ),
                  child: const Text('Ingresar'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: sesion.cargando
                      ? null
                      : () => context.read<SesionProvider>().registrar(
                          _correoController.text,
                          _claveController.text,
                          _nombreController.text,
                        ),
                  child: const Text('Crear cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
