#!/bin/bash
# shellcheck disable=SC1091,SC2164,SC2034,SC1072,SC1073,SC1009

CLIENTEXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c -E "/CN=$1\$")
if [[ $CLIENTEXISTS == '1' ]]; then
	echo ""
	echo "The specified client CN was already found in easy-rsa, please choose another name."
	exit
else
	cd /etc/openvpn/easy-rsa/ || return
	
		./easyrsa build-client-full "$1" nopass
		;;
		
	esac
	echo "Client $1 added."
fi


	# if not SUDO_USER, use /root
homeDir="/root"

# Determine if we use tls-auth or tls-crypt
if grep -qs "^tls-crypt" /etc/openvpn/server.conf; then
	TLS_SIG="1"
elif grep -qs "^tls-auth" /etc/openvpn/server.conf; then
	TLS_SIG="2"
fi

# Generates the custom client.ovpn
cp /etc/openvpn/client-template.txt "$homeDir/$1.ovpn"
{
	echo "<ca>"
	cat "/etc/openvpn/easy-rsa/pki/ca.crt"
	echo "</ca>"

	echo "<cert>"
	awk '/BEGIN/,/END/' "/etc/openvpn/easy-rsa/pki/issued/$CLIENT.crt"
	echo "</cert>"

	echo "<key>"
	cat "/etc/openvpn/easy-rsa/pki/private/$CLIENT.key"
	echo "</key>"

	case $TLS_SIG in
	1)
		echo "<tls-crypt>"
		cat /etc/openvpn/tls-crypt.key
		echo "</tls-crypt>"
		;;
	2)
		echo "key-direction 1"
		echo "<tls-auth>"
		cat /etc/openvpn/tls-auth.key
		echo "</tls-auth>"
		;;
	esac
} >>"$homeDir/$1.ovpn"
