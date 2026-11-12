import csv
import hashlib
import json
from collections import defaultdict
from pathlib import Path

base = Path(__file__).resolve().parent
p = base / 'logs_sinteticos.csv'
groups = defaultdict(list)
rows = list(csv.DictReader(p.open(newline='')))
for n, r in enumerate(rows, 2):
    groups[tuple(r.items())].append(n)
results = {'grupos_lineas_duplicadas': [ns for ns in groups.values() if len(ns) > 1], 'registros_unicos_totales': len(groups)}
failed = [r for r in rows if r['ip'] == '198.51.100.77' and r['event'] == 'login' and r['result'] == 'failed']
results['fallos_admin_registros'] = len(failed)
results['fallos_admin_registros_unicos'] = len({tuple(r.items()) for r in failed})
results['sha256_despues'] = hashlib.sha256(p.read_bytes()).hexdigest()
out = json.dumps(results, ensure_ascii=False, indent=2) + '\n'
(base / 'duplicados.txt').write_text(out)
print(out, end='')
