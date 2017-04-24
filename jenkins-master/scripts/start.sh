#! /bin/bash -e

: "${JENKINS_HOME:="/var/lib/jenkins"}"
: "${JAVA_OPTS:="-Djava.awt.headless=true -Djenkins.install.runSetupWizard=false"}"
: "${SCRIPTS_ROOT:="/scripts"}"

pushd ${SCRIPTS_ROOT}
./setup.sh &
popd

# if `docker run` first argument start with `--` the user is passing jenkins launcher arguments
if [[ $# -lt 1 ]] || [[ "$1" == "--"* ]]; then

  # read JAVA_OPTS and JENKINS_OPTS into arrays to avoid need for eval (and associated vulnerabilities)
  java_opts_array=()
  while IFS= read -r -d "" item; do
    java_opts_array+=( "$item" )
  done < <([[ $JAVA_OPTS ]] && xargs printf "%s\0" <<<"$JAVA_OPTS")

  jenkins_opts_array=( )
  while IFS= read -r -d "" item; do
    jenkins_opts_array+=( "$item" )
  done < <([[ $JENKINS_OPTS ]] && xargs printf "%s\0" <<<"$JENKINS_OPTS")

  echo $JAVA_OPTS

  exec java "${java_opts_array[@]}" -jar /usr/lib/jenkins/jenkins.war "${jenkins_opts_array[@]}" "$@"
fi

# As argument is not jenkins, assume user want to run his own process, for example a `bash` shell to explore this image
exec "$@"
