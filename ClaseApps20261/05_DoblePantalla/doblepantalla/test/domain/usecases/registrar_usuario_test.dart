import 'dart:async';

import 'package:doblepantalla/domain/entities/perfil.dart';
import 'package:doblepantalla/domain/repositories/auth_repository.dart';
import 'package:doblepantalla/domain/repositories/perfiles_repository.dart';
import 'package:doblepantalla/domain/usecases/registrar_usuario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Espera el registro y crea el perfil con el id devuelto', () async {
    final registro = Completer<String>();
    final auth = _AuthRepository((correo, clave) {
      expect(correo, 'ana@example.com');
      expect(clave, 'clave-de-prueba');
      return registro.future;
    });
    final perfiles = _PerfilesRepository();
    final registrar = RegistrarUsuario(auth, perfiles);

    final resultado = registrar('ana@example.com', 'clave-de-prueba', 'Ana');
    expect(perfiles.creaciones, isEmpty);

    registro.complete('usuario-123');
    await resultado;

    expect(perfiles.creaciones, [('usuario-123', 'Ana')]);
  });

  test('Propaga el error de registro sin crear un perfil', () async {
    final error = StateError('No se pudo registrar');
    final auth = _AuthRepository((_, _) async => throw error);
    final perfiles = _PerfilesRepository();
    final registrar = RegistrarUsuario(auth, perfiles);

    await expectLater(
      registrar('ana@example.com', 'clave-de-prueba', 'Ana'),
      throwsA(same(error)),
    );
    expect(perfiles.creaciones, isEmpty);
  });

  test('Propaga el mismo error si falla la creación del perfil', () async {
    final error = StateError('No se pudo crear el perfil');
    final auth = _AuthRepository((_, _) async => 'usuario-123');
    final perfiles = _PerfilesRepository(error: error);
    final registrar = RegistrarUsuario(auth, perfiles);

    await expectLater(
      registrar('ana@example.com', 'clave-de-prueba', 'Ana'),
      throwsA(same(error)),
    );
    expect(perfiles.creaciones, [('usuario-123', 'Ana')]);
  });
}

class _AuthRepository implements AuthRepository {
  final Future<String> Function(String, String) _registrar;

  _AuthRepository(this._registrar);

  @override
  Future<String> registrar(String correo, String clave) =>
      _registrar(correo, clave);

  @override
  Future<void> ingresar(String correo, String clave) =>
      throw UnimplementedError();

  @override
  Future<void> salir() => throw UnimplementedError();

  @override
  String? obtenerIdActual() => throw UnimplementedError();
}

class _PerfilesRepository implements PerfilesRepository {
  final Object? error;
  final creaciones = <(String, String)>[];

  _PerfilesRepository({this.error});

  @override
  Future<void> crear(String id, String nombre) async {
    creaciones.add((id, nombre));
    if (error != null) throw error!;
  }

  @override
  Future<List<Perfil>> obtenerTodos() => throw UnimplementedError();
}
