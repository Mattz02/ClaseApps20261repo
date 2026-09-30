# Divisor de Cuenta

App Flutter de una sola pantalla para dividir una cuenta entre varias personas.

## Estructura

- `lib/presentation/`: widgets, pantalla y estado de la interfaz.
- `lib/domain/`: entidades y reglas de negocio (cálculo de la división).
- `lib/data/`: fuentes de datos e implementaciones de repositorios.

Regla de dependencia: `presentation -> domain <- data`. `presentation` y `data`
dependen de `domain`; `domain` no depende de ninguna de las dos.
`domain` NO importa nada de `package:flutter` (solo Dart puro).

## Estándares

- Null safety en todo el código.
- Nombres de clases, métodos y variables en español.
- Sin paquetes externos: solo el SDK de Flutter/Dart.

## Qué NO tocar

- No modifiques `test/` a menos que te lo pidan.
- No agregues dependencias a `pubspec.yaml` sin avisar antes.
- No toques `android/` ni `ios/`.

## Comandos

- `flutter pub get`: instalar dependencias.
- `flutter run`: ejecutar la app.
- `flutter analyze`: análisis estático; debe quedar sin problemas.
- `flutter test`: correr los tests.
