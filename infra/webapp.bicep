param webAppName string // Web App name is required and will be supplied by the workflow variable (eShopOnWeb-webapp57092839)
param sku string = 'B1' // CHANGED: Setting to Basic (B1) as Free (F1) is sometimes disallowed in favor of B1 in lab policies.
param location string = resourceGroup().location

var appServicePlanName = toLower('AppServicePlan-${webAppName}')

// Resource: App Service Plan (Server Farm)
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  properties: {
    // Required for Linux App Service Plan
    reserved: true 
  }
  sku: {
    name: sku
  }
}

// Resource: Web App (Site)
resource appService 'Microsoft.Web/sites@2022-09-01' = {
  name: webAppName
  kind: 'app'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true // Recommended setting for production apps
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|8.0'
      appSettings: [
        {
          name: 'ASPNETCORE_ENVIRONMENT'
          value: 'Development'
        }
        {
          name: 'UseOnlyInMemoryDatabase'
          value: 'true'
        }
      ]
    }
  }
}

// Optional: Output the default hostname for easy access after deployment
output webAppHostName string = appService.properties.defaultHostName
