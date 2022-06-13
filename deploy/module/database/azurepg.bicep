@description('Server Name for Azure database for PostgreSQL')
param serverName string = 'azure-pg-default'

@description('Database administrator login name')
@minLength(1)
param administratorLogin string = 'root-default'

@description('Database administrator password')
@minLength(8)
@secure()
param administratorLoginPassword string

@description('Azure database for PostgreSQL sku name')
param skuName string = 'Standard_B1ms'

@description('Azure database for PostgreSQL Sku Size')
param storageSizeGB int = 32

@description('Azure database for PostgreSQL pricing tier')
@allowed([
  'Burstable'
  'GeneralPurpose'
  'MemoryOptimized'
])
param skuTier string = 'Burstable'

@description('PostgreSQL version')
@allowed([
  '11'
  '12'
  '13'
])
param postgresqlVersion string = '11'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('PostgreSQL Server backup retention days')
param backupRetentionDays int = 7

@description('Geo-Redundant Backup setting')
param geoRedundantBackup string = 'Disabled'

@description('The mode to create a new PostgreSQL server.')
@allowed([
  'Create'
  'Default'
  'PointInTimeRestore'
  'Update'
])
param createMode string = 'Default'

@description('	The HA mode for the server.')
@allowed([
  'Disabled'
  'ZoneRedundant'
])
param haMode string = 'Disabled'
param delegateSubnetId string
param privateDNSZoneId string

resource server 'Microsoft.DBforPostgreSQL/flexibleServers@2021-06-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    version: postgresqlVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    backup: {
      backupRetentionDays: backupRetentionDays
      geoRedundantBackup: geoRedundantBackup
    }
    createMode: createMode
    highAvailability: {
      mode: haMode
    }
    storage: {
      storageSizeGB: storageSizeGB
    }
    network: {
      delegatedSubnetResourceId: delegateSubnetId
      privateDnsZoneArmResourceId: privateDNSZoneId
    }
  }

}
