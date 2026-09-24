/// Entidad de dominio. No sabe de donde vienen los datos ni como se muestran.
class Usuario {
  final int id;
  final String nombre;
  final String email;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
  });
}
