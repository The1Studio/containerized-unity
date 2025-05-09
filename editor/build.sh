#!/usr/bin/env bash

# Set the default values for the environment variables
UNITY_PROJECT_PATH=${UNITY_PROJECT_PATH:-/project}
UNITY_OUTPUT_PATH=${UNITY_OUTPUT_PATH:-/output}
UNITY_BUILD_TARGET=${UNITY_BUILD_TARGET:-Android}
UNITY_PLATFORMS=${UNITY_PLATFORMS:-android}
UNITY_SCRIPTING_BACKEND=${UNITY_SCRIPTING_BACKEND:-il2cpp}
UNITY_SCRIPTING_DEFINE_SYMBOLS=${UNITY_SCRIPTING_DEFINE_SYMBOLS:-}
UNITY_ADDRESSABLES_BUILD_PATH=${UNITY_ADDRESSABLES_BUILD_PATH:-/addressables}
UNITY_ADDRESSABLES_LOAD_PATH=${UNITY_ADDRESSABLES_LOAD_PATH:-/addressables}
UNITY_LOG_FILE=${UNITY_LOG_FILE:-/dev/stdout}
source /active_lic.sh

# Build the project
unity-editor \
    -batchmode -nographics\
    -quit \
    -executeMethod "Build.BuildFromCommandLine" \
    -buildTarget "${UNITY_BUILD_TARGET}" \
    -platforms "${UNITY_PLATFORMS}" \
    -scriptingBackend "${UNITY_SCRIPTING_BACKEND}" \
    -projectPath "$UNITY_PROJECT_PATH" \
    -logFile "$UNITY_LOG_FILE" \
    -outputPath "$UNITY_OUTPUT_PATH" \
    -remoteAddressableBuildPath "$UNITY_ADDRESSABLES_BUILD_PATH" \
    -remoteAddressableLoadPath "$UNITY_ADDRESSABLES_LOAD_PATH" \
    -scriptingDefineSymbols "${UNITY_SCRIPTING_DEFINE_SYMBOLS}"

# Get the exit code of the build
BUILD_EXIT_CODE=$?

if [ $BUILD_EXIT_CODE -eq 0 ]; then
  echo "Build succeeded";
else
  echo "Build failed, with exit code $BUILD_EXIT_CODE";
fi

source /return_lic.sh
