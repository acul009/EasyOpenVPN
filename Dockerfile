FROM alpine
RUN apk update && apk upgrade && apk add openvpn easy-rsa bash iptables tini && \
    ln -s /usr/share/easy-rsa/easyrsa /bin

COPY openvpn/ /etc/openvpn/

ENV EASYRSA_REQ_ORG=OpenVPN-Provider \
    SERVER_NAME=vpn.example.com\
    EASYRSA_KEY_SIZE=4096 \
    DH_KEY_SIZE=2048 \
    EASYRSA_CA_EXPIRE=3650 \
    EASYRSA_CERT_EXPIRE=3650 \
    EASYRSA_DIGEST=sha512 \
    TARGET_NETWORK=0.0.0.0 \
    TARGET_MASK=0.0.0.0

EXPOSE 1194/udp
VOLUME /etc/openvpn/certs

ENTRYPOINT ["tini", "--"]
WORKDIR /etc/openvpn/scripts
RUN chmod +x /etc/openvpn/scripts/*.sh
CMD bash /etc/openvpn/scripts/start.sh
