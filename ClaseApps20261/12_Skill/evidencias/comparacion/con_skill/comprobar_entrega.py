from pathlib import Path
import csv, re, hashlib, json
artifacts=['informe.md','traza.md','validar.py','analizar.py','verificar.py','documentar_traza.py','comprobar_entrega.py','validacion.json','resultados.json','evidencia_enmascarada.json','verificacion.json']
assert all(Path(n).is_file() and Path(n).stat().st_size>0 for n in artifacts)
with Path('logs_sinteticos.csv').open(encoding='utf-8-sig',newline='') as f:
    rows=list(csv.DictReader(f))
values=[m.group(1) for r in rows for m in re.finditer(r'token=([^\s;,]+)',r['detail'])]
leaks=[n for n in artifacts if any(v and v in Path(n).read_text() for v in values)]
assert not leaks, 'La entrega contiene una coincidencia con un valor sensible; salida omitida.'
sha=hashlib.sha256(Path('logs_sinteticos.csv').read_bytes()).hexdigest()
assert sha==json.loads(Path('validacion.json').read_text())['sha256_antes']
result={'archivos_comprobados':len(artifacts),'valores_token_en_archivos_derivados':False,'sha256_final':sha,'csv_sin_cambios':True}
output=json.dumps(result,ensure_ascii=False,indent=2)
with Path('traza.md').open('a',encoding='utf-8') as f:
    f.write('\nComprobación final de entrega ejecutada: `python3 comprobar_entrega.py`. Leyó el CSV y los 11 archivos derivados enumerados en el script; verificó existencia, ausencia de los valores extraídos tras el marcador de token y hash final. Este control es específico de dichos valores, no una garantía universal de detección de secretos. Salida real de la herramienta:\n\n```json\n'+output+'\n```\n')
print(output)
