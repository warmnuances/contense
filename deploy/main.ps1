# Use file hash
# No timestamp in hash in case so you can skip file rebuild if file does not change

# No validation if file exists or property
param (
  ### Files ###
  [string]$sshPublicKeyPath = "~/.ssh/id_rsa.pub",
  # Create resource at the subscription level
  [string]$initFile = "init.bicep",
  # Create resource at the resource group level
  [string]$file = "main.bicep",
  # Read from a parameters file. Parameters take precedence
  [string]$paramUrl = "rg.parameters.local.json",

  # Bad Practice to have 1 password for everything but easier administration 
  [String]$adminPassword = "",

  ### Arguments ###

  # All resource will have this prefix. E.g. rg-contense, vm-contense,
  [string]$prefix = "contense",
  [string]$location = "australiaeast",
  [string]$hashingAlgorithm = "md5"
)

# Load Powershell functions
. "$PSScriptRoot\helper.ps1"

Write-Host "--- Running Script"

# Generate a new random password and output a local file containing the password
if($adminPassword -eq "") {
  $adminPassword = New-RandomPassword
  CreatePasswordFileIfNotExists -content  $adminPassword
}

# Parse
$sshPublicKey = Get-Content $sshPublicKeyPath


# Parse Template file
$params = Get-Content $paramUrl | Out-String | ConvertFrom-Json


# Override parameters
if(HasProperty $params "prefix") {
  $prefix = $params.prefix
}

if(HasProperty $params "location") {
  $location = $params.location
}


# # PS Vars
$fileName = [System.IO.Path]::GetFileNameWithoutExtension($file) 
$hash = Get-FileHash -Path $file -Algorithm $hashingAlgorithm | Select-Object -expand Hash

$initFileName = [System.IO.Path]::GetFileNameWithoutExtension($initFile) 
$hash = Get-FileHash -Path $file -Algorithm $hashingAlgorithm | Select-Object -expand Hash

# # Azure Vars
$rg = "rg-$prefix"

$rgList = az group list --query "[?name=='rg-$($prefix)']" --output json | ConvertFrom-Json


### Azure Deployment ###

if(!$rgList.Count -gt 0) {
  Write-Host "No resource group found in subscription. Creating... " -ForeGroundColor Red
  az deployment sub create --template-file $initFile --location $location  --name "$($initFileName)-$($hash)" --parameters `@subs.parameters.local.json
}

# Deployment name has a limit of 64 char
# --mode Complete ensures resources are deleted if not present in bicep
az deployment group create -g $rg --template-file $file --name "$($fileName)-$($hash)" --mode Complete `
  --parameters `@rg.parameters.local.json --parameters sshPublicKey=$sshPublicKey -c



Write-Host "--- End Script"