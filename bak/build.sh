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
UNITY_LOG_FILE=${UNITY_LOG_FILE:-/output/build.log}

# Parameters for Android builds
DEVELOPMENT=${DEVELOPMENT:-false}
OPTIMIZE_SIZE=${OPTIMIZE_SIZE:-false}
BUILD_APP_BUNDLE=${BUILD_APP_BUNDLE:-false}
KEYSTORE_NAME=${KEYSTORE_NAME:-}
KEYSTORE_PASS=${KEYSTORE_PASS:-}
KEYSTORE_ALIAS_NAME=${KEYSTORE_ALIAS_NAME:-}
KEYSTORE_ALIAS_PASS=${KEYSTORE_ALIAS_PASS:-}

# Parameters for iOS builds
IOS_SIGNING_TEAM_ID=${IOS_SIGNING_TEAM_ID:-}
IOS_TARGET_OS_VERSION=${IOS_TARGET_OS_VERSION:-}

# Parameters for WebGL builds
WEBGL_ORIENTATION=${WEBGL_ORIENTATION:-}
FACEBOOK_APP_ID=${FACEBOOK_APP_ID:-}
FACEBOOK_APP_SECRET=${FACEBOOK_APP_SECRET:-}
UPLOAD_TO_FACEBOOK=${UPLOAD_TO_FACEBOOK:-false}

export UNITY_LOG_FILE

source /active_lic.sh

# Build the project
UNITY_CMD=(
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
)

# Common parameters for all platforms
if [ "$DEVELOPMENT" = "true" ]; then
    UNITY_CMD+=( -development )
fi

if [ "$OPTIMIZE_SIZE" = "true" ]; then
    UNITY_CMD+=( -optimizeSize )
fi

# Platform-specific parameters
case "$UNITY_BUILD_TARGET" in
    "Android")
        if [ "$BUILD_APP_BUNDLE" = "true" ]; then
            UNITY_CMD+=( -buildAppBundle )
            [ -n "$KEYSTORE_NAME" ] && UNITY_CMD+=( -keyStoreFileName "$KEYSTORE_NAME" )
            [ -n "$KEYSTORE_PASS" ] && UNITY_CMD+=( -keyStorePassword "$KEYSTORE_PASS" )
            [ -n "$KEYSTORE_ALIAS_NAME" ] && UNITY_CMD+=( -keyStoreAliasName "$KEYSTORE_ALIAS_NAME" )
            [ -n "$KEYSTORE_ALIAS_PASS" ] && UNITY_CMD+=( -keyStoreAliasPassword "$KEYSTORE_ALIAS_PASS" )
        fi
        ;;
    "iOS")
        [ -n "$IOS_SIGNING_TEAM_ID" ] && UNITY_CMD+=( -iosSigningTeamId "$IOS_SIGNING_TEAM_ID" )
        [ -n "$IOS_TARGET_OS_VERSION" ] && UNITY_CMD+=( -iosTargetOSVersion "$IOS_TARGET_OS_VERSION" )
        ;;
    "WebGL")
        [ -n "$WEBGL_ORIENTATION" ] && UNITY_CMD+=( -webglOrientation "$WEBGL_ORIENTATION" )
        [ -n "$FACEBOOK_APP_ID" ] && UNITY_CMD+=( -facebookAppId "$FACEBOOK_APP_ID" )
        [ -n "$FACEBOOK_APP_SECRET" ] && UNITY_CMD+=( -facebookAppSecret "$FACEBOOK_APP_SECRET" )
        [ "$UPLOAD_TO_FACEBOOK" = "true" ] && UNITY_CMD+=( -uploadToFacebook )
        ;;
esac

"${UNITY_CMD[@]}"

# Get the exit code of the build
BUILD_EXIT_CODE=$?
if [ $BUILD_EXIT_CODE -eq 0 ]; then
  echo "Build succeeded";
else
  echo "Build failed, with exit code $BUILD_EXIT_CODE";
  echo "See build log at: $UNITY_LOG_FILE"
fi

echo "Build log saved to: $UNITY_LOG_FILE"

source /return_lic.sh

