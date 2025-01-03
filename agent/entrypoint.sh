#!/bin/sh

mkdir -p "${JENKINS_WORKDIR}"

cp /*.sh "${JENKINS_WORKDIR}/"
cp -r /BlankProject "${JENKINS_WORKDIR}/BlankProject/"

curl -s -o agent.jar "${JENKINS_HOST}/jnlpJars/agent.jar"
java -jar agent.jar -url "${JENKINS_HOST}" -secret "${JENKINS_SECRET}" -name "${JENKINS_NAME}" -webSocket -workDir "${JENKINS_WORKDIR}"
