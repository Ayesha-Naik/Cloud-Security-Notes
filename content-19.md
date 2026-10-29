# Class 19 – Amazon GuardDuty (Threat Detection)

## Topics Covered
1. GuardDuty kya hai
2. GuardDuty kaise kaam karta hai
3. Ye kya kya dekhta hai (Data Sources)
4. Kya kya detect kar sakta hai
5. Findings aur Severity
6. Detect karta hai, block nahi karta
7. GuardDuty aur uske saathi (CloudTrail, CloudWatch, Security Hub, Inspector, Security Groups)
8. GuardDuty ke saath kya kar sakte hain
9. Limits (kya yaad rakhna hai)
10. Five Lines Mein Poora Summary

---

## 1. GuardDuty Kya Hai?

**Definition:** Amazon GuardDuty AWS ke liye ek **managed threat detection service** hai. Ye tumhare AWS account aur workloads mein **shak wali ya khatarnak activity** dhoondta hai aur alert (finding) deta hai.

**Analogy:** Society ka **security guard jo CCTV footage dekhta rehta hai**. Wo chor ko khud pakadta nahi, lekin jaise hi koi shak wali harkat dekhta hai to turant batata hai: "Ye banda baar baar taale check kar raha hai."

**Managed ka matlab:** Tumhe koi server ya software khud chalana nahi padta, AWS sab sambhalta hai.

**Example:** Kisi ne tumhari access key chura li aur raat ko kisi doosre mulk se use karne laga. GuardDuty ye "unusual" usage pakad kar finding bana deta hai.

---

## 2. GuardDuty Kaise Kaam Karta Hai?

Basic protection ke liye **koi agent install nahi karna padta.** Bas on karo aur ye kaam shuru kar deta hai.

| Step | Naam | Kya hota hai |
|---|---|---|
| 1 | Collect | AWS activity data parhta hai: API calls, network traffic aur DNS queries |
| 2 | Analyze | Us activity ko **threat intelligence, machine learning aur detection rules** se compare karta hai |
| 3 | Create a finding | Kuch shak wali cheez mile to details ke saath **alert (finding)** likhta hai |
| 4 | Investigate and respond | Tum (ya tumhari automation) finding ko dekh kar jaanch aur action karte ho |

**Example:** EC2 server ek aise domain ko lookup karta hai jo malware se juda hua hai. GuardDuty us DNS query ko threat intelligence list se match karta hai aur finding banata hai.

---

## 3. Ye Kya Kya Dekhta Hai? (Data Sources)

**Foundational protection** teen sources parhti hai. Baqi sab optional hai.

| Source | Kya batata hai | Shak wali example |
|---|---|---|
| **CloudTrail events** | AWS mein kisne kya kiya | Koi nayi access key banata hai ya policy badalta hai |
| **VPC Flow Logs** | Network par kisne kis se baat ki | Server kisi known malicious IP se connect karta hai |
| **DNS logs** | Tumhare servers kaun se domain names dhoondte hain | Server aise domain ko resolve karta hai jo malware se juda ho |

**Important:** GuardDuty in logs ko **tumhari taraf se alag setup kiye baghair** khud analyze karta hai. Tumhe CloudTrail ya Flow Logs khud on karne ki zaroorat nahi.

### Optional Protection Plans

Ye khaas services tak coverage barhate hain:

| Plan | Kis cheez ko cover karta hai |
|---|---|
| S3 Protection | S3 data par shak wali access |
| EKS Protection | Kubernetes (EKS) clusters |
| RDS Protection | Databases (RDS) mein shak wali logins |
| Lambda Protection | Lambda functions ka network activity |
| Runtime Monitoring | Servers aur containers ke andar chalne wali activity |
| Malware Protection | Volumes aur uploaded files mein malware scan |

> **Tip:** Sirf wohi plans on karo jo tum sach mein use karti ho, kyunke har plan ka alag cost hota hai.

---

## 4. Ye Kya Kya Detect Kar Sakta Hai?

| Khatra | Matlab | Example |
|---|---|---|
| Stolen credentials | Access keys ka ghair mamooli ya shak wala use | Key achanak kisi naye mulk se use hone lagi |
| Compromised servers | EC2 instance command-and-control (C2) infrastructure se baat kar raha hai | Hacked server hacker ke control server se jurta hai |
| Cryptocurrency mining | Tumhara compute kisi aur ke munafe ke liye use ho raha hai | Server par crypto miner chal raha hai |
| Reconnaissance | Koi tumhare resources aur permissions ka naksha bana raha hai | Baar baar List/Describe calls ya port scanning |
| Data theft | S3 data tak shak wali access | Achanak bohat bara data download |
| Malware | Supported workloads, volumes aur uploaded files mein | Upload ki hui file mein virus |

**Finding type ke naam ka format** (padhne mein asaani ke liye): `ThreatPurpose:ResourceType/ThreatName`. Examples:

- `UnauthorizedAccess:EC2/SSHBruteForce`: kisi ne SSH password guess karne ki koshish ki
- `CryptoCurrency:EC2/BitcoinTool.B!DNS`: server bitcoin se jura domain lookup kar raha hai
- `Recon:EC2/PortProbeUnprotectedPort`: koi khuli port ko probe kar raha hai

---

## 5. Findings aur Severity

**Definition:** Finding batati hai ke **kya hua, kahan hua, aur kitna serious lagta hai.**

Har finding mein ye cheezein hoti hain: **type, severity, affected resource, account, region, time aur description.** Poori parho, sirf naam dekh kar faisla mat karo.

| Severity | Matlab | Tum kya karo |
|---|---|---|
| **High** | Mumkin hai serious masla hai | **Foran** investigate karo |
| **Medium** | Shak wali activity | Jaldi verify karo |
| **Low** | Context mein dekho, doosre signs ke saath mil kar ahem ban sakti hai | Review karo |

> **Bohat important:** Finding **breach ka saboot nahi hai.** Ye investigate karne ki wajah hai. Dekho ke activity expected thi ya nahi, kisne ki, aur kya doosra saboot isay support karta hai.

**Example:** Finding aayi ke tumhari key kisi naye IP se use hui. Ho sakta hai tum khud VPN se connect hui ho. Pehle check karo, panic mat karo.

---

## 6. Ye Detect Karta Hai, Block Nahi Karta

GuardDuty **sirf report karta hai.** Khud automatically response ke liye isay doosri services se jorna padta hai.

| Step | Kya hota hai |
|---|---|
| 1 | GuardDuty finding banata hai |
| 2 | **EventBridge rule** us finding ko pakadta hai |
| 3 | **Lambda ya SNS** trigger hota hai |
| 4 | Alert ya action (jaise email ya instance isolate) |

**Typical actions:**
- Security team ko email bhejna
- Ticket kholna
- Instance ko isolate karna (network se kaat dena)

> **Ehtiyat:** Automatic containment mein samajh se kaam lo. Ghalat action se **healthy application toot sakti hai ya saboot (evidence) tabah ho sakta hai.** Maslan instance foran terminate kar do to forensic saboot khatam.

**Analogy:** Guard ne chor dekha to alarm bajaya. Ab ye tum par ya tumhare automatic system par hai ke gate band karna hai ya pehle dekhna hai.

---

## 7. GuardDuty Aur Uske Saathi

Har service ek **alag sawal** ka jawab deti hai. Ye sab mil kar kaam karti hain.

| Service | Uska kaam |
|---|---|
| **CloudTrail** | Records who did what in AWS. Ye audit history hai |
| **CloudWatch** | Performance, logs aur alarms monitor karta hai. High CPU ka matlab khud-ba-khud attack nahi |
| **GuardDuty** | Shak wala behavior detect karta hai aur findings banata hai |
| **Security Hub** | Kai services ki findings **ek jagah** jama karta hai |
| **Inspector** | Software ki **vulnerabilities** attackers se pehle dhoondta hai |
| **Security Groups** | Control karte hain ke kaun sa traffic andar aur bahar ja sakta hai |

**Ek jumle mein farq:**
- **Security Group:** Darwaza (rokta hai)
- **Inspector:** Taale aur deewaron ki kamzori check karta hai (pehle se)
- **GuardDuty:** Guard jo shak wali harkat dekhta hai (dauran)
- **CloudTrail:** Visitor register (baad mein saboot)
- **CloudWatch:** Building ke health monitors
- **Security Hub:** Control room jahan sab alerts ek screen par aate hain

**Example flow:** Pichli class ka scenario: koi hacker EC2 instance delete kar deta hai. CloudTrail batata hai ke kisne kiya, GuardDuty pehle hi shak wali login ya key usage pakad kar finding dikha sakta hai, aur Security Hub sab alerts ek jagah dikhata hai.

---

## 8. GuardDuty Ke Saath Kya Kar Sakte Hain

| Kaam | Kaise |
|---|---|
| **Enable karo** | AWS Console mein ek click se. Foundational protection se shuru karo |
| **Sample findings banao** | Settings page se, taake dekh sako ke asli alerts kaise dikhte hain |
| **Finding parho** | Aur usay CloudTrail se wapas trace karo |
| **Notifications automate karo** | Findings ko **EventBridge aur SNS** ke zariye email par bhejo |
| **Kai accounts sambhalo** | **AWS Organizations** ke zariye ek administrator account se |

**Example (practice ke liye):** Console mein GuardDuty on karo, Settings mein "Generate sample findings" dabao, aur ek High severity finding kholo. Dekho us mein type, resource, region aur description kya hai. Phir CloudTrail mein us resource ki activity dhoondo.

---

## 9. Limits (Kya Yaad Rakhna Hai)

| Limit | Matlab |
|---|---|
| **Regional hai** | Har us Region mein enable karo jahan tumhare workloads chalte hain |
| **Aaj se shuru** | Enable karne se pehle ki activity analyze nahi karta |
| **Safety ki guarantee nahi** | Koi finding nahi, ye matlab nahi ke koi khatra nahi |
| **Hamesha free nahi** | Naye Region mein 30 din ka trial, phir **usage-based pricing**. Extra plans on karne se pehle pricing check karo |
| **Block nahi karta** | Sirf detect karta hai, response tum ya tumhari automation karegi |

---

## 10. Five Lines Mein

1. GuardDuty AWS ke liye ek **managed threat detection service** hai.
2. Ye **CloudTrail, VPC Flow Logs aur DNS logs** bina kisi agent ke parhta hai.
3. Ye **findings** banata hai jinki severity **Low, Medium ya High** hoti hai.
4. Ye **detect** karta hai. Response tum ya tumhari automation karegi.
5. Finding ka matlab hai **investigate karo, panic nahi.**

---

## Common Galtiyan aur Gotchas

1. Sochna ke GuardDuty khud attack rok dega. Wo sirf alert deta hai.
2. Sirf ek Region mein enable karna aur doosre Region ke attacks miss kar dena.
3. Finding ko foran "hack ho gaya" samajh lena. Pehle context aur CloudTrail dekho.
4. Finding ka sirf naam dekhna aur description na parhna.
5. "Koi finding nahi" ko "bilkul safe" samajh lena.
6. Saare optional plans on kar dena aur cost barh jana.
7. Automatic response mein instance terminate kar dena aur evidence kho dena.

---

## Quick Revision

| Topic | Yaad rakhne wali baat |
|---|---|
| GuardDuty | Managed threat detection service, society ka guard jo footage dekhta hai |
| Agent | Basic protection ke liye koi agent nahi chahiye, bas on karo |
| 3 data sources | CloudTrail events, VPC Flow Logs, DNS logs |
| Optional plans | S3, EKS, RDS, Lambda, Runtime Monitoring, Malware Protection |
| Detect karta hai | Stolen credentials, compromised servers, crypto mining, reconnaissance, data theft, malware |
| Finding | Kya hua, kahan, kitna serious (type, severity, resource, account, region, time) |
| Severity | High (foran), Medium (jaldi verify), Low (context mein dekho) |
| Finding = breach? | Nahi, investigate karne ki wajah hai |
| Block karta hai? | Nahi. EventBridge, Lambda ya SNS se automate hota hai |
| Automation ehtiyat | Ghalat action se app toot sakti hai ya evidence tabah ho sakta hai |
| CloudTrail | Kisne kya kiya (audit history) |
| CloudWatch | Performance, logs, alarms |
| Security Hub | Sab services ki findings ek jagah |
| Inspector | Software vulnerabilities pehle dhoondta hai |
| Security Groups | Traffic allow ya deny karte hain |
| Limits | Regional, aaj se shuru, safety ki guarantee nahi, 30 din trial phir paid |
| Multi-account | AWS Organizations se ek administrator account |
| Sabse zaroori baat | Finding ka matlab investigate karo, panic nahi |
