import '../entities/usuario.dart';

/// Abstraccion de la fuente de datos. El dominio declara QUE necesita;
/// la capa de datos decidira COMO obtenerlo.
abstract class UsuarioRepository {
  Future<List<Usuario>> obtener();
}
