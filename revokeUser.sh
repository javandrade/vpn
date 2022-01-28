function revokeClient () {
	echo ""
	echo "Insira o usuário a ser revogado"
	until [[ "$CLIENT" =~ ^[a-zA-Z0-9_]+$ ]]; do
		read -rp "Usuario: " -e CLIENT
	done
    cd /etc/openvpn/easy-rsa
    ./easyrsa revoke "$CLIENT"
    ./easyrsa gen-crl 
    cp ./pki/crl.pem /etc/openvpn

	echo "Usuário $CLIENT regogado"
	exit 0
}
revokeClient
