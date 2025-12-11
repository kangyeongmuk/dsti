#!/bin/bash

echo "=== Bond 인터페이스 생성 스크립트 ==="

read -p "Bond 이름 입력 (default: bond0): " BOND_NAME
BOND_NAME=${BOND_NAME:-bond0}

read -p "Bond 모드 입력 (default: active-backup): " BOND_MODE
BOND_MODE=${BOND_MODE:-active-backup}

read -p "Bond IP 주소 입력 (예: 192.168.137.155): " BOND_IP
read -p "Bond Prefix 입력 (예: 24): " BOND_PREFIX
read -p "Gateway 입력 (예: 192.168.137.1): " BOND_GW

# IP + Prefix 조합
BOND_ADDR="${BOND_IP}/${BOND_PREFIX}"

read -p "Slave NIC 1 이름 입력 (예: ens160): " SLAVE1
read -p "Slave NIC 2 이름 입력 (예: ens192): " SLAVE2

echo
echo "===== 입력값 확인 ====="
echo " Bond Name : $BOND_NAME"
echo " Bond Mode : $BOND_MODE"
echo " Bond IP   : $BOND_ADDR"
echo " Bond GW   : $BOND_GW"
echo " Slave1    : $SLAVE1 (Primary)"
echo " Slave2    : $SLAVE2"
echo "======================="

read -p "위 설정으로 생성할까요? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    echo "취소됨."
    exit 1
fi


echo "[1] 기존 Slave NIC 관련 프로파일 삭제"
nmcli connection delete $SLAVE1 2>/dev/null
nmcli connection delete $SLAVE2 2>/dev/null


echo "[2] Bond 생성 또는 수정"

nmcli connection add type bond \
    ifname $BOND_NAME con-name $BOND_NAME \
    mode $BOND_MODE ipv4.method manual \
    ipv4.addresses $BOND_ADDR ipv4.gateway $BOND_GW \
    bond.options "mode=$BOND_MODE,primary=$SLAVE1" \
    autoconnect yes 2>/dev/null

# Bond already exists → modify mode
if [[ $? -ne 0 ]]; then
    echo "→ Bond 이미 존재 → 수정"
    nmcli connection modify $BOND_NAME ipv4.addresses "$BOND_ADDR" ipv4.gateway "$BOND_GW" ipv4.method manual
    nmcli connection modify $BOND_NAME bond.options "mode=$BOND_MODE,primary=$SLAVE1"
    nmcli connection modify $BOND_NAME connection.autoconnect yes
fi


echo "[3] Slave NIC 추가 (slave-type=bond)"

nmcli connection add type ethernet slave-type bond \
    ifname $SLAVE1 con-name $SLAVE1 master $BOND_NAME

nmcli connection add type ethernet slave-type bond \
    ifname $SLAVE2 con-name $SLAVE2 master $BOND_NAME


echo "[4] Bond + Slave 인터페이스 DOWN"
nmcli connection down $BOND_NAME 2>/dev/null
nmcli connection down $SLAVE1 2>/dev/null
nmcli connection down $SLAVE2 2>/dev/null


echo "[5] 네트워크 설정 Reload"
nmcli connection reload


echo "[6] Bond + Slave 인터페이스 UP"
nmcli connection up $BOND_NAME
nmcli connection up $SLAVE1
nmcli connection up $SLAVE2


echo
echo "===== Bond 상태 (/proc/net/bonding/$BOND_NAME) ====="
cat /proc/net/bonding/$BOND_NAME || echo "Bond 정보 없음!"


echo
echo "===== NMCLI 장치 상태 ====="
nmcli device status | grep -e $BOND_NAME -e $SLAVE1 -e $SLAVE2


echo
echo "===== NMCLI 전체 프로필 목록 ====="
nmcli connection show


echo
echo "===== Bond 설정 완료! ====="
