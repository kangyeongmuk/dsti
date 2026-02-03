#!/bin/bash
# Rocky Linux 멀티게이트웨이 (Policy-Based Routing) 설정 스크립트
# bond0: 192.168.150.181 → gateway 192.168.150.1 (table 100)
# bond1: 192.168.200.141 → gateway 192.168.200.1 (table 200)

set -e  # 에러 발생 시 바로 종료

echo "기존 gateway 제거 및 never-default 설정 중..."
nmcli con mod bond0 ipv4.gateway "" ipv4.never-default yes
nmcli con mod bond1 ipv4.gateway "" ipv4.never-default yes

echo "bond0 PBR 설정 (table 100)..."
nmcli con mod bond0 \
  ipv4.routes "0.0.0.0/0 192.168.150.1 table=100" \
  ipv4.routing-rules "priority 100 from 192.168.150.181/32 table 100" \
  ipv4.route-metric 100

echo "bond1 PBR 설정 (table 200)..."
nmcli con mod bond1 \
  ipv4.routes "0.0.0.0/0 192.168.200.1 table=200" \
  ipv4.routing-rules "priority 200 from 192.168.200.141/32 table 200" \
  ipv4.route-metric 200

echo "NetworkManager 재시작 및 연결 업..."
nmcli con reload
nmcli con up bond0 || true
nmcli con up bond1 || true
# systemctl restart NetworkManager  # 필요 시 주석 해제 (재시작이 강력하지만 약간 느림)

echo ""
echo "=== 설정 확인 ==="
echo "1. Policy Rules:"
ip rule show | grep -E '100|200'

echo ""
echo "2. Table 100 (bond0):"
ip route show table 100

echo ""
echo "3. Table 200 (bond1):"
ip route show table 200

echo ""
echo "4. Main Table:"
ip route show table main

echo ""
echo "5. Source별 경로 테스트:"
echo "from 192.168.150.181 →"
ip route get 8.8.8.8 from 192.168.150.181
echo ""
echo "from 192.168.200.141 →"
ip route get 8.8.8.8 from 192.168.200.141

echo ""
echo "설정 완료! 문제가 있으면 위 출력 결과를 확인하세요."
echo "인터페이스가 down 상태라면 아래 명령으로 올려주세요:"
echo "ip link set bond0 up; ip link set bond1 up"
