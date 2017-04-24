#!/bin/bash

: "${JENKINS_HOME:="/var/lib/jenkins"}"
: "${JENKINS_USER:="jenkins"}"
: "${JENKINS_GROUP:="jenkins"}"
: "${SCRIPTS_HOME:="/scripts"}"
: "${FILES_HOME:="/files"}"
: "${JOBS_HOME:="/jobs"}"

wait_for_jenkins() {
	while [[ $(curl -sL -w "%{http_code}\\n" "http://127.0.0.1:8080" -o /dev/null) != "200" ]]
	do
		echo "Jenkins not up yet"
		sleep 5
	done
	echo "Jenkins up and running"
}

restart_and_wait_for_jenkins() {
	echo "Restarting Jenkins..."
	curl -XPOST http://127.0.0.1:8080/safeRestart
	wait_for_jenkins
}

cleanup_and_wait_for_jenkins() {
	echo "Cleaning up files..."
	if [[ $(ls /var/lib/jenkins/init.groovy.d/* | wc -l) -gt 0 ]]; then
		rm -f /var/lib/jenkins/init.groovy.d/*
	fi
	echo "Restarting Jenkins..."
	curl -XPOST http://127.0.0.1:8080/safeRestart
	wait_for_jenkins
}

mkdir -p ${JENKINS_HOME}/.ssh
cp ${FILES_HOME}/jenkins_key ${JENKINS_HOME}/.ssh/id_rsa
cp ${FILES_HOME}/ssh_config ${JENKINS_HOME}/.ssh/config
chown -R ${JENKINS_USER}.${JENKINS_GROUP} ${JENKINS_HOME}
chmod 600 ${JENKINS_HOME}/.ssh/id_rsa
chmod 644 ${JENKINS_HOME}/.ssh/config

# Add trusted certs
python ${SCRIPTS_HOME}/jdk_add_certs.py
chown root ${JAVA_HOME}/jre/lib/security/cacerts

wait_for_jenkins

# Set up plugins. Restart until complete
# do a while loop waiting for confirmed installation
echo "Plugins install started"
sleeptime=30
mkdir /var/lib/jenkins/init.groovy.d/
cp ${FILES_HOME}/plugins.txt /var/lib/jenkins/
cp ${SCRIPTS_HOME}/jenkins_install_plugins.groovy /var/lib/jenkins/init.groovy.d/
restart_and_wait_for_jenkins
sleep 270
restart_and_wait_for_jenkins
while [[ /bin/true ]]
do
	#sleeptime=$(($sleeptime + $sleeptime))
	echo "Waiting for $sleeptime before re-checking plugins..."
	sleep $sleeptime
	python ${SCRIPTS_HOME}/jenkins_check_plugins.py
	if [[ $(python ${SCRIPTS_HOME}/jenkins_check_plugins.py | tail -1) = "OK" ]]
	then
		break
	fi
done
#cleanup_and_wait_for_jenkins
echo "Plugin install complete"

# Set up credentials
echo "Setting up credentials"
cp ${FILES_HOME}/credentials.json /var/lib/jenkins/
cp ${FILES_HOME}/keys.json /var/lib/jenkins/
python ${SCRIPTS_HOME}/jenkins_add_credentials.py
python ${SCRIPTS_HOME}/jenkins_credentials.py
echo "Setting up credentials complete"

echo "Set up nodes"
python ${SCRIPTS_HOME}/jenkins_add_nodes.py
echo "Set up nodes done"

echo "Uploading jobs"
# Use xml to upload docker jobs
wget -qO- http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar > ${JOBS_HOME}/jenkins-cli.jar
python ${SCRIPTS_HOME}/jenkins_add_jobs.py
echo "Uploading jobs done"

# Sleep forever
sleep infinity
