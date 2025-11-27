param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name
param sku string = 'F1' // The App Service Plan SKU. Changed default from 'S1' to 'F1' (Free) to resolve common policy violations in lab environments.
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
