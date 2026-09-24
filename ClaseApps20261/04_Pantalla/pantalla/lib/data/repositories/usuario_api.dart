import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

/// Implementacion concreta del repositorio: sabe COMO se obtienen los datos.
/// Se encarga solo de la llamada HTTP, la URL, el jsonDecode y la conversion
/// del JSON a objetos Usuario. No aplica ninguna regla de negocio.
class UsuarioApi implements UsuarioRepository {
  static const _url = 'https://jsonplaceholder.typicode.com/users';

  @override
  Future<List<Usuario>> obtener() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode != 200) {
      throw Exception('Error HTTP ${response.statusCode}');
    }

    final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;

    return decoded
        .map((item) => _aUsuario(item as Map<String, dynamic>))
        .toList();
  }

  Usuario _aUsuario(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] as int,
      nombre: json['name'] as String,
      email: json['email'] as String,
    );
  }
}
