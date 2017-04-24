# Copyright (c) 2017-Present
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#################################################################
# Creates a base CentOS 7 image with Jenkins
#
#                    ##        .
#              ## ## ##       ==
#           ## ## ## ##      ===
#       /""""""""""""""""\___/ ===
#  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
#       \______ o          __/
#         \    \        __/
#          \____\______/
#
# Author:    Stan Chan <stanchan@gmail.com>
# License:   Apache
#################################################################

FROM centos:centos7
MAINTAINER Stan Chan <stanchan@gmail.com>

ENV jenkinsversion="2.55" \
    os="centos" \
    osversion="7"

ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_SLAVE_AGENT_PORT 443
ENV JAVA_HOME /usr/java/latest
ENV SCRIPTS_HOME /scripts
ENV FILES_HOME /files
ENV JOBS_HOME /jobs
ENV CERTS_HOME /certs

ARG user=jenkins
ARG group=jenkins
ARG uid=998
ARG gid=996

RUN echo -e "[cfx]\nname = CFX Packages for Enterprise Linux \$releasever - \$basearch\nbaseurl = https://repo.chanfx.com/yum/cfx_yum_repo/\$releasever\n#mirrorlist = https://mirrors.chanfx.com/metalink?repo=cfx-\$releasever&arch=\$basearch\nfailovermethod = priority\nenabled = 1\npriority = 50\nprotect = 0\ngpgcheck = 0\nsslverify = 0\ngpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CFX-7" > /etc/yum.repos.d/cfx.repo

ADD http://pkg.jenkins-ci.org/redhat/jenkins.repo /etc/yum.repos.d/jenkins.repo
RUN rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key

RUN yum -y install \
  git \
  gzip \
  jdk \
  jenkins \
  jq \
  jq-devel \
  maven \
  openssh-clients \
  openssh-server \
  passwd \
  python-pip \
  socat \
  sudo \
  tar \
  unzip \
  wget \
  which \
  && yum clean all

RUN pip install --upgrade pip setuptools

RUN pip install PyYAML python-jenkins ordereddict jenkinsapi jenkins-job-builder

# Clean up YUM when done.
RUN rm -f /etc/yum.repos.d/cfx.repo && yum clean all

ENV TINI_VERSION 0.13.2
ENV TINI_SHA afbf8de8a63ce8e4f18cb3f34dfdbbd354af68a1

# Use tini as subreaper in Docker container to adopt zombie processes 
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha1sum -c -

ADD scripts ${SCRIPTS_HOME}
RUN chmod +x ${SCRIPTS_HOME}/*.sh

ADD files ${FILES_HOME}

ADD jobs ${JOBS_HOME}
RUN chown ${user}.${group} ${JOBS_HOME}

RUN chown $user ${JAVA_HOME}/jre/lib/security/cacerts

# Adding Letsencrypt-CA To Truststore
RUN export KEYSTORE=$JAVA_HOME/jre/lib/security/cacerts && \
    wget -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx1.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/letsencryptauthorityx2.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x1-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x2-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.der && \
    wget -P /tmp/ https://letsencrypt.org/certs/lets-encrypt-x4-cross-signed.der && \
    $JAVA_HOME/bin/keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx1 -file /tmp/letsencryptauthorityx1.der && \
    $JAVA_HOME/bin/keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias isrgrootx2 -file /tmp/letsencryptauthorityx2.der && \
    $JAVA_HOME/bin/keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx1 -file /tmp/lets-encrypt-x1-cross-signed.der && \
    $JAVA_HOME/bin/keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx2 -file /tmp/lets-encrypt-x2-cross-signed.der && \
    $JAVA_HOME/bin/keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx3 -file /tmp/lets-encrypt-x3-cross-signed.der && \
    $JAVA_HOME/bin/keytool -trustcacerts -keystore $KEYSTORE -storepass changeit -noprompt -importcert -alias letsencryptauthorityx4 -file /tmp/lets-encrypt-x4-cross-signed.der

ADD configs/*.xml ${JENKINS_HOME}/

RUN chown -R ${user}.${group} ${JENKINS_HOME}

EXPOSE 8080 50000

USER ${user}

# Vagrant directory can be used for Vagrant-based scenarios,
# but you can use it for general filesystem-share with the
# host, e.g. you can place your Puppet manifests and execute
# puppet apply inside the container.
VOLUME ["/vagrant", "/run", "/var/lib/jenkins", "/var/log", "/var/cache/jenkins/war", "/certs"]

#CMD ["/scripts/start.sh"]

ENTRYPOINT ["/bin/tini", "--", "/scripts/start.sh"]
