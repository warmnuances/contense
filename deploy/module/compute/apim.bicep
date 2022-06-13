@description('Prefix to be appended to the name of the resource')
param apimName string = 'apim-default'

@description('The email address of the owner of the service')
@minLength(1)
param publisherEmail string

@description('The name of the owner of the service')
@minLength(1)
param publisherName string

@description('The pricing tier of this API Management service')
@allowed([
  'Developer'
  'Standard'
  'Premium'
  'Consumption'
])
param sku string = 'Consumption'

@description('The instance size of this API Management service.')
@allowed([
  1
  2
])
param skuCount int = 1

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Place APIM in a VNET. External for exposing public endpoint, Internal for use in vnet only')
@allowed([
  'External'
  'Internal'
  'None'
])
param virtualNetworkType string = 'External'

@description('SubnetId to deploy')
param subnetId string

resource apiManagementService 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apimName
  location: location
  sku: {
    name: sku
    capacity: skuCount
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: {
      subnetResourceId: subnetId
    }
  }
}
