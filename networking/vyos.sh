#!/usr/bin/env bash

# Named arguments
while getopts ":t:" opt; do
  case $opt in
    t) ssh_ip="$OPTARG"
    ;;
  esac
  case $OPTARG in
    -*)
      echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

[[ -z "${ssh_ip}" ]] && echo "Usage: $0 -t <user@ssh-ip>" && exit 0

public_ip="$(op-wrapper.sh read 'op://Personal/pvgd2k2gvpuwbkkryhoepth3dm/public-ip')"
gateway_ip="$(op-wrapper.sh read 'op://Personal/pvgd2k2gvpuwbkkryhoepth3dm/gateway-ip')"
password="$(op-wrapper.sh read 'op://Personal/pvgd2k2gvpuwbkkryhoepth3dm/password')"

echo "Attempting to run configuration against ${ssh_ip}"
ssh -o ConnectTimeout=3 "${ssh_ip}" 'vbash -s' <<EOF
source /opt/vyatta/etc/functions/script-template
configure

# Interface configuration
set interfaces ethernet eth0 address '${public_ip}/24'
set interfaces ethernet eth0 description 'WAN'
set interfaces ethernet eth1 address '10.0.50.1/24'
set interfaces ethernet eth1 description 'LAN'
# Alternate interface for LAN access (only use for emergencies)
set interfaces ethernet eth3 address '192.168.50.3/24'
set interfaces ethernet eth3 description 'MANAGEMENT_ALT'

#set default gateway
set protocols static route 0.0.0.0/0 next-hop ${gateway_ip}

# SSH configuration
set service ssh port 22
set service ssh listen-address 10.0.50.1
set service ssh listen-address 192.168.50.3 # alternate LAN port

# DHCP configuration
# Disabled, use static IPs on client devices
#set service dhcp-server shared-network-name LAN subnet 10.0.50.0/24 option default-router '10.0.50.1'
#set service dhcp-server shared-network-name LAN subnet 10.0.50.0/24 option name-server '10.0.50.1'
#set service dhcp-server shared-network-name LAN subnet 10.0.50.0/24 option domain-name 'heywoodlh.lan'
#set service dhcp-server shared-network-name LAN subnet 10.0.50.0/24 lease '86400'
#set service dhcp-server shared-network-name LAN subnet 10.0.50.0/24 range 0 start '10.0.50.9'
#set service dhcp-server shared-network-name LAN subnet 10.0.50.0/24 range 0 stop '10.0.50.254'
#set service dhcp-server shared-network-name LAN subnet 10.0.50.0/24 subnet-id '1'

# Allow DNS from LAN
set service dns forwarding cache-size '0'
set service dns forwarding listen-address '10.0.50.1'
set service dns forwarding allow-from '10.0.50.0/24'

# Masquerading
set nat source rule 100 outbound-interface name 'eth0'
set nat source rule 100 source address '10.0.50.0/24'
set nat source rule 100 translation address masquerade

# Firewall
## Group names
set firewall group interface-group WAN interface eth0
set firewall group interface-group LAN interface eth1
set firewall group network-group NET-INSIDE-v4 network '10.0.50.0/24'

## Default rules
set firewall global-options state-policy established action accept
set firewall global-options state-policy related action accept
set firewall global-options state-policy invalid action drop

## Block inbound traffic
set firewall ipv4 name OUTSIDE-IN default-action 'drop'
set firewall ipv4 forward filter rule 100 action jump
set firewall ipv4 forward filter rule 100 jump-target OUTSIDE-IN
set firewall ipv4 forward filter rule 100 inbound-interface group WAN
set firewall ipv4 forward filter rule 100 destination group network-group NET-INSIDE-v4

## Allow management access from LAN
set firewall ipv4 name MANAGEMENT default-action 'return'
set firewall ipv4 input filter rule 20 action jump
set firewall ipv4 input filter rule 20 jump-target MANAGEMENT
set firewall ipv4 input filter rule 20 destination port 22
set firewall ipv4 input filter rule 20 protocol tcp
set firewall ipv4 name MANAGEMENT rule 15 action 'accept'
set firewall ipv4 name MANAGEMENT rule 15 inbound-interface group 'LAN'
set firewall ipv4 name MANAGEMENT rule 20 action 'drop'
set firewall ipv4 name MANAGEMENT rule 20 recent count 4
set firewall ipv4 name MANAGEMENT rule 20 recent time minute
set firewall ipv4 name MANAGEMENT rule 20 state new
set firewall ipv4 name MANAGEMENT rule 20 inbound-interface group 'WAN'
set firewall ipv4 name MANAGEMENT rule 21 action 'accept'
set firewall ipv4 name MANAGEMENT rule 21 state new
set firewall ipv4 name MANAGEMENT rule 21 inbound-interface group 'WAN'

## Respond to ping
set firewall ipv4 input filter rule 30 action 'accept'
set firewall ipv4 input filter rule 30 icmp type-name 'echo-request'
set firewall ipv4 input filter rule 30 protocol 'icmp'
set firewall ipv4 input filter rule 30 state new

##  Allow DNS from LAN
set firewall ipv4 input filter rule 40 action 'accept'
set firewall ipv4 input filter rule 40 destination port '53'
set firewall ipv4 input filter rule 40 protocol 'tcp_udp'
set firewall ipv4 input filter rule 40 source group network-group NET-INSIDE-v4

## Allow all traffic from localhost
set firewall ipv4 input filter rule 50 action 'accept'
set firewall ipv4 input filter rule 50 source address 127.0.0.0/8

# User configuration
set system login user heywoodlh authentication plaintext-password ${password}
set system login user heywoodlh authentication public-keys 1password type ssh-rsa
set system login user heywoodlh authentication public-keys 1password key 'AAAAB3NzaC1yc2EAAAADAQABAAACAQCYn+7oSNHXN3qqDDidw42Vv7fDS0iEpYqaa0wCXRPBlfWAnD81f6dxj/QPGfZtxpl9jvk7nAKpE7RVUvQiJzUC2VM3Bw/4ucT+xliEHo3oesMQQa1AT70VPTbP5PdU7oUpgQWLq39j9XHno2YPJ/WWtuOl/UTjY6IDokkAmNmvft/jqqkiwSkGMmw68qrLFEM7+rNwJV5cXKvvpB6Gqc7qnbJmk1TZ1MRGW5eLjP9ofDqiyoLbnTm7Dw3iHn40GgTcnv5CWGpa0vrKnnLEGrgRB7kR/pyvfsjapkHz0PDvuinQov+MgJfV8B8PHdPC94dsS0DEWJplxhYojtsYa1VZy5zTEMNWICz1QG1yKHN1JQtpbEreHG6DVYvqwnKvK/XN5yiEeiamhD2oKnSh36PexIR0h0AAPO29Ln+anqpRlqJ0nET2CNS04e0vpV4VDJrG6BnyGUQ6CCo7THSq97F4Ne0nY9fpYu5WTFTCh1tTm+nSey0fP/xk22oINl/41VTI/Vk5pNQuuhHUvQupJHw9cD74aKzRddwvgfuAQjPlEuxxsqgFTltTiPF6lZQNeoMIc1OMCRsnl1xNqIepnb7Q5O1CGq+BqtOWh3G4/SPQI5ZUIkOAZegsnPpGWYMrRd7s6LJn5LrBYaY6IvRxmpGOig3tjOUy3fqk7coyTeJXmQ=='
set system login user heywoodlh authentication public-keys ipad-pro type ecdsa-sha2-nistp256
set system login user heywoodlh authentication public-keys ipad-pro key 'AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAm0/cQIuqSpF5G3s2lbvVgn9eEotzHypZg2NWUaA0PgB7GQvaDuLdqh0jknA0m4upmK9kYxsV05fWgqrvoRq8c='
set service ssh disable-password-authentication

# Delete vyos user
delete system login user vyos

## Port forward Plex to router
set nat destination rule 10 description 'Port Forward: Plex to 10.0.50.2'
set nat destination rule 10 destination port '32400'
set nat destination rule 10 inbound-interface name 'eth0'
set nat destination rule 10 protocol 'tcp'
set nat destination rule 10 translation address '10.0.50.2'

## Enable suricata
#set service suricata interface 'eth0'
#set service suricata interface 'eth1'

# Commit, and exit
commit
save
exit

#run update suricata
EOF
