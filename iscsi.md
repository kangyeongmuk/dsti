<!--
Linux iSCSI 구성 스크립트 (Target/Initiator)
작성자: (작성자 이름)
목적: Target 서버와 Initiator 서버에서 iSCSI 디스크 구성 방법
-->

# 1️⃣ Target 서버 (디스크 제공 서버)
# IP: 192.168.150.140
# 역할: iSCSI Target 설치, LUN 생성, 포털 설정, ACL 등록

```bash
# 1.1 iSCSI Target 패키지 설치
yum install -y targetcli

# 1.2 target 서비스 시작 및 부팅 시 자동 등록
systemctl enable --now target

# 1.3 targetcli 쉘 실행
targetcli

# 1.4 iSCSI Target 생성 (IQN 지정)
# 쉘 안에서
/ > iscsi create iqn.2025-12.com.test:1234

# 1.5 실제 디스크(/dev/sdb)를 백스토어로 등록
/ > backstores/block create name=iscsi dev=/dev/sdb

# 1.6 iSCSI 접속 포털(IP) 생성 → Target 서버 IP 사용
/ > iscsi/iqn.2025-12.com.test:1234/tpg1/portals create 192.168.150.140

# 1.7 LUN 생성 및 백스토어 연결
/ > iscsi/iqn.2025-12.com.test:1234/tpg1/luns create /backstores/block/iscsi

# 3.1 ACL 생성 → Initiator(IP 142, IQN) 접근 허용
/ > iscsi/iqn.2025-12.com.test:1234/tpg1/acls create iqn.1994-05.com.redhat:d4dd30d5426

# 쉘 종료
/ > exit


# 2.1 iSCSI Initiator 패키지 설치
yum install -y iscsi-initiator-utils

# 2.2 Initiator IQN 확인
cat /etc/iscsi/initiatorname.iscsi
# 예: InitiatorName=iqn.1994-05.com.redhat:d4dd30d5426

# 3.2 Target 검색
iscsiadm -m discovery -t st -p 192.168.150.140

# 3.3 Target 로그인
iscsiadm -m node -T iqn.2025-12.com.test:1234 -l

# 3.4 Target 디스크 확인 및 파일시스템 생성
grep "Attached SCSI" /var/log/messages
mkfs.ext4 /dev/sdb

# 3.5 마운트 및 사용 가능 확인
mkdir /iscsiVolume
mount /dev/sdb /iscsiVolume/
df -Th

# 3.6 부팅 시 자동 마운트 등록
vi /etc/fstab
# 예시 라인:
/dev/sdb  /iscsiVolume  ext4  _netdev  0 0
