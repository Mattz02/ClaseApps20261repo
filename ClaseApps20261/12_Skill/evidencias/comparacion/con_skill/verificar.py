import csv, json, hashlib, re
from pathlib import Path
from datetime import datetime
with Path('logs_sinteticos.csv').open(encoding='utf-8-sig',newline='') as f:
    original={n:r for n,r in enumerate(csv.DictReader(f),2)}
def dt(n): return datetime.fromisoformat(original[n]['timestamp'])
def check_rows(numbers,event,result,ip,user=None):
    return all(original[n]['event']==event and original[n]['result']==result and original[n]['ip']==ip and (user is None or original[n]['user']==user) for n in numbers)
fails=[17,19,20,22,23,25,26,27]
spray=[67,68,70,71,73,74]
assert check_rows(fails,'login','failed','198.51.100.77','admin')
assert len(fails)==8 and (dt(27)-dt(17)).total_seconds()==240
assert check_rows([28],'login','success','198.51.100.77','admin')
assert (dt(28)-dt(27)).total_seconds()==60
assert check_rows(spray,'login','failed','203.0.113.89')
assert len({original[n]['user'] for n in spray})==6 and (dt(74)-dt(67)).total_seconds()==120
assert 'token=' in original[33]['detail']
assert check_rows([59],'role_change','success','203.0.113.42','guest')
# Segunda comprobación, con tokens separados por espacio según el delimitador observado.
approvals=[v.split('=',1)[1] for v in original[59]['detail'].split() if v.startswith('approved=')]
assert approvals==['false']
assert check_rows([38,39,41],'login','failed','192.0.2.25','maria')
assert check_rows([42],'login','success','192.0.2.25','maria')
health=[78,80,81,82,83,84]
assert check_rows(health,'healthcheck','success','192.0.2.200','healthbot')
assert all('token=' not in original[n]['detail'] for n in health)
keys=lambda n: tuple(original[n][k] for k in ('timestamp','ip','user','event','result','detail'))
assert all(keys(a)==keys(b) for a,b in [(19,20),(22,23),(25,26)])
unique_count=len({keys(n) for n in fails})
assert unique_count==5
sha_after=hashlib.sha256(Path('logs_sinteticos.csv').read_bytes()).hexdigest()
sha_before=json.loads(Path('validacion.json').read_text())['sha256_antes']
assert sha_after==sha_before
result={'verificacion':'Todas las aserciones ejecutadas pasaron, contra una nueva lectura del CSV original','R1':{'filas':fails,'registros':8,'duracion_segundos':240,'exito_fila':28,'exito_delta_segundos':60,'combinaciones_completas_distintas':unique_count},'R2':{'filas':spray,'usuarios_distintos':6,'duracion_segundos':120},'R3':{'fila':33,'marcador':'token=[REDACTED]'},'R4':{'fila':59,'atributo':'approved=false','cantidad_atributos_approved':len(approvals)},'bajo_umbral':{'fallos':[38,39,41],'conteo':3,'segundos':(dt(41)-dt(38)).total_seconds(),'exito':42},'healthchecks':health,'sha256_despues':sha_after,'csv_sin_cambios':True}
Path('verificacion.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print(json.dumps(result,ensure_ascii=False,indent=2))
