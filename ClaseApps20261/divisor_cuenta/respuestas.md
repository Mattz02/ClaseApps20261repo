
## Preguntas

Responde en `respuestas.md`, en la raíz del proyecto. Respuestas cortas, con tus palabras.

1. **Rojo antes de verde.** ¿Qué mensaje de error te mostró `flutter test` en la Parte 2?
   ¿Por qué era importante ver esa prueba fallar **antes** de escribir el código?
La prueba esperaba que la propina no supere el 100% pero recibio una lista de errores vacia, se queria que falle primero para ver que detecte cuando esta mal antes de hacer el codigo para que salga verde

2. **Linter vs. IA.** Nombra un aviso que te mostró `flutter analyze` y un code smell que te
   señaló la IA. ¿Por qué el linter no encontró el code smell?
flutter analyze nunca dio un aviso en mi app, el agente mas que nada menicono cosas como codigo repetido en los TextField, el linter no lo detecta porque es una repeticion que no infringe reglas
3. **Tu refactorización.** ¿Qué code smell elegiste, qué cambió en el código y cómo sabes
   que la app sigue haciendo exactamente lo mismo?
elegi el codigo de interfaz repetido, y se que funciona ya que flutter test paso todas las pruebas sin haber cambiado las pruebas
4. **Coverage.** ¿Qué archivo de `lib/` tiene el porcentaje más bajo? ¿Significa eso que
   ese archivo tiene errores? Explica.
lib/main.dart es el que tiene la cobertura mas baja, esto no significa que haya errores, solo significa que el 85.71% del codigo se esta ejecutando