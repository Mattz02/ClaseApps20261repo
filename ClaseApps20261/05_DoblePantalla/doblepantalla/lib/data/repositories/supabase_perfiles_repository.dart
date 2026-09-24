import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/perfil.dart';
import '../../domain/repositories/perfiles_repository.dart';

class SupabasePerfilesRepository implements PerfilesRepository {
  @override
  Future<void> crear(String id, String nombre) async {
    await Supabase.instance.client.from('perfiles').insert({
      'id': id,
      'nombre': nombre,
    });
  }

  @override
  Future<List<Perfil>> obtenerTodos() async {
    final filas = await Supabase.instance.client.from('perfiles').select();
    return filas
        .map(
          (fila) => Perfil(
            id: fila['id'] as String,
            nombre: fila['nombre'] as String,
            creadoEn: DateTime.parse(fila['creado_en'] as String),
          ),
        )
        .toList();
  }
}
