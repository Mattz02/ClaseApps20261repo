import csv, hashlib, json, re
from pathlib import Path
from datetime import datetime, timedelta
from collections import defaultdict, Counter
p=Path('logs_sinteticos.csv')
with p.open(encoding='utf-8-sig',newline='') as f:
    rows=[dict(r,fila=n) for n,r in enumerate(csv.DictReader(f),2)]

def safe(v,field):
    patterns={'timestamp':r'[0-9TZ:+. -]+','ip':r'[0-9a-fA-F:.]+','user':r'[a-zA-Z][a-zA-Z0-9_.@-]{0,60}','event':r'[a-z_]{1,40}','result':r'[a-z_]{1,20}'}
    return v if re.fullmatch(patterns[field],v or '') else '[OMITIDO]'

def attrs(d):
    # Solo valores categóricos conocidos se emiten; el detalle completo jamás sale.
    out=[]
    for m in re.finditer(r'(?<![\w])([A-Za-z_][A-Za-z0-9_]*)=([^\s;,]*)',d):
        if m.group(1) in ('approved','not_approved'):
            out.append({'atributo':m.group(1),'valor':m.group(2) if m.group(2) in ('true','false','falsehood') else '[OMITIDO]','delimitador_previo':d[m.start()-1] if m.start()>0 and d[m.start()-1] in ' ;,\n' else ('inicio' if m.start()==0 else 'otro'),'delimitador_siguiente':d[m.end()] if m.end()<len(d) and d[m.end()] in ' ;,\n' else ('fin' if m.end()==len(d) else 'otro')})
    return out

for r in rows:
    r['dt']=datetime.fromisoformat(r['timestamp'].replace('Z','+00:00'))
masked=[]
for r in rows:
    m={k:safe(r[k],k) for k in ('timestamp','ip','user','event','result')}
    m.update(fila=r['fila'],detail='token=[REDACTED]' if 'token=' in r['detail'] else '[OMITIDO]',atributos_aprobacion=attrs(r['detail']))
    masked.append(m)
Path('evidencia_enmascarada.json').write_text(json.dumps(masked,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
ordered=sorted(rows,key=lambda r:(r['dt'],r['fila']))
pairs=defaultdict(list); ips=defaultdict(list)
for r in ordered:
    if r['event']=='login' and r['result']=='failed':
        if r['ip'] and r['user']: pairs[r['ip'],r['user']].append(r)
        if r['ip'] and r['user']: ips[r['ip']].append(r)

def windows(rs,rule):
    out=[]
    for start in rs:
        subset=[r for r in rs if start['dt']<=r['dt']<=start['dt']+timedelta(minutes=5)]
        count=len(subset) if rule=='R1' else len({r['user'] for r in subset})
        if count >= (6 if rule=='R1' else 5):
            item={'inicio':subset[0]['timestamp'],'fin':subset[-1]['timestamp'],'segundos':(subset[-1]['dt']-subset[0]['dt']).total_seconds(),'conteo':count,'filas':[r['fila'] for r in subset]}
            if rule=='R1':
                item['exitos_posteriores']=[{'fila':r['fila'],'timestamp':r['timestamp'],'segundos_desde_ultimo_fallo':(r['dt']-subset[-1]['dt']).total_seconds()} for r in ordered if r['event']=='login' and r['result']=='success' and (r['ip'],r['user'])==(start['ip'],start['user']) and timedelta(0)<r['dt']-subset[-1]['dt']<=timedelta(minutes=5)]
            out.append(item)
    return out
r1=[{'ip':safe(ip,'ip'),'user':safe(user,'user'),'ventanas':windows(rs,'R1')} for (ip,user),rs in pairs.items()]
r2=[{'ip':safe(ip,'ip'),'ventanas':windows(rs,'R2')} for ip,rs in ips.items()]
rawkeys=[tuple(r[k] for k in ('timestamp','ip','user','event','result','detail')) for r in rows]
duplicates=[[rows[i]['fila'] for i,k in enumerate(rawkeys) if k==key] for key,count in Counter(rawkeys).items() if count>1]
result={'cobertura':{'inicio':ordered[0]['timestamp'],'fin':ordered[-1]['timestamp'],'zonas':sorted({str(r['dt'].tzinfo) for r in rows}),'orden_original_cronologico':all(rows[i]['dt']<=rows[i+1]['dt'] for i in range(len(rows)-1)),'identidades_ausentes':[r['fila'] for r in rows if not r['ip'] or not r['user']],'duplicados_exactos':duplicates},'R1':r1,'R2':r2,'R3_filas':[r['fila'] for r in rows if 'token=' in r['detail']],'role_change':[m for m in masked if m['event']=='role_change'],'conteos_evento_resultado':[{'event':safe(e,'event'),'result':safe(s,'result'),'conteo':n} for (e,s),n in Counter((r['event'],r['result']) for r in rows).items()]}
Path('resultados.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,ensure_ascii=False,indent=2))
print('EVIDENCIA POR FILA (detalle completo omitido)')
for m in masked: print(json.dumps(m,ensure_ascii=False))
