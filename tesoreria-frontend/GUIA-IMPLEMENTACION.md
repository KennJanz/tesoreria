# Tesorería Frontend — Guía de Implementación

Documento con todo lo realizado en el frontend del sistema de tesorería. El código original (un solo `index.html` con CSS y JS embebidos) se separó en archivos independientes para mantenerlo ordenado, reutilizable y fácil de desplegar en Cloudflare Pages.

---

## 1. Estructura del Proyecto

Se creó la carpeta `tesoreria-frontend/` en la ruta:

```
C:\Users\User\Music\proyectos\tesoreria-frontend\
```

Contenido final:

```
tesoreria-frontend/
│
├── index.html          # Estructura HTML (markup) de la página
├── css/
│   └── estilos.css     # Estilos propios de la aplicación
└── js/
    └── app.js          # Toda la lógica JavaScript del frontend
```

---

## 2. ¿Qué se hizo?

Se tomó el código original de la interfaz de Control de Tesorería y se dividió en 3 archivos:

| Archivo             | Contenido                                                                 |
|---------------------|---------------------------------------------------------------------------|
| `index.html`        | Todo el markup: dashboard, tarjeta de balance, panel de registro, escáner SINPE, formulario e historial. |
| `css/estilos.css`   | Estilos personalizados (el resto de estilos vienen de Bootstrap vía CDN). |
| `js/app.js`         | Constantes, funciones de carga de transacciones, escaneo con Gemini y guardado de registros. |

No se cambió la funcionalidad: solo se reorganizó el código en archivos separados siguiendo buenas prácticas.

---

## 3. Contenido de cada archivo

### 3.1 `index.html`

- Usa **Bootstrap 5.3** desde CDN (`https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css`).
- Enlaza los archivos locales:
  - `css/estilos.css` (en `<head>`)
  - `js/app.js` (al final de `<body>`)
- Secciones:
  - **Balance General** (`#lblBalance`) — saldo total calculado.
  - **Registrar Movimiento** — tarjeta con escáner de imagen SINPE (`#inputSinpeImg`) + formulario (`#formRegistro`) con tipo, medio de pago, monto, comprobante y detalle.
  - **Historial de Movimientos** — tabla (`#tblCuerpo`) con botón de actualizar.

### 3.2 `css/estilos.css`

Estilos propios mínimos:

```css
.lblBalance-number {
  font-size: 2rem;
}

.table-responsive {
  min-height: 120px;
}
```

El resto del diseño corre por cuenta de las clases de Bootstrap (`.bg-light`, `.card`, `.shadow-sm`, etc.).

### 3.3 `js/app.js`

Contiene toda la lógica:

- **`API_URL`** — constante con la URL del backend:
  ```js
  const API_URL = "https://tesoreria-f5ng.onrender.com";
  ```
- **`cargarTransacciones()`** — consulta `GET /transacciones`, construye las filas de la tabla y calcula el balance (INGRESO suma, EGRESO resta). Se ejecuta al entrar a la página.
- **`procesarImagenSINPE()`** — sube la imagen a `POST /escanear-sinpe`, muestra spinner mientras analiza y rellena automáticamente los campos del formulario con los datos extraídos por Gemini (monto, comprobante, emisor).
- **`guardarRegistro(e)`** — envía el formulario a `POST /registrar` (`FormData`), deshabilita el botón mientras guarda, resetea el formulario y recarga las transacciones.

---

## 4. Configuración del Backend (Importante)

El frontend apunta a un backend desplegado en Render:

```
API_URL = "https://tesoreria-f5ng.onrender.com"
```

Actualmente el backend local levantado en este equipo responde en:

```
http://127.0.0.1:8080
```

> **Si quieres probar el frontend contra el backend local**, cambia en `js/app.js`:
>
> ```js
> const API_URL = "http://127.0.0.1:8080";
> ```

Nota: si abres `index.html` desde el explorador con el backend local, puede bloquearse por **CORS**; el backend ya tiene CORS habilitado con `allow_origins=["*"]`, así que debe funcionar sin problema.

---

## 5. Cómo probar

1. Abrir `index.html` directamente en un navegador (o servir la carpeta con cualquier servidor estático).
2. Al cargar, se llama a `cargarTransacciones()` y se muestra el balance y el historial.
3. Se puede:
   - **Escanear** un screenshot de SINPE Móvil (la IA lo analiza y rellena el formulario).
   - **Registrar manualmente** un movimiento (INGRESO/EGRESO, SINPE/Efectivo/Otro).
4. El botón **Actualizar** recarga el historial.

---

## 6. Próximos Pasos

1. Desplegar la carpeta en **Cloudflare Pages** (arrastrar o conectar el repo; build command vacío, output directory `/` ya que son archivos estáticos).
2. Confirmar que el backend en Render (`https://tesoreria-f5ng.onrender.com`) está activo, o apuntar `API_URL` al backend local en `http://127.0.0.1:8080`.
3. (Opcional) Agregar variable de entorno para `API_URL` en Cloudflare Pages en vez de hardcodearla en `js/app.js`.

---

## 7. Seguridad

- El frontend es estático y **no contiene credenciales**.
- El `API_URL` es público y no expone secretos.
- Recuerda que las credenciales reales (`.env`) viven solo en el backend y no deben subirse a ningún repositorio (ya se agregó el `.gitignore` correspondiente en `tesoreria-backend/`).