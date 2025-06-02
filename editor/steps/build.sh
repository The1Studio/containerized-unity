#!/usr/bin/env bash

# Set the default values for the environment variables (from bak/build.sh, these are now the canonical source)
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

echo "Using project path \"$UNITY_PROJECT_PATH\"."
echo "Using build name \"$BUILD_NAME\"."
echo "Using build target \"$UNITY_BUILD_TARGET\"."
if [ -z "$BUILD_PROFILE" ]; then
  echo "Doing a default \"$UNITY_BUILD_TARGET\" platform build."
else
  echo "Using build profile \"$BUILD_PROFILE\" relative to \"$UNITY_PROJECT_PATH\"."
fi
echo "Using build path \"$UNITY_OUTPUT_PATH\"."

UNITY_CMD=(
    unity-editor \
    -batchmode -nographics \
    -quit \
    -executeMethod "${BUILD_METHOD:-Build.BuildFromCommandLine}" \
    -buildTarget "$UNITY_BUILD_TARGET" \
    -platforms "$UNITY_PLATFORMS" \
    -scriptingBackend "$UNITY_SCRIPTING_BACKEND" \
    -projectPath "$UNITY_PROJECT_PATH" \
    -logFile "$UNITY_LOG_FILE" \
    -outputPath "$UNITY_OUTPUT_PATH" \
    -remoteAddressableBuildPath "$UNITY_ADDRESSABLES_BUILD_PATH" \
    -remoteAddressableLoadPath "$UNITY_ADDRESSABLES_LOAD_PATH" \
    -scriptingDefineSymbols "$UNITY_SCRIPTING_DEFINE_SYMBOLS"
)

if [ "$DEVELOPMENT" = "true" ]; then
    UNITY_CMD+=( -development )
fi
if [ "$OPTIMIZE_SIZE" = "true" ]; then
    UNITY_CMD+=( -optimizeSize )
fi

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


BUILD_EXIT_CODE=$?
if [ $BUILD_EXIT_CODE -eq 0 ]; then
  echo "Build succeeded";
else
  echo "Build failed, with exit code $BUILD_EXIT_CODE";
  echo "See build log at: $UNITY_LOG_FILE"
fi

echo "Build log saved to: $UNITY_LOG_FILE"

if [[ -n "$CHOWN_FILES_TO" ]]; then
  echo "Changing ownership of files to $CHOWN_FILES_TO for $UNITY_OUTPUT_PATH and $UNITY_PROJECT_PATH"
  chown -R "$CHOWN_FILES_TO" "$UNITY_OUTPUT_PATH"
  chown -R "$CHOWN_FILES_TO" "$UNITY_PROJECT_PATH"
fi
chmod -R a+r "$UNITY_OUTPUT_PATH"
chmod -R a+r "$UNITY_PROJECT_PATH"
if [[ "$UNITY_BUILD_TARGET" == "StandaloneOSX" ]]; then
  OSX_EXECUTABLE_PATH="$UNITY_OUTPUT_PATH/$BUILD_NAME.app/Contents/MacOS"
  find "$OSX_EXECUTABLE_PATH" -type f -exec chmod +x {} \;
fi
ls -alh "$UNITY_OUTPUT_PATH"

# Insert "-build" before the file extension of UNITY_LOG_FILE
NEW_LOG_FILE="${UNITY_LOG_FILE%.*}-build.${UNITY_LOG_FILE##*.}"

if [ "$UNITY_LOG_FILE" != "$NEW_LOG_FILE" ]; then
  cp "$UNITY_LOG_FILE" "$NEW_LOG_FILE"
fi