#!/usr/bin/env pwsh
# Individual image build scripts for more granular control

param(
    [Parameter(Mandatory=$false)]
    [string]$UbuntuVersion = "22.04",
    
    [Parameter(Mandatory=$false)]
    [string]$Architecture = "x86_64",
    
    [Parameter(Mandatory=$false)]
    [string]$DockerUsername = "leduchieu101"
)

$Platform = if ($Architecture -eq "arm64") { "linux/arm64" } else { "linux/amd64" }
$ImageName = "$DockerUsername/containerized-unity-base:$UbuntuVersion"

Write-Host "Building Unity Base Image..." -ForegroundColor Cyan
Write-Host "Image: $ImageName" -ForegroundColor Yellow
Write-Host "Platform: $Platform" -ForegroundColor Yellow

$buildArgs = @(
    "build"
    "--platform", $Platform
    "--build-arg", "version=$UbuntuVersion"
    "-t", $ImageName
    "./base"
)

Write-Host "Command: docker $($buildArgs -join ' ')" -ForegroundColor Gray
& docker @buildArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Base image built successfully: $ImageName" -ForegroundColor Green
} else {
    Write-Host "✗ Base image build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
