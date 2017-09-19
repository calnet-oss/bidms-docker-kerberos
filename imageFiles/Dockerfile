#
# Copyright (c) 2017, Regents of the University of California and
# contributors.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# 
FROM bidms/debian_base

ARG APT_PROXY_URL=
RUN if [ ! -z "$APT_PROXY_URL" ]; then echo "Acquire::http::Proxy \"$APT_PROXY_URL\";" > /etc/apt/apt.conf.d/00aptproxy; else echo "not using apt proxy"; fi

RUN set -x \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y krb5-kdc krb5-user krb5-admin-server \
       wamerican-huge expect \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /core

RUN mkdir /var/log/kerberos

COPY etc/krb5.conf /etc
COPY etc/krb5kdc/* /etc/krb5kdc/

ARG KRB_REALM=EXAMPLE.COM
ARG KRB_DOMAIN=example.com

RUN sed -i "s/EXAMPLE\.COM/$KRB_REALM/" /etc/krb5.conf \
  && sed -i "s/example\.com/$KRB_DOMAIN/" /etc/krb5.conf \
  && sed -i "s/EXAMPLE\.COM/$KRB_REALM/" /etc/krb5kdc/kdc.conf \
  && sed -i "s/EXAMPLE\.COM/$KRB_REALM/" /etc/krb5kdc/kadm5.acl

COPY tmp_passwords/ /tmp/tmp_passwords/

RUN mkdir -p /v1/krb5kdc/etc /v1/krb5kdc/var /v1/private \
  && chmod 750 /v1/private

# Initialize the KDC database
RUN if [ -f /tmp/tmp_passwords/kdc_master_pw ]; then \
       echo "Using KDC master password from tmp_passwords/kdc_master_pw"; \
       KDC_MASTER_PW_FILE=/tmp/tmp_passwords/kdc_master_pw; \
     else \
       echo "Using default insecure KDC master password from tmp_passwords/kdc_master_pw.template"; \
       KDC_MASTER_PW_FILE=/tmp/tmp_passwords/kdc_master_pw.template; \
     fi \
  && sed -i "s/EXAMPLE\.COM/$KRB_REALM/" /tmp/tmp_passwords/create_realm.exp \
  && sed -i "s#KDC_MASTER_PW_FILE#$KDC_MASTER_PW_FILE#" /tmp/tmp_passwords/create_realm.exp \
  && expect -f /tmp/tmp_passwords/create_realm.exp

# Add default policy
RUN kadmin.local addpol -maxlife 0 -minlife 0 -minlength 9 -minclasses 3 -history 2 -maxfailure 10 -failurecountinterval 00:05:00 -lockoutduration 00:15:00 default

# Add the admin/admin principal
RUN if [ -f /tmp/tmp_passwords/kdc_admin_pw ]; then \
       echo "Using KDC admin password from tmp_passwords/kdc_admin_pw"; \
       KDC_ADMIN_PW_FILE=/tmp/tmp_passwords/kdc_admin_pw; \
     else \
       echo "Using default insecure KDC admin password from tmp_passwords/kdc_admin_pw.template"; \
       KDC_ADMIN_PW_FILE=/tmp/tmp_passwords/kdc_admin_pw.template; \
     fi \
  && sed -i "s/EXAMPLE\.COM/$KRB_REALM/" /tmp/tmp_passwords/add_admin_princ.exp \
  && sed -i "s#KDC_ADMIN_PW_FILE#$KDC_ADMIN_PW_FILE#" /tmp/tmp_passwords/add_admin_princ.exp \
  && expect -f /tmp/tmp_passwords/add_admin_princ.exp

# Add add/admin principal
RUN if [ -f /tmp/tmp_passwords/kdc_add_admin_pw ]; then \
       echo "Using KDC add_admin password from tmp_passwords/kdc_add_admin_pw"; \
       KDC_ADD_ADMIN_PW_FILE=/tmp/tmp_passwords/kdc_add_admin_pw; \
     else \
       echo "Using default insecure KDC add_admin password from tmp_passwords/kdc_add_admin_pw.template"; \
       KDC_ADD_ADMIN_PW_FILE=/tmp/tmp_passwords/kdc_add_admin_pw.template; \
     fi \
  && sed -i "s/EXAMPLE\.COM/$KRB_REALM/" /tmp/tmp_passwords/add_add_admin_princ.exp \
  && sed -i "s#KDC_ADD_ADMIN_PW_FILE#$KDC_ADD_ADMIN_PW_FILE#" /tmp/tmp_passwords/add_add_admin_princ.exp \
  && expect -f /tmp/tmp_passwords/add_add_admin_princ.exp \
  && kadmin.local ktadd -norandkey -k /v1/private/add-admin.keytab add/admin

# Add chpw/admin principal
RUN if [ -f /tmp/tmp_passwords/kdc_chpw_admin_pw ]; then \
       echo "Using KDC chpw_admin password from tmp_passwords/kdc_chpw_admin_pw"; \
       KDC_CHPW_ADMIN_PW_FILE=/tmp/tmp_passwords/kdc_chpw_admin_pw; \
     else \
       echo "Using default insecure KDC chpw_admin password from tmp_passwords/kdc_chpw_admin_pw.template"; \
       KDC_CHPW_ADMIN_PW_FILE=/tmp/tmp_passwords/kdc_chpw_admin_pw.template; \
     fi \
  && sed -i "s/EXAMPLE\.COM/$KRB_REALM/" /tmp/tmp_passwords/add_chpw_admin_princ.exp \
  && sed -i "s#KDC_CHPW_ADMIN_PW_FILE#$KDC_CHPW_ADMIN_PW_FILE#" /tmp/tmp_passwords/add_chpw_admin_princ.exp \
  && expect -f /tmp/tmp_passwords/add_chpw_admin_princ.exp \
  && kadmin.local ktadd -norandkey -k /v1/private/chpw-admin.keytab chpw/admin

# Add krbproxy/ucb-krbservice principal -- only needed at UCB
RUN if [ -f /tmp/tmp_passwords/kdc_krbproxy_krbservice_pw ]; then \
       echo "Using KDC krbproxy-krbservice password from tmp_passwords/kdc_krbproxy_krbservice_pw"; \
       KDC_KRBPROXY_KRBSERVICE_PW_FILE=/tmp/tmp_passwords/kdc_krbproxy_krbservice_pw; \
     else \
       echo "Using default insecure KDC krbproxy-krbservice password from tmp_passwords/kdc_krbproxy_krbservice_pw.template"; \
       KDC_KRBPROXY_KRBSERVICE_PW_FILE=/tmp/tmp_passwords/kdc_krbproxy_krbservice_pw.template; \
     fi \
  && sed -i "s/EXAMPLE\.COM/$KRB_REALM/" /tmp/tmp_passwords/add_krbproxy-krbservice_princ.exp \
  && sed -i "s#KDC_KRBPROXY_KRBSERVICE_PW_FILE#$KDC_KRBPROXY_KRBSERVICE_PW_FILE#" /tmp/tmp_passwords/add_krbproxy-krbservice_princ.exp \
  && expect -f /tmp/tmp_passwords/add_krbproxy-krbservice_princ.exp \
  && kadmin.local ktadd -norandkey -k /v1/private/krbproxy-krbservice.keytab chpw/admin

RUN set -x \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get purge -y expect \
  && apt-get -y autoremove \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /core

RUN rm -rf /tmp/tmp_passwords

COPY etc/container/ /etc/container/
ENTRYPOINT ["/etc/container/krb-entrypoint.sh", "interactive"]

EXPOSE 750/udp
EXPOSE 88/udp
EXPOSE 749/tcp

# Use 'docker inspect <name>' to find the volume files on the host.
# <name> is the value of the --name parameter when invoking docker run.
VOLUME /v1

RUN rm -f /core
