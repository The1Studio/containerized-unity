#!/usr/bin/env bash

UNITY_EMAIL=${UNITY_EMAIL:-}
UNITY_PASSWORD=${UNITY_PASSWORD:-}

# Return license
unity-editor \
    -logFile /dev/stdout \
    -quit \
    -returnlicense \
    -username "$UNITY_EMAIL" \
    -password "$UNITY_PASSWORD" \
    -projectPath /home/jenkins/BlankProject

# Store the exit code from the verify command
UNITY_EXIT_CODE=$?

# Check if UNITY_EXIT_CODE is 0
if [[ $UNITY_EXIT_CODE -eq 0 ]]
then
  echo "Return successful"
else
  echo "Return failed"
fi
