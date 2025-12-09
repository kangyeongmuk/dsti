# Linux iSCSI 연결 해제 가이드

iSCSI Target과 Initiator 간에 구성된 디스크 연결을 해제하는 방법입니다.

---

## 1️⃣ Initiator 서버 (iSCSI 디스크 받는 서버)

### 1. 마운트 해제
```bash
umount /iscsiVolume
2. 부팅 시 자동 마운트(fstab) 제거
bash
코드 복사
sed -i '/\/iscsiVolume/d' /etc/fstab
또는 /etc/fstab에서 해당 라인을 수동으로 삭제합니다.

3. iSCSI Target 로그아웃
bash
코드 복사
iscsiadm -m node -T iqn.2025-12.com.test:1234 -u
4. iSCSI 세션 삭제 (선택 사항)
bash
코드 복사
iscsiadm -m node -o delete -T iqn.2025-12.com.test:1234
5. iSCSI 서비스 중지 (필요 시)
bash
코드 복사
systemctl stop iscsid
systemctl disable iscsid
2️⃣ Target 서버 (디스크 제공 서버)
1. Target LUN 및 ACL 제거
bash
코드 복사
targetcli
# 해당 Target 확인
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
2. Target 서비스 중지 (선택 사항)
bash
코드 복사
systemctl stop target
systemctl disable target
💡 요약
Initiator: 마운트 해제 → fstab 삭제 → 로그아웃 → 세션 삭제

Target: LUN/ACL 삭제 → 포털 삭제 → Target 삭제

yaml
코드 복사

---

원하면 제가 이걸 **GitHub에서 바로 예쁘게 보이도록 Table of Contents**까지 넣어서 md 완성본으로 만들어드릴 수도 있습니다.  
그렇게 해드릴까요?






나의 말:
그냥 한번만 복붙하게 해줘바


ChatGPT의 말:
좋아요, 그대로 한 번에 복붙할 수 있는 GitHub Markdown 버전입니다.

markdown
코드 복사
# Linux iSCSI 연결 해제 가이드

iSCSI Target과 Initiator 간에 구성된 디스크 연결을 해제하는 방법입니다.

---

## 1️⃣ Initiator 서버 (iSCSI 디스크 받는 서버)

### 1. 마운트 해제
```bash
umount /iscsiVolume
2. 부팅 시 자동 마운트(fstab) 제거
bash
코드 복사
sed -i '/\/iscsiVolume/d' /etc/fstab
또는 /etc/fstab에서 해당 라인을 수동으로 삭제합니다.

3. iSCSI Target 로그아웃
bash
코드 복사
iscsiadm -m node -T iqn.2025-12.com.test:1234 -u
4. iSCSI 세션 삭제 (선택 사항)
bash
코드 복사
iscsiadm -m node -o delete -T iqn.2025-12.com.test:1234
5. iSCSI 서비스 중지 (필요 시)
bash
코드 복사
systemctl stop iscsid
systemctl disable iscsid
2️⃣ Target 서버 (디스크 제공 서버)
1. Target LUN 및 ACL 제거
bash
코드 복사
targetcli
# 해당 Target 확인
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
2. Target 서비스 중지 (선택 사항)
bash
코드 복사
systemctl stop target
systemctl disable target
💡 요약
Initiator: 마운트 해제 → fstab 삭제 → 로그아웃 → 세션 삭제

Target: LUN/ACL 삭제 → 포털 삭제 → Target 삭제
