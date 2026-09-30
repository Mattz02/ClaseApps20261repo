import 'package:flutter/material.dart';

import 'data/redondeo_exacto.dart';
import 'data/redondeo_hacia_arriba.dart';
import 'domain/calcular_division.dart';
import 'domain/validar_entrada.dart';
import 'presentation/divisor_controller.dart';
import 'presentation/formateador_moneda.dart';
import 'presentation/pantalla_divisor.dart';

/// Qué hace: arranca la app.
/// Por qué existe: es el punto de entrada que Flutter ejecuta.
/// Recibe: nada.
/// Devuelve: nada.
/// Errores: ninguno.
void main() => runApp(construirApp());

/// Qué hace: crea todas las piezas concretas, las conecta y devuelve la app.
/// Por qué existe: es el único punto de composición (constitución,
/// principio II); las pruebas de aceptación lo usan para probar la misma app.
/// Recibe: nada.
/// Devuelve: el `MaterialApp` con `PantallaDivisor` como pantalla principal.
/// Errores: ninguno.
///
/// Para agregar un modo de redondeo basta con crear su clase en `data/` y
/// sumarla al mapa de estrategias; no hay que editar nada más (OCP). El orden
/// del mapa es el orden del selector, y el primero es el modo inicial.
Widget construirApp() {
  final controlador = DivisorController(
    validador: const ValidarEntrada(),
    calculadora: const CalcularDivision(),
    estrategias: {
      'Exacto': const RedondeoExacto(),
      'Hacia arriba': const RedondeoHaciaArriba(),
    },
    formateador: const FormateadorMoneda(),
  );
  return MaterialApp(
    title: 'Divisor de Cuenta',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
    home: PantallaDivisor(controlador: controlador),
  );
}
