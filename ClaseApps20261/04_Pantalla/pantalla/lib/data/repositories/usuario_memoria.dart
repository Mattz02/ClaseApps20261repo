import '../../domain/entities/usuario.dart';
import '../../domain/repositories/usuario_repository.dart';

/// Segunda implementacion del mismo contrato: datos fijos en memoria,
/// sin red, sin JSON. Tampoco aplica la regla del filtro por vocal.
class UsuarioMemoria implements UsuarioRepository {
  static const _usuarios = [
    Usuario(id: 1, nombre: 'Ana Torres', email: 'ana.torres@memoria.test'),
    Usuario(id: 2, nombre: 'Bruno Diaz', email: 'bruno.diaz@memoria.test'),
    Usuario(id: 3, nombre: 'Ines Ramirez', email: 'ines.ramirez@memoria.test'),
  ];

  @override
  Future<List<Usuario>> obtener() async => _usuarios;
}
