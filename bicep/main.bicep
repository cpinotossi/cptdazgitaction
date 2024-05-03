param storageName string
param principalId string // ObjectID of the service principal
param location string

resource stg 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

var builtInRoleNames = {
  'Storage Blob Data Contributor': tenantResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
}

resource raSP2Storage 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageName,'serviceprincipal2storage','Storage Blob Data Contributor')
  properties: {
    roleDefinitionId: builtInRoleNames['Storage Blob Data Contributor']
    principalId: principalId
  }
  scope: resourceGroup()
}

output storageEndpoint object = stg.properties.primaryEndpoints
