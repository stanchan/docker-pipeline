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
# Creates a base CentOS 7 image with Nexus
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

ENV nexusversion="3.3.0-01" \
    os="centos" \
    osversion="7"

RUN echo -e "[cfx]\nname = CFX Packages for Enterprise Linux \$releasever - \$basearch\nbaseurl = https://repo.chanfx.com/yum/cfx_yum_repo/\$releasever\n#mirrorlist = https://mirrors.chanfx.com/metalink?repo=cfx-\$releasever&arch=\$basearch\nfailovermethod = priority\nenabled = 1\npriority = 50\nprotect = 0\ngpgcheck = 0\nsslverify = 0\ngpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CFX-7" > /etc/yum.repos.d/cfx.repo

#RUN yum -y install epel-release && \
#    yum clean all

RUN yum -y update && yum clean all

RUN yum -y install \
  curl \
  git \
  jdk \
  jq \
  jq-devel \
  sudo \
  tar \
  unzip \
  which \
  && yum clean all

ARG NEXUS_VERSION=3.3.0-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz

ENV JAVA_HOME=/usr/java \
  JAVA_VERSION_MAJOR=8 \
  JAVA_VERSION_MINOR=121 \
  JAVA_VERSION_BUILD=13

ENV SONATYPE_DIR=/opt/sonatype
ENV NEXUS_HOME=${SONATYPE_DIR}/nexus \
  NEXUS_DATA=/nexus-data \
  NEXUS_CONTEXT='' \
  SONATYPE_WORK=${SONATYPE_DIR}/sonatype-work

RUN mkdir -p ${NEXUS_HOME} \
  && curl --fail --silent --location --retry 3 \
  ${NEXUS_DOWNLOAD_URL} \
  | gunzip \
  | tar x -C ${NEXUS_HOME} --strip-components=1 nexus-${NEXUS_VERSION} \
  && chown -R root:root ${NEXUS_HOME}

RUN sed \
    -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' \
    -i ${NEXUS_HOME}/etc/nexus-default.properties

RUN useradd -r -u 200 -m -c "nexus role account" -d ${NEXUS_DATA} -s /bin/false nexus \
  && mkdir -p ${NEXUS_DATA}/etc ${NEXUS_DATA}/log ${NEXUS_DATA}/tmp ${SONATYPE_WORK} \
  && ln -s ${NEXUS_DATA} ${SONATYPE_WORK}/nexus3 \
  && chown -R nexus:nexus ${NEXUS_DATA}

VOLUME ${NEXUS_DATA}

EXPOSE 8081
USER nexus
WORKDIR ${NEXUS_HOME}

ENV JAVA_MAX_MEM=1200m \
  JAVA_MIN_MEM=1200m \
  EXTRA_JAVA_OPTS=""

CMD ["bin/nexus", "run"]
