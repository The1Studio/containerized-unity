# Unity Docker Build Scripts

This folder contains scripts to build Unity Docker images locally without requiring GitHub Actions or Docker Hub push operations.

## Main Build Script

### PowerShell (Recommended)
```powershell
# Build all images in the correct order
.\build-all.ps1 -EditorVersion "6000.1.3f1" -EditorChangeset "xxxxxxxxxxxx"

# With custom parameters
.\build-all.ps1 -EditorVersion "6000.1.3f1" -EditorChangeset "xxxxxxxxxxxx" -HubVersion "3.12.1" -UbuntuVersion "22.04" -Architecture "x86_64" -EditorModules "android webgl ios"
```

### Batch File
```cmd
# Build all images in the correct order
build-all.bat "6000.1.3f1" "xxxxxxxxxxxx"

# With all parameters
build-all.bat "6000.1.3f1" "xxxxxxxxxxxx" "3.12.1" "22.04" "x86_64" "android webgl ios"
```

## Individual Build Scripts (PowerShell)

For more granular control, you can build images individually:

```powershell
# Build base image
.\build-base.ps1 -UbuntuVersion "22.04" -Architecture "x86_64"

# Build hub image (requires base image)
.\build-hub.ps1 -HubVersion "3.12.1" -UbuntuVersion "22.04" -Architecture "x86_64"

# Build editor image (requires base and hub images)
.\build-editor.ps1 -EditorVersion "6000.1.3f1" -EditorChangeset "xxxxxxxxxxxx" -EditorModules "android webgl"
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| EditorVersion | Yes | - | Unity Editor version (e.g., "6000.1.3f1") |
| EditorChangeset | Yes | - | Unity Editor changeset hash |
| HubVersion | No | "3.12.1" | Unity Hub version |
| UbuntuVersion | No | "22.04" | Ubuntu base image version |
| Architecture | No | "x86_64" | Target architecture (x86_64 or arm64) |
| EditorModules | No | "android webgl" | Space-separated list of Unity modules |
| DockerUsername | No | "leduchieu101" | Docker username for image naming |

## Common Unity Editor Changesets

You can find Unity Editor changesets at: https://unity.com/releases/editor/archive

Example changesets:
- Unity 6000.1.3f1: `170d2541580d`
- Unity 2023.2.20f1: `0e25a174756c`
- Unity 2022.3.48f1: `8bf49c377ebf`

## Usage After Building

Once built, you can use the editor image like this:

```bash
docker run --rm \
  --cpus=8 --memory=16g \
  -v /path/to/your/project:/home/jenkins/workspace/project:cached \
  -v unity-cache:/root/.cache/unity3d \
  -e 'UNITY_PROJECT_PATH=/home/jenkins/workspace/project' \
  -e 'UNITY_OUTPUT_PATH=build/output.apk' \
  -e 'UNITY_BUILD_TARGET=Android' \
  -e 'UNITY_EMAIL=your-email@example.com' \
  -e 'UNITY_PASSWORD=your-password' \
  -e 'UNITY_SERIAL=your-serial' \
  leduchieu101/containerized-unity-editor:6000.1.3f1-x86_64
```

## Build Order

The scripts must be run in this order due to dependencies:
1. **Base** → Contains Ubuntu + Unity dependencies
2. **Hub** → Contains Unity Hub (depends on Base)
3. **Editor** → Contains Unity Editor (depends on Base + Hub)

The `build-all.ps1` and `build-all.bat` scripts handle this ordering automatically.
