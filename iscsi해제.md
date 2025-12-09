# Linux iSCSI 연결 해제 가이드

iSCSI Target과 Initiator 간에 구성된 디스크 연결을 해제하는 방법입니다.

---

## 1️⃣ Initiator 서버 (iSCSI 디스크 받는 서버)
```bash
# 마운트 해제
umount /iscsiVolume

# 부팅 시 자동 마운트(fstab) 제거
sed -i '/\/iscsiVolume/d' /etc/fstab
# 또는 /etc/fstab에서 해당 라인을 수동으로 삭제합니다.

# iSCSI Target 로그아웃
iscsiadm -m node -T iqn.2025-12.com.test:1234 -u

# iSCSI 세션 삭제 (선택 사항)
iscsiadm -m node -o delete -T iqn.2025-12.com.test:1234

# iSCSI 서비스 중지 (필요 시)
systemctl stop iscsid
systemctl disable iscsid
```

## 2️⃣ Target 서버 (디스크 제공 서버)
```bash
코드 복사
# Target LUN 및 ACL 제거
targetcli
ls

# LUN 삭제
iscsi/iqn.2025-12.com.test:1234/tpg1/luns delete 0

# ACL 삭제
iscsi/iqn.2025-12.com.test:1234/tpg1/acls delete iqn.1994-05.com.redhat:d4dd30d5426

# 포털 삭제 (원하면)
iscsi/iqn.2025-12.com.test:1234/tpg1/portals delete 192.168.150.140

# Target 삭제 (원하면)
iscsi delete iqn.2025-12.com.test:1234
exit

# Target 서비스 중지 (선택 사항)
systemctl stop target
systemctl disable target

```

💡 요약
Initiator: 마운트 해제 → fstab 삭제 → 로그아웃 → 세션 삭제

Target: LUN/ACL 삭제 → 포털 삭제 → Target 삭제
