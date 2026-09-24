import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/perfiles_provider.dart';
import '../providers/sesion_provider.dart';
import 'pantalla_ingreso.dart';

class PantallaUsuarios extends StatefulWidget {
  const PantallaUsuarios({super.key});

  @override
  State<PantallaUsuarios> createState() => _PantallaUsuariosState();
}

class _PantallaUsuariosState extends State<PantallaUsuarios> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<PerfilesProvider>().cargar();
    });
  }

  Future<void> _cerrarSesion() async {
    final sesion = context.read<SesionProvider>();
    await sesion.salir();
    if (!mounted) return;

    if (sesion.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(sesion.error!)));
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const PantallaIngreso()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final perfiles = context.watch<PerfilesProvider>();
    final sesion = context.watch<SesionProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: perfiles.cargando
                ? null
                : () => context.read<PerfilesProvider>().cargar(),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: sesion.cargando ? null : _cerrarSesion,
          ),
        ],
      ),
      body: perfiles.cargando
          ? const Center(child: CircularProgressIndicator())
          : perfiles.error != null
          ? Center(
              child: Text(
                perfiles.error!,
                style: const TextStyle(color: Colors.red),
              ),
            )
          : ListView.builder(
              itemCount: perfiles.perfiles.length,
              itemBuilder: (context, index) {
                final perfil = perfiles.perfiles[index];
                return ListTile(
                  title: Text(perfil.nombre),
                  subtitle: Text(perfil.creadoEn.toString()),
                );
              },
            ),
    );
  }
}
