import csv
import hashlib
import json
import re
from pathlib import Path

BASE = Path(__file__).resolve().parent
CSV = BASE / 'logs_sinteticos.csv'

def mask(text):
    # Se ocultan asignaciones, cadenas entre comillas, credenciales y tokens largos.
    text = re.sub(r'(?i)\b(?:bearer|basic)\s+\S+', '[CREDENCIAL_OCULTA]', text)
    text = re.sub(r'([\w.-]+\s*[=:]\s*)("[^"\n]*"|\x27[^\x27\n]*\x27|[^\s,;]+)', r'\1[VALOR_OCULTO]', text)
    text = re.sub(r'"[^"\n]*"|\x27[^\x27\n]*\x27', '[CADENA_OCULTA]', text)
    text = re.sub(r'(?i)\b(?:password|passwd|pwd|secret|token|api[_-]?key|credential)\s+\S+', '[CREDENCIAL_OCULTA]', text)
    text = re.sub(r'[A-Za-z0-9_+/=.-]{24,}', '[TOKEN_LARGO_OCULTO]', text)
    return text

def main():
    digest = hashlib.sha256(CSV.read_bytes()).hexdigest()
    rows = list(csv.DictReader(CSV.open(newline='')))
    out = [f'sha256: {digest}', f'filas: {len(rows)}']
    for index, row in enumerate(rows, start=2):
        safe = {k: mask(v) if k == 'detail' else v for k, v in row.items()}
        out.append(f'linea {index}: ' + json.dumps(safe, ensure_ascii=False))
    (BASE / 'salida_enmascarada.txt').write_text('\n'.join(out) + '\n')
    print('\n'.join(out))

if __name__ == '__main__':
    main()
