@minLength(5)
@maxLength(50)
@description('Provide a globally unique name containing alpha numeric characters between 5 and 50 characters')
param acrName string = 'default'

@description('Provide a location for the registry.')
param location string = resourceGroup().location

@description('Provide a tier of your Azure Container Registry.')
param acrSku string = 'Basic'

@description('Provide a tier of your Azure Container Registry.')
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccess string = 'Enabled'

resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
    publicNetworkAccess: publicNetworkAccess
  }
}


output result object = {
  loginServer: acr.properties.loginServer
  acrId: acr.id
}
