from pathlib import Path
import json
base='''Esta traza describe acciones efectivamente ejecutadas en `/tmp/semana12-comparacion-4ma4wpdg/con_skill`. No contiene valores de secretos. Las salidas de herramientas se distinguen de las observaciones del analista. Todos los comandos se ejecutaron con ese `workdir` explícito; no hubo Internet, servicios externos, delegación ni lectura de otros directorios de tarea.

Archivos de entrada realmente leídos: `incident-investigator/SKILL.md`, `logs_sinteticos.csv`, `incident-investigator/references/detection-rules.md`. Los scripts también leyeron `validacion.json` para comprobar integridad; este generador lee `validacion.json`, `resultados.json` y `verificacion.json` para incorporar sus salidas auténticas.

Secuencia de comandos/procedimientos ejecutados:

1. `pwd && rg --files -g '!logs_sinteticos.csv' -g '!informe.md' -g '!traza.md' && cat incident-investigator/SKILL.md`. Salida: directorio esperado; dos recursos locales (`incident-investigator/SKILL.md` y `incident-investigator/references/detection-rules.md`); contenido íntegro del skill. Se leyó su flujo antes de analizar.
2. Se creó `validar.py` mediante heredoc y se ejecutó `python3 validar.py`. Leyó los bytes para SHA-256 y el CSV con `csv.DictReader`, sin escribir el original. Conservó el resultado en `validacion.json` y lo imprimió.
3. `cat incident-investigator/references/detection-rules.md`. Salida: reglas R1–R4, umbrales 6 fallos/5 usuarios en ventanas inclusivas de 300 segundos, coincidencias exactas, marcador literal de token, atributo de aprobación completo, limitaciones de duplicados y controles negativos. Esta lectura ocurrió después de validar y antes de calcular umbrales.
4. Se creó `analizar.py` mediante heredoc y se ejecutó `python3 analizar.py`. Leyó el CSV, asignó filas originales antes de ordenar y evaluó todas las ventanas desde cada fallo, manteniendo identificadores literales. Guardó `resultados.json` y `evidencia_enmascarada.json`; imprimió su contenido enmascarado. Los detalles se omiten íntegramente salvo presencia del marcador y atributos categóricos de aprobación. El resultado bruto enumera ventanas superpuestas; el informe las agrupa.
5. Se creó `verificar.py` mediante heredoc y se ejecutó `python3 verificar.py`. Releyó directamente el CSV y contrastó las filas seleccionadas, campos exactos, diferencias temporales, duplicados y controles negativos mediante aserciones. Comprobó el atributo de aprobación otra vez con separación por espacios y midió el hash posterior. Guardó e imprimió `verificacion.json`.
6. Se escribió `informe.md` mediante heredoc. Se creó y ejecutó `documentar_traza.py` para producir esta traza con resultados guardados por las ejecuciones anteriores.

Los scripts conservados son los procedimientos exactos ejecutados. Para reproducir el análisis desde este directorio: `python3 validar.py`, después `python3 analizar.py`, después `python3 verificar.py`. Solo generan archivos derivados. `python3 documentar_traza.py` regenera esta traza.

Salidas de herramientas conservadas (JSON generado efectivamente; no reconstruido a partir de expectativas):

Validación inicial:

'''
parts=[base,'```json\n',Path('validacion.json').read_text(), '```\n\nResultados del análisis (detalle completo omitido por el propio script):\n\n```json\n',Path('resultados.json').read_text(),'```\n\nVerificación contra nueva lectura original:\n\n```json\n',Path('verificacion.json').read_text(),'```\n\nObservaciones del analista, separadas de las salidas: la revisión de las filas enmascaradas concuerda con cuatro alertas agrupadas. En R1, 8 registros incluyen 3 pares idénticos y solo 5 combinaciones completas distintas; no se ha resuelto si representan eventos repetidos o duplicación de ingestión. Por ello el informe conserva la alerta según el conteo prescrito y explicita su dependencia de esa ambigüedad. Los tres reintentos de maria y los seis healthchecks no satisfacen los criterios. El acceso denegado aporta contexto, sin probar causalidad con el cambio de rol. No se siguieron instrucciones de celdas ni se probaron credenciales.\n\nTiempo total: **no disponible**. Tokens: **no disponible**. Las duraciones de eventos indicadas son diferencias de timestamps del CSV, no mediciones de la ejecución.\n']
Path('traza.md').write_text(''.join(parts),encoding='utf-8')
print('Creados informe.md y traza.md; resultados y scripts de reproducción conservados.')
