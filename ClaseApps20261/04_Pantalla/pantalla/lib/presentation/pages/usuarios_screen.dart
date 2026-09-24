import 'package:flutter/material.dart';

import '../../domain/entities/usuario.dart';
import '../../domain/usecases/obtener_usuarios_con_vocal.dart';

/// Capa de presentacion: solo maneja estados de UI y dibuja.
/// No sabe de HTTP, ni de JSON, ni de la URL, ni de la regla del filtro.
class UsuariosScreen extends StatefulWidget {
  final ObtenerUsuariosConVocal obtenerUsuariosConVocal;

  const UsuariosScreen({super.key, required this.obtenerUsuariosConVocal});

  @override
  State<UsuariosScreen> createState() => _UsuariosScreenState();
}

class _UsuariosScreenState extends State<UsuariosScreen> {
  List<Usuario> _usuarios = [];
  bool _cargando = true;
  bool _huboError = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _huboError = false;
    });

    try {
      final usuarios = await widget.obtenerUsuariosConVocal();
      if (!mounted) return;
      setState(() {
        _usuarios = usuarios;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _huboError = true;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios con nombre que empieza en vocal'),
        actions: [
          IconButton(
            onPressed: _cargando ? null : _cargar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _construirCuerpo(),
    );
  }

  Widget _construirCuerpo() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_huboError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No se pudieron cargar los usuarios'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _cargar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_usuarios.isEmpty) {
      return const Center(child: Text('No hay usuarios que cumplan el filtro'));
    }

    return ListView.separated(
      itemCount: _usuarios.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final usuario = _usuarios[index];
        return ListTile(
          leading: CircleAvatar(child: Text(usuario.nombre[0].toUpperCase())),
          title: Text(usuario.nombre),
          subtitle: Text(usuario.email),
        );
      },
    );
  }
}
