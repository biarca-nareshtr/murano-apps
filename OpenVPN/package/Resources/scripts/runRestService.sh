#!/bin/bash
# This file installs the python flask server and copies required files from package to OpenVPN
# server instance and it starts the vpn-clientgen service
apt-get install python-pip -y
pip install flask
cp openvpn/create-tap.sh /opt/openvpn/
cp openvpn/create-tap-server.py /opt/openvpn/
cp openvpn/vpn-clientgen  /etc/init.d/
chmod +x /etc/init.d/vpn-clientgen
service vpn-clientgen  start
