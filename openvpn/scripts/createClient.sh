#!/bin/bash
 if [ $# -ne 1 ] ; then
    echo "usage: createClient <username>"
    exit
 fi

cd /etc/openvpn/certs

if [[ ! -f "/etc/openvpn/certs/pki/reqs/$1.req" ]]
then
    easyrsa build-client-full $1 nopass
else
    echo "client already exists"
fi

echo \
"dev tun
tls-client
remote ${SERVER_NAME} 1194
proto udp

pull

cipher AES-256-GCM

# sets the tls-cipher as client
#key-direction 1

# keep-alive ping
ping 10
" > "/etc/openvpn/certs/clients/$1.ovpn"

echo "<ca>" >> "/etc/openvpn/certs/clients/$1.ovpn"
cat /etc/openvpn/certs/pki/ca.crt >> "/etc/openvpn/certs/clients/$1.ovpn"
echo "</ca>" >> "/etc/openvpn/certs/clients/$1.ovpn"
echo "<cert>" >> "/etc/openvpn/certs/clients/$1.ovpn"
cat "/etc/openvpn/certs/pki/issued/$1.crt" >> "/etc/openvpn/certs/clients/$1.ovpn"
echo "</cert>" >> "/etc/openvpn/certs/clients/$1.ovpn"
echo "<key>" >> "/etc/openvpn/certs/clients/$1.ovpn"
cat "/etc/openvpn/certs/pki/private/$1.key" >> "/etc/openvpn/certs/clients/$1.ovpn"
echo "</key>" >> "/etc/openvpn/certs/clients/$1.ovpn"
echo "<tls-crypt>" >> "/etc/openvpn/certs/clients/$1.ovpn"
cat /etc/openvpn/certs/ta.key >> "/etc/openvpn/certs/clients/$1.ovpn"
echo "</tls-crypt>" >> "/etc/openvpn/certs/clients/$1.ovpn"

echo "----- Exporting Client Config To ./data/clients -----"
chmod a+rw "/etc/openvpn/certs/clients/$1.ovpn"

echo "Client config finished."
echo "Please download the file and delete it afterwards."
