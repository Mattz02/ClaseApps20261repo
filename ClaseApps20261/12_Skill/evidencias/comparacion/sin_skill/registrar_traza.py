from pathlib import Path
import hashlib

base = Path(__file__).resolve().parent
intro = '''# Traza de ejecución

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
'''
parts = [intro, (base / 'salida_enmascarada.txt').read_text(), '''```

## 3. Conteos, validaciones y metadatos permitidos

Procedimiento ejecutado: se escribió `verificar.py` y se ejecutó `python3 verificar.py`. Se analizaron fechas, campos, conteos, agrupaciones por IP y coincidencias exactas. Para recuperar el significado de `role`, `approved` y `resource`, el script solo imprime valores que coincidan con una lista fija de metadatos permitidos. Para token imprime únicamente booleanos de presencia, sin longitud, fragmentos o valor. No verifica autenticidad ni vigencia del token.

Salida de herramienta/procedimiento, tomada de `verificacion.txt`:

```text
''', (base / 'verificacion.txt').read_text(), '''```

Observaciones: el cambio indica `user->admin`, aunque el campo usuario identifica a `guest`. La falta de aprobación está expresada por `approved=false`. El patrón de ocho registros de fallo requiere comprobar duplicados antes de interpretarlo como ocho acciones independientes.

## 4. Comprobación de duplicados

Procedimiento ejecutado: se escribió `duplicados.py` y se ejecutó `python3 duplicados.py`. Se agruparon registros por la igualdad exacta de todos sus campos, preservando sus números de línea. No se eliminaron filas del CSV.

Salida de herramienta/procedimiento, tomada de `duplicados.txt`:

```text
''', (base / 'duplicados.txt').read_text(), '''```

Observaciones: hay tres pares idénticos, todos en los fallos contra `admin`. Los ocho registros corresponden a cinco combinaciones distintas de campos; sin ID de evento no se resuelve si hubo reingesta o acciones coincidentes. El informe distingue estos conteos y limita su conclusión a posible acceso indebido.

## 5. Informe y registro

Se escribió `informe.md` con evidencia por línea, fecha, IP, cuenta, tipo de evento y resultado; se separaron hallazgos, explicaciones benignas, limitaciones y acciones sugeridas no ejecutadas. Se escribió y ejecutó `python3 registrar_traza.py` para ensamblar esta traza a partir de las salidas reales guardadas y calcular nuevamente el hash.

Salida del procedimiento de hash al generar esta traza:

```text
sha256_final: ''', hashlib.sha256((base / 'logs_sinteticos.csv').read_bytes()).hexdigest(), '''
```

Tiempo total: no disponible. Tokens consumidos: no disponible. Los tiempos parciales de herramientas no se han interpretado como duración total del análisis.

No se ejecutaron pruebas de credenciales, consultas externas, cambios de permisos ni contención de incidentes. No se consultaron reglas externas, rúbricas o resultados ajenos.
''']
(base / 'traza.md').write_text(''.join(parts))
print('Creado traza.md a partir de salidas guardadas.')
print('sha256_final:', hashlib.sha256((base / 'logs_sinteticos.csv').read_bytes()).hexdigest())
