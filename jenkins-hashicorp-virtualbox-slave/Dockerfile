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

ENV os="centos" \
    osversion="7"

ENV JENKINS_HOME /var/lib/jenkins
ENV JENKINS_LABELS hashicorp
ENV JENKINS_USER jenkins
ENV JENKINS_PASSWORD jenkins
ENV JAVA_HOME /usr/java/latest
ENV VAGRANT_HOME=/opt/vagrant
ENV PACKER_VERSION=1.0.0
ENV VAGRANT_VERSION=1.9.3
ENV VAULT_VERSION=0.7.0
ENV TERRAFORM_VERSION=0.9.3
ENV ATLAS_CLI_VERSION=0.2.0
ENV VIRTUALBOX_VERSION=latest
ENV SCRIPTS_HOME /scripts
ENV CERTS_HOME /certs

ARG user=jenkins
ARG group=jenkins
ARG uid=998
ARG gid=996

RUN groupadd -g ${gid} ${group} && \
    useradd -u ${uid} -g ${gid} -d ${JENKINS_HOME} ${user} && \
    echo "${user}   ALL=(ALL)          NOPASSWD:ALL" >> /etc/sudoers

RUN yum -y --setopt=group_package_types=mandatory,default,optional group install "Development Tools" && \
    yum -y erase java-1.8.0-openjdk

RUN echo -e "[cfx]\nname = CFX Packages for Enterprise Linux \$releasever - \$basearch\nbaseurl = https://repo.chanfx.com/yum/cfx_yum_repo/\$releasever\n#mirrorlist = https://mirrors.chanfx.com/metalink?repo=cfx-\$releasever&arch=\$basearch\nfailovermethod = priority\nenabled = 1\npriority = 50\nprotect = 0\ngpgcheck = 0\nsslverify = 0\ngpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CFX-7" > /etc/yum.repos.d/cfx.repo

RUN yum -y install \
  git \
  gzip \
  jdk \
  jq \
  jq-devel \
  maven \
  openssh-clients \
  openssh-server \
  passwd \
  python-pip \
  sudo \
  tar \
  unzip \
  wget \
  which \
  && yum clean all

# Clean up YUM when done.
RUN rm -f /etc/yum.repos.d/cfx.repo && yum clean all

RUN pip install --upgrade pip setuptools

ADD scripts ${SCRIPTS_HOME}
RUN chmod +x ${SCRIPTS_HOME}/*.sh

RUN mkdir -p ${JENKINS_HOME}/.ssh
ADD files/ssh_config ${JENKINS_HOME}/.ssh/config
RUN chown -R $user.$group ${JENKINS_HOME}/.ssh && \
    chmod 644 ${JENKINS_HOME}/.ssh/config && \
    chown $user ${JAVA_HOME}/jre/lib/security/cacerts

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

# Install Hashicorp Tools
RUN wget --directory-prefix=/tmp https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip /tmp/packer_${PACKER_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    wget --directory-prefix=/tmp https://releases.hashicorp.com/vagrant/${VAGRANT_VERSION}/vagrant_${VAGRANT_VERSION}_x86_64.rpm && \
    rpm -i /tmp/vagrant_${VAGRANT_VERSION}_x86_64.rpm && \
    wget --directory-prefix=/tmp https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip && \
    unzip /tmp/vault_${VAULT_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    wget --directory-prefix=/tmp https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip /tmp/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin && \
    wget --directory-prefix=/tmp https://github.com/hashicorp/atlas-upload-cli/releases/download/v${ATLAS_CLI_VERSION}/atlas-upload-cli_${ATLAS_CLI_VERSION}_linux_amd64.tar.gz && \
    ls -All /tmp && \
    tar xzf /tmp/atlas-upload-cli_${ATLAS_CLI_VERSION}_linux_amd64.tar.gz -C /usr/local/bin && \
    mkdir -p ${VAGRANT_HOME} && \
    chown -R ${CONTAINER_USER}:${CONTAINER_GROUP} ${VAGRANT_HOME} && \
    rm -rf /tmp/*

# Install Virtualbox (Example version: 5.1.18_114002_el7-1)
RUN mkdir -p /opt/virtualbox && \
    cd /etc/yum.repos.d/ && \
    wget http://download.virtualbox.org/virtualbox/rpm/el/virtualbox.repo && \
    yum install -y \
      dkms \
      kernel-devel && \
    yum -y groupinstall "Development Tools" && \
    if  [ "${VIRTUALBOX_VERSION}" = "latest" ]; then \
      yum install -y VirtualBox-5.1 ; else \
      yum install -y VirtualBox-5.1-${VIRTUALBOX_VERSION} ; \
    fi && \
    yum clean all && rm -rf /var/cache/yum/*

RUN wget -O $JENKINS_HOME/swarm-client-3.3.jar https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.3/swarm-client-3.3.jar

USER ${user}

VOLUME ${VAGRANT_HOME}

ENTRYPOINT ["/scripts/startup.sh"]
