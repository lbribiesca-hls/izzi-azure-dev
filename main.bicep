
@description('Nombre del proyecto')
param projectName string = 'izzi-dev'

@description('Región de despliegue')
param location string = resourceGroup().location

@description('SKU de PostgreSQL')
param postgresSku string = 'Standard_B1ms'

@description('Nombre de usuario para PostgreSQL')
param dbAdmin string = 'pgadmin'

@secure()
@description('Password del administrador de PostgreSQL')
param dbPassword string

var vnetName = '${projectName}-vnet'
var appServicePlanName = '${projectName}-plan'
var backendAppName = '${projectName}-backend'
var postgresName = toLower('${projectName}-psql')
var staticWebAppName = '${projectName}-frontend'
var frontDoorName = '${projectName}-fd'
var insightsName = '${projectName}-insights'

// VNet
resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'backend-subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
      {
        name: 'db-subnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}

// Application Insights
resource insights 'Microsoft.Insights/components@2020-02-02' = {
  name: insightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// App Service Plan
resource plan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

// App Service (Backend)
resource backendApp 'Microsoft.Web/sites@2022-03-01' = {
  name: backendAppName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: plan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|7.0'
      appSettings: [
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: insights.properties.InstrumentationKey
        }
      ]
    }
    httpsOnly: true
  }
  dependsOn: [
    plan
    insights
  ]
}

// PostgreSQL Flexible Server
resource postgres 'Microsoft.DBforPostgreSQL/flexibleServers@2023-03-01-preview' = {
  name: postgresName
  location: location
  properties: {
    administratorLogin: dbAdmin
    administratorLoginPassword: dbPassword
    version: '15'
    storage: {
      storageSizeGB: 32
    }
    network: {
      publicNetworkAccess: 'Enabled'
    }
  }
  sku: {
    name: 'Standard_B1ms'
    tier: 'Burstable'
    capacity: 1
    family: 'B'
  }
}

// Static Web App (Frontend)
resource staticWeb 'Microsoft.Web/staticSites@2022-03-01' = {
  name: staticWebAppName
  location: location
  properties: {
    repositoryUrl: 'https://github.com/<your-org>/<your-repo>'
    branch: 'main'
    buildProperties: {
      appLocation: '/'
      outputLocation: '.next'
      apiLocation: ''
    }
  }
}

// Front Door (Frontend Only)
resource frontdoor 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: frontDoorName
  location: location
  sku: {
    name: 'Standard_Microsoft'
  }
  properties: {
    originGroups: [
      {
        name: 'frontend-group'
        properties: {
          origins: [
            {
              name: 'staticWebOrigin'
              properties: {
                hostName: '${staticWeb.name}.azurestaticapps.net'
              }
            }
          ]
        }
      }
    ]
    endpoints: [
      {
        name: '${frontDoorName}-endpoint'
        properties: {
          originGroups: [
            {
              id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Cdn/profiles/${frontDoorName}/originGroups/frontend-group'
            }
          ]
        }
      }
    ]
  }
}
