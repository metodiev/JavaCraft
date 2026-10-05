#!/usr/bin/env pwsh
# Restart JavaCraft on Windows. PowerShell 5.1 and 7+ compatible.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$composeFile = Join-Path $projectRoot 'docker-compose.yml'
. (Join-Path $PSScriptRoot 'lib.ps1')

Assert-JcDocker
Get-JcComposeCli
$worker = Resolve-JcWorker

# Tear down every profile first so an earlier worker session cannot keep the network.
Invoke-JcCompose @('-f', $composeFile, '--profile', 'execution', 'down')

$arguments = @('-f', $composeFile)
if ($worker) {
    $arguments += '--profile', 'execution'
}
$arguments += 'up', '--build', '-d'
Invoke-JcCompose $arguments

Write-Host ''
Write-Host 'JavaCraft is restarting.'
Write-Host 'Frontend:   http://localhost:5173'
Write-Host 'API:        http://localhost:8080/api/v1/catalog'
Write-Host 'Health:     http://localhost:8080/actuator/health'
