# Tesorería Backend — Guía de Implementación

Documento con todo lo realizado: estructura del proyecto, archivos creados, configuración, instalación, ejecución y verificación del backend de tesorería (FastAPI + Gemini OCR + Supabase).

---

## 1. Estructura del Proyecto

Se creó la carpeta `tesoreria-backend/` en la ruta:

```
C:\Users\User\Music\proyectos\tesoreria-backend\
```

Contenido final:

```
tesoreria-backend/
│
├── main.py              # Server FastAPI con endpoints
├── requirements.txt     # Dependencias de Python
├── Dockerfile           # Imagen para Render/Docker
├── .env                 # Credenciales (NO subir a git)
├── start_server.bat     # Script para iniciar el servidor en Windows
└── uvicorn.log          # Log de salida del servidor
    uvicorn_err.log      # Log de errores del servidor
```

---

## 2. Archivos Creados

### 2.1 `.env`

Variables de entorno con las credenciales.

```env
GEMINI_API_KEY=AQ.Ab8RN6Ko-_Ct4VGvdIomUQq354sWnqdNHLXizR44Z5wksyanqA

SUPABASE_URL=https://zabtzdjtkymqmddutbtg.supabase.co

SUPABASE_ANON_KEY=sb_publishable_54t_bJlB-HyzBHM4v-opNg_VqO4UaZl

DATABASE_URL=postgresql://postgres:CamilaEsLaLider123456789%40@db.zabtzdjtkymqmddutbtg.supabase.co:5432/postgres
```

> **Importante:** El `@` de la contraseña se codificó como `%40` porque dentro de una URL de conexión el `@` es el separador del host.

> **Seguridad:** Este archivo contiene credenciales. No debe subirse a repositorios (agregar a `.gitignore`).

### 2.2 `requirements.txt`

```txt
fastapi
uvicorn
psycopg2-binary
google-generativeai
python-multipart
python-dotenv
```

### 2.3 `main.py`

Server de FastAPI con:

- **CORS habilitado** (origen `*`) para permitir llamadas desde Cloudflare Pages o local.
- **`GET /`** → verifica que la API responda (`{"status": "ok"}`).
- **`GET /transacciones`** → consulta todos los movimientos de la tabla `transacciones`, ordenados por fecha desc.
- **`POST /escanear-sinpe`** → recibe un screenshot de comprobante SINPE/Transferencia y usa **Gemini 1.5 Flash** para extraer `monto`, `numero_comprobante` y `emisor_o_nota` en JSON.
- **`POST /registrar`** → inserta un movimiento nuevo en Supabase (campos `monto`, `tipo`, `medio_pago`, `numero_comprobante`, `descripcion`, `registrado_por`).

### 2.4 `Dockerfile`

Imagen basada en `python:3.11-slim`, instala dependencias, copia el código y arranca con Uvicorn en el puerto `8080` (compatible con Render).

### 2.5 `start_server.bat`

Script para Windows que posiciona la consola en la carpeta del proyecto y lanza Uvicorn con logs redirigidos a `uvicorn.log` y `uvicorn_err.log`.

```bat
@echo off
cd /d C:\Users\User\Music\proyectos\tesoreria-backend
C:\Users\User\AppData\Local\Programs\Python\Python313\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8080 > uvicorn.log 2> uvicorn_err.log
```

> Nota: Se usa la ruta completa del Python 3.13 (`C:\Users\User\AppData\Local\Programs\Python\Python313\python.exe`) porque el `python` del PATH apuntaba a una instalación de MSYS2 sin Uvicorn.

---

## 3. Instalación

Se instalaron las dependencias con:

```
pip install -r requirements.txt
```

La instalación fue exitosa (FastAPI, psycopg2-binary, google-generativeai 0.8.6, etc.).

---

## 4. Ejecución del Servidor

El servidor se lanzó en segundo plano con `Win32_Process.Create` (para que quede desacoplado de la consola):

```
cmd.exe /c "C:\Users\User\Music\proyectos\tesoreria-backend\start_server.bat"
```

- **PID del proceso `cmd`:** 11740
- **PID del proceso Python (Uvicorn):** 17716
- **Dirección:** `http://127.0.0.1:8080`

---

## 5. Verificación

### 5.1 Endpoint raíz

```
GET http://127.0.0.1:8080/
```

Respuesta:

```json
{
    "status": "ok",
    "mensaje": "API de Tesorería activa y lista"
}
```

### 5.2 Conexión a la base de datos

```
GET http://127.0.0.1:8080/transacciones
```

Respuesta: `OK - 0 transacciones` → la conexión a Supabase/Postgres es exitosa (aún no hay registros).

---

## 6. Endpoints de la API

| Método | Ruta              | Descripción                                                  |
|--------|-------------------|--------------------------------------------------------------|
| GET    | `/`               | Estado de la API                                             |
| GET    | `/transacciones`  | Lista todas las transacciones (más reciente → más antigua)   |
| POST   | `/escanear-sinpe` | Sube screenshot y extrae datos con Gemini (multipart: `file`) |
| POST   | `/registrar`      | Registra un movimiento (multipart: `monto`, `tipo`, `medio_pago`, opcionales `numero_comprobante`, `descripcion`, `registrado_por`) |
| GET    | `/docs`           | Documentación interactiva de FastAPI (Swagger UI)            |

---

## 7. Próximos Pasos

1. Confirmar que la tabla `transacciones` existe en Supabase (SQL Editor) con las columnas:
   - `id` (serial/auto, PK)
   - `fecha` (timestamp, default `now()`)
   - `monto` (numeric/float)
   - `tipo` (text)
   - `medio_pago` (text)
   - `numero_comprobante` (text, nullable)
   - `descripcion` (text, nullable)
   - `registrado_por` (text)

2. Para volver a levantar el servidor en el futuro:
   ```
   cd C:\Users\User\Music\proyectos\tesoreria-backend
   start_server.bat
   ```
   o manualmente:
   ```
   C:\Users\User\AppData\Local\Programs\Python\Python313\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8080 --reload
   ```

3. Despliegue en Render usando el `Dockerfile`.

---

## 8. Advertencia de Seguridad

Durante esta sesión se compartieron y quedaron en `.env` las siguientes credenciales, por lo que **deberían rotarse/regenerarse** si el documento original o esta guía va a circular más allá de tu máquina:

- `GEMINI_API_KEY`
- `SUPABASE_ANON_KEY`
- Contraseña de la base de datos de Supabase