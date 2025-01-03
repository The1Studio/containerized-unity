#!/usr/bin/env bash

UNITY_SERIAL=${UNITY_SERIAL:-}
UNITY_EMAIL=${UNITY_EMAIL:-}
UNITY_PASSWORD=${UNITY_PASSWORD:-}

# Activate the license
unity-editor \
  -logFile /dev/stdout \
  -quit \
  -serial "$UNITY_SERIAL" \
  -username "$UNITY_EMAIL" \
  -password "$UNITY_PASSWORD" \
  -projectPath /jenkins/BlankProject

# Store the exit code from the verify command
UNITY_EXIT_CODE=$?

# Check if UNITY_EXIT_CODE is 0
if [[ $UNITY_EXIT_CODE -eq 0 ]]
then
  echo "Active successful"
else
  echo "Active failed"
fi
