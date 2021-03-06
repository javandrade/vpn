#!/bin/bash
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
iptables -A INPUT -i eth0 -m state --state NEW -p udp --dport 1194 -j ACCEPT
iptables -A INPUT -i eth0 -m state --state NEW -p udp --dport 59417 -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
# regras de liberacao
iptables -A FORWARD -i tun0 -s 10.8.0.2/32 -d 10.158.0.0/20 -j ACCEPT # luis
######################################
iptables -A FORWARD -i tun0 -s 10.8.0.0/24 -j DROP
iptables -A FORWARD -i tun+ -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth0 -o tun+ -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -A OUTPUT -o tun+ -j ACCEPT


