#!/bin/bash

source ~/.bashrc

curl -s -o agent.jar "${JENKINS_HOST}/jnlpJars/agent.jar"
mkdir -p "${JENKINS_WORKDIR}"
java -jar agent.jar -url "${JENKINS_HOST}" -secret "${JENKINS_SECRET}" -name "${JENKINS_NAME}" -webSocket -workDir "${JENKINS_WORKDIR}"
