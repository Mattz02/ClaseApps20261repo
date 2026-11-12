# Traza de ejecución

## Alcance real y distinción de fuentes

Directorio de trabajo de todos los comandos: `/tmp/semana12-comparacion-4ma4wpdg/sin_skill`.
Archivo de datos leído: `logs_sinteticos.csv`, mediante lectura de bytes para SHA-256 y `csv.reader`/`csv.DictReader` para el análisis. Los scripts creados y ejecutados fueron `analizar.py`, `verificar.py`, `duplicados.py` y `registrar_traza.py`. Este último leyó las tres salidas generadas para incorporarlas literalmente a esta traza y volvió a leer el CSV para su hash. También se creó `informe.md` mediante un heredoc. No se leyó ningún archivo de tarea fuera del directorio asignado. Python utilizó su biblioteca estándar.

Las secciones rotuladas «salida de herramienta/procedimiento» son resultados efectivamente obtenidos; las rotuladas «observaciones» son interpretación del analista. Los scripts contienen el procedimiento ejecutado, sin valores de secretos. Las salidas enmascaradas se generaron antes de imprimirse.

## 1. Inspección inicial

Comandos ejecutados: `pwd`, `ls -la` y el siguiente bloque Python, en ese orden y con directorio de trabajo explícito:

```python
import csv, hashlib
from pathlib import Path
p=Path('logs_sinteticos.csv')
b=p.read_bytes()
print('sha256:', hashlib.sha256(b).hexdigest())
with p.open(newline='') as f:
 r=csv.reader(f)
 header=next(r)
 print('columns:', header)
 print('rows:',sum(1 for _ in r))
```

Salida de herramienta (fragmentos pertinentes, copiados de la ejecución):

```text
/tmp/semana12-comparacion-4ma4wpdg/sin_skill
-rw-r--r-- 1 mattz mattz 7076 Nov 12 10:33 logs_sinteticos.csv
sha256: 7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8
columns: ['timestamp', 'ip', 'user', 'event', 'result', 'detail']
rows: 93
```

## 2. Lectura enmascarada

Procedimiento ejecutado: se escribió `analizar.py` y se ejecutó `python3 analizar.py`. El script oculta asignaciones en `detail`, credenciales con esquema, cadenas entre comillas y tokens largos antes de producir salida. Conserva los campos de tiempo, IP, usuario, evento y resultado para correlacionar. La máscara inicial es deliberadamente amplia: también oculta metadatos no secretos, comprobados después mediante un vocabulario fijo permitido.

Salida de herramienta/procedimiento, tomada de `salida_enmascarada.txt`:

```text
sha256: 7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8
filas: 93
linea 2: {"timestamp": "2026-11-05T01:01:00-05:00", "ip": "192.0.2.13", "user": "luisa", "event": "login", "result": "success", "detail": "ordinary login"}
linea 3: {"timestamp": "2026-11-05T01:02:00-05:00", "ip": "192.0.2.11", "user": "sofia", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 4: {"timestamp": "2026-11-05T01:03:00-05:00", "ip": "192.0.2.10", "user": "sofia", "event": "login", "result": "success", "detail": "ordinary login"}
linea 5: {"timestamp": "2026-11-05T01:03:00-05:00", "ip": "192.0.2.13", "user": "carlos", "event": "login", "result": "success", "detail": "ordinary login"}
linea 6: {"timestamp": "2026-11-05T01:04:00-05:00", "ip": "192.0.2.13", "user": "ana", "event": "login", "result": "success", "detail": "ordinary login"}
linea 7: {"timestamp": "2026-11-05T01:05:00-05:00", "ip": "192.0.2.12", "user": "luisa", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 8: {"timestamp": "2026-11-05T01:06:00-05:00", "ip": "192.0.2.13", "user": "carlos", "event": "login", "result": "success", "detail": "ordinary login"}
linea 9: {"timestamp": "2026-11-05T01:07:00-05:00", "ip": "192.0.2.11", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 10: {"timestamp": "2026-11-05T01:07:00-05:00", "ip": "192.0.2.12", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 11: {"timestamp": "2026-11-05T01:09:00-05:00", "ip": "192.0.2.12", "user": "diego", "event": "login", "result": "success", "detail": "ordinary login"}
linea 12: {"timestamp": "2026-11-05T01:10:00-05:00", "ip": "192.0.2.12", "user": "carlos", "event": "login", "result": "success", "detail": "ordinary login"}
linea 13: {"timestamp": "2026-11-05T01:11:00-05:00", "ip": "192.0.2.10", "user": "ana", "event": "login", "result": "success", "detail": "ordinary login"}
linea 14: {"timestamp": "2026-11-05T01:12:00-05:00", "ip": "192.0.2.10", "user": "carlos", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 15: {"timestamp": "2026-11-05T01:13:00-05:00", "ip": "192.0.2.12", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 16: {"timestamp": "2026-11-05T01:14:00-05:00", "ip": "192.0.2.11", "user": "luisa", "event": "login", "result": "success", "detail": "ordinary login"}
linea 17: {"timestamp": "2026-11-05T01:14:00-05:00", "ip": "198.51.100.77", "user": "admin", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 18: {"timestamp": "2026-11-05T01:15:00-05:00", "ip": "192.0.2.13", "user": "carlos", "event": "login", "result": "success", "detail": "ordinary login"}
linea 19: {"timestamp": "2026-11-05T01:15:00-05:00", "ip": "198.51.100.77", "user": "admin", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 20: {"timestamp": "2026-11-05T01:15:00-05:00", "ip": "198.51.100.77", "user": "admin", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 21: {"timestamp": "2026-11-05T01:16:00-05:00", "ip": "192.0.2.12", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 22: {"timestamp": "2026-11-05T01:16:00-05:00", "ip": "198.51.100.77", "user": "admin", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 23: {"timestamp": "2026-11-05T01:16:00-05:00", "ip": "198.51.100.77", "user": "admin", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 24: {"timestamp": "2026-11-05T01:17:00-05:00", "ip": "192.0.2.12", "user": "maria", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 25: {"timestamp": "2026-11-05T01:17:00-05:00", "ip": "198.51.100.77", "user": "admin", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 26: {"timestamp": "2026-11-05T01:17:00-05:00", "ip": "198.51.100.77", "user": "admin", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 27: {"timestamp": "2026-11-05T01:18:00-05:00", "ip": "198.51.100.77", "user": "admin", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 28: {"timestamp": "2026-11-05T01:19:00-05:00", "ip": "198.51.100.77", "user": "admin", "event": "login", "result": "success", "detail": "login after multiple failures"}
linea 29: {"timestamp": "2026-11-05T01:20:00-05:00", "ip": "192.0.2.12", "user": "diego", "event": "login", "result": "success", "detail": "ordinary login"}
linea 30: {"timestamp": "2026-11-05T01:21:00-05:00", "ip": "192.0.2.12", "user": "diego", "event": "login", "result": "success", "detail": "ordinary login"}
linea 31: {"timestamp": "2026-11-05T01:25:00-05:00", "ip": "192.0.2.12", "user": "maria", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 32: {"timestamp": "2026-11-05T01:27:00-05:00", "ip": "192.0.2.12", "user": "sofia", "event": "login", "result": "success", "detail": "ordinary login"}
linea 33: {"timestamp": "2026-11-05T01:27:00-05:00", "ip": "192.0.2.44", "user": "api_service", "event": "debug", "result": "warning", "detail": "token=[VALOR_OCULTO]; debug output"}
linea 34: {"timestamp": "2026-11-05T01:28:00-05:00", "ip": "192.0.2.10", "user": "maria", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 35: {"timestamp": "2026-11-05T01:29:00-05:00", "ip": "192.0.2.13", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 36: {"timestamp": "2026-11-05T01:30:00-05:00", "ip": "192.0.2.13", "user": "carlos", "event": "login", "result": "success", "detail": "ordinary login"}
linea 37: {"timestamp": "2026-11-05T01:34:00-05:00", "ip": "192.0.2.13", "user": "sofia", "event": "login", "result": "success", "detail": "ordinary login"}
linea 38: {"timestamp": "2026-11-05T01:35:00-05:00", "ip": "192.0.2.25", "user": "maria", "event": "login", "result": "failed", "detail": "mistyped password"}
linea 39: {"timestamp": "2026-11-05T01:36:00-05:00", "ip": "192.0.2.25", "user": "maria", "event": "login", "result": "failed", "detail": "mistyped password"}
linea 40: {"timestamp": "2026-11-05T01:37:00-05:00", "ip": "192.0.2.11", "user": "carlos", "event": "login", "result": "success", "detail": "ordinary login"}
linea 41: {"timestamp": "2026-11-05T01:37:00-05:00", "ip": "192.0.2.25", "user": "maria", "event": "login", "result": "failed", "detail": "mistyped password"}
linea 42: {"timestamp": "2026-11-05T01:38:00-05:00", "ip": "192.0.2.25", "user": "maria", "event": "login", "result": "success", "detail": "legitimate user"}
linea 43: {"timestamp": "2026-11-05T01:39:00-05:00", "ip": "192.0.2.11", "user": "luisa", "event": "login", "result": "success", "detail": "ordinary login"}
linea 44: {"timestamp": "2026-11-05T01:41:00-05:00", "ip": "192.0.2.12", "user": "sofia", "event": "login", "result": "success", "detail": "ordinary login"}
linea 45: {"timestamp": "2026-11-05T01:43:00-05:00", "ip": "192.0.2.11", "user": "carlos", "event": "login", "result": "success", "detail": "ordinary login"}
linea 46: {"timestamp": "2026-11-05T01:43:00-05:00", "ip": "192.0.2.11", "user": "diego", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 47: {"timestamp": "2026-11-05T01:45:00-05:00", "ip": "192.0.2.13", "user": "luisa", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 48: {"timestamp": "2026-11-05T01:46:00-05:00", "ip": "192.0.2.13", "user": "sofia", "event": "login", "result": "success", "detail": "ordinary login"}
linea 49: {"timestamp": "2026-11-05T01:46:00-05:00", "ip": "192.0.2.11", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 50: {"timestamp": "2026-11-05T01:46:00-05:00", "ip": "192.0.2.11", "user": "luisa", "event": "login", "result": "success", "detail": "ordinary login"}
linea 51: {"timestamp": "2026-11-05T01:47:00-05:00", "ip": "192.0.2.12", "user": "carlos", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 52: {"timestamp": "2026-11-05T01:47:00-05:00", "ip": "192.0.2.11", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 53: {"timestamp": "2026-11-05T01:47:00-05:00", "ip": "192.0.2.12", "user": "carlos", "event": "login", "result": "success", "detail": "ordinary login"}
linea 54: {"timestamp": "2026-11-05T01:48:00-05:00", "ip": "192.0.2.12", "user": "ana", "event": "login", "result": "success", "detail": "ordinary login"}
linea 55: {"timestamp": "2026-11-05T01:49:00-05:00", "ip": "192.0.2.10", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 56: {"timestamp": "2026-11-05T01:49:00-05:00", "ip": "192.0.2.11", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 57: {"timestamp": "2026-11-05T01:49:00-05:00", "ip": "203.0.113.42", "user": "guest", "event": "access", "result": "denied", "detail": "resource=[VALOR_OCULTO]"}
linea 58: {"timestamp": "2026-11-05T01:50:00-05:00", "ip": "192.0.2.13", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 59: {"timestamp": "2026-11-05T01:50:00-05:00", "ip": "203.0.113.42", "user": "guest", "event": "role_change", "result": "success", "detail": "role=[VALOR_OCULTO]; approved=[VALOR_OCULTO]"}
linea 60: {"timestamp": "2026-11-05T01:53:00-05:00", "ip": "192.0.2.10", "user": "diego", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 61: {"timestamp": "2026-11-05T01:54:00-05:00", "ip": "192.0.2.10", "user": "diego", "event": "login", "result": "success", "detail": "ordinary login"}
linea 62: {"timestamp": "2026-11-05T01:54:00-05:00", "ip": "192.0.2.13", "user": "ana", "event": "login", "result": "success", "detail": "ordinary login"}
linea 63: {"timestamp": "2026-11-05T01:55:00-05:00", "ip": "192.0.2.10", "user": "ana", "event": "login", "result": "success", "detail": "ordinary login"}
linea 64: {"timestamp": "2026-11-05T01:58:00-05:00", "ip": "192.0.2.11", "user": "sofia", "event": "login", "result": "success", "detail": "ordinary login"}
linea 65: {"timestamp": "2026-11-05T02:00:00-05:00", "ip": "192.0.2.12", "user": "luisa", "event": "login", "result": "success", "detail": "ordinary login"}
linea 66: {"timestamp": "2026-11-05T02:00:00-05:00", "ip": "192.0.2.13", "user": "sofia", "event": "login", "result": "success", "detail": "ordinary login"}
linea 67: {"timestamp": "2026-11-05T02:01:00-05:00", "ip": "203.0.113.89", "user": "ana", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 68: {"timestamp": "2026-11-05T02:01:00-05:00", "ip": "203.0.113.89", "user": "carlos", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 69: {"timestamp": "2026-11-05T02:02:00-05:00", "ip": "192.0.2.10", "user": "carlos", "event": "login", "result": "success", "detail": "ordinary login"}
linea 70: {"timestamp": "2026-11-05T02:02:00-05:00", "ip": "203.0.113.89", "user": "luisa", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 71: {"timestamp": "2026-11-05T02:02:00-05:00", "ip": "203.0.113.89", "user": "diego", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 72: {"timestamp": "2026-11-05T02:03:00-05:00", "ip": "192.0.2.10", "user": "luisa", "event": "login", "result": "success", "detail": "ordinary login"}
linea 73: {"timestamp": "2026-11-05T02:03:00-05:00", "ip": "203.0.113.89", "user": "maria", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 74: {"timestamp": "2026-11-05T02:03:00-05:00", "ip": "203.0.113.89", "user": "sofia", "event": "login", "result": "failed", "detail": "incorrect password"}
linea 75: {"timestamp": "2026-11-05T02:04:00-05:00", "ip": "192.0.2.13", "user": "ana", "event": "login", "result": "success", "detail": "ordinary login"}
linea 76: {"timestamp": "2026-11-05T02:04:00-05:00", "ip": "192.0.2.11", "user": "ana", "event": "login", "result": "success", "detail": "ordinary login"}
linea 77: {"timestamp": "2026-11-05T02:05:00-05:00", "ip": "192.0.2.13", "user": "sofia", "event": "login", "result": "success", "detail": "ordinary login"}
linea 78: {"timestamp": "2026-11-05T02:10:00-05:00", "ip": "192.0.2.200", "user": "healthbot", "event": "healthcheck", "result": "success", "detail": "scheduled monitoring"}
linea 79: {"timestamp": "2026-11-05T02:11:00-05:00", "ip": "192.0.2.10", "user": "carlos", "event": "login", "result": "success", "detail": "ordinary login"}
linea 80: {"timestamp": "2026-11-05T02:11:00-05:00", "ip": "192.0.2.200", "user": "healthbot", "event": "healthcheck", "result": "success", "detail": "scheduled monitoring"}
linea 81: {"timestamp": "2026-11-05T02:12:00-05:00", "ip": "192.0.2.200", "user": "healthbot", "event": "healthcheck", "result": "success", "detail": "scheduled monitoring"}
linea 82: {"timestamp": "2026-11-05T02:13:00-05:00", "ip": "192.0.2.200", "user": "healthbot", "event": "healthcheck", "result": "success", "detail": "scheduled monitoring"}
linea 83: {"timestamp": "2026-11-05T02:14:00-05:00", "ip": "192.0.2.200", "user": "healthbot", "event": "healthcheck", "result": "success", "detail": "scheduled monitoring"}
linea 84: {"timestamp": "2026-11-05T02:15:00-05:00", "ip": "192.0.2.200", "user": "healthbot", "event": "healthcheck", "result": "success", "detail": "scheduled monitoring"}
linea 85: {"timestamp": "2026-11-05T02:17:00-05:00", "ip": "192.0.2.11", "user": "ana", "event": "login", "result": "success", "detail": "ordinary login"}
linea 86: {"timestamp": "2026-11-05T02:21:00-05:00", "ip": "192.0.2.13", "user": "sofia", "event": "login", "result": "success", "detail": "ordinary login"}
linea 87: {"timestamp": "2026-11-05T02:24:00-05:00", "ip": "192.0.2.11", "user": "maria", "event": "login", "result": "failed", "detail": "ordinary login"}
linea 88: {"timestamp": "2026-11-05T02:24:00-05:00", "ip": "192.0.2.11", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 89: {"timestamp": "2026-11-05T02:24:00-05:00", "ip": "192.0.2.13", "user": "sofia", "event": "login", "result": "success", "detail": "ordinary login"}
linea 90: {"timestamp": "2026-11-05T02:25:00-05:00", "ip": "192.0.2.13", "user": "maria", "event": "login", "result": "success", "detail": "ordinary login"}
linea 91: {"timestamp": "2026-11-05T02:27:00-05:00", "ip": "192.0.2.13", "user": "luisa", "event": "login", "result": "success", "detail": "ordinary login"}
linea 92: {"timestamp": "2026-11-05T02:27:00-05:00", "ip": "192.0.2.11", "user": "luisa", "event": "login", "result": "success", "detail": "ordinary login"}
linea 93: {"timestamp": "2026-11-05T02:29:00-05:00", "ip": "192.0.2.10", "user": "luisa", "event": "login", "result": "success", "detail": "ordinary login"}
linea 94: {"timestamp": "2026-11-05T02:29:00-05:00", "ip": "192.0.2.11", "user": "luisa", "event": "login", "result": "success", "detail": "ordinary login"}
```

## 3. Conteos, validaciones y metadatos permitidos

Procedimiento ejecutado: se escribió `verificar.py` y se ejecutó `python3 verificar.py`. Se analizaron fechas, campos, conteos, agrupaciones por IP y coincidencias exactas. Para recuperar el significado de `role`, `approved` y `resource`, el script solo imprime valores que coincidan con una lista fija de metadatos permitidos. Para token imprime únicamente booleanos de presencia, sin longitud, fragmentos o valor. No verifica autenticidad ni vigencia del token.

Salida de herramienta/procedimiento, tomada de `verificacion.txt`:

```text
columnas: ["timestamp", "ip", "user", "event", "result", "detail"]
registros: 93
eventos_resultados: {"login/success": 56, "login/failed": 28, "debug/warning": 1, "access/denied": 1, "role_change/success": 1, "healthcheck/success": 6}
periodo: ["2026-11-05T01:01:00-05:00", "2026-11-05T02:29:00-05:00"]
orden_no_decreciente: true
campos_faltantes_o_extra: 0
duplicados_exactos: 3
grupo 198.51.100.77: {"lineas": [17, 19, 20, 22, 23, 25, 26, 27, 28], "usuarios": ["admin"], "resultados": {"failed": 8, "success": 1}, "inicio": "2026-11-05T01:14:00-05:00", "fin": "2026-11-05T01:19:00-05:00"}
grupo 203.0.113.89: {"lineas": [67, 68, 70, 71, 73, 74], "usuarios": ["ana", "carlos", "diego", "luisa", "maria", "sofia"], "resultados": {"failed": 6}, "inicio": "2026-11-05T02:01:00-05:00", "fin": "2026-11-05T02:03:00-05:00"}
grupo 192.0.2.25: {"lineas": [38, 39, 41, 42], "usuarios": ["maria"], "resultados": {"failed": 3, "success": 1}, "inicio": "2026-11-05T01:35:00-05:00", "fin": "2026-11-05T01:38:00-05:00"}
grupo 192.0.2.200: {"lineas": [78, 80, 81, 82, 83, 84], "usuarios": ["healthbot"], "resultados": {"success": 6}, "inicio": "2026-11-05T02:10:00-05:00", "fin": "2026-11-05T02:15:00-05:00"}
ordinary_login: {"cantidad": 65, "resultados": {"success": 54, "failed": 11}}
credencial_linea_33: {"campo_token_presente": true, "valor_no_vacio": true, "valor_oculto": true}
metadatos_permitidos_linea_57: {"resource": "/admin"}
metadatos_permitidos_linea_59: {"role": "user->admin", "approved": "false"}
sha256_despues: "7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8"
```

Observaciones: el cambio indica `user->admin`, aunque el campo usuario identifica a `guest`. La falta de aprobación está expresada por `approved=false`. El patrón de ocho registros de fallo requiere comprobar duplicados antes de interpretarlo como ocho acciones independientes.

## 4. Comprobación de duplicados

Procedimiento ejecutado: se escribió `duplicados.py` y se ejecutó `python3 duplicados.py`. Se agruparon registros por la igualdad exacta de todos sus campos, preservando sus números de línea. No se eliminaron filas del CSV.

Salida de herramienta/procedimiento, tomada de `duplicados.txt`:

```text
{
  "grupos_lineas_duplicadas": [
    [
      19,
      20
    ],
    [
      22,
      23
    ],
    [
      25,
      26
    ]
  ],
  "registros_unicos_totales": 90,
  "fallos_admin_registros": 8,
  "fallos_admin_registros_unicos": 5,
  "sha256_despues": "7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8"
}
```

Observaciones: hay tres pares idénticos, todos en los fallos contra `admin`. Los ocho registros corresponden a cinco combinaciones distintas de campos; sin ID de evento no se resuelve si hubo reingesta o acciones coincidentes. El informe distingue estos conteos y limita su conclusión a posible acceso indebido.

## 5. Informe y registro

Se escribió `informe.md` con evidencia por línea, fecha, IP, cuenta, tipo de evento y resultado; se separaron hallazgos, explicaciones benignas, limitaciones y acciones sugeridas no ejecutadas. Se escribió y ejecutó `python3 registrar_traza.py` para ensamblar esta traza a partir de las salidas reales guardadas y calcular nuevamente el hash.

Salida del procedimiento de hash al generar esta traza:

```text
sha256_final: 7d8219e9f8c9dd995be0c2dc038f4f7e67f0f12446b4fdc07fadf508befb5da8
```

Tiempo total: no disponible. Tokens consumidos: no disponible. Los tiempos parciales de herramientas no se han interpretado como duración total del análisis.

No se ejecutaron pruebas de credenciales, consultas externas, cambios de permisos ni contención de incidentes. No se consultaron reglas externas, rúbricas o resultados ajenos.
