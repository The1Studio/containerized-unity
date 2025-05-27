#!/usr/bin/env pwsh
# Build Unity Hub image

param(
    [Parameter(Mandatory=$false)]
    [string]$HubVersion = "3.12.1",
    
    [Parameter(Mandatory=$false)]
    [string]$UbuntuVersion = "22.04",
    
    [Parameter(Mandatory=$false)]
    [string]$Architecture = "x86_64",
    
    [Parameter(Mandatory=$false)]
    [string]$DockerUsername = "leduchieu101"
)

$Platform = if ($Architecture -eq "arm64") { "linux/arm64" } else { "linux/amd64" }
$BaseImageName = "$DockerUsername/containerized-unity-base:$UbuntuVersion"
$HubImageName = "$DockerUsername/containerized-unity-hub:$HubVersion-ubuntu$UbuntuVersion-$Architecture"

Write-Host "Building Unity Hub Image..." -ForegroundColor Cyan
Write-Host "Base Image: $BaseImageName" -ForegroundColor Yellow
Write-Host "Hub Image: $HubImageName" -ForegroundColor Yellow
Write-Host "Platform: $Platform" -ForegroundColor Yellow

$buildArgs = @(
    "build"
    "--platform", $Platform
    "--build-arg", "baseImage=$BaseImageName"
    "--build-arg", "hubVersion=$HubVersion"
    "-t", $HubImageName
    "./hub"
)

Write-Host "Command: docker $($buildArgs -join ' ')" -ForegroundColor Gray
& docker @buildArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Hub image built successfully: $HubImageName" -ForegroundColor Green
} else {
    Write-Host "✗ Hub image build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
