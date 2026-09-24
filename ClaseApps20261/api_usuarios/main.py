import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from supabase import create_client
from dotenv import load_dotenv

load_dotenv()

# clave secreta: esto NUNCA iría dentro de la app Flutter
supabase = create_client(os.environ["SUPABASE_URL"], os.environ["SUPABASE_SECRET"])

app = FastAPI()


class NuevoUsuario(BaseModel):
    correo: str
    clave: str
    nombre: str


@app.post("/usuarios")
def crear_usuario(u: NuevoUsuario):
    try:
        r = supabase.auth.admin.create_user({
            "email": u.correo,
            "password": u.clave,
            "email_confirm": True,
        })
        supabase.table("perfiles").insert({"id": r.user.id, "nombre": u.nombre}).execute()
        return {"ok": True, "id": r.user.id}
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))