# Investigación: divisor de cuenta web

Completada el 2026-10-14 para la spec activa, sin modificarla.

## Estado y composición

- **Decisión:** React/Vite/JavaScript existentes; useDivisor(dependencias) mantiene con useState
  entradas textuales y salida nula/éxito/error. Editar cambia entrada y borra salida en la misma
  actualización. Solo submit valida/calcula. Main crea proveedores y catálogo.
- **Razón:** una pantalla no necesita estado global ni efectos para sincronizar resultados.
- **Alternativas:** Redux/Zustand no están autorizados; calcular en render o efectos incumple
  el cálculo exclusivo al enviar.
- **Fuentes:** [useState](https://react.dev/reference/react/useState) y
  [hooks con parámetros](https://react.dev/learn/reusing-logic-with-custom-hooks).

Revisión OCP contra la constitución 2.0.0: el registro de una nueva implementación en
src/main.jsx está permitido explícitamente. El cálculo, la validación, el hook y la pantalla
se mantienen sin cambios al extender el catálogo. Exacto/arriba son los ids iniciales,
no una enumeración cerrada en validarEntrada. La resolución genérica por id permite probar
un proveedor adicional inyectado sin cambiar esos consumidores.

## Aritmética y contrato de redondeo

- **Decisión:** BigInt: monto en centavos, propina en centésimas de porcentaje y personas enteras.
  aplicar recibe una fracción en centavos y devuelve centavos enteros BigInt.
- **Razón:** el numerador máximo es 10999899999890001, mayor que Number.MAX_SAFE_INTEGER.
  Las operaciones enteras preservan las mitades y el techo en todo el rango.
- **Alternativas:** Number con Math.round/toFixed introduce errores; EPSILON no corrige todos
  los tamaños. Una dependencia decimal no resulta necesaria.
- **Fuente:** ECMAScript: [producto exacto BigInt](https://tc39.es/ecma262/2024/#sec-numeric-types-bigint-multiply)
  y [división truncada](https://tc39.es/ecma262/2024/#sec-numeric-types-bigint-divide).

Con monto M, propina T y personas P, construir N=M*(10000+T), D=10000*P, todos BigInt.
Exacto usa q=N/D, r=N%D; suma un centavo cuando 2*r>=D. Hacia arriba calcula el techo
al entero monetario directamente desde N/(100*D), sin redondeo previo a centavos.
Así, 1.00 con 0.01 % da 2.00 hacia arriba. Formato con cociente/resto de centavos entre 100,
sin convertir a Number.

## Validación y entradas

- **Decisión:** inputs controlados de texto con inputMode; formulario noValidate. Validar los
  tres campos en dominio y devolver mensajes simultáneos exactos. Recortar espacios exteriores,
  admitir coma/punto y normalizar a enteros escalados solo después de validar precisión/límites.
- **Razón:** abc y 12,50 deben alcanzar el validador sin sanitización del navegador.
- **Alternativas:** type=number puede alterar entradas; parseFloat parcial acepta basura.
- **Fuente:** [inputs controlados](https://react.dev/reference/react-dom/components/input).

Decisión de parser: admitir signo opcional, ceros iniciales y decimales ordinarios como .5 y 12.;
rechazar exponentes, hexadecimal y separadores de miles. Personas requiere sintaxis entera:
2.0 y 2,0 se rechazan. Se mantienen todos los mensajes y límites de la spec.

## Pruebas y herramientas

- **Decisión:** conservar React/Vite del proyecto; Vitest 5 y jsdom 30 como devDependencies,
  fijadas en lockfile al implementar. Node 24 LTS >=24.15.0; entorno actual 24.18.1.
  Unitarias en Node, hook/pantalla en jsdom con act y createRoot, sin biblioteca adicional.
- **Razón:** integración con Vite y pruebas de mensajes, eventos, invalidación y sustitución.
- **Alternativas:** otro runner duplica configuración; snapshots no prueban el comportamiento.
  jsdom no demuestra pintura ni usabilidad real.
- **Fuentes:** [Vitest](https://vitest.dev/guide/), [entornos](https://vitest.dev/guide/environment),
  [act](https://react.dev/reference/react/act), [jsdom 30.1.2](https://github.com/jsdom/jsdom/releases/tag/30.1.2)
  y [requisitos jsdom](https://github.com/jsdom/jsdom/blob/30.1.2/package.json).

## Operación sin conexión y mediciones

- **Decisión:** recursos incluidos en el build; después de cargarlos se garantizan cálculos,
  validaciones y cambios de modo sin red. La aplicación no inicia peticiones ni persiste
  datos del formulario. Sin APIs, CDN ni service worker. No se garantiza primera apertura
  remota ni recarga sin conexión; sin incorporar PWA ni caché persistente.
- **Razón:** el usuario confirmó explícitamente este alcance para FR-015/SC-004.
  Se mantiene el cálculo local y spec.md intacta. La validación offline empieza una vez
  completada la carga inicial de recursos, y conserva todos los mensajes y reglas del formulario.
- **Alternativas:** backend viola el alcance; PWA añade infraestructura no solicitada.
- **Fuente:** [build/preview Vite](https://vite.dev/guide/static-deploy.html).

Validación prevista: cargar el build, activar Offline sin recargar y ejecutar A1–A7,
incluyendo entradas inválidas y cambios entre ambos modos. Comprobar los mismos resultados,
mensajes y limpieza de salida al editar, con cero peticiones y sin persistencia del formulario.

SC-003 se mide desde submit hasta resultado visible en navegador build (<1 s).
SC-002 requiere un primer uso cronometrado (<30 s). Se documenta la comprobación manual;
los tests jsdom no bastan para afirmar esos resultados. No quedan decisiones pendientes.
