```bash
nmcli con mod bond0 ipv4.gateway ""
nmcli con mod bond0 ipv4.never-default yes

nmcli con mod bond1 ipv4.gateway ""
nmcli con mod bond1 ipv4.never-default yes

nmcli con mod bond0 \
  ipv4.routes "0.0.0.0/0 192.168.150.1 table=100" \
  ipv4.routing-rules "priority 100 from 192.168.150.181/32 table 100" \
  ipv4.route-metric 100

nmcli con mod bond1 \
  ipv4.routes "0.0.0.0/0 192.168.200.1 table=200" \
  ipv4.routing-rules "priority 200 from 192.168.200.141/32 table 200" \
  ipv4.route-metric 200

nmcli con reload
nmcli con up bond0
nmcli con up bond1

ip rule show | grep -E "100|200"
ip route show table 100
ip route show table 200
ip route show table main

ip route get 8.8.8.8 from 192.168.150.181
ip route get 8.8.8.8 from 192.168.200.141

ip link set bond0 up
ip link set bond1 up
