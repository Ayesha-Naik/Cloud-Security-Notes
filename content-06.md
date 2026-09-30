# Class 6 — EBS, Networking, Security, Key Pair, User Data, EC2 Lifecycle, Pricing & Scaling

## 1. EBS — Elastic Block Store

**EBS (Elastic Block Store)** = EC2 instance ke liye **storage (hard disk)**. Jab tum ek EC2 instance banati ho, uske sath ek **EBS volume** attach hota hai jahan uska data, OS, files sab store hote hain.

**Plain meaning:** Socho EC2 instance ek **computer** hai, to EBS uski **hard disk** hai. Instance chalta hai, lekin data (files, OS, apps) EBS mein rehta hai.

**Important cheez:** EBS **persistent** hota hai — matlab agar instance ko **stop** kar do (band karo, delete nahi), to EBS ka data **safe rehta hai**. Jab tum instance wapas **start** karti ho, wahi data wapas mil jata hai.

**Example:** Socho tumne apna laptop (EC2 instance) band kar diya raat ko. Subah wapas ON kiya to tumhari saari files (EBS) wahin maujood hain — kuch delete nahi hua. Bas power off/on hua, hard disk ka data nahi gaya.

**NovaTech Solutions ka example:** NovaTech Solutions apni website EC2 par chalati hai. Website ka database EBS volume mein store hai. Agar raat ko server maintenance ke liye EC2 instance **stop** kiya jaye, to EBS mein pada customer data **safe** rehta hai — jaise hi instance start hoga, sab wapas available hoga.

---

## 2. Networking Basics

Jab EC2 instance launch hoti hai, use **network** se connect hona padta hai taake wo internet ya doosre servers se baat kar sake. Isi liye har instance ko **IP addresses** milte hain.

### Public IP vs Private IP

**Public IP** = wo address jisse tumhari instance **internet** par pehchani jaati hai — koi bhi bahar se isko access kar sakta hai (agar permission ho).

**Private IP** = wo address jo sirf **AWS ke andar ke network mein** kaam karta hai — internet se directly access nahi hota, sirf usi network ke andar doosre servers isse baat kar sakte hain.

**Example (ghar ki analogy):** Tumhara **ghar ka address** (jaise "House #12, Street 5") wo **Private IP** ki tarah hai — sirf mohalle wale (internal network) isse pehchante hain. Lekin tumhara **CNIC ya passport number** jo poori duniya mein unique hai aur kahin bhi identify ho sakta hai — wo **Public IP** ki tarah hai.

**NovaTech ka example:** NovaTech ka web server ek **Public IP** rakhta hai taake customers browser se website khol sakein. Unka database server **Private IP** rakhta hai — sirf web server hi usse baat kar sakta hai, bahar se koi directly access nahi kar sakta. Ye **extra security** deta hai.

---

## 3. Security Groups

**Security Group** = EC2 instance ke liye ek **virtual firewall** — ye control karta hai **kaun sa traffic andar (inbound) aa sakta hai aur kaun sa bahar (outbound) ja sakta hai**.

**Plain meaning:** Security Group ek **darban (gatekeeper)** hai jo instance ke darwaze par khada hai aur decide karta hai kaun andar aa sakta hai, kaun nahi.

**Example:** Agar tum chahti ho ke sirf **website traffic (port 80/443)** tumhari instance tak pahunche, aur koi bhi doosra port band rahe — to Security Group mein rule banati ho: "**sirf port 80 aur 443 allow karo, baaki sab block**."

**NovaTech ka example:** NovaTech ke web server ka Security Group sirf **HTTP/HTTPS traffic** allow karta hai duniya bhar se, lekin **SSH (server ka remote access)** sirf company ke office ke IP address se allow karta hai — taake koi bahar wala server ke andar login na kar sake.

---

## 4. Key Pair

**Key Pair** = do keys ka set — ek **Public Key** (AWS ke paas, instance mein lagti hai) aur ek **Private Key** (tumhare paas, .pem file ke roop mein) — jo instance mein **securely login** karne ke kaam aati hai.

**Plain meaning:** Ye password ki jagah **digital chaabi** hai. Jab tum instance launch karti ho, AWS tumhe ek Private Key file deta hai — usi se tum instance mein SSH kar ke andar ja sakti ho. **Password nahi, key chahiye.**

**Example:** Ye aise hai jaise ek **locker** hai jiska lock sirf ek **khaas chaabi** se khulta hai (password se nahi). Jab locker banaya gaya, chaabi tumhe di gayi — agar wo chaabi kho gayi, to locker khulna mushkil ho jata hai (isliye Private Key file **bohot sambhal kar rakhni** hoti hai).

**NovaTech ka example:** NovaTech ka developer apne EC2 server mein login karne ke liye password nahi daalta — uske paas ek `.pem` **Key Pair file** hai jo uske laptop mein save hai. Jab wo terminal se SSH command chalata hai, wo file automatically use hoti hai aur server unlock ho jata hai.

---

## 5. User Data

**User Data** = wo **script/commands** jo tum EC2 instance ko **launch karte waqt** deti ho, jo instance **khud-ba-khud pehli baar boot hone par** chala deta hai.

**Plain meaning:** Ye instance ke liye ek "**welcome note with instructions**" hai — jaisa hi instance zinda hota hai, wo ye instructions apne aap follow karta hai, tumhe manually kuch karne ki zaroorat nahi.

**Example:** Socho tum ek naye employee ko join karwati ho aur uske table par ek **note chhod deti ho**: "sabse pehle apna email set up karo, phir software install karo." Wo employee (EC2 instance) join karte hi khud ye steps follow kar leta hai — tumhe khade ho kar batana nahi padta.

**NovaTech ka example:** NovaTech jab bhi naya EC2 instance launch karta hai, User Data mein ek script daalta hai jo automatically **web server software install** kar de aur **website ki latest copy** download kar le. Isse instance launch hote hi **turant ready** ho jata hai, bina kisi manual kaam ke.

---

## 6. EC2 Life Cycle

EC2 instance apni **zindagi mein kai states** se guzarta hai:

| State | Matlab |
|---|---|
| **Launch (Pending)** | Instance banayi ja rahi hai, taiyar ho rahi hai |
| **Running** | Instance chal rahi hai, use ho rahi hai |
| **Stopped** | Instance band hai (lekin EBS data safe hai), koi bill nahi lag raha compute ka |
| **Terminated** | Instance **permanently delete** ho gayi — wapas nahi aa sakti |

**Example:** Ye bilkul ek **light switch aur bulb** jaisa hai:
- **Launch** = bulb lagaya ja raha hai
- **Running** = bulb jal raha hai (roshni de raha, bill bhi lag raha)
- **Stopped** = bulb off hai lekin lagi hui hai (bill nahi lag raha, lekin bulb wahin hai — turant wapas jala sakte ho)
- **Terminated** = bulb nikaal kar phenk diya — ab wapas nahi laga sakte, naya lagana padega

**NovaTech ka example:** Weekend par NovaTech apna testing server **Stop** kar deta hai taake paisa bache (compute ka bill nahi lagta), lekin Monday ko **Start** karte hi wapas wahi setup mil jata hai. Jab ek purana project band ho gaya, wo instance **Terminate** kar di jati hai kyunki ab kabhi zaroorat nahi.

---

## 7. EC2 Pricing Options

AWS EC2 ko **use karne ke alag-alag pricing tareeqe** deta hai — depend karta hai tumhari zaroorat par.

### On-Demand
Jitna use karo utna **pay-as-you-go** pay karo, koi commitment nahi. **Sabse flexible, lekin sabse mehnga per-hour.**

**Example:** Jaise **taxi book karna** — jab zaroorat ho tabhi book karo, jitna safar karo utna pay karo, koi lambi commitment nahi.

### Reserved Instances
Agar tum **1 ya 3 saal ke liye commit** karti ho ek instance use karne ka, to AWS tumhe **bohot discount** (up to 70%+) deta hai on-demand ke comparison mein.

**Example:** Jaise ek **gaadi ko 1 saal ke liye monthly rent pe lena**, roz-roz taxi book karne ki bajaye — sasta padta hai agar tumhe pata hai ke poore saal chahiye hogi.

**NovaTech ka example:** NovaTica apna **main production server** (jo hamesha chalta rehta hai) Reserved Instance pe leta hai kyunki wo saal bhar chalna hi hai — isse unka bill kaafi kam ho jata hai.

### Spot Instances
AWS ke **fazool pade hue (spare) compute capacity** ko **bohot sasta** (up to 90% discount) mein use karna — lekin AWS kabhi bhi, thodi warning ke sath, wo instance **wapas le sakta hai** agar kisi aur ko zaroorat pad jaye.

**Example:** Ye aise hai jaise **standby flight ticket** lena — bohot sasti milti hai, lekin agar flight full ho jaye to tumhari seat kisi confirmed passenger ko de di jati hai achanak.

**NovaTech ka example:** NovaTech apna **non-critical data processing task** (jaise raat ko background reports banana) Spot Instances par chalata hai kyunki agar wo beech mein rukk bhi jaye to koi bada nuqsaan nahi — bohot sasta padta hai.

---

## 8. Scaling — Horizontal vs Vertical (Recap)

**Horizontal Scaling** = **zyada EC2 instances add karna** — load ko multiple servers mein baantna.

**Vertical Scaling** = **ek hi EC2 instance ka size badhana** (chhoti instance type se badi type mein switch karna — jaise t2.micro se t2.large).

**Example:** NovaTech ke website par traffic badh gaya:
- **Horizontal** = 1 server ki jagah 5 servers laga do, load balancer traffic baant de
- **Vertical** = usi 1 server ka size chhota se bada kar do (zyada CPU/RAM)

---

## 9. High Availability (Recap)

**High Availability** = system **hamesha chalta rahe**, chahe koi ek part fail ho jaye. EC2 ke context mein, isko achieve karte hain instances ko **multiple Availability Zones** mein chala kar.

**Example:** NovaTech apne 2 EC2 instances **alag-alag Availability Zones** mein chalata hai. Agar ek zone mein koi masla ho jaye (power outage, hardware fail), to doosri zone wala instance website ko **chalta rakhta hai** — customers ko pata bhi nahi chalta.

---

## 10. What does AWS manage vs What do YOU manage? (Recap)

*(Ye Shared Responsibility Model hai jo Class 4 mein detail se padha tha — yahan EC2 ke context mein revise kiya)*

**AWS manage karta hai:**
- Physical data centre
- Hardware (asli servers, storage drives)
- Networking (global network jo Regions ko jodta hai)

**Tum manage karti ho:**
- Instance ka OS
- Apni application aur data
- Security Groups, Key Pairs, patches — sab kuch jo instance ke **andar** hai

**Example:** AWS tumhe ek **plot** (physical infrastructure) aur **bijli-pani ka connection** (network) deta hai. Ghar (OS, apps, data, security) **tum khud** banati aur sambhalti ho.

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| EBS | EC2 ki persistent storage (hard disk); stop karne par data safe rehta hai |
| Public IP | internet se access hone wala address |
| Private IP | sirf AWS ke andar ke network mein kaam karne wala address |
| Security Group | virtual firewall — traffic in/out control karta hai |
| Key Pair | Public + Private key jo password ki jagah login ke liye use hoti hai |
| User Data | script jo instance boot hote hi khud chal jati hai |
| EC2 Life Cycle | Launch → Running → Stopped → Terminated |
| On-Demand pricing | jitna use utna pay, koi commitment nahi |
| Reserved Instances | 1-3 saal commit karo, bohot discount milta hai |
| Spot Instances | AWS ki spare capacity, bohot sasti, lekin kabhi bhi wapas li ja sakti hai |
| Horizontal Scaling | zyada instances add karna |
| Vertical Scaling | ek instance ka size badhana |
| High Availability | multiple Availability Zones mein chalana taake system kabhi na ruke |
| AWS manage karta hai | physical data centre, hardware, networking |
| Tum manage karti ho | OS, apps, data, security groups, key pairs |
