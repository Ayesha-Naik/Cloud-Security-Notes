# Class 20 – Request ka Safar VPC ke Andar (Ali ka Scenario: mycafe.com)

## Topics Covered
1. Scenario aur important IP addresses
2. Poora raasta ek nazar mein
3. Step 0: DNS (address dhoondna)
4. Step 1: Laptop se Internet tak
5. Step 2: Internet Gateway (IGW) aur 1:1 NAT
6. Step 3: VPC Router aur Route Table
7. Step 4: NACL (block ka security checkpoint)
8. Step 5: Security Group (flat ka guard)
9. Step 6: Web Server
10. Wapsi ka safar (jawab Ali tak kaise pohanchta hai)
11. Packet ka address har jagah kaise badalta hai
12. NACL vs Security Group
13. Troubleshooting checklist

---

## 1. Scenario

Tumhari cafe ki website AWS par hai. **Ali Islamabad mein apne laptop par `mycafe.com` kholta hai.** Dekhna ye hai ke uski request **kahan kahan jati hai, kaise jati hai aur kyun jati hai.**

| Cheez | Value |
|---|---|
| Web server ki **private IP** | `10.0.1.25` |
| Web server ki **public IP** | `54.10.20.30` |
| **Ali ki IP** | `39.45.8.17` |
| VPC | `10.0.0.0/16` (tumhari society) |
| Public subnet | `10.0.1.0/24` |

**Analogy (housing society):**

| AWS | Society |
|---|---|
| VPC | Poori society |
| Public subnet | Society ka ek block |
| Internet Gateway | Society ka main gate |
| Route Table | Road signs aur traffic police ki rulebook |
| NACL | Block ke entrance ka security checkpoint |
| Security Group | Flat ke darwaze ka guard |
| EC2 web server | Flat |

---

## 2. Poora Raasta Ek Nazar Mein

**Jaane wali request (REQUEST):**

Ali ka laptop, phir ISP (internet), phir **Internet Gateway**, phir **Router + Route Table**, phir **NACL**, phir **Security Group**, aur aakhir mein **EC2 Web Server.**

**Wapas aane wala jawab (JAWAB)** bilkul ulte raaste se wapas jata hai.

| Step | Jagah | Kaam |
|---|---|---|
| 0 | DNS | Naam se IP dhoondna |
| 1 | Laptop, WiFi, ISP, Internet | Request AWS tak pohanchna |
| 2 | Internet Gateway | Public IP ko private IP mein badalna |
| 3 | VPC Router + Route Table | Raasta batana |
| 4 | NACL | Subnet level par rules check |
| 5 | Security Group | Instance level par rules check |
| 6 | Web server (Apache) | Page tayyar karna |
| Wapsi | SG, NACL, Route Table, IGW, Internet | Jawab Ali tak |

---

## 3. Step 0: Pehle Address Dhoondna (DNS)

Laptop ko `mycafe.com` **samajh nahi aata, wo sirf IP samajhta hai.** **DNS (phone book)** bata deta hai: `mycafe.com = 54.10.20.30`.

Phir laptop request banata hai: **"Mujhe 54.10.20.30 ke port 80 se page chahiye."**

| Cheez | Value |
|---|---|
| Kis ne bheja (source) | `39.45.8.17:51234` |
| Kisko (destination) | `54.10.20.30:80` |

**Ye kyun hai?** Kyunke computer naam nahi, sirf IP address samajhta hai.

**Port ki baat:**
- `80` = HTTP (web server ka darwaza). Ye **destination port** hai.
- `51234` = Ali ke laptop ka **random (ephemeral) port**, jis par jawab wapas aayega.

---

## 4. Step 1: Laptop Se Internet Tak

Laptop ki request Ali ke **WiFi, phir ISP (jaise PTCL/Nayatel), phir internet** ke raaste **AWS ke data center tak** aati hai.

---

## 5. Step 2: Internet Gateway (IGW), Society Ka Main Gate

Request AWS ke gate par pohanchti hai. Yahan ek ajeeb baat hai: **tumhare EC2 ko apni public IP pata hi nahi hoti.** Usay sirf `10.0.1.25` pata hai. Public IP to AWS ne bahar se laga rakhi hai.

**Analogy:** Society ke gate par ek **intercom list** hoti hai: *"Bahar se jo 54.10.20.30 par aaye, wo andar 10.0.1.25 ke flat ka hai."*

IGW wahi list dekh kar **destination badal deta hai:** `54.10.20.30` ban jata hai `10.0.1.25`. Isay **1:1 NAT** kehte hain.

| Cheez | Value (IGW ke baad) |
|---|---|
| Source | `39.45.8.17:51234` |
| Destination | `10.0.1.25:80` |

**Ye kyun hai?** IGW ke bina VPC ka internet se koi rishta hi nahi. **IGW public aur private IP ke beech tarjuma karta hai.**

---

## 6. Step 3: VPC Router aur Route Table

**VPC Router kya hai?** Har VPC mein AWS ek **invisible traffic police** laga deta hai. Tum usay dekh nahi sakti aur na bana sakti ho, wo bas maujood hota hai.

**Route Table kya hai?** Us police ki **rulebook.** Isme likha hota hai: *"Is destination ka traffic is raaste se jaye."*

| Destination | Target | Matlab |
|---|---|---|
| `10.0.0.0/16` | `local` | VPC ke andar ka traffic andar hi rahe |
| `0.0.0.0/0` | `igw-xxxx` | Baqi sab kuch internet gate se bahar |

**Kyun use hoti hai?** Iske bina packet ko pata hi nahi chalega ke kidhar jana hai.

**Zaroori baat:** Request ke andar aane mein iska role **chhota** hai (`10.0.1.25` to VPC ke andar hi hai, `local` route). Iska **asli kaam wapsi mein** hota hai, jab server jawab bhejta hai. Wahan route table batati hai: **"bahar jana hai to IGW se jao."** Isi se subnet **"public"** ya **"private"** banta hai.

---

## 7. Step 4: NACL, Block Ka Security Checkpoint

Request ab **public subnet ke darwaze** par pohanchi. Wahan NACL baitha hai. **NACL = subnet ke liye rules ki list.** Har rule ka **number** hota hai, aur wo **sab se chhota number pehle** check hota hai.

| Rule # | Type | Port | Source | Action |
|---|---|---|---|---|
| 100 | HTTP | 80 | `0.0.0.0/0` | **ALLOW** |
| 110 | SSH | 22 | `0.0.0.0/0` | **DENY** |
| `*` | All | All | `0.0.0.0/0` | **DENY** |

**Ali ki request port 80 par hai.** Guard upar se neeche dekhta hai: **Rule 100 match, ALLOW, andar jao.** Jahan pehla match mila, wahi faisla ho jata hai, aage ke rules nahi dekhta.

**Agar koi hacker port 22 (SSH) par aaye** to Rule 110 par **DENY**, wahin se wapas.

**Aakhri rule (`*`):** Jo kisi rule se match na ho wo **deny** ho jata hai.

> **NACL stateless hai.** Guard ko **yaad nahi rehta** ke abhi kisko andar bheja. Wapsi par dobara rules dekhega, isliye **outbound rule bhi chahiye.**

---

## 8. Step 5: Security Group, Flat Ka Guard

Ab request **EC2 ke darwaze** par pohanchi. Yahan `web-sg` hai. NACL **poori society ke block** ke liye tha. **SG sirf is ek server** ke liye hai. SG mein **sirf ALLOW rules** hote hain. Jo allow nahi, wo khud-ba-khud blocked.

| Type | Port | Source |
|---|---|---|
| HTTP | 80 | `0.0.0.0/0` |
| SSH | 22 | My IP |

**Ali ki request port 80 par hai.** List mein HTTP 80 hai, **andar jao.**

> **SG stateful hai:** guard ko **yaad rehta hai** ke "isne request bheji thi". Isliye **jawab ke liye alag rule nahi chahiye.**

---

## 9. Step 6: Web Server

Request `10.0.1.25` par **Apache** tak pohanchti hai. Apache `index.html` uthata hai aur **jawab tayar karta hai.**

---

## 10. Wapsi Ka Safar (Jawab Ali Tak Kaise Pohanchta Hai?)

**Raasta:**

EC2, phir SG (yaad hai, jaane do), phir NACL (outbound rule check), phir Route Table (`0.0.0.0/0` to IGW), phir IGW (source `10.0.1.25` ko wapas `54.10.20.30` bana deta hai), phir Internet, phir Ali ka laptop, **page khul gaya.**

| # | Kya hota hai |
|---|---|
| 1 | **Wapsi ka pata request mein hi likha hota hai.** Har packet par "kis ne bheja (source)" likha hota hai. Ali ki request par `39.45.8.17` (Ali ki IP) likha tha. Server bas "from" aur "to" ulta kar ke jawab bhej deta hai, jaise khat ke peeche likha pata dekh kar jawab likhna. |
| 2 | **SG** ko request yaad hai, to jawab ko rokta nahi. |
| 3 | **NACL** ko yaad nahi, wo dobara dekhta hai. Ali ka laptop request ke saath ek **random port** bhi bhejta hai (jaise `51234`), jawab usi port par wapas jata hai. Isliye NACL ke **outbound rule mein `1024-65535` allow** hona chahiye. |
| 4 | **Route table:** `39.45.8.17` VPC ke andar nahi hai, to rule `0.0.0.0/0 to IGW` lagta hai. **Yahan route table ka kaam saamne aata hai.** Ye rule na ho to jawab bahar ja hi nahi sakta. |
| 5 | **IGW** source `10.0.1.25` ko wapas `54.10.20.30` bana deta hai, taake Ali ko lage jawab usi se aaya jisko usne bola tha. |
| 6 | **Internet, ISP, WiFi:** packet Ali ki IP ke raaste uske router tak jata hai. Router port `51234` dekh kar sahi laptop ko deta hai. |

**Browser ko page mil gaya, mycafe.com khul gayi.**

---

## 11. Packet Ka Address Har Jagah Kaise Badalta Hai

| Jagah | Source | Destination |
|---|---|---|
| Ali ka laptop se nikalte waqt | `39.45.8.17:51234` | `54.10.20.30:80` |
| **IGW ke baad** (andar) | `39.45.8.17:51234` | `10.0.1.25:80` |
| EC2 se jawab nikalte waqt | `10.0.1.25:80` | `39.45.8.17:51234` |
| **IGW ke baad** (bahar) | `54.10.20.30:80` | `39.45.8.17:51234` |

**Trick:** Wapsi mein source aur destination **ulte** ho jate hain, aur IGW private IP ko wapas public IP bana deta hai.

---

## 12. NACL vs Security Group

| Point | NACL | Security Group |
|---|---|---|
| Kahan lagta hai | **Subnet** (poora block) | **Instance** (ek flat) |
| Rules | **Allow aur Deny** dono | Sirf **Allow** |
| Stateful? | **Nahi (stateless)** | **Haan (stateful)** |
| Wapsi ka traffic | **Alag outbound rule chahiye** | Khud allow |
| Order | **Rule number** ke hisaab se, pehla match jeet jata hai | Saare rules dekhe jate hain |
| Analogy | Block ka checkpoint | Flat ka guard |

**Dono layers kyun?** Ye **defense in depth** hai. Ek layer chook jaye to doosri bacha leti hai.

**Is example se ek ahem sabaq:** SG mein SSH `My IP` se allowed hai, lekin NACL Rule 110 **SSH ko `0.0.0.0/0` se deny** kar raha hai. To SSH **NACL par hi ruk jayega**, SG tak pohanchega hi nahi. **Request ko dono layers se guzarna padta hai.**

---

## 13. Troubleshooting Checklist

Agar `mycafe.com` na khule to is order mein check karo:

| # | Check | Sawal |
|---|---|---|
| 1 | DNS | Domain sahi public IP par point kar raha hai? |
| 2 | Public IP | Instance ko public IP ya Elastic IP mili hai? |
| 3 | IGW | Internet Gateway VPC se attached hai? |
| 4 | Route Table | Subnet ki route table mein `0.0.0.0/0 to IGW` hai? |
| 5 | NACL inbound | Port 80 allowed hai? |
| 6 | NACL outbound | Ephemeral ports `1024-65535` allowed hain? |
| 7 | Security Group | HTTP 80 ka inbound rule hai? |
| 8 | Server | Apache chal raha hai aur port 80 par sun raha hai? |

---

## Common Galtiyan aur Gotchas

1. Sochna ke EC2 ko apni public IP pata hoti hai. Usay sirf private IP pata hoti hai, public IP ka tarjuma IGW karta hai.
2. NACL mein sirf inbound rule likhna aur outbound bhool jana. NACL stateless hai.
3. NACL outbound mein ephemeral ports (`1024-65535`) allow na karna.
4. NACL ke rules ka number galat rakhna. Chhota number pehle check hota hai aur pehla match jeet jata hai.
5. SG allow kar dena lekin NACL mein deny hona (ya ulta). Dono ko allow karna padta hai.
6. Route table mein `0.0.0.0/0 to IGW` ka rule bhool jana. Jawab bahar nahi ja sakega.
7. SG mein SSH `0.0.0.0/0` khol dena. Hamesha `My IP` rakho.

---

## Quick Revision

| Topic | Yaad rakhne wali baat |
|---|---|
| DNS | Naam ko IP mein badalta hai (phone book) |
| Request ka raasta | Laptop, ISP, Internet, IGW, Router + Route Table, NACL, SG, EC2 |
| Source / Destination | Kis ne bheja / kisko, packet par likha hota hai |
| Ephemeral port | Laptop ka random port (jaise 51234), jawab isi par wapas aata hai |
| EC2 aur public IP | EC2 ko sirf private IP pata hai, public IP ka tarjuma IGW karta hai |
| IGW | Society ka main gate, public aur private IP ka 1:1 NAT karta hai |
| VPC Router | Invisible traffic police, har VPC mein khud hota hai |
| Route Table | Police ki rulebook (Destination aur Target) |
| `local` route | VPC ke andar ka traffic andar hi rahe |
| `0.0.0.0/0 to IGW` | Baqi sab kuch internet gate se bahar (subnet ko public banata hai) |
| Route table ka asli kaam | Wapsi mein, jab jawab bahar jata hai |
| NACL | Subnet level, stateless, allow aur deny, rule number order, pehla match jeet jata hai |
| NACL outbound | Wapsi ke liye `1024-65535` allow karna zaroori hai |
| Aakhri rule `*` | Jo kisi rule se match na ho wo deny |
| Security Group | Instance level, stateful, sirf allow |
| SG stateful | Request yaad rehti hai, jawab ke liye alag rule nahi chahiye |
| Dono layers | NACL aur SG dono se guzarna padta hai (defense in depth) |
| Wapsi | EC2, SG, NACL (outbound), Route Table, IGW (source wapas public IP), Internet, Ali |
| Packet ke address | Wapsi mein source aur destination ulte hote hain |
| Sabse zaroori baat | Request jo raaste se aati hai, jawab usi raaste se ulta wapas jata hai |
