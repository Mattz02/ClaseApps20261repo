# Guía de validación

Escenarios para después de implementar. Ahora el proyecto conserva el ejemplo Vite;
Vitest, los scripts de test y sus suites se incorporarán durante implementación.

## Preparación

Desde divisor_cuenta_web, usar Node 24 LTS >=24.15.0 y npm. La instalación inicial requiere
dependencias disponibles; la aplicación no requiere red para calcular.

```bash
node --version
npm ci
export SPECIFY_FEATURE_DIRECTORY="specs/001-divisor-cuenta"
```

Durante implementación se añadirán Vitest 5 y jsdom 30 como devDependencies, actualizando
lockfile. Después, npm ci debe reproducir el entorno.

## Pruebas y build

Scripts previstos: test = vitest run; test:watch = vitest.

```bash
npm test
npm run lint
npm run build
npm run preview -- --host 127.0.0.1
```

Esperado: suites, lint y build sin errores; preview sirve dist y muestra la pantalla del
proyecto. Integración usa jsdom; las verificaciones manuales usan el navegador sobre el build.

- Ejecutar A1–A7 de [pantalla](contracts/pantalla.md): los seis originales pasan 6/6 y A7
  conserva el entero. Ejecutar cobertura FR-001–015 y todos los casos límite.
- Comprobar mitad ascendente, límites y ausencia de redondeo previo según la tabla de
  [dominio](contracts/dominio.md); comprobar sustitución con estrategia ficticia.
- Verificar imports presentation -> domain <- data, dominio sin React/DOM, y creación de
  proveedores de producción exclusivamente en main.
- Revisar OCP con la constitución 2.0.0: el registro de proveedores en main está permitido;
  inyectar un catálogo con un tercer id/estrategia en pruebas debe funcionar sin modificar
  cálculo, validación, hook ni pantalla, y sin enumerar modos dentro del validador.

## Recorrido de pantalla

1. Abrir preview: campos vacíos, modo Exacto, sin resultados ni errores.
2. Escribir 100.00, 4 y 10: no aparece resultado antes de enviar. Calcular: 27.50 por persona.
3. Editar cualquier campo o modo: ocultar salida inmediatamente. Repetir el resto de A1–A7.
4. Escribir abc, 0 y -1: ver los tres mensajes exactos sin monto por persona.
5. Cambiar un campo/modo: ocultar todos los mensajes y no recalcular automáticamente.
6. Cerrar/abrir una nueva sesión: formulario inicial, sin restauración.

## Mediciones

- SC-002: cronometrar primer uso con una persona que no conozca la app; apertura hasta
  resultado <30 s. Registrar condiciones/dispositivo y tiempo.
- SC-003: sobre preview/build, medir con herramientas de rendimiento desde submit hasta
  el frame con resultado visible: <1000 ms, también con máximos y ambos modos.
  Los tiempos de tests jsdom no sustituyen la medición de pantalla.

## Sin conexión (FR-015 / SC-004)

Alcance confirmado por el usuario: después de cargar los recursos, cálculos, validaciones
y cambios de modo funcionan sin red. La aplicación no realiza peticiones ni persiste el formulario.
No se garantiza primera apertura remota ni recarga sin conexión.

1. Cargar todos los recursos del build servido localmente. Verificar ausencia de CDN, APIs,
   fuentes remotas y solicitudes de aplicación al calcular.
2. Después de completar la carga, desconectar red o activar Offline en DevTools sin recargar.
3. Ejecutar A1–A7 y probar comas, propina vacía y límites: mismos resultados y mensajes,
   100 % de cálculos y validaciones locales. Alternar ambos modos, comprobando que ocultan
   resultado/errores anteriores y que solo el siguiente submit calcula con el modo elegido.
4. Comprobar cero peticiones de aplicación durante esos cálculos, validaciones y cambios de modo.
5. Verificar que no hay escrituras del formulario en localStorage, sessionStorage, IndexedDB,
   cookies ni otros mecanismos de persistencia.

Registrar resultados observados y condiciones del recorrido; el procedimiento por sí solo
no demuestra que la verificación se haya ejecutado. Sin añadir PWA ni caché persistente.
La instalación de dependencias no es red de la aplicación.

## Revisión de la materia

El estudiante explica el recorrido validación -> Cuenta -> cálculo -> aplicar -> formato
-> pantalla y para cada función qué hace, por qué existe, qué recibe, qué devuelve y qué
errores produce. Distinguir mensajes de entrada y errores de contrato de programación.
Revisar ausencia de secretos en los cambios.
