#!/usr/bin/env pwsh
# Stop JavaCraft on Windows. PowerShell 5.1 and 7+ compatible.
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$composeFile = Join-Path $projectRoot 'docker-compose.yml'
. (Join-Path $PSScriptRoot 'lib.ps1')

Assert-JcDocker
Get-JcComposeCli

# Always include the execution profile so the optional worker and sandbox image
# are torn down as well, even if this shell did not enable them.
Invoke-JcCompose @('-f', $composeFile, '--profile', 'execution', 'down')

Write-Host ''
Write-Host 'JavaCraft containers are stopped. Database data is preserved.'
