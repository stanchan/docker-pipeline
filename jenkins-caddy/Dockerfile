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
# Creates a base Alpine latest image with Caddy
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

FROM alpine:latest
MAINTAINER Stan Chan <stanchan@gmail.com>

LABEL caddy_version="0.10.0" architecture="amd64"

ENV CADDY_VERSION=0.10.0 \
	CADDYPATH=/root/.caddy \
	CADDY_TLS_MODE=caddy_tls_selfsigned

ARG plugins=dns,hook.service,http.awslambda,http.cgi,http.cors,http.expires,http.filemanager,http.filter,http.git,http.hugo,http.ipfilter,http.jwt,http.mailout,http.minify,http.ratelimit,http.realip,http.upload,net,tls.dns.namecheap,tls.dns.route53

RUN apk add --no-cache tini ca-certificates bash curl git openssh-client tar wget 

RUN params=$(echo ${plugins} | sed -e 's/,/%2C/') && \
    curl --silent --show-error --fail --location \
      --header "Accept: application/tar+gzip, application/x-gzip, application/octet-stream" -o - \
      "https://caddyserver.com/download/linux/amd64?plugins=${params}" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy && \
    chmod 0755 /usr/bin/caddy && \
    /usr/bin/caddy -version

RUN mkdir -p /etc/caddy
ADD files/sslmodes /etc/caddy/sslmodes
COPY Caddyfile /etc/Caddyfile
COPY index.html /var/www/html/index.html

EXPOSE 80 443 2015
VOLUME [ "/var/www/html", "/root/.caddy", "/srv" ]

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["caddy", "--conf", "/etc/Caddyfile", "--log", "stdout"]