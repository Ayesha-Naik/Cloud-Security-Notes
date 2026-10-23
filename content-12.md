# Class 12 – AWS VPC aur Networking

## Topics Covered
1. Networking kyun zaroori hai (Big Picture)
2. VPC kya hai
3. VPC ki types: Default vs Custom, IPv4 vs Dual-stack, Tenancy
4. IP addresses aur CIDR
5. Subnets aur Subnet types
6. Route Tables
7. Gateways: Internet Gateway, NAT Gateway, Egress-only Gateway
8. Security Groups
9. Network ACLs (NACLs)

---

## 1. Networking Kyun Zaroori Hai? (Big Picture)

Cloud mein server banana aasan hai, lekin **kaun us tak pohanch sakta hai** aur **wo bahar kahan tak ja sakta hai**, ye networking decide karti hai. Poore course ko ek **housing society** se samjho:

| AWS cheez | Real-life analogy |
|---|---|
| Region | Shehar (city) |
| VPC | Poori housing society |
| Subnet | Society ki ek gali (street) |
| EC2 instance | Ek ghar |
| IP address | Ghar ka number |
| Route table | Road signs |
| Internet Gateway | Society ka main gate |
| Security Group | Ek ghar ke darwaze ka lock aur guard |
| Network ACL | Gali ke entrance ka checkpoint |
| NAT Gateway | Ghar walon ke bahar call karne ka zariya (bahar se koi andar nahi aa sakta) |

**Example:** Tum chahti ho ke tumhari website sab dekh sakein, lekin database sirf website ke andar se access ho. Ye sab VPC, subnet, route aur firewall rules se hota hai.

---

## 2. VPC (Virtual Private Cloud)

**Definition:** VPC AWS mein tumhara **apna isolated network** hai, jahan tum khud address range chuntay ho aur traffic ka control rakhtay ho.

**Analogy:** Poori housing society, jiski apni streets, gate aur rules hain.

**VPC mein tum kya control karte ho:**
- IP range
- Subnets
- Route tables
- Gateways
- Security rules

> **Important:** VPC bana lene se andar ki cheezein **public nahi ho jati**. Public access tab aata hai jab tum **gateway, route, public address aur firewall rule** khud jaan boojh kar lagao.

**Example:** Society ban gayi, lekin jab tak main gate lagake road na banao, bahar se koi andar nahi aa sakta.

---

## 3. VPC ki Types

### Type 1: Default VPC vs Custom VPC

| Point | Default VPC | Custom VPC |
|---|---|---|
| Kaun banata hai | AWS, har Region mein khud | Tum |
| Kitni | Har Region mein ek | Quota tak (default 5 per Region, badh sakti hai) |
| Address range | `172.31.0.0/16` | Tumhari choice, `/16` se `/28` tak |
| Subnets | Har AZ mein ek public subnet | Koi nahi, khud banao |
| Internet | IGW attached, route aur public IP auto | Kuch connected nahi jab tak khud na banao |
| Best for | Learning, quick tests | Real projects, jahan private subnets chahiye |

**Banne ke foran baad kya maujood hota hai?**

| Cheez | Default VPC | New Custom VPC |
|---|---|---|
| Subnets | Haan, har AZ mein ek public | Nahi, khud banao |
| Internet Gateway attached | Haan | Nahi, khud banao aur attach karo |
| Route `0.0.0.0/0` to IGW | Haan | Nahi, sirf local route hota hai |
| Naye instances ko public IP auto | Haan | Subnets hi nahi, to lagu nahi |
| Default Security Group | Haan | Haan (rules add karne tak koi andar nahi aa sakta) |
| Default Network ACL | Haan (sab allow) | Haan (sab allow) |

**Example:** Default VPC ek **ready-made furnished flat** hai, chaabi lo aur rehna shuru. Custom VPC **khaali plot** hai, tum khud design karte ho. Isiliye tumhara pehla EC2 server minutes mein chal gaya tha, kyunki default VPC already public-ready hota hai. Lekin ye convenient hai, secure nahi, kyunke sab kuch public-facing hota hai.

### Type 2: IPv4-only vs Dual-stack

- Har VPC ki ek **IPv4** range hoti hai.
- Tum chaho to usay **IPv6** range bhi de sakti ho (AWS deta hai). IPv4 + IPv6 dono wale VPC ko **dual-stack** kehte hain.
- IPv6 addresses **globally unique aur publicly routable** hote hain. To privacy address chhupa kar nahi, balki **routes aur security rules** se control hoti hai.

### Type 3: Tenancy

| Tenancy | Matlab | Cost |
|---|---|---|
| Default | Tumhare instances shared hardware par chalte hain | Kam |
| Dedicated | Hardware sirf tumhare liye reserve | Zyada |

Beginners ke liye **Default** hi theek hai.

### Do Settings Jinhe Jaanna Zaroori Hai

| Setting | Kaam |
|---|---|
| DNS resolution | Servers VPC ke built-in DNS se naam ko IP mein badalte hain |
| DNS hostnames | Instances ko public DNS naam milte hain (VPC wizard mein dono enable kar sakti ho) |

**Extra:**
- Baad mein VPC mein **aur CIDR ranges** (secondary CIDRs) add ki ja sakti hain.
- **DHCP option set** domain name aur DNS servers jaisi cheezein instances ko deta hai. Pehle din ismein change nahi karte.
- Console mein: VPC, Your VPCs. Default VPC ke samne "Default VPC: Yes" likha hota hai.

> **Watch out:** VPC ki IPv4 range `/16` (sabse bari) aur `/28` (sabse choti) ke darmiyan honi chahiye.

---

## 4. IP Addresses aur CIDR

### IP address kya hai?
Network par har device ka **unique pata**, bilkul ghar ke number ki tarah.

### IP addresses ki 4 kinds

| Kind | Kya hai | Example |
|---|---|---|
| Private IPv4 | VPC ke andar kaam karta hai, har instance ko milta hai | `172.31.42.167` |
| Public IPv4 | Internet par reachable, IGW ke zariye translate hota hai | Auto-assigned ya Elastic IP |
| Elastic IP | Fixed public IPv4 jo tumhare account mein reserve rehta hai | Stop/start par change nahi hota |
| IPv6 | Naya, bohat bara address space, globally unique | 128-bit |

**Private IPv4 ke 3 standard ranges:**
- `10.0.0.0/8`
- `172.16.0.0/12`
- `192.168.0.0/16`

**Example:** Private IP ghar ke andar ka internal number hai (kamra 1, kamra 2), Public IP society ke bahar ka dak ka pata hai.

### CIDR kya hai?

**Definition:** CIDR (Classless Inter-Domain Routing) ek IP range likhne ka tareeka hai: `IP/number`. Slash ke baad ka number batata hai ke range kitni badi hai.

**Golden rule:** **Slash ke baad number jitna bara, block utna chota.** `/24` chota hai `/16` se.

**Size ka formula:** `2 ^ (32 minus number)`

| CIDR | Total addresses | Kab use hota hai |
|---|---|---|
| `/16` | 65,536 | Poora VPC |
| `/24` | 256 | Aam subnet |
| `/28` | 16 | Sabse chota allowed |
| `/32` | Exactly 1 | Ek IP, jaise "SSH sirf meri IP se" |

**Example calculation:** `10.0.1.0/24`
- Pehla address: `10.0.1.0`, aakhri: `10.0.1.255`
- Total: 256 (2 ki power 8)
- **Subnet mein AWS 5 addresses khud reserve kar leta hai**, to **251 usable** bachte hain.

### Subnet fit ke 2 rules
1. Subnet VPC range ke **andar** hona chahiye.
2. Do subnets **overlap nahi** kar sakte.

**Example:** VPC `10.0.0.0/16`, Subnet A `10.0.1.0/24`, Subnet B `10.0.2.0/24`. Dono VPC ke andar hain aur overlap nahi karte, to plan **kaam karega**. Agar B ko `10.0.1.0/24` de do to overlap ho jayega aur fail hoga. Agar B ko `192.168.1.0/24` de do to VPC se bahar hai, wo bhi fail.

---

## 5. Subnets aur Subnet Types

**Definition:** Subnet VPC ke andar ek **chhoti address range** hai. **Har subnet sirf ek Availability Zone (AZ) mein** rehta hai.

**Analogy:** Society ki ek gali. Ek gali ke ghar ek hi route se gate tak jaate hain.

**Subnets kyun chahiye?** Alag cheezein alag jagah rakhne ke liye: public cheezein ek mein, private cheezein doosre mein, aur har ek ke apne rules.

### Subnet types

| Type | Kaise set hota hai | Typical residents |
|---|---|---|
| Public | Route table mein `0.0.0.0/0` IGW ki taraf | Web servers, load balancers |
| Private | IGW ka route nahi (bahar jaane ke liye NAT use hota hai) | App servers, databases |
| VPN-only | Route sirf VPN gateway ki taraf | Company ke office network se connected resources |
| Isolated | Bahar ka koi route hi nahi | Bohat sensitive data |

**Key point:** Subnet ko "public" ya "private" uska **naam** nahi banata, uski **route table** banati hai.

**Best practice:** High Availability ke liye **kam az kam 2 AZs** mein subnets rakho, taake ek AZ down ho to application chalti rahe.

---

## 6. Route Tables

**Definition:** Route table **Destination aur Target** ke pairs ki list hai jo AWS ko batati hai ke traffic kahan bhejna hai.

**Analogy:** Road sign: "Highway: turn right."

**Kaise kaam karta hai:** Har subnet **bilkul ek** route table se associate hota hai. Har packet ke liye AWS **best matching route** dhoondta hai aur packet us route ke Target ko bhej deta hai.

| Destination | Target | Matlab |
|---|---|---|
| `10.0.0.0/16` | `local` | VPC ki apni range VPC ke andar hi rehti hai (khud add hota hai) |
| `0.0.0.0/0` | `igw-xxxx` | Baqi har IPv4 destination Internet Gateway ko jati hai |

**Example:** Packet `10.0.2.15` ke liye jaye to "local" match hoga, VPC ke andar hi rahega. Packet `8.8.8.8` ke liye jaye to sirf `0.0.0.0/0` match hota hai, to IGW se bahar internet par jayega.

---

## 7. Gateways: Internet, NAT aur Egress-only

Gateways VPC aur bahar ki duniya ke beech ke **darwaze** hain.

### 7.1 Internet Gateway (IGW)

**Definition:** IGW tumhare VPC ko internet se jodta hai, jab routing, addressing aur security sab sahi jagah ho.

**Analogy:** Society ka main gate. Wo hai, lekin ye decide nahi karta ke kaun kis ghar mein jayega.

**Kaise kaam karta hai:**
- Ek VPC par **ek hi IGW** attach ho sakta hai.
- **Free** hai.
- Jin instances ke paas public IPv4 hai unke liye ye public aur private address ke darmiyan **one-to-one translation** karta hai.

### Website server ko IPv4 internet traffic ke liye 5 cheezein chahiye

| # | Cheez | Kyun |
|---|---|---|
| 1 | Internet Gateway VPC se attached | Bahar ka darwaza |
| 2 | Subnet ki route table mein `0.0.0.0/0` to IGW | Raasta |
| 3 | Instance ke paas public IPv4 (ya Elastic IP) | Bahar se pehchaan |
| 4 | Security Group traffic allow kare | Ghar ka guard |
| 5 | Network ACL traffic allow kare | Gali ka checkpoint |

Ek bhi missing ho to internet se connect nahi hoga. **Troubleshooting mein yahi 5 cheezein ek ek check karo.**

### 7.2 NAT Gateway

**Definition:** NAT Gateway **private subnet** ke instances ko **bahar internet par jaane** deta hai (updates download karna etc.), lekin bahar se koi unke andar **shuru nahi** kar sakta.

**Analogy:** Ghar walon ke liye bahar call karne ka zariya: wo bahar call kar sakte hain, lekin bahar se koi seedha ghar ke andar nahi aa sakta.

**Details:**
- NAT Gateway ko **public subnet** mein rakha jata hai.
- Usay **Elastic IP** chahiye.
- Private subnet ki route table: `0.0.0.0/0` to NAT Gateway.
- **Paid service** hai (hourly + data charges).

**Example:** Private subnet mein database server ko security patches download karne hain. NAT ke zariye wo internet se patch le leta hai, lekin koi hacker internet se us database ko seedha touch nahi kar sakta.

### 7.3 Egress-only Internet Gateway

- **Sirf IPv6** ke liye.
- IPv6 traffic ko **bahar jaane** deta hai, bahar se **andar aane nahi** deta.
- Ye IPv6 ke liye NAT Gateway jaisa kaam karta hai (kyunke IPv6 addresses already public hote hain).

### Gateways ka quick comparison

| Gateway | Direction | Kis ke liye |
|---|---|---|
| Internet Gateway | Dono taraf | Public subnet ke resources |
| NAT Gateway | Sirf bahar ki taraf (outbound) | Private subnet, IPv4 |
| Egress-only IGW | Sirf bahar ki taraf (outbound) | Private subnet, IPv6 |

---

## 8. Security Groups

**Definition:** Security group ek **stateful firewall** hai jo control karta hai ke un resources tak kaun sa traffic aa sakta hai aur wahan se ja sakta hai jin se wo attached hai.

**Analogy:** Ek ghar ke front door ka lock aur guard.

**Example rules:**
- HTTP 80 from `0.0.0.0/0`: public web traffic
- SSH 22 from `your IP/32`: admin sirf ek address se

### 3 khaas baatein

| # | Point | Matlab |
|---|---|---|
| 1 | **Stateful** | Agar connection andar aane diya gaya, to jawab (reply) khud bahar jaane diya jata hai |
| 2 | **Allow rules only** | Deny rules hote hi nahi. Jo allow nahi wo automatically denied |
| 3 | **Network interface par laga hota hai** | Poore subnet par nahi. Ek instance par kai groups ho sakte hain |

**Example:** Tumne port 80 ka rule inbound allow kiya. Browser request aayi, to jawab bhi khud bahar chala jayega, alag outbound rule likhne ki zaroorat nahi.

**Default behavior:** Naye security group mein **saara inbound deny** hota hai jab tak tum rule na lagao.

---

## 9. Network ACLs (NACLs)

**Definition:** Network ACL ek **stateless filter** hai jisme **allow aur deny** dono rules hote hain, aur ye **poore subnet** par lagta hai.

**Analogy:** Gali ke entrance par checkpoint. Gali mein jaane wale har gaari ko rokta hai.

### Security Group vs Network ACL

| Point | Security Group | Network ACL |
|---|---|---|
| Kahan lagta hai | Network interface (instance) | Subnet |
| Stateful? | Haan | **Nahi, stateless** |
| Rules | Sirf Allow | Allow aur Deny |
| Return traffic | Automatic | **Dono directions mein allow karna padta hai** |
| Evaluation | Jo bhi allow rule match kare wo decide karta hai | Rule numbers **ascending order** mein, **pehla match jeet jata hai** |
| Default | Naya group sab inbound deny karta hai | **Default NACL sab allow karta hai.** Naya custom NACL sab deny karta hai jab tak rules na dalo |

**Stateless ka matlab:** NACL ko pichla yaad nahi rehta. Agar tumne inbound port 80 allow kiya, to reply ke liye **outbound** rule alag se likhna padega (ephemeral ports ke saath). Warna reply block ho jayega.

**Example (rule order):**
- Rule 100: Allow HTTP from anywhere
- Rule 200: Deny HTTP from `203.0.113.5/32`

Yahan rule 100 pehle match ho jayega, isliye us IP ko bhi allow ho jayega. Agar us IP ko block karna hai to deny rule ka number **chhota** rakho (jaise 90).

### Do layers kyun?
Security Group instance ka guard hai, NACL gali ka checkpoint. **Defense in depth**: agar ek ne chook ki to doosra bacha lega.

---

## Poora Flow Ek Jagah

Internet se ek user ki request tumhare web server tak:

| Step | Kya hota hai |
|---|---|
| 1 | Request internet se **Internet Gateway** tak aati hai |
| 2 | **Route table** batati hai ke packet kis subnet mein jaye |
| 3 | Subnet ke entrance par **Network ACL** rules check karta hai |
| 4 | Instance ke darwaze par **Security Group** check karta hai |
| 5 | Request EC2 instance (server) tak pohanch jati hai |
| 6 | Reply wapas jaata hai (SG stateful hai, NACL ke liye outbound rule chahiye) |

---

## Common Galtiyan aur Gotchas

1. VPC bana kar maan lena ke wo public hai. Public hone ke liye 5 cheezein chahiye (IGW, route, public IP, SG, NACL).
2. Subnet ko sirf naam se "public" samajhna. Asli faisla route table karti hai.
3. NACL mein sirf inbound rule likhna aur outbound bhool jana. NACL stateless hai.
4. Do subnets ki CIDR overlap kar dena.
5. Poori `0.0.0.0/0` se SSH (port 22) khol dena. Hamesha apni IP `/32` rakho.
6. Sab kuch ek hi AZ mein rakhna. Ek AZ fail hui to sab band.
7. NAT Gateway ko private subnet mein rakhna. Wo **public subnet** mein hota hai.

---

## Quick Revision

| Topic | Yaad rakhne wali baat |
|---|---|
| VPC | Tumhara apna isolated network, jahan tum range aur traffic control karte ho |
| Default VPC | AWS khud banata hai, har Region mein ek, `172.31.0.0/16`, sab public-ready |
| Custom VPC | Khaali plot, tum sab khud banate ho, `/16` se `/28` range |
| Dual-stack | IPv4 + IPv6 dono wala VPC |
| Tenancy | Default (shared hardware) vs Dedicated (sirf tumhara, mehnga) |
| CIDR | `IP/number`, number bara to block chota, size = 2^(32 minus number) |
| Reserved IPs | Har subnet mein AWS 5 addresses rakh leta hai (`/24` mein 251 usable) |
| Subnet | VPC ka chhota hissa, sirf ek AZ mein |
| Subnet types | Public, Private, VPN-only, Isolated |
| Route table | Destination + Target pairs, har subnet ke liye ek |
| Internet Gateway | VPC ka main gate, free, ek VPC par ek |
| NAT Gateway | Private subnet ko sirf bahar jaane deta hai, public subnet mein rehta hai, paid |
| Egress-only IGW | IPv6 ka outbound-only gateway |
| Internet ke liye 5 cheezein | IGW, route, public IP, SG allow, NACL allow |
| Security Group | Stateful, sirf allow, instance level |
| Network ACL | Stateless, allow + deny, subnet level, rule number order mein, pehla match jeetta hai |
| Housing society analogy | Region = city, VPC = society, Subnet = gali, EC2 = ghar, SG = ghar ka lock, NACL = gali ka checkpoint |
