@description('The name of the managed identity resource.')
param managedIdentityName string = 'userMI-contributor'

@description('The Azure location where the managed identity should be created.')
param location string = resourceGroup().location

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

@description('The resource ID of the user-assigned managed identity.')
var managedIdentityResourceId = managedIdentity.id
@description('The ID of the Azure AD application associated with the managed identity.')
var managedIdentityClientId = managedIdentity.properties.clientId
@description('The ID of the Azure AD service principal associated with the managed identity.')
var managedIdentityPrincipalId = managedIdentity.properties.principalId

// Role IDs: ttps://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles
var roleDefinitionID = 'b24988ac-6180-42a0-ab88-20f7382dd24c'
var roleAssignmentName= guid(managedIdentityName, roleDefinitionID, resourceGroup().id)


resource contributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionID)
    principalId: managedIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

output results object = {
  managedIdentityPrincipalId: managedIdentityPrincipalId
  managedIdentityClientId: managedIdentityClientId
  managedIdentityResourceId: managedIdentityResourceId
}
