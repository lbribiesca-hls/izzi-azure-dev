
# Izzi Azure Dev Deployment

Este proyecto define y despliega una arquitectura base en Azure para un entorno de desarrollo utilizando:

- Frontend (Next.js) en Azure Static Web Apps
- Backend (.NET Core 7) en Azure App Service (Linux)
- Base de datos PostgreSQL con acceso público
- Monitorización con Application Insights
- Exposición del frontend únicamente a través de Azure Front Door

---

## 📁 Estructura del proyecto

```
izzi-azure-dev/
├── main.bicep                          # Plantilla de infraestructura en Azure
└── .github/
    └── workflows/
        ├── deploy-frontend.yml         # CI/CD frontend
        └── deploy-backend.yml          # CI/CD backend
```

---

## 🚀 Requisitos

- Cuenta de Azure activa
- Repositorio en GitHub
- Azure CLI instalado
- Permisos para crear recursos y secretos

---

## 🧱 1. Desplegar infraestructura

1. Inicia sesión en Azure:
   ```bash
   az login
   ```

2. Crea el grupo de recursos:
   ```bash
   az group create --name izzi-dev-rg --location eastus
   ```

3. Despliega la infraestructura usando Bicep:
   ```bash
   az deployment group create \
     --resource-group izzi-dev-rg \
     --template-file main.bicep \
     --parameters dbPassword=<TuPasswordSegura>
   ```

---

## ⚙️ 2. Configurar secrets en GitHub

Ve a tu repositorio en GitHub > Settings > Secrets > Actions y crea los siguientes:

### 🔐 `AZURE_WEBAPP_PUBLISH_PROFILE`

1. Ve al recurso App Service en el portal de Azure
2. Clic en "Get publish profile"
3. Copia el contenido del archivo `.PublishSettings`
4. Pega el contenido como valor del secret

### 🔐 `AZURE_STATIC_WEB_APPS_API_TOKEN`

1. Ve a Static Web Apps > Manage deployment token
2. Copia el token
3. Pega el valor como nuevo secret

---

## 🚀 3. Flujo CI/CD automático

Cada vez que haces push a `main`, se ejecutan:

- `deploy-frontend.yml`: construye y despliega el frontend (`/frontend`)
- `deploy-backend.yml`: construye y despliega el backend (`/backend`)

---

## ✅ Notas

- La base de datos PostgreSQL permite conexión pública para entorno de desarrollo.
- Solo el frontend es accesible vía Azure Front Door.
- Auth0 y otras autenticaciones se integrarán en fases posteriores.

---

