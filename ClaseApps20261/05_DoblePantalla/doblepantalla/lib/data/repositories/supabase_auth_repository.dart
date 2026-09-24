import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  @override
  Future<String> registrar(String correo, String clave) async {
    final respuesta = await Supabase.instance.client.auth.signUp(
      email: correo,
      password: clave,
    );
    final usuario = respuesta.user;
    if (usuario == null) {
      throw StateError('El registro no devolvió un usuario.');
    }
    return usuario.id;
  }

  @override
  Future<void> ingresar(String correo, String clave) async {
    await Supabase.instance.client.auth.signInWithPassword(
      email: correo,
      password: clave,
    );
  }

  @override
  Future<void> salir() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  String? obtenerIdActual() => Supabase.instance.client.auth.currentUser?.id;
}
