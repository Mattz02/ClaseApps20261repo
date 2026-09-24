import 'package:flutter/foundation.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/registrar_usuario.dart';

class SesionProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final RegistrarUsuario _registrarUsuario;

  String? idUsuario;
  bool cargando = false;
  String? error;

  SesionProvider(this._authRepository, this._registrarUsuario)
    : idUsuario = _authRepository.obtenerIdActual();

  Future<void> registrar(String correo, String clave, String nombre) async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      await _registrarUsuario(correo, clave, nombre);
      idUsuario = _authRepository.obtenerIdActual();
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> ingresar(String correo, String clave) async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      await _authRepository.ingresar(correo, clave);
      idUsuario = _authRepository.obtenerIdActual();
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  Future<void> salir() async {
    cargando = true;
    error = null;
    notifyListeners();

    try {
      await _authRepository.salir();
      idUsuario = null;
    } catch (e) {
      error = e.toString();
    } finally {
      cargando = false;
      notifyListeners();
    }
  }
}
