#!/bin/sh

# TCP/UDP Chains
iptables -N TCP
iptables -N UDP

# Default rules for FORWARD/OUTPUT/INPUT
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -P INPUT DROP

# Allow for related/established
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Loopback
iptables -A INPUT -i lo -j ACCEPT

# Drop invalid packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Drop pings
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j DROP

# Attach TCP/UDP chains
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP

# DROP TCP RESET/UDP Streams
iptables -A INPUT -p udp -j DROP
iptables -A INPUT -p tcp -j DROP

# DROP the rest
iptables -A INPUT -j DROP

# Spoofing attack protection
iptables -t raw -I PREROUTING -m rpfilter --invert -j DROP

# Block SYN scan
iptables -I TCP -p tcp -m recent --update --seconds 60 --name TCP-PORTSCAN -j DROP

# Add hosts to rejected list
iptables -D INPUT -p tcp -j DROP
iptables -A INPUT -p tcp -m recent --set --name TCP-PORTSCAN -j DROP

# Block UDP scans
iptables -I UDP -p udp -m recent --update --seconds 60 --name UDP-PORTSCAN -j DROP
iptables -D INPUT -p udp -j DROP
iptables -A INPUT -p udp -m recent --set --name UDP-PORTSCAN -j DROP

# Restore final rule
iptables -D INPUT -j DROP
iptables -A INPUT -j DROP

