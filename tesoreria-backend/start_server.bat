@echo off
cd /d C:\Users\User\Music\proyectos\tesoreria-backend
C:\Users\User\AppData\Local\Programs\Python\Python313\python.exe -m uvicorn main:app --host 0.0.0.0 --port 8080 > uvicorn.log 2> uvicorn_err.log