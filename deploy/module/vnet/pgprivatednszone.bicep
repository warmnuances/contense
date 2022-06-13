@description('The vnet to associate this dns zone with')
param vnetId string

// DNS zone specially for postgres need to register
// Fixed value - https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-networking
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
      id: vnetId
    }
  }
}


output results object = {
  privateDNSZoneId: privateDNSZone.id
}
