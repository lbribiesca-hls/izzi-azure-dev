
# 🛠️ Guía completa de despliegue en Azure para principiantes  
## Proyecto: `izzi-azure-dev`

Esta guía te enseña a desplegar una arquitectura completa en Azure para un entorno de desarrollo, utilizando código fuente desde GitHub y automatización con GitHub Actions.

---

## 🎯 ¿Qué vamos a lograr?

✅ Infraestructura en Azure con Bicep  
✅ Base de datos PostgreSQL accesible desde tu equipo  
✅ Backend en .NET Core en Azure App Service  
✅ Frontend en Next.js en Azure Static Web Apps  
✅ Automatización con GitHub Actions  
✅ Acceso al frontend solo desde Azure Front Door  

---

## 📋 Paso 0: Requisitos previos

Antes de comenzar, asegúrate de tener:

### En tu máquina:
- ✅ Cuenta en [Azure](https://portal.azure.com/)
- ✅ Cuenta en [GitHub](https://github.com/)
- ✅ Azure CLI instalada → https://learn.microsoft.com/es-es/cli/azure/install-azure-cli
- ✅ Git instalado → https://git-scm.com/
- ✅ Editor de código como VS Code

---

## 🧱 Paso 1: Clonar y preparar el repositorio

Clona el proyecto base que descargaste:

```bash
git clone https://github.com/<TU_USUARIO>/izzi-azure-dev.git
cd izzi-azure-dev
```

Verifica que el archivo `main.bicep` y las carpetas de workflows estén en su lugar:

```
izzi-azure-dev/
├── main.bicep
└── .github/
    └── workflows/
```

---

## 🔐 Paso 2: Iniciar sesión en Azure

1. Abre tu terminal y ejecuta:

```bash
az login
```

Se abrirá una ventana del navegador para iniciar sesión.

---

## 📦 Paso 3: Crear grupo de recursos

Todos los servicios de Azure se agrupan dentro de un "Resource Group".

```bash
az group create --name izzi-dev-rg --location eastus
```

> Puedes cambiar `eastus` por otra región como `westeurope` si lo prefieres.

---

## 🏗️ Paso 4: Desplegar la infraestructura

```bash
az deployment group create \
  --resource-group izzi-dev-rg \
  --template-file main.bicep \
  --parameters dbPassword=TuPasswordSegura123!
```

---

## 🌐 Paso 5: Configurar secrets en GitHub

Sube este código a tu repositorio personal:

```bash
git remote set-url origin https://github.com/<TU_USUARIO>/<TU_REPO>.git
git push -u origin main
```

Luego ve a **Settings > Secrets and variables > Actions > New repository secret** y crea los siguientes:

---

### 🔐 `AZURE_WEBAPP_PUBLISH_PROFILE`

1. Entra a tu recurso **App Service** en Azure  
2. Clic en "Get publish profile"  
3. Abre el archivo `.PublishSettings` con un editor de texto  
4. Copia todo el contenido  
5. Pégalo como valor del secret `AZURE_WEBAPP_PUBLISH_PROFILE`

---

### 🔐 `AZURE_STATIC_WEB_APPS_API_TOKEN`

1. Entra al recurso **Static Web App** en Azure  
2. Busca "Manage deployment token"  
3. Copia el token  
4. Guárdalo como secret en GitHub con el nombre `AZURE_STATIC_WEB_APPS_API_TOKEN`

---

## 🚀 Paso 6: Activar despliegue automático (CI/CD)

Cada vez que haces `git push` a la rama `main`, se ejecutará:

- 🏗️ `deploy-frontend.yml` → construye y publica el frontend (`/frontend`)
- ⚙️ `deploy-backend.yml` → construye y publica el backend (`/backend`)

---

## 🧪 Paso 7: Probar el sistema

1. Ingresa a tu Static Web App desde el portal de Azure  
2. Copia el dominio `.azurestaticapps.net`  
3. Valida que se esté mostrando tu frontend  
4. Desde el frontend, asegúrate que la API se conecta al backend correctamente

---

## 📚 Recursos adicionales

- [Azure App Service](https://learn.microsoft.com/en-us/azure/app-service/)
- [Static Web Apps](https://learn.microsoft.com/en-us/azure/static-web-apps/)
- [PostgreSQL en Azure](https://learn.microsoft.com/en-us/azure/postgresql/)

---
