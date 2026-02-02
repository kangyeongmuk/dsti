# ✅ Rocky Linux 멀티 게이트웨이 영구 적용 가이드 (bond0 + bond1)

작성자: (작성자 이름)  
목적: Rocky Linux 8에서 bond0, bond1 두 인터페이스 모두 외부 통신 가능하도록  
**Policy Based Routing을 iproute 방식 그대로 영구 적용**  

---

## 1️⃣ 네트워크 구성 정보

**bond0 IP:** 192.168.150.184/24  
**bond0 Gateway:** 192.168.150.1  

**bond1 IP:** 192.168.200.141/24  
**bond1 Gateway:** 192.168.200.1  

---

## 2️⃣ 임시 설정(ip route/ip rule) → 영구 적용 방법

Rocky Linux 8에서는 아래 파일을 생성하면  
부팅 시 자동으로 정책 라우팅이 적용된다.

---

# ✅ bond0 영구 설정

---

### 📌 1) bond0 라우팅 테이블 파일 생성

```bash
vi /etc/sysconfig/network-scripts/route-bond0
```

내용:

```ini
192.168.150.0/24 dev bond0 src 192.168.150.184 table bond0tbl
default via 192.168.150.1 dev bond0 table bond0tbl
```

---

### 📌 2) bond0 Policy Rule 파일 생성

```bash
vi /etc/sysconfig/network-scripts/rule-bond0
```

내용:

```ini
from 192.168.150.184 table bond0tbl priority 100
```

---

# ✅ bond1 영구 설정

---

### 📌 3) bond1 라우팅 테이블 파일 생성

```bash
vi /etc/sysconfig/network-scripts/route-bond1
```

내용:

```ini
192.168.200.0/24 dev bond1 src 192.168.200.141 table bond1tbl
default via 192.168.200.1 dev bond1 table bond1tbl
```

---

### 📌 4) bond1 Policy Rule 파일 생성

```bash
vi /etc/sysconfig/network-scripts/rule-bond1
```

내용:

```ini
from 192.168.200.141 table bond1tbl priority 200
```

---

## 3️⃣ 적용 방법

설정 파일 작성 후 NetworkManager 재시작

```bash
systemctl restart NetworkManager
```

---

## 4️⃣ 최종 확인

```bash
ip rule show
```

정상 출력 예시:

```
from 192.168.150.184 lookup bond0tbl
from 192.168.200.141 lookup bond1tbl
```

---

```bash
ip route show table bond0tbl
ip route show table bond1tbl
```

---

## 5️⃣ 통신 테스트

```bash
ping -I bond0 8.8.8.8
ping -I bond1 8.8.8.8
```

둘 다 성공해야 정상이다.

---

✅ 이 방식은 nmcli 변환 없이  
임시로 성공했던 `ip route/ip rule` 설정을 그대로 영구 적용하는 정석이다.

---
