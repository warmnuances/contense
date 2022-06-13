@description('The vnet to associate this dns zone with')
param vnetId string

@description('The vnet to associate this dns zone with')
param privateDnsZoneName string = 'default.com'

resource privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  // This is a global service
  location: 'global'
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDNSZone
  name: '${privateDnsZoneName}-link'
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
