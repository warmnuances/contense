// Default
param location string = resourceGroup().location
param prefix string = 'default'


param sshPublicKey string

module vnetMod 'module/vnet/hubvnet.bicep' = {
  name: 'vnetMod'
  params: {
    vnetName: 'vnet-${prefix}'
    location: location
  }
}

module dbvnetMod 'module/vnet/dbvnet.bicep' = {
  name: 'dbvnetMod'
  params: {
    vnetName: 'vnet-db-${prefix}'
    location: location
  }
}

module privateDNSZoneMod 'module/vnet/privatednszone.bicep' = {
  name: 'privateDNSZoneMod'
  params: {
    vnetId: vnetMod.outputs.results.vnetId
    privateDnsZoneName: '${prefix}.internal'
  }
}

// Need more granular controls. Right now grants contributor
module userMIContributorMod 'module/governance/mi-contributor.bicep' = {
  name: 'userMIContributorMod'
  params: {
    location: location
    managedIdentityName: 'userMI${prefix}'
  }
}

module keyVaultMod 'module/keyvault.bicep' = {
  dependsOn: [
    userMIContributorMod
  ]
  name: 'keyVaultMod'
  params: {
    keyVaultName: 'kv-${prefix}'
    location:location
  }
}

module peKeyVaultMod 'module/vnet/privateendpoint.bicep' = {
  dependsOn: [
    vnetMod
  ]
  name: 'peKeyVaultMod'
  params:{
    location: location
    snetId: vnetMod.outputs.results.subnetEndpointsId
    privateDnsZoneId: privateDNSZoneMod.outputs.results.privateDNSZoneId
    serviceId: keyVaultMod.outputs.results.keyVaultId
    groupIds: [
      'vault'
    ]
  }
}

module linuxDevBoxMod 'module/compute/linuxDevBox.bicep' = {
  name: 'linuxDevBoxMod'
  dependsOn: [
    vnetMod
    dbvnetMod
    userMIContributorMod
  ]
  params: {
    vmName: 'vm-${prefix}'
    location: location
    subnetId: vnetMod.outputs.results.subnetManagementId
    sshKey: sshPublicKey
    userManagedIdentity: {
       '${userMIContributorMod.outputs.results.managedIdentityResourceId}': {}
    }
  }
}


module acrMod 'module/acr.bicep' = {
  name: 'acrMod'
  dependsOn: [
    vnetMod
    privateDNSZoneMod
  ]
  params: {
    acrName: 'acr${prefix}'
    location: location
  }
}

module containerAppsMod 'module/compute/containerapps.bicep' = {
  name: 'containerAppsMod'
  dependsOn: [
    vnetMod
    privateDNSZoneMod
  ]
  params: {
    location: location
  }
}


output results object = {
  sshPublicKey: sshPublicKey
  mi: userMIContributorMod.outputs.results.managedIdentityResourceId
  rgId: resourceGroup().id
}
