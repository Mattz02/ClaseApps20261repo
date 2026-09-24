import 'dart:async';

import 'package:doblepantalla/domain/entities/perfil.dart';
import 'package:doblepantalla/domain/repositories/auth_repository.dart';
import 'package:doblepantalla/domain/repositories/perfiles_repository.dart';
import 'package:doblepantalla/domain/usecases/registrar_usuario.dart';
import 'package:doblepantalla/main.dart';
import 'package:doblepantalla/presentation/pantallas/pantalla_ingreso.dart';
import 'package:doblepantalla/presentation/pantallas/pantalla_usuarios.dart';
import 'package:doblepantalla/presentation/providers/perfiles_provider.dart';
import 'package:doblepantalla/presentation/providers/sesion_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  late _AuthRepository auth;
  late _PerfilesRepository perfiles;

  setUp(() {
    auth = _AuthRepository();
    perfiles = _PerfilesRepository();
  });

  Future<void> montar(WidgetTester tester, {bool usuarios = false}) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) =>
                SesionProvider(auth, RegistrarUsuario(auth, perfiles)),
          ),
          ChangeNotifierProvider(create: (_) => PerfilesProvider(perfiles)),
        ],
        child: usuarios
            ? const MaterialApp(home: PantallaUsuarios())
            : const MyApp(),
      ),
    );
  }

  Future<void> completarCampos(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).at(0), 'ana@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'clave-de-prueba');
    await tester.enterText(find.byType(TextField).at(2), 'Ana');
  }

  testWidgets('Ingresar envía credenciales y reemplaza la pantalla', (
    tester,
  ) async {
    await montar(tester);
    expect(find.byType(TextField), findsNWidgets(3));
    expect(
      tester.widget<TextField>(find.byType(TextField).at(1)).obscureText,
      isTrue,
    );
    await completarCampos(tester);
    await tester.tap(find.text('Ingresar'));
    await tester.pumpAndSettle();

    expect(auth.credenciales, ('ana@example.com', 'clave-de-prueba'));
    expect(find.byType(PantallaUsuarios), findsOneWidget);
    expect(find.byType(PantallaIngreso), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(PantallaUsuarios))).canPop(),
      isFalse,
    );
  });

  testWidgets('Crear cuenta envía el nombre al caso de uso', (tester) async {
    await montar(tester);
    await completarCampos(tester);
    await tester.tap(find.text('Crear cuenta'));
    await tester.pumpAndSettle();

    expect(auth.credenciales, ('ana@example.com', 'clave-de-prueba'));
    expect(perfiles.creaciones, [('usuario-123', 'Ana')]);
    expect(find.byType(PantallaUsuarios), findsOneWidget);
  });

  testWidgets('Bloquea botones durante la carga y muestra errores en rojo', (
    tester,
  ) async {
    auth.respuesta = Completer<void>();
    await montar(tester);
    await completarCampos(tester);
    await tester.tap(find.text('Ingresar'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    for (final boton in tester.widgetList<ElevatedButton>(
      find.byType(ElevatedButton),
    )) {
      expect(boton.onPressed, isNull);
    }

    final error = StateError('Credenciales incorrectas');
    auth.respuesta!.completeError(error);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(PantallaIngreso), findsOneWidget);
    expect(
      tester.widget<Text>(find.text(error.toString())).style?.color,
      Colors.red,
    );
    for (final boton in tester.widgetList<ElevatedButton>(
      find.byType(ElevatedButton),
    )) {
      expect(boton.onPressed, isNotNull);
    }
  });

  testWidgets('Una sesión existente navega sin iniciar sesión de nuevo', (
    tester,
  ) async {
    auth.id = 'usuario-existente';
    await montar(tester);
    await tester.pumpAndSettle();

    expect(auth.credenciales, isNull);
    expect(find.byType(PantallaUsuarios), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Carga perfiles al abrir y permite recargar la lista', (
    tester,
  ) async {
    perfiles.respuesta = Completer<List<Perfil>>();
    await montar(tester, usuarios: true);
    await tester.pump();
    expect(perfiles.cargas, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.refresh))
          .onPressed,
      isNull,
    );

    final perfil = Perfil(
      id: 'usuario-123',
      nombre: 'Ana',
      creadoEn: DateTime.utc(2026, 9, 24),
    );
    perfiles.respuesta!.complete([perfil]);
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text(perfil.creadoEn.toString()), findsOneWidget);

    perfiles.respuesta = null;
    await tester.tap(find.byTooltip('Recargar'));
    await tester.pumpAndSettle();
    expect(perfiles.cargas, 2);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('Muestra el error de perfiles en rojo y permite reintentar', (
    tester,
  ) async {
    final error = StateError('No se pudieron cargar los perfiles');
    perfiles.error = error;
    await montar(tester, usuarios: true);
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(find.text(error.toString())).style?.color,
      Colors.red,
    );
    expect(find.byType(ListView), findsNothing);

    perfiles.error = null;
    await tester.tap(find.byTooltip('Recargar'));
    await tester.pumpAndSettle();
    expect(find.text(error.toString()), findsNothing);
    expect(find.byType(ListView), findsOneWidget);
  });

  testWidgets('Cerrar sesión regresa a ingreso y reemplaza la ruta', (
    tester,
  ) async {
    auth.id = 'usuario-123';
    await montar(tester, usuarios: true);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(auth.id, isNull);
    expect(find.byType(PantallaIngreso), findsOneWidget);
    expect(find.byType(PantallaUsuarios), findsNothing);
    expect(
      Navigator.of(tester.element(find.byType(PantallaIngreso))).canPop(),
      isFalse,
    );
  });

  testWidgets(
    'Si falla cerrar sesión, muestra el error y conserva la pantalla',
    (tester) async {
      auth.id = 'usuario-123';
      auth.errorSalida = StateError('No se pudo cerrar sesión');
      await montar(tester, usuarios: true);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Cerrar sesión'));
      await tester.pumpAndSettle();

      expect(auth.id, 'usuario-123');
      expect(find.byType(PantallaUsuarios), findsOneWidget);
      expect(find.text(auth.errorSalida.toString()), findsOneWidget);
    },
  );
}

class _AuthRepository implements AuthRepository {
  String? id;
  (String, String)? credenciales;
  Completer<void>? respuesta;
  Object? errorSalida;

  @override
  Future<String> registrar(String correo, String clave) async {
    credenciales = (correo, clave);
    await respuesta?.future;
    id = 'usuario-123';
    return id!;
  }

  @override
  Future<void> ingresar(String correo, String clave) async {
    credenciales = (correo, clave);
    await respuesta?.future;
    id = 'usuario-123';
  }

  @override
  String? obtenerIdActual() => id;

  @override
  Future<void> salir() async {
    if (errorSalida != null) throw errorSalida!;
    id = null;
  }
}

class _PerfilesRepository implements PerfilesRepository {
  final creaciones = <(String, String)>[];
  Completer<List<Perfil>>? respuesta;
  Object? error;
  int cargas = 0;

  @override
  Future<void> crear(String id, String nombre) async {
    creaciones.add((id, nombre));
  }

  @override
  Future<List<Perfil>> obtenerTodos() async {
    cargas++;
    if (error != null) throw error!;
    if (respuesta != null) return respuesta!.future;
    return [];
  }
}
