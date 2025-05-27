#!/usr/bin/env pwsh
# Build Unity Editor image

param(
    [Parameter(Mandatory=$true)]
    [string]$EditorVersion,
    
    [Parameter(Mandatory=$true)]
    [string]$EditorChangeset,
    
    [Parameter(Mandatory=$false)]
    [string]$HubVersion = "3.12.1",
    
    [Parameter(Mandatory=$false)]
    [string]$UbuntuVersion = "22.04",
    
    [Parameter(Mandatory=$false)]
    [string]$Architecture = "x86_64",
    
    [Parameter(Mandatory=$false)]
    [string]$EditorModules = "android webgl",
    
    [Parameter(Mandatory=$false)]
    [string]$DockerUsername = "leduchieu101"
)

$Platform = if ($Architecture -eq "arm64") { "linux/arm64" } else { "linux/amd64" }
$BaseImageName = "$DockerUsername/containerized-unity-base:$UbuntuVersion"
$HubImageName = "$DockerUsername/containerized-unity-hub:$HubVersion-ubuntu$UbuntuVersion-$Architecture"
$EditorImageName = "$DockerUsername/containerized-unity-editor:$EditorVersion-$Architecture"

Write-Host "Building Unity Editor Image..." -ForegroundColor Cyan
Write-Host "Base Image: $BaseImageName" -ForegroundColor Yellow
Write-Host "Hub Image: $HubImageName" -ForegroundColor Yellow
Write-Host "Editor Image: $EditorImageName" -ForegroundColor Yellow
Write-Host "Platform: $Platform" -ForegroundColor Yellow
Write-Host "Editor Version: $EditorVersion" -ForegroundColor Yellow
Write-Host "Editor Changeset: $EditorChangeset" -ForegroundColor Yellow
Write-Host "Editor Modules: $EditorModules" -ForegroundColor Yellow

$buildArgs = @(
    "build"
    "--platform", $Platform
    "--build-arg", "baseImage=$BaseImageName"
    "--build-arg", "hubImage=$HubImageName"
    "--build-arg", "version=$EditorVersion"
    "--build-arg", "changeSet=$EditorChangeset"
    "--build-arg", "module=$EditorModules"
    "-t", $EditorImageName
    "./editor"
)

Write-Host "Command: docker $($buildArgs -join ' ')" -ForegroundColor Gray
& docker @buildArgs

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Editor image built successfully: $EditorImageName" -ForegroundColor Green
} else {
    Write-Host "✗ Editor image build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}
