#!bin/bash
yum install -y openswan
cat <<EOF>> /etc/sysctl.conf
net.ipv4.ip_forward = 1
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv4.conf.eth0.send_redirects=0
EOF
sysctl -p /etc/sysctl.conf

printf "고객 게이트웨이 IP는> "
read leftid
printf "Tunnel1의 IP는> "
read right
printf "local subnet> "
read local
printf "remote subnet> "
read remote

cat<<EOF>> /etc/ipsec.d/aws.conf
conn Tunnel1
	authby=secret
	auto=start
	left=%defaultroute
	leftid="$leftid"
	right="$right"
	type=tunnel
	ikelifetime=8h
	keylife=1h
	phase2alg=aes128-sha1;modp1024
	ike=aes128-sha1;modp1024
	keyingtries=%forever
	keyexchange=ike
	leftsubnet="$local"
	rightsubnet="$remote"
	dpddelay=10
	dpdtimeout=30
	dpdaction=restart_by_peer
EOF

cat<<EOF> /etc/ipsec.d/aws.secrets
$leftid $right : PSK "password"
EOF

systemctl start ipsec & systctl enable ipsec