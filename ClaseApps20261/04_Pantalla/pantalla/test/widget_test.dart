// Ahora la pantalla se puede testear sin red: se le inyecta un repositorio falso.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pantalla/domain/entities/usuario.dart';
import 'package:pantalla/domain/repositories/usuario_repository.dart';
import 'package:pantalla/domain/usecases/obtener_usuarios_con_vocal.dart';
import 'package:pantalla/presentation/pages/usuarios_screen.dart';

class UsuarioRepositoryFalso implements UsuarioRepository {
  @override
  Future<List<Usuario>> obtener() async => const [
        Usuario(id: 1, nombre: 'Ana Lopez', email: 'ana@test.com'),
        Usuario(id: 2, nombre: 'Carlos Ruiz', email: 'carlos@test.com'),
        Usuario(id: 3, nombre: 'Ervin Howell', email: 'ervin@test.com'),
      ];
}

void main() {
  testWidgets('Muestra solo los usuarios cuyo nombre empieza con vocal',
      (WidgetTester tester) async {
    final caso = ObtenerUsuariosConVocal(UsuarioRepositoryFalso());

    await tester.pumpWidget(
      MaterialApp(home: UsuariosScreen(obtenerUsuariosConVocal: caso)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana Lopez'), findsOneWidget);
    expect(find.text('Ervin Howell'), findsOneWidget);
    expect(find.text('Carlos Ruiz'), findsNothing);
  });
}
