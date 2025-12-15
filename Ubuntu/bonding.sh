#!/bin/bash

echo "=== Ubuntu Netplan Bond 설정 스크립트 (networkd) ==="
echo

read -p "Bond 이름 (default: bond0): " BOND_NAME
BOND_NAME=${BOND_NAME:-bond0}

read -p "Slave NIC 1 (예: ens160): " SLAVE1
read -p "Slave NIC 2 (예: ens192): " SLAVE2

read -p "IP 주소 (예: 192.168.10.100): " IP_ADDR
read -p "Prefix (예: 24): " PREFIX
read -p "Gateway (예: 192.168.10.1): " GATEWAY

read -p "Primary NIC (default: $SLAVE1): " PRIMARY
PRIMARY=${PRIMARY:-$SLAVE1}

NETPLAN_FILE="/etc/netplan/00-installer-config.yaml"

echo
echo "===== 설정 확인 ====="
echo " Bond Name   : $BOND_NAME"
echo " Slave NICs  : $SLAVE1, $SLAVE2"
echo " IP Address : $IP_ADDR/$PREFIX"
echo " Gateway    : $GATEWAY"
echo " Primary    : $PRIMARY"
echo "======================"
echo

read -p "이대로 적용할까요? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
  echo "취소됨"
  exit 1
fi

echo "기존 netplan 파일 백업 중..."
sudo mv $NETPLAN_FILE ${NETPLAN_FILE}.bak 2>/dev/null

echo "netplan 설정 파일 생성 중..."

sudo tee $NETPLAN_FILE > /dev/null <<EOF
network:
  version: 2
  renderer: networkd

  ethernets:
    $SLAVE1:
      dhcp4: no
    $SLAVE2:
      dhcp4: no

  bonds:
    $BOND_NAME:
      interfaces:
        - $SLAVE1
        - $SLAVE2
      addresses:
        - $IP_ADDR/$PREFIX
      gateway4: $GATEWAY
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
      parameters:
        mode: active-backup
        primary: $PRIMARY
        mii-monitor-interval: 100
EOF

echo
echo "netplan 적용 중..."
sudo netplan apply

echo
echo "=== 완료 ==="
ip addr show $BOND_NAME
