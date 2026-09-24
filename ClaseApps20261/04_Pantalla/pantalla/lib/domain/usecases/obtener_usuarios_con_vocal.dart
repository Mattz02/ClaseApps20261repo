import '../entities/usuario.dart';
import '../repositories/usuario_repository.dart';

/// Caso de uso: pide los usuarios al repositorio y devuelve solo aquellos
/// cuyo nombre empieza con A, E, I, O o U, sin distinguir mayusculas.
class ObtenerUsuariosConVocal {
  final UsuarioRepository repository;

  const ObtenerUsuariosConVocal(this.repository);

  static const _vocales = {'a', 'e', 'i', 'o', 'u'};

  Future<List<Usuario>> call() async {
    final usuarios = await repository.obtener();
    return usuarios.where(_empiezaConVocal).toList();
  }

  bool _empiezaConVocal(Usuario usuario) {
    final nombre = usuario.nombre.trim();
    if (nombre.isEmpty) return false;
    return _vocales.contains(nombre[0].toLowerCase());
  }
}
