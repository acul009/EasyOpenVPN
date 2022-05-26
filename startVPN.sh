 #!/bin/bash
 if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi


 if [ $# -ne 3 ] ; then
    echo "usage: startVPN.sh <public address> <target subnet> <target mask>"
    echo "e.g.: startVPN.sh vpn.example.com 192.168.1.0 255.255.255.0"
    exit
 fi

#check for docker and install if neccesary
docker -v
if [ $? -ne 0 ]; then

   while true
   do
      read -r -p "Docker is not installed. Try installing it? [Y/n] " input

      case $input in
         [yY][eE][sS]|[yY])
            apt-get update
            apt-get install ca-certificates curl gnupg lsb-release
            mkdir -p /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
            echo \
               "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
               $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
            apt-get update
            apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
            break
            ;;
         [nN][oO]|[nN])
            exit 1
            ;;
         *)
                  ;;
      esac
done

else
    echo "Docker is already installed."
fi

mount=/docker/openvpn

echo "trying to stop old openvpn server"

docker stop openvpn
docker rm openvpn

echo "Building openvpn Image..."

docker build . -t openvpn --pull --no-cache

if [ $? -ne 0 ]
then
   echo "Error Building Image"
   exit 2
fi
echo "Build finished, spinning up openvpn-server"

mkdir data
chown $USER data
chgrp $USER data

docker run \
-ti \
--name=openvpn \
--cap-add=NET_ADMIN \
--restart=unless-stopped \
-v $(pwd)/data:/etc/openvpn/certs \
-e EASYRSA_REQ_ORG=OpenVPN-Provider \
-e SERVER_NAME=$1 \
-e TARGET_NETWORK=$2 \
-e TARGET_MASK=$3 \
-p 1194:1194/udp \
openvpn
