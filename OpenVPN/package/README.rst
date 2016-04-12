OpenVPN for Murano
============================
Biarca Team developed a Murano package for OpenVPN application.
On deployment it establishes VPN bridge network on private OpenStack and
sets up a private secure VPN tunnel to public cloud providers such as GCE.
Murano Kubernetes cluster can deploy on top of OpenVPN to provide a hybrid cloud cluster strategy.

Overview of OpenVPN
----------------------
OpenVPN allows for a secure & encrypted channel of communication between
end points on different networks. It does so by createing secure
ethernet bridges using virtual tap devices. This feature enables nodes
on private network to on-board nodes on the public network to present a
seemless and virtually unified cluster in a hybrid environment.

How murano installs OpenVPN
---------------------------
Murano copies the reqiure templates, OpenVPN server and client script files from the package to instance.
Creates the conf file in the instance and get the variable values as arguments to this script from the UI forms.
From murano pl it invokes the deploy OpenVPN server.

OpenVPN Server
--------------
server.sh script adds a bridge interface, Create a *new* directory and prepare it to be used as a (CA) key management directory
(to create and store keys and certificates)and tap interface and generate server certificates, Setup the CA,
create the first server certificate. We had created a couple of new scripts to be used by the openvpn server i.e, down.sh and up.sh
and make both scripts executable. Then created server.conf to confiuring openvpn itself. Restart the openvpn and it loads the new config.

OpenVPN Client
--------------
It creates a client certificate and key files and setting up a client configuration file.
Client.sh script installs openvpn on client machine and generates clinet certificates and key files in server instance and
place the certificates and key files on client machines from server instance using secure copy.

Port Disabling
---------------
It removes a security group of an instance and disable the security port of instance using OpenStack Rest APIs to communicate with public
cloud instances.

Python flask server
---------------
This file invokes create-tap.sh when the API (/api/v1/create/) gets a request.
It returns id_rsa.pub key when get the request from /api/v1/id_rsa API. It generates client certs
and key files on OpenVPN server instance and copy to clients when get a request via REST API.


Physical & Logical Network Topology
----------------------------------

.. image:: https://github.com/biarca-nareshtr/murano-apps/blob/master/OpenVPN/Physical.Logical.Network.Topology.JPG

