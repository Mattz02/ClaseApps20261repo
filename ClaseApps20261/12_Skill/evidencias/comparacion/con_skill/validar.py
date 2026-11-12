import csv, hashlib, json
from pathlib import Path
from datetime import datetime
p=Path('logs_sinteticos.csv')
b=p.read_bytes()
sha=hashlib.sha256(b).hexdigest()
text=b.decode('utf-8-sig')
required=['timestamp','ip','user','event','result','detail']
with p.open(encoding='utf-8-sig',newline='') as f:
    reader=csv.DictReader(f)
    header=reader.fieldnames
    count=0; invalid_dates=[]; multiline=[]; malformed=[]
    previous=reader.line_num
    for rownum,r in enumerate(reader,2):
        count+=1
        if reader.line_num-previous>1: multiline.append({'fila':rownum,'inicio':previous+1,'fin':reader.line_num})
        previous=reader.line_num
        if None in r or any(v is None for v in r.values()): malformed.append(rownum)
        try: datetime.fromisoformat(r['timestamp'].replace('Z','+00:00'))
        except (ValueError,KeyError,AttributeError): invalid_dates.append(rownum)
result={'archivo':str(p),'sha256_antes':sha,'codificacion':'UTF-8 válida (lector utf-8-sig)','delimitador':',','columnas_requeridas_presentes':[x for x in required if x in header],'columnas_adicionales':len(set(header)-set(required)),'registros':count,'fechas_invalidas':invalid_dates,'registros_multilinea':multiline,'registros_malformados':malformed}
Path('validacion.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,ensure_ascii=False,indent=2))
