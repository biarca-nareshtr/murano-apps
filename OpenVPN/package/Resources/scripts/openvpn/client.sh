#!/bin/bash
# This file generates certs on OpenVPN server and copy to clients when it call from deployOpenVPNClient.sh while deploying OpenVPN

set -e

# Parsing input parameters from conf
conf_file="/etc/os_openvpn/os_openvpn.conf"
gceUserName=$(awk -F "=" '/^gceUserName/ {print $2}' $conf_file)
gcePassword=$(awk -F "=" '/^gcePassword/ {print $2}' $conf_file)
gceNodesIp=$(awk -F "=" '/^gceNodesIp/ {print $2}' $conf_file)
publicServerPort=$(awk -F "=" '/^publicServerPort/ {print $2}' $conf_file)
publicServerIp=$(awk -F "=" '/^publicServerIp/ {print $2}' $conf_file)

# ssh key Generating
if [ ! -f ~/.ssh/id_rsa ]; then
   ssh-keygen -t rsa -f  ~/.ssh/id_rsa -N ''
fi


# Client IPs storing in a array
function create_client_array()
{
    while IFS=',' read -ra IP; do
        for i in "${IP[@]}"; do
            CLIENTS_ARRAY+=("$i")
        done
    done <<< "$gceNodesIp"
}

# This func creates client names like new0, new1, new2...
# Change name pattern if required. ex: pattern="client-"
function create-client-name() {
    pattern="client-"
    count=0
    while true
    do
       name="$pattern$count"
       if [ ! -f /etc/openvpn/easy-rsa/keys/$name.crt ] && [ ! -f /etc/openvpn/easy-rsa/keys/$name.key ]
       then
          CLIENT_NAME="$name"
          break
       else
          ((count=count+1))
          continue
       fi
    done
}

# Generating client certificates and copying
function gen_cert()
{
    clientname=$1
    gceIp=$2
    cd /etc/openvpn/easy-rsa
    # shellcheck disable=SC1091
    source ./vars
    ./pkitool ${clientname}

    sshpass -p ${gcePassword} ssh-copy-id ${gceUserName}@${gceIp} -o "StrictHostKeyChecking=no"

    ssh ${gceUserName}@${gceIp} uptime
    ssh ${gceUserName}@${gceIp} sudo apt-get update
    ssh ${gceUserName}@${gceIp} sudo apt-get install -y openvpn

    scp /opt/openvpn/templates/client.conf /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/easy-rsa/keys/ta.key /etc/openvpn/easy-rsa/keys/${clientname}.crt /etc/openvpn/easy-rsa/keys/${clientname}.key ${gceUserName}@${gceIp}:

    ssh ${gceUserName}@${gceIp} sed -ie s/SERVER_PORT/${publicServerPort}/ client.conf
    ssh ${gceUserName}@${gceIp} sed -ie s/SERVER_IP/${publicServerIp}/ client.conf
    ssh ${gceUserName}@${gceIp} sed -ie s/CLIENT/${clientname}/ client.conf
    ssh ${gceUserName}@${gceIp} sudo cp client.conf ca.crt ta.key ${clientname}.crt ${clientname}.key /etc/openvpn

    ssh ${gceUserName}@${gceIp} sudo service openvpn restart
}

# Client IPs stores in array
create_client_array

#parsing client IP from array and generating certificates for clients on OpenVPN Server
for ip in "${CLIENTS_ARRAY[@]}"
do

   create-client-name
   gen_cert $CLIENT_NAME $ip

done



