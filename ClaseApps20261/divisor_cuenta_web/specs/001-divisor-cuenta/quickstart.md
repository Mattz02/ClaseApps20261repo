# Guía de validación

Guía de validación del divisor de cuenta. Los checkpoints al final registran resultados
observados; las comprobaciones humanas se indican por separado.

## Preparación

Desde divisor_cuenta_web, usar Node 24 LTS >=24.15.0 y npm. La instalación inicial requiere
dependencias disponibles; la aplicación no requiere red para calcular.

```bash
node --version
npm ci
export SPECIFY_FEATURE_DIRECTORY="specs/001-divisor-cuenta"
```

Vitest 5.0.4 y jsdom 30.1.2 están instalados como devDependencies y resueltos en lockfile.
La instalación reproducible con npm ci --offline se verificó con la caché disponible.

## Pruebas y build

Scripts disponibles: test = vitest run; test:watch = vitest.

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

## Registro de implementación

- Base: 44 pruebas de validación fallaron por comportamiento antes de implementar y luego pasaron.
- US1: 71 pruebas en 7 archivos pasan (A1/A2/A5, formato, precisión y extensión inyectada).
  Build Vite correcto. Se retiraron el montaje y los recursos de demostración sin uso.

- US2: 97 pruebas en 7 archivos pasan; se verifican A3/A4, errores simultáneos,
  asociaciones de campo y limpieza al editar campo o modo. Los nuevos casos fallaron antes del cambio.

- US3: 113 pruebas pasan, incluidas A6/A7, techo sin redondeo previo, máximos y tercer id
  inyectado. Lint y build correctos. Los hashes de cálculo, validación, hook y pantalla
  son idénticos antes/después de registrar Hacia arriba: extensión conforme a OCP 2.0.0.

## Verificación final observada — 2026-10-14

- Node 24.18.1, Vitest 5.0.4, jsdom 30.1.2 y Vite 8.3.4 en Linux x86_64.
- 116 pruebas en 7 archivos aprobadas. npm run lint termina sin advertencias ni errores;
  npm run build genera dist correctamente. npm ci --offline reprodujo las dependencias.
- Auditoría de las capas y composición aprobada: domain no usa React/DOM/efectos,
  presentation no importa data y solo main instancia los proveedores de producción.
  No se detectaron patrones de secretos en los archivos de aplicación revisados.
- Spec intacta, SHA-256:
  6c7aff2b21fac7961ba3a7f767424fb9f6ef1151b2f9662e8f80084315e307d0.

### Recorrido de navegador (T036)

Firefox 156.0 headless, perfil temporal, build servido por Vite preview en 127.0.0.1:4173.
Se completaron 14 casos conectado y los mismos 14 con Offline real mediante WebDriver BiDi,
verificando navigator.onLine=false sin recargar el documento. Incluyen A1–A7, máximos,
valor diminuto, mitad ascendente, coma, techo sin redondeo previo y errores simultáneos.
Los importes y mensajes coincidieron; A3/A4 no mostraron output. El cambio de modo borró
los errores anteriores sin recalcular.

Se observaron cero peticiones durante operación, cero entradas de localStorage/sessionStorage,
ninguna cookie y ninguna base IndexedDB. Los tests de aislamiento también impiden accesos
a esos mecanismos desde la aplicación. Sin errores de consola durante el recorrido.

Evidencia: [resultados del navegador](evidencias/validacion-browser.json),
[vista de escritorio](evidencias/escritorio.png) y [vista móvil](evidencias/movil.png).
La revisión visual incluyó 1280×900 y 390×844; no hubo desbordamiento horizontal móvil,
incluido el importe máximo. En móvil el documento puede desplazarse verticalmente.

### Mediciones y revisión humana (T037)

SC-003: se midió el intervalo desde click en Calcular hasta dos requestAnimationFrame,
comprobando output visible y de anchura positiva. El máximo observado fue 35 ms en este
entorno, con ambos modos y límites probados; todas las muestras estuvieron bajo 1000 ms.
Es una medición de frames en navegador real automatizado, no un tiempo jsdom ni una garantía
sobre cualquier dispositivo. Las muestras están en el JSON de evidencia.

Verificación humana comunicada por el usuario en esta sesión, 2026-10-14:

- SC-002: el usuario informó aproximadamente 5 segundos para su primer cálculo en
  http://127.0.0.1:4173/, en el recorrido solicitado (100, 4 personas, 10 %; esperado 27.50).
  Es un tiempo informado por el usuario y cumple el umbral de menos de 30 segundos.
- Regla de la materia: tras consultar la guía de funciones del README, el usuario confirmó
  «sí, puedo explicarlas» respecto a propósito, entradas, salida y errores de cada función.

Con estas confirmaciones y la medición de SC-003, T037 queda completada.
