#!/bin/bash
# This will invoke client.sh which generates client.crt client.key files in server instance and copy to clients such as GCE
bash /opt/openvpn/client.sh >> /tmp/openvpn-client.log
