import 'dart:async';

import 'package:doblepantalla/domain/entities/perfil.dart';
import 'package:doblepantalla/domain/repositories/auth_repository.dart';
import 'package:doblepantalla/domain/repositories/perfiles_repository.dart';
import 'package:doblepantalla/domain/usecases/registrar_usuario.dart';
import 'package:doblepantalla/presentation/providers/perfiles_provider.dart';
import 'package:doblepantalla/presentation/providers/sesion_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final operacion in ['registrar', 'ingresar', 'salir']) {
    test('$operacion notifica el error y permite reintentar', () async {
      final auth = _AuthRepository()..id = 'sesion-previa';
      final perfiles = _PerfilesRepository();
      final provider = SesionProvider(auth, RegistrarUsuario(auth, perfiles));
      addTearDown(provider.dispose);
      expect(provider.idUsuario, 'sesion-previa');

      final estados = <(bool, String?)>[];
      provider.addListener(() {
        estados.add((provider.cargando, provider.error));
      });
      Future<void> ejecutar() => switch (operacion) {
        'registrar' => provider.registrar('ana@example.com', 'clave', 'Ana'),
        'ingresar' => provider.ingresar('ana@example.com', 'clave'),
        _ => provider.salir(),
      };

      final error = StateError('Sin conexión');
      auth.error = error;
      await ejecutar();
      expect(estados, [(true, null), (false, error.toString())]);
      expect(provider.idUsuario, 'sesion-previa');

      auth.error = null;
      estados.clear();
      final resultado = ejecutar();
      expect(provider.cargando, isTrue);
      expect(provider.error, isNull);
      await resultado;
      expect(estados, [(true, null), (false, null)]);
      expect(provider.idUsuario, operacion == 'salir' ? null : 'usuario-123');
      if (operacion == 'registrar') {
        expect(perfiles.creaciones, [('usuario-123', 'Ana')]);
      }
    });
  }

  test('Registrar muestra también los errores al crear el perfil', () async {
    final auth = _AuthRepository();
    final error = StateError('No se pudo crear el perfil');
    final perfiles = _PerfilesRepository()..error = error;
    final provider = SesionProvider(auth, RegistrarUsuario(auth, perfiles));
    addTearDown(provider.dispose);

    await provider.registrar('ana@example.com', 'clave', 'Ana');

    expect(provider.error, error.toString());
    expect(provider.cargando, isFalse);
  });

  test('Cargar espera los datos y los conserva si falla una recarga', () async {
    final repositorio = _PerfilesRepository();
    final provider = PerfilesProvider(repositorio);
    addTearDown(provider.dispose);
    final estados = <(bool, String?)>[];
    provider.addListener(() {
      estados.add((provider.cargando, provider.error));
    });
    final perfil = Perfil(
      id: 'usuario-123',
      nombre: 'Ana',
      creadoEn: DateTime.utc(2026),
    );

    final carga = provider.cargar();
    expect(provider.perfiles, isEmpty);
    expect(provider.cargando, isTrue);
    repositorio.resultado.complete([perfil]);
    await carga;
    expect(provider.perfiles, [perfil]);
    expect(estados, [(true, null), (false, null)]);

    final error = StateError('Sin conexión');
    repositorio.error = error;
    estados.clear();
    await provider.cargar();
    expect(provider.perfiles, [perfil]);
    expect(estados, [(true, null), (false, error.toString())]);

    repositorio.error = null;
    estados.clear();
    await provider.cargar();
    expect(estados, [(true, null), (false, null)]);
  });
}

class _AuthRepository implements AuthRepository {
  String? id;
  Object? error;

  @override
  Future<String> registrar(String correo, String clave) async {
    if (error != null) throw error!;
    id = 'usuario-123';
    return id!;
  }

  @override
  Future<void> ingresar(String correo, String clave) async {
    if (error != null) throw error!;
    id = 'usuario-123';
  }

  @override
  Future<void> salir() async {
    if (error != null) throw error!;
    id = null;
  }

  @override
  String? obtenerIdActual() => id;
}

class _PerfilesRepository implements PerfilesRepository {
  Object? error;
  final resultado = Completer<List<Perfil>>();
  final creaciones = <(String, String)>[];

  @override
  Future<void> crear(String id, String nombre) async {
    if (error != null) throw error!;
    creaciones.add((id, nombre));
  }

  @override
  Future<List<Perfil>> obtenerTodos() async {
    if (error != null) throw error!;
    return resultado.future;
  }
}
