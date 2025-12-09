# Linux iSCSI 구성 가이드 (Target + Initiator)

작성자: (작성자 이름)  
목적: Target 서버와 Initiator 서버에서 iSCSI 디스크 구성 방법  

---

## 1️⃣ Target 서버 (디스크 제공 서버)
**IP:** 192.168.150.140  
**역할:** iSCSI Target 설치, LUN 생성, 포털 설정, ACL 등록  

```bash
# [Target] 1.1 iSCSI Target 패키지 설치
yum install -y targetcli

# [Target] 1.2 target 서비스 시작 및 부팅 시 자동 등록
systemctl enable --now target

# [Target] 1.3 targetcli 쉘 실행
targetcli

# [Target] 1.4 iSCSI Target 생성 (IQN 지정)
iscsi create iqn.2025-12.com.test:1234

# [Target] 1.5 실제 디스크(/dev/sdb)를 백스토어로 등록
backstores/block create name=iscsi dev=/dev/sdb

# [Target] 1.6 iSCSI 접속 포털(IP) 생성 → Target 서버 IP 사용
iscsi/iqn.2025-12.com.test:1234/tpg1/portals create 192.168.150.140

# [Target] 1.7 LUN 생성 및 백스토어 연결
iscsi/iqn.2025-12.com.test:1234/tpg1/luns create /backstores/block/iscsi

# [Target] 1.8 ACL 생성 → Initiator(IP 192.168.150.142, IQN) 접근 허용
iscsi/iqn.2025-12.com.test:1234/tpg1/acls create iqn.1994-05.com.redhat:d4dd30d5426

# [Target] targetcli 종료
exit
