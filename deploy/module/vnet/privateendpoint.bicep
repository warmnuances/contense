@description('Name of the private endpoint')
param privateEndpointName string = 'pe-default'

@description('Location for all resources.')
param location string = resourceGroup().location


@description('DNS Zone Id')
param privateDnsZoneId string

@description('Location for all resources.')
param snetId string

@description('The resource id of private link service. E.g. keyvault.id, storageaccount.id')
param serviceId string

@description('The ID(s) of the group(s) obtained from the remote resource that this private endpoint should connect to.')
param groupIds array

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-05-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: snetId
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: serviceId
          groupIds: groupIds
        }
      }
    ]
  }
}

// https://stackoverflow.com/questions/69810938/what-is-azure-private-dns-zone-group
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2020-08-01' = {
  parent: privateEndpoint
  name: 'dnsgroupname'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
