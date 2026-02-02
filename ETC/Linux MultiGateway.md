# ✅ Rocky Linux 멀티 게이트웨이 구성 가이드 (bond0 + bond1)

작성자: (작성자 이름)  
목적: Rocky Linux 8에서 bond0, bond1 두 인터페이스 모두 외부 통신 가능하도록 Policy Based Routing을 영구 적용  

---

### 1️⃣ 네트워크 구성 정보

**bond0 IP:** 192.168.150.184/24  
**bond0 Gateway:** 192.168.150.1  

**bond1 IP:** 192.168.200.141/24  
**bond1 Gateway:** 192.168.200.1  

---

### 2️⃣ Rocky Linux 8 영구 적용 (NetworkManager 기반)

✅ 재부팅 후에도 유지됨  
nmcli로 Policy Routing 설정  

---

```bash
# bond1은 Default Gateway 제거 (main routing table에 default 중복 방지)
nmcli con mod bond1 ipv4.never-default yes
```

---

```bash
# bond0 정책 라우팅 설정 (Table 100 사용)

# bond0 routing table 지정
nmcli con mod bond0 ipv4.route-table 100

# bond0 default route 추가
nmcli con mod bond0 +ipv4.routes "0.0.0.0/0 192.168.150.1"

# bond0 소스 기반 rule 추가
nmcli con mod bond0 +ipv4.routing-rules \
"priority 100 from 192.168.150.184 table 100"
```

---

```bash
# bond1 정책 라우팅 설정 (Table 200 사용)

# bond1 routing table 지정
nmcli con mod bond1 ipv4.route-table 200

# bond1 default route 추가
nmcli con mod bond1 +ipv4.routes "0.0.0.0/0 192.168.200.1"

# bond1 소스 기반 rule 추가
nmcli con mod bond1 +ipv4.routing-rules \
"priority 200 from 192.168.200.141 table 200"
```

---

```bash
# 설정 적용 (인터페이스 재시작)
nmcli con down bond0 && nmcli con up bond0
nmcli con down bond1 && nmcli con up bond1
```

---

### ✅ 최종 확인

```bash
# Policy Routing Rule 확인
ip rule show
```

```bash
# Routing Table 확인
ip route show table 100
ip route show table 200
```

---

### ✅ 통신 테스트

```bash
# bond0로 외부 통신 확인
ping -I bond0 8.8.8.8
```

```bash
# bond1로 외부 통신 확인
ping -I bond1 8.8.8.8
```

---
