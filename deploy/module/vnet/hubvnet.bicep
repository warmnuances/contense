@description('VNet name')
param vnetName string = 'vnet-default'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Address prefix')
param vnetAddressPrefix string = '10.0.0.0/16'

param subnetDict object = {
  subnetEndpoints: {
    name: 'snet-external-${substring(vnetName,5)}'
    subnetPrefix: '10.0.0.0/24'
    delegations: []
  }
  subnetManagement: {
    name: 'snet-management-${substring(vnetName,5)}'
    subnetPrefix: '10.0.252.0/24'
    delegations: []
  }
  subnetGateway: {
    name: 'GatewaySubnet'
    subnetPrefix: '10.0.253.0/27'
    delegations: []
  }
  subnetBastion: {
    // Azure Bastion can only be created in subnet with name 'AzureBastionSubnet'
    name: 'AzureBastionSubnet'
    subnetPrefix: '10.0.254.0/26'
    delegations: []
  }
  subnetFirewall: {
    // Azure Bastion can only be created in subnet with name 'AzureBastionSubnet'
    name: 'AzureFirewall'
    subnetPrefix: '10.0.255.0/26'
    delegations: []
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
        privateEndpointNetworkPolicies: 'Disabled'
      }
    }]
  }
}

resource subnetEndpoints 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  parent: vnet
  name: subnetDict.subnetEndpoints.name
}

resource subnetManagement 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  parent: vnet
  name: subnetDict.subnetManagement.name
}

resource subnetGateway 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  parent: vnet
  name: subnetDict.subnetGateway.name
}

resource subnetFirewall 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  parent: vnet
  name: subnetDict.subnetFirewall.name
}

resource subnetBastion 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  parent: vnet
  name: subnetDict.subnetBastion.name
}

// This will be used throughout
output results object = {
  subnetEndpointsId: subnetEndpoints.id
  subnetGatewayId: subnetGateway.id
  subnetFirewallId: subnetFirewall.id
  subnetBastionId: subnetBastion.id
  subnetManagementId: subnetManagement.id
  vnetId: vnet.id
}
