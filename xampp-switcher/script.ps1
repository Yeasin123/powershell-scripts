$xamppPaths = Get-Content .\config.json | ConvertFrom-Json

function generateConfigWisePaths {
  param (
    [string] $relativePath
  )

  $phpPaths = @{}
  $xamppPaths.PSObject.Properties | ForEach-Object { $phpPaths[$_.Name] = Join-Path $_.Value $relativePath }
  return $phpPaths
}

function getEnvPhpVersion {
  param (
    [hashtable] $phpPaths
  )

  $path = [System.Environment]::GetEnvironmentVariable(
    'PATH',
    'User'
  )

  $foundEnvPath = ($path.split(';') | Where-Object { $_ -match '.*(php)$' })
  if ($null -eq $foundEnvPath) {
    return $null;
  }

  $foundPath = $phpPaths.GetEnumerator() | Where-Object { $_.Value -eq $foundEnvPath }
  if ($null -eq $foundPath) {
    return $null
  }

  return $foundPath.Key
}

function stopServices {
  param(
    [string] $phpVersion
  )
  Invoke-Expression 'Start-Process -WindowStyle hidden -Wait "C:\xampp-$phpVersion\apache_stop.bat"'
  Invoke-Expression 'Start-Process -WindowStyle hidden -Wait "C:\xampp-$phpVersion\mysql_stop.bat"'
}

function startServices {
  param(
    [string] $phpVersion
  )
  Invoke-Expression 'Start-Process -WindowStyle hidden "C:\xampp-$phpVersion\apache_start.bat"'
  Invoke-Expression 'Start-Process -WindowStyle hidden "C:\xampp-$phpVersion\mysql_start.bat"'
}

function updateEnvironmentPath {
  param(
    [string] $phpVersion
  )
  $envPaths = [System.Environment]::GetEnvironmentVariable(
    'PATH',
    'User'
  )
  $envPaths = ($envPaths.split(';') | Where-Object { $_ -match '.*(?<!php)$' }) | Where-Object { $_ -match '.*(?<!mysql\\bin)$' }
  $envPaths += $xamppPHPPaths[$promptPHPVersion]
  $envPaths += $xamppMySQLPaths[$promptPHPVersion]
  $envPaths = $envPaths -join ';'
  [System.Environment]::SetEnvironmentVariable(
    'PATH',
    $envPaths,
    'User'
  )
}

$xamppPHPPaths = generateConfigWisePaths("php")
$xamppMySQLPaths = generateConfigWisePaths("mysql\bin")
$envPHPVersion = getEnvPhpVersion($xamppPHPPaths)

if ($null -ne $envPHPVersion) {
  Write-Output "Active PHP Version is: $envPHPVersion"
}

$promptPHPVersion = Read-Host -Prompt "Enter PHP Version:"
$selectdXamppPHPVersion = $xamppPHPPaths.GetEnumerator() | Where-Object { $_.Key -eq $promptPHPVersion }

if ($null -eq $selectdXamppPHPVersion) {
  Write-Output "Config not found"
  return
}

if ($null -ne $envPHPVersion) {
  stopServices($envPHPVersion)
}
startServices($promptPHPVersion)
updateEnvironmentPath($promptPHPVersion)

Write-Output 'Version activated'