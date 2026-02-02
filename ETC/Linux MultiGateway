# Rocky Linux 8 멀티 게이트웨이(PBR) 영구 적용 설정

## ✅ 환경

- **bond0** : `192.168.150.182/24`  
  - Gateway : `192.168.150.1` (기본 Default)

- **bond1** : `192.168.200.141/24`  
  - Gateway : `192.168.200.1` (Policy Routing)

목표:

- bond0, bond1 모두 동시에 통신 가능  
- Default Gateway는 bond0만 유지  
- bond1은 Policy Based Routing(PBR) 방식으로 분리  
- 재부팅 후에도 영구 적용

---

```bash
✅ 1) bond0만 기본 게이트웨이 설정
nmcli con mod bond0 ipv4.addresses 192.168.150.182/24
nmcli con mod bond0 ipv4.gateway 192.168.150.1
nmcli con mod bond0 ipv4.never-default no

✅ 2) bond1은 Policy Routing만 사용
nmcli con mod bond1 ipv4.addresses 192.168.200.141/24
nmcli con mod bond1 ipv4.never-default yes
nmcli con mod bond1 ipv4.route-table 200

✅ 3) bond1 Default Route는 table200에만 추가
nmcli con mod bond1 ipv4.routes "0.0.0.0/0 192.168.200.1"

✅ 4) bond1 소스 IP 트래픽은 table200으로 강제
nmcli con mod bond1 ipv4.routing-rules "priority 100 from 192.168.200.141 table 200"

✅ 5) rp_filter 끄기 (필수)
rp_filter가 켜져 있으면 bond1 트래픽이 드랍될 수 있음.

cat <<EOF > /etc/sysctl.d/99-multi-gw.conf
net.ipv4.conf.all.rp_filter=0
EOF

sysctl --system

✅ 6) 적용
systemctl restart NetworkManager

✅ 확인
라우팅 확인
ip route

Policy Rule 확인
ip rule

Table 200 확인
ip route show table 200

✅ 테스트

bond0 경로 테스트:
ping -I 192.168.150.182 8.8.8.8

bond1 경로 테스트:
ping -I 192.168.200.141 8.8.8.8
