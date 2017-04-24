#! /bin/bash -e

: "${SSHD_ROOT:="/etc/ssh"}"
: "${JAVA_HOME:="/usr/java/latest"}"
: "${SCRIPTS_HOME:="/scripts"}"
: "${CERTS_HOME:="/certs"}"

python ${SCRIPTS_HOME}/jdk_add_certs.py

if [[ ! -f ${SSHD_ROOT}/ssh_host_rsa_key ]]; then
	ssh-keygen -t rsa -b 2048 -N '' -f ${SSHD_ROOT}/ssh_host_rsa_key
	ssh-keygen -t ecdsa -N '' -f ${SSHD_ROOT}/ssh_host_ecdsa_key
	ssh-keygen -t ed25519 -N '' -f ${SSHD_ROOT}/ssh_host_ed25519_key
fi

/sbin/sshd -D -f "${SSHD_ROOT}/sshd_config"
