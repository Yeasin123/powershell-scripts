$path = [System.Environment]::GetEnvironmentVariable(
    'PATH',
    'User'
)

$phpVersions = @{
    '7.4' = 'C:\xampp-7.4\php';
    '8.0' = 'C:\xampp-8.0\php';
    '8.1' = 'C:\xampp-8.1\php';
}

$currentVersion = ($path.split(';') | Where-Object { $_ -match '.*(php)$' })
$currentVersion = $phpVersions.GetEnumerator() | Where-Object { $_.Value -eq $currentVersion }
if ($null -ne $currentVersion) {
    $currentVersion = $currentVersion.Key
}
else {
    $currentVersion = $null
}

$message = 'Current xampp php version: ' + $currentVersion
Write-Output $message

$apacheStarts = @{
    '7.4' = 'Start-Process -WindowStyle hidden "C:\xampp-7.4\apache_start.bat"';
    '8.0' = 'Start-Process -WindowStyle hidden "C:\xampp-8.0\apache_start.bat"';
    '8.1' = 'Start-Process -WindowStyle hidden "C:\xampp-8.1\apache_start.bat"';
}

$apacheStops = @{
    '7.4' = 'Start-Process -WindowStyle hidden -Wait "C:\xampp-7.4\apache_stop.bat"';
    '8.0' = 'Start-Process -WindowStyle hidden -Wait "C:\xampp-8.0\apache_stop.bat"';
    '8.1' = 'Start-Process -WindowStyle hidden -Wait "C:\xampp-8.1\apache_stop.bat"';
}

$mysqlStarts = @{
    '7.4' = 'Start-Process -WindowStyle hidden "C:\xampp-7.4\mysql_start.bat"';
    '8.0' = 'Start-Process -WindowStyle hidden "C:\xampp-8.0\mysql_start.bat"';
    '8.1' = 'Start-Process -WindowStyle hidden "C:\xampp-8.1\mysql_start.bat"';
}

$mysqlStops = @{
    '7.4' = 'Start-Process -WindowStyle hidden -Wait "C:\xampp-7.4\mysql_stop.bat"';
    '8.0' = 'Start-Process -WindowStyle hidden -Wait "C:\xampp-8.0\mysql_stop.bat"';
    '8.1' = 'Start-Process -WindowStyle hidden -Wait "C:\xampp-8.1\mysql_stop.bat"';
}

$selectedVersion = Read-Host -Prompt 'Enter php version:'

$selected = $phpVersions.GetEnumerator() | Where-Object { $_.key -eq $selectedVersion }

if ($null -eq $selected) {
    Write-Output 'Invalid Version'
    return
}

if ($null -ne $currentVersion) {
    try {
        Invoke-Expression $apacheStops[$currentVersion]
    }
    catch {
    }
    try {
        Invoke-Expression $mysqlStops[$currentVersion]
    }
    catch {
    }
}

Invoke-Expression $apacheStarts[$selectedVersion]
Invoke-Expression $mysqlStarts[$selectedVersion]

$path = ($path.split(';') | Where-Object { $_ -match '.*(?<!php)$' })
$path += $phpVersions[$selectedVersion]
$path = $path -join ';'

[System.Environment]::SetEnvironmentVariable(
    'PATH',
    $path,
    'User'
)

Write-Output 'Version activated'