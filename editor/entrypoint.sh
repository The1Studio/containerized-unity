#!/usr/bin/env bash

# Set the default values for the environment variables (from steps/build.sh, canonical source)
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

# Ensure machine ID is randomized for personal license activation
if [[ "$UNITY_SERIAL" = F* ]]; then
  echo "Randomizing machine ID for personal license activation"
  dbus-uuidgen > /etc/machine-id && mkdir -p /var/lib/dbus/ && ln -sf /etc/machine-id /var/lib/dbus/machine-id
fi

#
# Prepare Android SDK, if needed
# We do this here to ensure it has root permissions
#

fullProjectPath="$UNITY_PROJECT_PATH"

if [[ "$UNITY_BUILD_TARGET" == "Android" ]]; then
  export JAVA_HOME="$(awk -F'=' '/JAVA_HOME=/{print $2}' /usr/bin/unity-editor.d/*)"
  ANDROID_HOME_DIRECTORY="$(awk -F'=' '/ANDROID_HOME=/{print $2}' /usr/bin/unity-editor.d/*)"
  SDKMANAGER=$(find $ANDROID_HOME_DIRECTORY/cmdline-tools -name sdkmanager)
  if [ -z "${SDKMANAGER}" ]
  then
    SDKMANAGER=$(find $ANDROID_HOME_DIRECTORY/tools/bin -name sdkmanager)
    if [ -z "${SDKMANAGER}" ]
    then
      echo "No sdkmanager found"
      exit 1
    fi
  fi

  if [[ -n "$ANDROID_SDK_MANAGER_PARAMETERS" ]]; then
    echo "Updating Android SDK with parameters: $ANDROID_SDK_MANAGER_PARAMETERS"
    $SDKMANAGER "$ANDROID_SDK_MANAGER_PARAMETERS"
  else
    echo "Updating Android SDK with auto detected target API version"
    # Read the line containing AndroidTargetSdkVersion from the file
    targetAPILine=$(grep 'AndroidTargetSdkVersion' "$fullProjectPath/ProjectSettings/ProjectSettings.asset")

    # Extract the number after the semicolon
    targetAPI=$(echo "$targetAPILine" | cut -d':' -f2 | tr -d '[:space:]')

    $SDKMANAGER "platforms;android-$targetAPI"
  fi

  echo "Updated Android SDK."
else
  echo "Not updating Android SDK."
fi

if [[ "$RUN_AS_HOST_USER" == "true" ]]; then
  echo "Running as host user"

  # Stop on error if we can't set up the user
  set -e

  # Get host user/group info so we create files with the correct ownership
  USERNAME=$(stat -c '%U' "$fullProjectPath")
  USERID=$(stat -c '%u' "$fullProjectPath")
  GROUPNAME=$(stat -c '%G' "$fullProjectPath")
  GROUPID=$(stat -c '%g' "$fullProjectPath")

  groupadd -g $GROUPID $GROUPNAME
  useradd -u $USERID -g $GROUPID $USERNAME
  usermod -aG $GROUPNAME $USERNAME
  mkdir -p "/home/$USERNAME"
  chown $USERNAME:$GROUPNAME "/home/$USERNAME"

  # Normally need root permissions to access when using su
  chmod 777 /dev/stdout
  chmod 777 /dev/stderr

  # Don't stop on error when running our scripts as error handling is baked in
  set +e

  # Switch to the host user so we can create files with the correct ownership
  su $USERNAME -c "$SHELL -c 'source /steps/runsteps.sh'"
else
  echo "Running as root"

  # Run as root
  source /steps/runsteps.sh
fi

exit $?