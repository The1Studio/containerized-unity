#!/usr/bin/env pwsh
# PowerShell script to build Unity Docker images locally
# Usage: .\build-all.ps1 -EditorVersion "6000.1.3f1" -EditorChangeset "xxx" -HubVersion "3.12.1" -UbuntuVersion "22.04" -Architecture "x86_64" -EditorModules "android webgl"

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

# Color functions for better output
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    } else {
        $input | Write-Output
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green $args }
function Write-Info { Write-ColorOutput Cyan $args }
function Write-Warning { Write-ColorOutput Yellow $args }
function Write-Error { Write-ColorOutput Red $args }

# Set platform for Docker
$Platform = if ($Architecture -eq "arm64") { "linux/arm64" } else { "linux/amd64" }

# Image names
$BaseImageName = "$DockerUsername/containerized-unity-base:$UbuntuVersion"
$HubImageName = "$DockerUsername/containerized-unity-hub:$HubVersion-ubuntu$UbuntuVersion-$Architecture"
$EditorImageName = "$DockerUsername/containerized-unity-editor:$EditorVersion-$Architecture"

Write-Info "=== Unity Docker Build Pipeline ==="
Write-Info "Ubuntu Version: $UbuntuVersion"
Write-Info "Hub Version: $HubVersion"
Write-Info "Editor Version: $EditorVersion"
Write-Info "Editor Changeset: $EditorChangeset"
Write-Info "Editor Modules: $EditorModules"
Write-Info "Architecture: $Architecture"
Write-Info "Platform: $Platform"
Write-Info ""

try {
    # Step 1: Build Base Image
    Write-Info "=== Step 1/3: Building Base Image ==="
    Write-Info "Building: $BaseImageName"
    
    $baseArgs = @(
        "build"
        "--platform", $Platform
        "--build-arg", "version=$UbuntuVersion"
        "-t", $BaseImageName
        "./base"
    )
    
    Write-Info "Command: docker $($baseArgs -join ' ')"
    & docker @baseArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "Base image build failed with exit code $LASTEXITCODE"
    }
    Write-Success "✓ Base image built successfully: $BaseImageName"
    Write-Info ""
    
    # Step 2: Build Hub Image
    Write-Info "=== Step 2/3: Building Hub Image ==="
    Write-Info "Building: $HubImageName"
    
    $hubArgs = @(
        "build"
        "--platform", $Platform
        "--build-arg", "baseImage=$BaseImageName"
        "--build-arg", "hubVersion=$HubVersion"
        "-t", $HubImageName
        "./hub"
    )
    
    Write-Info "Command: docker $($hubArgs -join ' ')"
    & docker @hubArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "Hub image build failed with exit code $LASTEXITCODE"
    }
    Write-Success "✓ Hub image built successfully: $HubImageName"
    Write-Info ""
    
    # Step 3: Build Editor Image
    Write-Info "=== Step 3/3: Building Editor Image ==="
    Write-Info "Building: $EditorImageName"
    
    $editorArgs = @(
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
    
    Write-Info "Command: docker $($editorArgs -join ' ')"
    & docker @editorArgs
    
    if ($LASTEXITCODE -ne 0) {
        throw "Editor image build failed with exit code $LASTEXITCODE"
    }
    Write-Success "✓ Editor image built successfully: $EditorImageName"
    Write-Info ""
    
    # Summary
    Write-Success "=== Build Pipeline Completed Successfully! ==="
    Write-Success "Built images:"
    Write-Success "  Base:   $BaseImageName"
    Write-Success "  Hub:    $HubImageName"
    Write-Success "  Editor: $EditorImageName"
    Write-Info ""
    Write-Info "You can now use the editor image with:"
    Write-Info "docker run --rm -e 'UNITY_PROJECT_PATH=/path/to/project' $EditorImageName"
    
} catch {
    Write-Error "=== Build Pipeline Failed! ==="
    Write-Error "Error: $($_.Exception.Message)"
    exit 1
}
