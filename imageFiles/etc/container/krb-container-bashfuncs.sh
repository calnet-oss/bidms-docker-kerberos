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

function container_startup {
  if [ -e /etc/krb5kdc/shuttingdown ]; then
    rm /etc/krb5kdc/shuttingdown
  fi
  if [ -e /etc/krb5kdc/cleanshutdown ]; then
    rm /etc/krb5kdc/cleanshutdown
  fi
  /usr/sbin/syslogd
  /etc/init.d/krb5-kdc start
  /etc/init.d/krb5-admin-server start
}

function container_shutdown {
  touch /etc/krb5kdc/shuttingdown
  /etc/init.d/krb5-admin-server stop
  /etc/init.d/krb5-kdc stop
  echo ""
  kill -TERM $(cat /var/run/syslog.pid)
  echo "Processes still running after shutdown:" > /etc/krb5kdc/cleanshutdown
  ps -uxaw >> /etc/krb5kdc/cleanshutdown
  rm /etc/krb5kdc/shuttingdown
  exit
}
