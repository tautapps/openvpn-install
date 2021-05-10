#!/bin/bash
 
CLIENTEXISTS=$(tail -n +2 /etc/openvpn/easy-rsa/pki/index.txt | grep -c -E "/CN=$1\$")
 
 	cd /etc/openvpn/easy-rsa/ || return
	
		./easyrsa build-client-full "$1" nopass 

	# if not SUDO_USER, use /root
homeDir="/var/vpnkeys/"

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
	awk '/BEGIN/,/END/' "/etc/openvpn/easy-rsa/pki/issued/$1.crt"
	echo "</cert>"

	echo "<key>"
	cat "/etc/openvpn/easy-rsa/pki/private/$1.key"
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

cat "$homeDir/$1.ovpn"
