# EasyOpenVPN

This little Projekt allows me to ramp up an OpenVPN-server in minutes.

## Requirements
docker

## Usage

### Starting the Server

    $ git clone https://github.com/acul009/EasyOpenVPN.git
  
    $ EasyOpenVPN/startVPN.sh <external domain or ip> <target network> <target netmask>
  
  e.g.:

    $ EasyOpenVPN/startVPN.sh vpn.example.com 192.168.0.0 255.255.255.0
  
  ### Adding a user
    $ EasyOpenVPN/createUser.sh <username>
  
  After the given command you can find the configuration inside the folder
    EasyOpenVPN/data/clients
  Download the file and then delete it from the server
