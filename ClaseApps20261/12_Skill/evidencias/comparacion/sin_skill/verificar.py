import csv
import hashlib
import json
import re
from collections import Counter
from datetime import datetime
from pathlib import Path

BASE = Path(__file__).resolve().parent
p = BASE / 'logs_sinteticos.csv'
rows = list(csv.DictReader(p.open(newline='')))
numbered = list(enumerate(rows, 2))
output = []
def emit(label, value):
    output.append(label + ': ' + json.dumps(value, ensure_ascii=False))
emit('columnas', list(rows[0]))
emit('registros', len(rows))
emit('eventos_resultados', dict(Counter(r['event'] + '/' + r['result'] for r in rows)))
times = [datetime.fromisoformat(r['timestamp']) for r in rows]
emit('periodo', [min(times).isoformat(), max(times).isoformat()])
emit('orden_no_decreciente', times == sorted(times))
emit('campos_faltantes_o_extra', sum(None in r or any(v is None or v == '' for v in r.values()) for r in rows))
emit('duplicados_exactos', sum(v - 1 for v in Counter(tuple(r.values()) for r in rows).values()))
for ip in ['198.51.100.77', '203.0.113.89', '192.0.2.25', '192.0.2.200']:
    group = [(n, r) for n, r in numbered if r['ip'] == ip]
    emit('grupo ' + ip, {'lineas': [n for n, r in group], 'usuarios': sorted({r['user'] for n, r in group}), 'resultados': dict(Counter(r['result'] for n, r in group)), 'inicio': group[0][1]['timestamp'], 'fin': group[-1][1]['timestamp']})
ordinary = [r for r in rows if r['detail'] == 'ordinary login']
emit('ordinary_login', {'cantidad':len(ordinary), 'resultados':dict(Counter(r['result'] for r in ordinary))})
# Únicamente vocabulario fijo permitido; nunca se imprimen valores arbitrarios.
for n, r in numbered:
    if r['event'] in ['role_change', 'access']:
        fields = dict(re.findall(r'([\w_]+)\s*=\s*([^;]+)', r['detail']))
        safe = {}
        for k, v in fields.items():
            v = v.strip()
            if k == 'approved':
                safe[k] = v if v in ['true', 'false', 'yes', 'no'] else '[OCULTO]'
            elif k == 'role':
                safe[k] = v if v in ['admin', 'guest', 'user', 'guest->admin', 'guest -> admin', 'user->admin'] else '[OCULTO]'
            elif k == 'resource':
                safe[k] = v if v in ['/admin', 'admin', '/admin/users', '/etc/passwd'] else '[OCULTO]'
        emit('metadatos_permitidos_linea_' + str(n), safe)
    if r['event'] == 'debug':
        token = re.search(r'(?i)\btoken\s*=\s*([^;\s]+)', r['detail'])
        emit('credencial_linea_' + str(n), {'campo_token_presente': token is not None, 'valor_no_vacio': bool(token and token.group(1)), 'valor_oculto': True})
emit('sha256_despues', hashlib.sha256(p.read_bytes()).hexdigest())
text = '\n'.join(output) + '\n'
(BASE / 'verificacion.txt').write_text(text)
print(text, end='')
