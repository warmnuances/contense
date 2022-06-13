function HasProperty($object, $propertyName)
{
  [bool]$object.PSObject.Properties[$propertyName]
}

function New-RandomPassword {
  param(
      [ValidateRange(12, 256)]
      [int] 
      $length = 14
  )
  $symbols = '!@#$%^&*'.ToCharArray()
  $characterList = 'a'..'z' + 'A'..'Z' + '0'..'9' + $symbols

  do {
      $password = -join (0..$length | % { $characterList | Get-Random })
      [int]$hasLowerChar = $password -cmatch '[a-z]'
      [int]$hasUpperChar = $password -cmatch '[A-Z]'
      [int]$hasDigit = $password -match '[0-9]'
      [int]$hasSymbol = $password.IndexOfAny($symbols) -ne -1

  }
  until (($hasLowerChar + $hasUpperChar + $hasDigit + $hasSymbol) -ge 3)

  $password

}

function CreatePasswordFileIfNotExists {
  param(
    [string] $credentialPath = "$(Get-Location)\credentials.txt",
    [string] $content 
  )

  if (-not(Test-Path -Path $credentialPath -PathType Leaf)) {
    try {
        $null = New-Item -ItemType File -Path $filePath -Force -ErrorAction Stop
        Write-Host "The file [$file] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
  }

  Add-Content $credentialPath "password=$content"

}




