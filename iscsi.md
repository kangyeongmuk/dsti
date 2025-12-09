# Linux iSCSI 구성 가이드 (Target + Initiator)

작성자: (작성자 이름)  
목적: Target 서버와 Initiator 서버에서 iSCSI 디스크 구성 방법  

---

## 1️⃣ Target 서버 (디스크 제공 서버)
**IP:** 192.168.150.140  
**역할:** iSCSI Target 설치, LUN 생성, 포털 설정, ACL 등록  

```bash
# iSCSI Target 패키지 설치
yum install -y targetcli

# target 서비스 시작 및 부팅 시 자동 등록
systemctl enable --now target

# targetcli 쉘 실행
targetcli

# iSCSI Target 생성 (IQN 지정)
iscsi create iqn.2025-12.com.test:1234

# 실제 디스크(/dev/sdb)를 백스토어로 등록
backstores/block create name=iscsi dev=/dev/sdb

# iSCSI 접속 포털(IP) 생성
iscsi/iqn.2025-12.com.test:1234/tpg1/portals create 192.168.150.140

# LUN 생성 및 백스토어 연결
iscsi/iqn.2025-12.com.test:1234/tpg1/luns create /backstores/block/iscsi

# ACL 생성 → Initiator 접근 허용
iscsi/iqn.2025-12.com.test:1234/tpg1/acls create iqn.1994-05.com.redhat:d4dd30d5426

# targetcli 종료
exit

---

## 2️⃣ Initiator 서버 (디스크 받는 서버)
**IP: 192.168.150.142
**역할: Target 검색, 로그인, 디스크 마운트

```bash
# iSCSI Initiator 패키지 설치
yum install -y iscsi-initiator-utils

# Initiator IQN 확인
cat /etc/iscsi/initiatorname.iscsi
# 예시: InitiatorName=iqn.1994-05.com.redhat:d4dd30d5426

# Target 검색 (Target 서버 IP: 192.168.150.140)
iscsiadm -m discovery -t st -p 192.168.150.140

# Target 로그인
iscsiadm -m node -T iqn.2025-12.com.test:1234 -l

# Target 디스크 확인 및 파일시스템 생성
grep "Attached SCSI" /var/log/messages
mkfs.ext4 /dev/sdb

# 디스크 마운트 및 확인
mkdir -p /iscsiVolume
mount /dev/sdb /iscsiVolume/
df -Th

# 부팅 시 자동 마운트 등록
echo "/dev/sdb  /iscsiVolume  ext4  _netdev  0 0" >> /etc/fstab


# iSCSI Target 패키지 설치
yum install -y targetcli
# target 서비스 시작 및 부팅 시 자동 등록
systemctl enable --now target
# targetcli 쉘 실행
targetcli
# iSCSI Target 생성 (IQN 지정)
iscsi create iqn.2025-12.com.test:1234
# 실제 디스크(/dev/sdb)를 백스토어로 등록
backstores/block create name=iscsi dev=/dev/sdb
# iSCSI 접속 포털(IP) 생성
iscsi/iqn.2025-12.com.test:1234/tpg1/portals create 192.168.150.140
# LUN 생성 및 백스토어 연결
iscsi/iqn.2025-12.com.test:1234/tpg1/luns create /backstores/block/iscsi
# ACL 생성 → Initiator 접근 허용
iscsi/iqn.2025-12.com.test:1234/tpg1/acls create iqn.1994-05.com.redhat:d4dd30d5426
# targetcli 종료
exit

# iSCSI Initiator 패키지 설치
yum install -y iscsi-initiator-utils
# Initiator IQN 확인
cat /etc/iscsi/initiatorname.iscsi
# 예시: InitiatorName=iqn.1994-05.com.redhat:d4dd30d5426
# Target 검색 (Target 서버 IP: 192.168.150.140)
iscsiadm -m discovery -t st -p 192.168.150.140
# Target 로그인
iscsiadm -m node -T iqn.2025-12.com.test:1234 -l
# Target 디스크 확인 및 파일시스템 생성
grep "Attached SCSI" /var/log/messages
mkfs.ext4 /dev/sdb
# 디스크 마운트 및 확인
mkdir -p /iscsiVolume
mount /dev/sdb /iscsiVolume/
df -Th
# 부팅 시 자동 마운트 등록
echo "/dev/sdb /iscsiVolume ext4 _netdev 0 0" >> /etc/fstab

