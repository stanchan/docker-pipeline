#!/bin/bash
SLAVE_JENKINS_NAME=${JENKINS_SLAVE_NAME:-jenkins-swarm-slave}
SLAVE_JENKINS_SCHEME=${JENKINS_SCHEME:-http}
SLAVE_JENKINS_SERVER=${JENKINS_SERVER:-jenkins-master}
SLAVE_JENKINS_PORT=${JENKINS_SLAVE_PORT:-8080}
SLAVE_JENKINS_LABELS=${JENKINS_LABELS:-swarm}
SLAVE_JENKINS_HOME=${JENKINS_HOME:-$HOME}
SLAVE_JENKINS_USER=${JENKINS_USER:-jenkins}
SLAVE_JENKINS_PASSWORD=${JENKINS_PASSWORD:-jenkins}
SLAVE_JENKINS_EXECUTORS=${JENKINS_EXECUTORS:-1}
JAVA_HOME=${JAVA_HOME:-/usr/java/latest}
SCRIPTS_HOME=${SCRIPTS_HOME:-/scripts}
CERTS_HOME=${CERTS_HOME:-/certs}

python ${SCRIPTS_HOME}/jdk_add_certs.py
chown root ${JAVA_HOME}/jre/lib/security/cacerts

echo "Wait three minutes before starting swarm client"
sleep 180
#echo "Starting up swarm client with args:"
#echo "$@"
#echo "and env:"
#echo "$(env)"
set -x
java -jar ${SLAVE_JENKINS_HOME}/swarm-client-3.3.jar -name ${SLAVE_JENKINS_NAME} -fsroot "${SLAVE_JENKINS_HOME}" -executors ${SLAVE_JENKINS_EXECUTORS} -labels "${SLAVE_JENKINS_LABELS}" -username "${SLAVE_JENKINS_USER}" -passwordEnvVariable SLAVE_JENKINS_PASSWORD -master ${SLAVE_JENKINS_SCHEME}://${SLAVE_JENKINS_SERVER}:${SLAVE_JENKINS_PORT} $@
sleep infinity
