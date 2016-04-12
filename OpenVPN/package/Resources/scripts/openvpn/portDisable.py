#!/usr/bin/python
"""
This file removes security group of an instance and
disable the security port of instance using OpenStack Rest APIs
"""
import json
import ConfigParser
import requests
import sys
import logging

logging.basicConfig(filename='/tmp/port-disable.log', level=logging.DEBUG)
data_file = "/etc/os_openvpn/os_openvpn.conf"

# parsing required input parameters from data file
config = ConfigParser.ConfigParser()
config.read(data_file)
config.sections()

instanceName = config.get('INSTANCE', 'instanceName')
envName = config.get('INSTANCE', 'envName')
OPENSTACK_IP = config.get('INSTANCE', 'OPENSTACK_IP')
tenant = config.get('INSTANCE', 'tenant')
username = config.get('INSTANCE', 'username')
password = config.get('INSTANCE', 'password')

token_id = ""
instance_info = None

# Default port numbers of OpenStack services
# Supports HTTPS method
public_endPoint = "5000"
neutron_service = "9696"
nova_endPoint = "8774"


def get_keystone_token():
    """
      Requesting for auth token using OpenStack REST api
    """
    global token_id
    url = 'https://{0}:{1}/v2.0/tokens'.format(OPENSTACK_IP, public_endPoint)
    data = ('{ "auth" : {"passwordCredentials": {"username": "'+username+'",'
            '"password": "'+password+'"}, "tenantName":"'+tenant+'"}}')
    try:
        request = requests.post(url, data=data, verify=False)
    except Exception:
        try:
            url = 'http://{0}:{1}/v2.0/tokens'.format(OPENSTACK_IP,
                                                      public_endPoint)
            request = requests.post(url, data=data)
        except Exception:
            logging.debug('Error while gettting auth token')
            logging.debug('%s', request.status_code)
            sys.exit(1)
    decode_response = (request.text.decode('utf-8'))
    string = str(decode_response)
    token_info = json.loads(string)
    try:
        token_id = token_info["access"]["token"]["id"]
    except Exception:
        sys.exit(1)
    logging.info('Received auth token')


def instance_details():
    """
       Receiving and parsing instance details.
       Looking for instance id, port id, security group id, tenant id
    """
    global instance_info
    url = 'https://{0}:{1}/v2.0/ports.json'.format(OPENSTACK_IP,
                                                   neutron_service)
    headers = {"X-Auth-Token": token_id}
    try:
        request = requests.get(url, headers=headers, verify=False)
    except Exception:
        try:
            url = 'http://{0}:{1}/v2.0/ports.json'.format(OPENSTACK_IP,
                                                          neutron_service)
            request = requests.get(url, headers=headers)
        except Exception:
            logging.debug('Error while gettting instance details')
            logging.debug('%s', request.status_code)
            sys.exit(1)
    decode_response = (request.text.decode('utf-8'))
    string = str(decode_response)
    ports_info = json.loads(string)
    for info in ports_info["ports"]:
        if instanceName in info['name']:
            instance_info = info
    logging.info('Received instance details')


def remove_secgroup():
    """
      Removing security group of an insatnce using REST api
    """
    try:
        port_id = instance_info['id']
    except Exception:
        sys.exit(1)
    url = 'https://{0}:{1}/v2.0/ports/{2}.json'.format(OPENSTACK_IP,
                                                       neutron_service,
                                                       port_id)
    headers = {"Content-Type": "application/json", "X-Auth-Token": token_id}
    data = '{"port": {"security_groups": []}}'
    try:
        request = requests.put(url, headers=headers, data=data, verify=False)
    except Exception:
        try:
            url = 'http://{0}:{1}/v2.0/ports/{2}.json'.format(OPENSTACK_IP,
                                                              neutron_service,
                                                              port_id)
            request = requests.put(url, headers=headers, data=data)
        except Exception:
            logging.debug('Error while removing secgroup of an instance')
            logging.debug('%s', request.status_code)
            sys.exit(1)
    logging.info('Security group has removed of an instance')


def port_disable():
    """
      Disabling security port
    """
    try:
        port_id = instance_info['id']
    except Exception:
        sys.exit(1)
    url = 'https://{0}:{1}/v2.0/ports/{2}.json'.format(OPENSTACK_IP,
                                                       neutron_service,
                                                       port_id)
    headers = {"Content-Type": "application/json", "X-Auth-Token": token_id}
    data = '{"port": {"port_security_enabled": "False"}}'
    try:
        request = requests.put(url, headers=headers, data=data, verify=False)
    except Exception:
        try:
            url = 'http://{0}:{1}/v2.0/ports/{2}.json'.format(OPENSTACK_IP,
                                                              neutron_service,
                                                              port_id)
            request = requests.put(url, headers=headers, data=data)
        except Exception:
            logging.debug('Error while disabling securtiy port')
            logging.debug('%s', request.status_code)
            sys.exit(1)
    logging.info('Disabled scurtiy port')

get_keystone_token()
instance_details()
remove_secgroup()
port_disable()
