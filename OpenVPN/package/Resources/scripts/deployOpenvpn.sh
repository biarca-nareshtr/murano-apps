#!/bin/bash

# This file deploys the OpenVPN server in Instance
# Procedure:
# Copies the reqiure templetes and openvpn server&client script files from package to Instance
# Creates the conf file (/etc/os_openvpn/os_openvpn.conf) in instance and
# get the variables values as argumns to this script from the UI forms
# Finally invokes server.sh file which deploys a OpenVPN server

# $1 - tapDhcpBegin
# $2 - tapDhcpEnd
# $3 - netmask
# $4 - gceUserName
# $5 - gcePassword
# $6 - gceNodesIp
# $7 - publicServerPort
# $8 - publicServerIp
# $9 - instance name
# $10 - environment name
# $11 - OPENSTACK_IP
# $12 - tenant
# $13 - username
# $14 - password

openvpn_conf="/etc/os_openvpn/os_openvpn.conf"
mkdir -p /etc/os_openvpn
sudo touch ${openvpn_conf}
echo "[DEFAULT]" >> ${openvpn_conf}
echo "TAP_DHCP_BEGIN=${1}" >> ${openvpn_conf}
echo "TAP_DHCP_END=${2}" >> ${openvpn_conf}
echo "netmask=${3}" >> ${openvpn_conf}
echo " " >> ${openvpn_conf}
echo "[GCE]" >> ${openvpn_conf}
echo "gceUserName=${12}" >> ${openvpn_conf}
echo "gcePassword=${13}" >> ${openvpn_conf}
echo "gceNodesIp=${14}" >> ${openvpn_conf}
echo "publicServerPort=${4}" >> ${openvpn_conf}
echo "publicServerIp=${5}" >> ${openvpn_conf}
echo " " >> ${openvpn_conf}
echo "[INSTANCE]" >> ${openvpn_conf}
echo "instanceName=${6}" >> ${openvpn_conf}
echo "envName=${7}" >> ${openvpn_conf}
echo "OPENSTACK_IP=${8}" >> ${openvpn_conf}
echo "tenant=${9}" >> ${openvpn_conf}
echo "username=${10}" >> ${openvpn_conf}
echo "password=${11}" >> ${openvpn_conf}

mkdir -p /opt/openvpn
mkdir -p /opt/openvpn/templates
cp openvpn/client.sh /opt/openvpn
cp openvpn/server.sh /opt/openvpn
cp openvpn/portDisable.py /opt/openvpn
cp openvpn/templates/client.conf /opt/openvpn/templates
cp openvpn/templates/down.sh /opt/openvpn/templates
cp openvpn/templates/interfaces /opt/openvpn/templates
cp openvpn/templates/server.conf /opt/openvpn/templates
cp openvpn/templates/up.sh /opt/openvpn/templates

bash /opt/openvpn/server.sh >> /tmp/openvpn-server.log
