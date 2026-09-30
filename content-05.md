# Class 5 — Amazon EC2 Basics

## 1. EC2 kya hai?

**Amazon EC2** = **Elastic Cloud Compute**.

EC2 tumhe **virtual computers rent** karne deta hai AWS ke data centers mein, aur tum unhe use karti ho **applications, websites, APIs, databases, scripts aur baaki workloads** chalane ke liye.

**Instead of buying (khareedne ki bajaye):** Pehle ke zamane mein agar company ko server chahiye hota to **physical server** khareedna padta tha — jisme ye sab khud manage karna padta:
- CPU
- RAM
- Storage
- Network
- Power
- Cooling

Ab tum AWS se **request** karti ho ek virtual server ke liye:
Flow: AWS → EC2 → CPU + RAM → Storage → OS → Application

**Example:** Socho **Zelos Defence** naam ki company ko apni website chalani hai. Unke paas 2 options hain:
- **Option A:** $2000 ka physical server khareedo (mehnga, maintain khud karna, hafton ka wait)
- **Option B:** AWS data center se ek **virtual server** rent pe lo → us par apni application chalao

EC2 tumhe **Option B** deta hai — resources jitne use karo, **usi hisaab se pay karo** (applicable pricing model ke mutabiq). Isliye EC2 ko kehte hain: "**Compute on Demand**" — jitni zaroorat, utna compute.

---

## 2. Shared Responsibility (EC2 ke context mein)

- **AWS manage karta hai:** underlying **physical infrastructure** (asli hardware, data center)
- **Tum manage karti ho:** **OS** aur jo bhi tum **instance ke andar run** karti ho (apps, data)

*(Ye Class 4 ke "Shared Responsibility Model" ka EC2-specific example hai — yaad rakho: EC2 IaaS hai, isliye tum sabse zyada manage karti ho.)*

---

## 3. EC2 Instance kya hai?

**EC2 Instance** = ek **virtual server** jo AWS mein chal rahi hai.

**VS (comparison):** Ye ek **digital, software-based copy** hai ek asli physical computer ki, jo **ek bade machine ke andar** chalti hai.

**Hypervisor kya karta hai:**
Ek **hypervisor** = software ka wo piece jo ek **bade computer ko chhoti, isolated pieces** mein katata hai.

**Virtual Server:** Har slice (piece) ek **poori tarah independent computer** ki tarah kaam karta hai — apna khud ka OS aur apps ke sath.

Flow: Physical Server (Hypervisor) → 3 slices banti hain → Virtual Server 1, Virtual Server 2, Virtual Server 3

**Har EC2 Instance ka apna hota hai:**
- OS
- CPU capacity
- Memory
- Storage
- Network configuration
- Security configuration
- Application

**Example:** Socho ek **bada building** hai (physical server), jise ek **manager (hypervisor)** alag-alag **flats** (virtual servers) mein baant deta hai. Har flat mein alag family rehti hai (Instance 1, 2, 3), aur har flat ka apna bijli meter, apna lock, apna saman hai — bilkul alag-alag independent ghar ki tarah, chahe building ek hi ho.

---

## 4. EC2 Physical Computer NAHI hai

Jab tum ek EC2 instance **launch** karti ho:
- AWS tumhe **asli (real) server nahi bhejta**
- Balke tumhe ek **virtual machine** milti hai jo **AWS ke physical infrastructure par** chal rahi hoti hai

**Example:** Socho AWS ke paas ek bada **server rack** hai jisme bohot saare chhote-chhote **instances** chal rahe hain. Tumhe jo "Instance 1" milta hai, usme: Linux, 2 vCPU, 4GB RAM, App. Ye instance us bade rack ke **andar (inside)** chal raha hota hai — tumhe kabhi asli hardware touch nahi karna padta.

### EC2 ka naam "Elastic" kyun?

**EC2 = Elastic Computing**

**Elastic** ka matlab hai: **tumhari computing capacity demand ke sath adjust ho sakti hai.**

**Example:**

| Normal Day | Busy Din (Sale/Event) | Normal Din (wapas) |
|---|---|---|
| EC2 | EC2 | EC2 |
| EC2 | EC2 | EC2 |
| | EC2 | |
| | EC2 | |
| | EC2 | |

Jab traffic kam hai to sirf **2 instances** chalti hain. Jab traffic **spike** hota hai (busy din), to zaroorat ke hisaab se **5 instances** tak badhaya ja sakta hai. Baad mein normal din wapas aane par instances **kam** kar diye jaate hain. *(Ye wahi Elasticity hai jo Class 2 mein padha tha — yahan EC2 par direct apply ho rahi hai.)*

---

## 5. EC2 aur bhi powerful ban jata hai jab combine karte hain

Baad mein EC2 aur zyada powerful ho jata hai jab isko in ke sath combine karte hain:
- **Elastic Load Balancing** (traffic ko multiple instances mein baantna)
- **Auto Scaling Groups** (instances ko automatically badhana/ghatana)

### Combination of Resources = EC2

Ek EC2 Instance teen cheezon ka combination hai:
EC2 Instance → Compute (CPU/RAM) + Storage (EBS) + Network (IP/Security)

---

## 6. AMI — Amazon Machine Image

**AMI = Amazon Machine Image**

Kisi bhi EC2 instance ko **launch karne se pehle**, AWS ko ye jaanna zaroori hai:
- **Kaunsa OS chahiye?**
- **Kaunsi software configuration** se server start hona chahiye?

**Yahin par AMI kaam aata hai.** AMI ko socho ek **template** ki tarah, ek EC2 instance ke liye.

Flow: AMI → EC2-1, EC2-2, EC2-3 (ek hi AMI se kai instances launch ho sakti hain)

**Example:** Agar tum "**Ubuntu AMI**" choose karti ho, to jo bhi EC2 instance tum launch karogi, wo **Ubuntu Server** ban jayegi. Agar tum "**Windows Server AMI**" choose karti ho, to instance **Windows Server** ban jayegi.

- Ubuntu AMI → EC2 → Ubuntu Server
- Windows Server AMI → EC2 → Windows Server

**AMI = Template?**

**Template** = ek **file jisme saari settings ka record** hota hai — jaise:
- OS kya hoga?
- DB (database) kya hoga?

---

## 7. Instance Types & Families

**Sawaal:** Tumhare virtual server ko **kis kism ka hardware** chahiye? Ye decide hota hai **Instance Type** se.

AWS aksar **kai instance families** deta hai, alag-alag workloads ke liye. **Tumhe har AWS instance type yaad karne ki zaroorat nahi** — bas ye samajhna hai ke har family kis kaam ke liye best hai.

### T (General Purpose)
**Balanced** — CPU = Memory (barabar)

**Achha hai in ke liye:**
- Websites
- Development
- Chhote apps
- General workloads

### T2 — Compute Optimized
**Zyada CPU-focused** (CPU zyada, RAM kam)

**Useful hai:**
- CPU-intensive apps ke liye
- Batch processing
- Compute-heavy workloads

### T3 — Memory Optimized
**Zyada RAM-focused** (CPU kam, RAM zyada)

**Useful hai:**
- Memory-intensive applications
- Large in-memory workloads
- Kuch khaas databases

### Storage Optimized
**High storage performance** ke liye design kiya gaya:
- Large data processing
- High I/O workloads

### T5 — Accelerated Computing
**Specialized hardware use karta hai**, jaise **GPUs** ya doosre accelerators.

**Useful hai:**
- Machine Learning
- Graphics
- Scientific Computing

*(Note: Handwritten notes mein numbering "T1, T2, T3... T5" thi lekin AWS real-world naming ismein thodi alag hoti hai jaise M (General Purpose), C (Compute Optimized), R (Memory Optimized), I (Storage Optimized), P/G (Accelerated Computing) — ye numbering apne sir ke page se verify kar lena, isliye jaisa page pe likha tha waisa hi rakha hai.)*

---

## 8. Instance Size

AWS tumhe **alag-alag sizes** deta hai:
- t-type.small
- t-type.medium
- t-type.large
- t-type.xlarge

**Generally:** Bade size par move karne se tumhe **zyada resources** milte hain, lekin **exact characteristics** is baat par depend karti hain ke wo **kaunsi instance family** hai.

**Yaad rakho farq:**
- **Instance Family** = **kis kism ka workload** hai (General, Compute, Memory...)
- **Instance Size** = **kitni capacity** hai (small, medium, large, xlarge...)

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| EC2 | Elastic Cloud Compute — virtual servers rent pe lena |
| Elastic | computing capacity demand ke sath adjust hoti hai |
| EC2 Instance | ek virtual server jo AWS mein chal rahi hai |
| Hypervisor | software jo ek bade computer ko chhote isolated pieces mein katta hai |
| AMI | Amazon Machine Image — EC2 launch karne ka template (OS + config) |
| Template | file jisme saari settings ka record hai |
| Instance Family | kis kism ka workload hai (General, Compute, Memory, Storage, Accelerated) |
| Instance Size | kitni capacity hai (small, medium, large, xlarge) |
| General Purpose | CPU aur Memory balanced — websites, dev, small apps |
| Compute Optimized | zyada CPU — batch processing, compute-heavy workloads |
| Memory Optimized | zyada RAM — memory-intensive apps, databases |
| Storage Optimized | high storage performance — large data processing, high I/O |
| Accelerated Computing | GPUs/specialized hardware — ML, graphics, scientific computing |
