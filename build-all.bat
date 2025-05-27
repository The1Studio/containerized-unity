@echo off
REM Batch script to build Unity Docker images locally
REM Usage: build-all.bat "6000.1.3f1" "xxx" "3.12.1" "22.04" "x86_64" "android webgl"

setlocal enabledelayedexpansion

REM Parameters - remove quotes properly
set "EDITOR_VERSION=%~1"
set "EDITOR_CHANGESET=%~2"
set "HUB_VERSION=%~3"
set "UBUNTU_VERSION=%~4"
set "ARCHITECTURE=%~5"
set "EDITOR_MODULES=%~6"
set "DOCKER_USERNAME=%~7"

REM Default values if not provided
if "%EDITOR_VERSION%"=="" (
    echo Error: Editor version is required
    echo Usage: build-all.bat "EditorVersion" "EditorChangeset" ["HubVersion"] ["UbuntuVersion"] ["Architecture"] ["EditorModules"] ["DockerUsername"]
    exit /b 1
)

if "%EDITOR_CHANGESET%"=="" (
    echo Error: Editor changeset is required
    echo Usage: build-all.bat "EditorVersion" "EditorChangeset" ["HubVersion"] ["UbuntuVersion"] ["Architecture"] ["EditorModules"] ["DockerUsername"]
    exit /b 1
)

if "%HUB_VERSION%"=="" set "HUB_VERSION=3.12.1"
if "%UBUNTU_VERSION%"=="" set "UBUNTU_VERSION=22.04"
if "%ARCHITECTURE%"=="" set "ARCHITECTURE=x86_64"
if "%EDITOR_MODULES%"=="" set "EDITOR_MODULES=android webgl"
if "%DOCKER_USERNAME%"=="" set "DOCKER_USERNAME=leduchieu101"

REM Set platform for Docker
if "%ARCHITECTURE%"=="arm64" (
    set PLATFORM=linux/arm64
) else (
    set PLATFORM=linux/amd64
)

REM Image names
set BASE_IMAGE_NAME=%DOCKER_USERNAME%/containerized-unity-base:%UBUNTU_VERSION%
set HUB_IMAGE_NAME=%DOCKER_USERNAME%/containerized-unity-hub:%HUB_VERSION%-ubuntu%UBUNTU_VERSION%-%ARCHITECTURE%
set EDITOR_IMAGE_NAME=%DOCKER_USERNAME%/containerized-unity-editor:%EDITOR_VERSION%-%ARCHITECTURE%

echo === Unity Docker Build Pipeline ===
echo Ubuntu Version: %UBUNTU_VERSION%
echo Hub Version: %HUB_VERSION%
echo Editor Version: %EDITOR_VERSION%
echo Editor Changeset: %EDITOR_CHANGESET%
echo Editor Modules: %EDITOR_MODULES%
echo Architecture: %ARCHITECTURE%
echo Platform: %PLATFORM%
echo.

REM Step 1: Build Base Image
echo === Step 1/3: Building Base Image ===
echo Building: %BASE_IMAGE_NAME%

docker build --platform %PLATFORM% --build-arg version=%UBUNTU_VERSION% -t %BASE_IMAGE_NAME% ./base

if !errorlevel! neq 0 (
    echo Error: Base image build failed with exit code !errorlevel!
    exit /b !errorlevel!
)

echo ✓ Base image built successfully: %BASE_IMAGE_NAME%
echo.

REM Step 2: Build Hub Image
echo === Step 2/3: Building Hub Image ===
echo Building: %HUB_IMAGE_NAME%

docker build --platform %PLATFORM% --build-arg baseImage=%BASE_IMAGE_NAME% --build-arg hubVersion=%HUB_VERSION% -t %HUB_IMAGE_NAME% ./hub

if !errorlevel! neq 0 (
    echo Error: Hub image build failed with exit code !errorlevel!
    exit /b !errorlevel!
)

echo ✓ Hub image built successfully: %HUB_IMAGE_NAME%
echo.

REM Step 3: Build Editor Image
echo === Step 3/3: Building Editor Image ===
echo Building: %EDITOR_IMAGE_NAME%

docker build --platform %PLATFORM% --build-arg baseImage=%BASE_IMAGE_NAME% --build-arg hubImage=%HUB_IMAGE_NAME% --build-arg version=%EDITOR_VERSION% --build-arg changeSet=%EDITOR_CHANGESET% --build-arg "module=%EDITOR_MODULES%" -t %EDITOR_IMAGE_NAME% ./editor

if !errorlevel! neq 0 (
    echo Error: Editor image build failed with exit code !errorlevel!
    exit /b !errorlevel!
)

echo ✓ Editor image built successfully: %EDITOR_IMAGE_NAME%
echo.

REM Summary
echo === Build Pipeline Completed Successfully! ===
echo Built images:
echo   Base:   %BASE_IMAGE_NAME%
echo   Hub:    %HUB_IMAGE_NAME%
echo   Editor: %EDITOR_IMAGE_NAME%
echo.
echo You can now use the editor image with:
echo docker run --rm -e "UNITY_PROJECT_PATH=/path/to/project" %EDITOR_IMAGE_NAME%

endlocal
