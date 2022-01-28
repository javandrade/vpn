function newClient () {
	echo ""
	echo "Insira o nome de usuário utilizando somente letras"
	until [[ "$CLIENT" =~ ^[a-zA-Z0-9_]+$ ]]; do
		read -rp "Client name: " -e CLIENT
	done
	echo ""
	echo "Do you want to protect the configuration file with a password?"
	echo "(e.g. encrypt the private key with a password)"
	echo "   1) Add a passwordless client"
	echo "   2) Use a password for the client"
	until [[ "$PASS" =~ ^[1-2]$ ]]; do
		read -rp "Select an option [1-2]: " -e -i 2 PASS
	done
	cd /etc/openvpn/easy-rsa/ || return
	case $PASS in
		1)
			./easyrsa build-client-full "$CLIENT" nopass
		;;
		2)
		echo "⚠️ You will be asked for the client password below ⚠️"
			./easyrsa build-client-full "$CLIENT"
		;;
	esac
	# Home directory of the user, where the client configuration (.ovpn) will be written
	if [ -e "/home/$CLIENT" ]; then  # if $1 is a user name
		homeDir="/home/$CLIENT"
	elif [ "${SUDO_USER}" ]; then # if not, use SUDO_USER
		homeDir="/home/${SUDO_USER}"
	else # if not SUDO_USER, use /root
		homeDir="/root"
	fi
	# Determine if we use tls-auth or tls-crypt
	if grep -qs "^tls-crypt" /etc/openvpn/server.conf; then
		TLS_SIG="1"
	elif grep -qs "^tls-auth" /etc/openvpn/server.conf; then
		TLS_SIG="2"
	fi
	# Generates the custom client.ovpn
	cp /etc/openvpn/client-template.txt "$homeDir/$CLIENT.ovpn"
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
	} >> "$homeDir/$CLIENT.ovpn"
	echo ""
	echo "Client $CLIENT added, the configuration file is available at $homeDir/$CLIENT.ovpn."
	echo "Download the .ovpn file and import it in your OpenVPN client."
	echo "** NECESSARIO CRIACAO DE REGRAS DE FIREWALL **"
	exit 0
}
newClient
