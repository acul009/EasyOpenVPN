#!/bin/bash

cd /etc/openvpn/certs

#creating config
if [[ ! -f "/etc/openvpn/server.conf" ]]
then
    echo "Creating config from template..."
    cp /etc/openvpn/template.conf /etc/openvpn/server.conf
    echo "push \"route $TARGET_NETWORK $TARGET_MASK\"" >> "/etc/openvpn/server.conf"
fi

#initializing all neccesary certificates
if [[ ! -d "/etc/openvpn/certs/pki" ]]
then
    echo "no existing pki found, regernerating"
    easyrsa init-pki
    EASYRSA_KEY_SIZE=2048 easyrsa gen-dh
    openvpn --genkey secret /etc/openvpn/certs/ta.key
    easyrsa build-ca
    easyrsa build-server-full OpenVPNServer nopass
    exit
fi

if [[ ! -d "/etc/openvpn/certs/clients" ]]
then
    mkdir -p /etc/openvpn/certs/clients
    chmod a+rw "/etc/openvpn/certs/clients"
fi

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]
then
    mknod /dev/net/tun c 10 200
fi

#setting forwarding rules
echo "enabling forwarding"
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
iptables -A FORWARD -i eth0 -o tun0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.0.0.0/8 ! -d 10.0.0.0/8 -o eth0 -j MASQUERADE

echo "----- Starting OpenVPN -----"
openvpn --config /etc/openvpn/server.conf
echo "----- Shutting Down OpenVPN -----"
