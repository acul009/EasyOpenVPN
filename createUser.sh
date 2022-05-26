 #!/bin/bash
 if [ $# -ne 1 ] ; then
    echo "usage: createUser.sh <username>"
    exit
 fi
 if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi
sudo docker exec -ti openvpn ./createClient.sh $1
