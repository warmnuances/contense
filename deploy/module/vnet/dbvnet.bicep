@description('VNet name')
param vnetName string = 'vnet-db-default'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Address prefix')
param vnetAddressPrefix string = '10.1.0.0/16'

param subnetDict object = {
  subnetAzurePg: {
    name: 'snet-service-${substring(vnetName,5)}'
    subnetPrefix: '10.1.0.0/24'
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
        }
      }
    ]
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [for subnet in items(subnetDict): {
      name: subnet.value.name
      properties: {
        addressPrefix: subnet.value.subnetPrefix
        delegations: subnet.value.delegations
      }
    }]
  }
}


resource subnetAzurePg 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  parent: vnet
  name: subnetDict.subnetAzurePg.name
}


var dbPrivateDnsZoneName = 'private.postgres.database.azure.com'

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: dbPrivateDnsZoneName
  // This is a global service
  location: 'global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDNSZone
  name: '${dbPrivateDnsZoneName}-link'
  // This is a global service
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

// This will be used throughout
output results object = {
  azurePgSubnetId: subnetAzurePg.id
  vnetId: vnet.id
  privateDNSZoneId: privateDNSZone.id
}
