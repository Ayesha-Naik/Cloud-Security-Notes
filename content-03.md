# Class 3 — Migration, Shared Responsibility & IAM Basics

## 1. Cloud Migration — The 6 R's

**Migration** = apne existing systems ko apne data center se **cloud mein move karna**. AWS is process ke liye 6 common strategies batata hai — inhe "**6 R's**" kehte hain. Har ek ek alag tareeqa hai ke ek application ko **kaise** move kiya jaye.

| Strategy | Simple Lafzon Mein | Example |
|---|---|---|
| 1. **Rehost** ("lift and shift") | App ko **jaisa hai waisa** cloud pe move kar do, koi changes nahi | Ek company apna purana on-premises app EC2 server pe copy kar deti hai — bina code change kiye |
| 2. **Replatform** ("lift, tinker, shift") | Move karte waqt **kuch chhoti improvements** kar do, lekin koi bada redesign nahi | Company apna database EC2 se **AWS RDS (managed database)** pe shift karti hai — thoda tinker kiya, lekin app ka baaki structure same rakha |
| 3. **Repurchase** | Purana app chhod kar **doosre (aksar SaaS) product** pe switch kar jao | Company apna khud ka banaya hua email system chhod kar **Gmail/Google Workspace** use karna shuru kar deti hai |
| 4. **Refactor / Re-architect** | App ko **significantly rebuild** karo taake cloud features poori tarah use ho sakein | Company apna purana monolithic app tod kar **microservices** mein rebuild karti hai — sabse zyada mehnat lagti hai, lekin sabse zyada cloud-native fayda milta hai |
| 5. **Retire** | Samajh jao ke **app ki ab zaroorat nahi** — use band/shut kar do | Company dekhti hai ke ek purana internal tool koi use nahi kar raha — usko permanently retire kar deti hai |
| 6. **Retain** | App ko **abhi ke liye wahin rehne do** — move mat karo | Company decide karti hai ke ek legacy system abhi bohot critical/complex hai move karne ke liye, to use **on-premises hi rakha jata hai** filhaal |

**Yaad rakhne ka trick:** Har R "how" batata hai — sabse aasan (Rehost) se sabse zyada mehnat wale (Refactor) tak, aur do strategies aisi bhi hain jahan tum app ko move hi nahi karte (Retire, Retain).

---

## 2. The Shared Responsibility Model (Introduction)

Ye concept **bohot important** hai — cloud security ka bunyadi usool.

**Plain meaning:** Cloud mein security ek **team ka kaam** hai — AWS aur tum dono milkar security sambhalte ho. AWS kuch cheezein secure karta hai, tum baaki cheezein secure karti ho. **Koi bhi akela poori security nahi karta.**

**The Rule (yaad rakhne wala):**
- **AWS responsible hai:** "**Security OF the cloud**" — matlab wo cheezein jo cloud ko chalati hain
- **Tum responsible ho:** "**Security IN the cloud**" — matlab wo cheezein jo tum cloud ke **andar** rakhti ho

Do lafz yaad rakho: **OF** vs **IN**.

### AWS handles "Security OF the cloud"
Sab kuch jo **AWS khud chalata hai** — jo cheezein tum kabhi touch nahi karti:
- **Physical data centers** — buildings, locks, guards
- **Hardware** — asli servers, storage drives, networking equipment
- **Global network** — jo AWS ke Regions ko aapas mein jodta hai
- **Base software/virtualization** — jo cloud ko andar se chalata hai

**Example:** Agar AWS ke kisi data center mein koi hardware fail ho jaye ya building ki security break ho, ye **AWS ki zimmedari** hai — tum is par kuch control nahi rakhti.

### You handle "Security IN the cloud"
Sab kuch jo **tum khud dalti/control karti ho**:
- **Tumhara data** — tum khud iski malik ho, tum khud isko protect karti ho
- **Kaun kya access kar sakta hai** — identity & access management (IAM)
- **Tumhari configuration/settings** — jaise galti se koi storage bucket public na kar dena
- **Apna data encrypt karna**
- **Tumhara operating system, firewall, patches** — un services ke liye jahan ye tumhara kaam hai (jaise EC2)

**Example:** Agar tum apni AWS S3 storage bucket ki settings galti se "public" kar deti ho aur koi data leak ho jata hai — ye **tumhari zimmedari** hai, AWS ki nahi, kyunki configuration tumhare control mein thi.

---

## 3. Responsibility SHIFTS depending on the service (deeper detail)

Ye **exam ke liye bohot important** point hai. **AWS aur tumhare beech ki line har service ke sath badalti hai** — jitna zyada AWS manage karta hai, utni kam zimmedari tumhari hoti hai.

| Service | Type | Tum kya manage karti ho | AWS kya manage karta hai |
|---|---|---|---|
| **Amazon EC2** | IaaS (virtual server) | OS, patching, firewall, apps, data | Hardware, hypervisor, facility |
| **Amazon RDS** | Managed database | Tumhara data, access, kuch settings | OS, database patching, hardware |
| **AWS Lambda** | Serverless | Sirf tumhara code & permissions | OS, servers, scaling, patching |

**The pattern (ye samajhna zaroori hai):**
- **EC2** = tum sabse zyada manage karti ho, kyunki ye **sirf ek raw server** hai — OS bhi tumhara kaam, patching bhi tumhara kaam
- **RDS** = AWS database ki admin/patching apne upar le leta hai, isliye tum **kam manage** karti ho — bas apna data aur access sambhalna hai
- **Lambda** = AWS **lagbhag sab kuch** manage karta hai — tum sirf apna **code** aur **kaun use access kar sakta hai** ye handle karti ho

**Example (poora scenario):** Socho tumhare paas ek application hai jo user data store karti hai.
- Agar ye **EC2** pe chal rahi hai — tumhe khud OS update karna, firewall set karna, patches lagana sab kuch tumhara kaam hai
- Agar tum wahi database **RDS** pe move kar do — AWS khud database ka software patch karta rahega, tumhe sirf apne data aur access rules ka khayal rakhna hai
- Agar tum apna code **Lambda** pe chalati ho — tumhe server ka bilkul khayal nahi rakhna, bas apna code likho aur permissions set karo, baaki AWS sambhal leta hai

**Yaad rakho:** "**More managed = less your responsibility.**" (Jitna zyada AWS sambhalta hai, utni kam zimmedari tumhari.)

---

## 4. IAM — Identity and Access Management

**IAM** (Identity and Access Management) wo AWS service hai jo control karti hai ke **kaun login kar sakta hai** aur **wo kya karne ke allowed hain**. Agar "security IN the cloud" tumhara kaam hai, to **IAM tumhara main tool hai** ye kaam karne ke liye.

**Plain meaning:** IAM tumhare AWS account ke darwaze pe khada **security guard** hai. Har action ke liye ye 2 sawaal poochta hai:
1. "**Tum kaun ho?**" (Authentication)
2. "**Kya tumhe ye karne ki ijazat hai?**" (Authorization)

### Do words jo confuse nahi honi chahiye

**Authentication** = **saabit karna ke tum WHO ho** — login karna username + password se, ya ek key se. Sawaal: "**Kya tum sach mein wahi ho jo tum keh rahi ho?**"

**Authorization** = ek baar andar aane ke baad, **tumhe kya karne ki ijazat hai**. Sawaal: "**Tum andar to ho — lekin kya tum ise delete kar sakti ho?**"

**Airport Analogy (bohot clear example):**
- **Authentication** = airport check-in pe apna **passport dikhana** — ye saabit karta hai tum kaun ho
- **Authorization** = tumhara **boarding pass** decide karta hai konsi flight aur konsi seat tum le sakti ho — ye decide karta hai tumhe kya karne ki ijazat hai
- Dono **alag-alag checks** hain — passport ho sakta hai valid ho, lekin boarding pass kisi aur flight ka ho to tum us flight mein nahi baith sakti

**Important fact for exam:** IAM **free** hai, aur ye ek **global service** hai (kisi ek Region tak limited nahi — poori AWS account mein same rehta hai).

**EXAM ANGLE:** Agar koi sawaal poochta hai "**kaunsi service user access aur permissions control karti hai AWS mein?**" → jawab hai **IAM**.

---

## 5. IAM Building Blocks — User & Group

IAM ke 4 building blocks hote hain, lekin abhi sirf **do** cover kar rahi hoon — baaki (Role, Policies) sir agli class mein detail se padhayenge.

### IAM User
Ek **user** = **ek identity ek person (ya ek application) ke liye**. Iska apna alag login hota hai.

**Example:** Company mein ek employee hai **Sara** — uske liye ek alag IAM user banaya jata hai, jisse wo apni khud ki login credentials se AWS account mein access kar sake.

### IAM Group
Ek **group** = **users ka ek bucket** jinhe **same permissions** chahiye hoti hain. Tum users ko group mein daalti ho, group ko permissions deti ho, aur andar ke sab users ko wo permissions mil jaati hain automatically — ek-ek karke permission dene se **bohot aasan tareeqa**.

**Example:** Company mein ek "**Developers**" naam ka group banaya jata hai. Jitne bhi developers hain unhe is group mein daal diya jata hai — ab agar developers ko kisi naye tool ka access dena ho, to sirf **group ki permission** update karni padti hai, har developer ko alag se nahi dena padta.

### IAM Role
Ek **role** = **permissions ka ek set jo temporarily pehna ja sakta hai** kisi user, kisi application, ya kisi AWS service ke dwara. Ye kisi ek person ke sath **hamesha ke liye tied nahi** hota. Roles **temporary credentials** use karte hain.

**Example:** Ek **EC2 server** ko S3 storage bucket se data padhna hai. Server mein password store karne ki bajaye, server ek role "**assume**" karta hai jo use bucket padhne ki permission deta hai. Password kahin likha hi nahi, isliye leak hone ka darr bhi nahi.

**Yaad rakho:** User = ek permanent identity (jaise Sara). Role = ek temporary "topi" jo koi bhi zaroorat par pehen sakta hai aur kaam khatam hone par utar deta hai.

### IAM Policy
Ek **policy** = ek **document (JSON format mein likha hua)** jo bilkul batata hai ke **kya allowed hai ya denied hai**. Policies ko **users, groups, ya roles** ke sath attach kiya jata hai.

**Policies ki do kisme hain:**
- **Managed policies** = AWS ki bani banai, **ready-to-use** policies
- **Custom policies** = wo policies jo **tum khud likhti ho**, apni zaroorat ke hisaab se

**Example:** AWS ki ek ready-made policy hoti hai jo sirf S3 ko **read-only** access deti hai. Tum use seedha "Developers" group ke sath attach kar sakti ho (managed policy). Agar tumhe aisi rule chahiye ke "sirf ek khaas bucket ko padho, baaki ko nahi", to tum apni **custom policy** likhogi.

### Office Building Analogy (User, Group, Role, Policy ek saath)
Ek office building socho:
- **User** = ek employee ka **ID badge**
- **Group** = ek **department**, jahan sab ka badge **same darwaze** kholta hai
- **Role** = ek **visitor badge** jo koi bhi **temporarily** khaas kamron ke liye le sakta hai
- **Policy** = wo **likha hua rule** ke kaunse darwaze badge kholega

**Example:** Sara ka apna ID badge hai (User). Wo "Developers" department mein hai (Group), isliye engineering floor ke darwaze khulte hain. Ek contractor aaya jo sirf server room dekhega, use ek din ka visitor badge (Role) diya. Kaun sa badge kaun sa darwaza kholega, ye sab **likha hua rule (Policy)** decide karta hai.

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| Rehost | app ko jaisa hai waisa move karna (lift and shift) |
| Replatform | chhoti improvements ke sath move karna |
| Repurchase | purana app chhod kar naya (SaaS) product lena |
| Refactor/Re-architect | app ko poori tarah rebuild karna |
| Retire | app ki zaroorat khatam, band kar dena |
| Retain | app ko abhi move na karna |
| Shared Responsibility Model | security ka kaam AWS aur customer ke beech baant'na |
| Security OF the cloud | AWS ki zimmedari (hardware, buildings, network) |
| Security IN the cloud | customer ki zimmedari (data, access, config, encryption) |
| Responsibility shift pattern | zyada managed service (Lambda) = kam responsibility tumhari |
| IAM | AWS service jo access/permissions control karti hai |
| Authentication | tum kaun ho, ye saabit karna |
| Authorization | tumhe kya karne ki ijazat hai |
| IAM User | ek identity ek person/app ke liye |
| IAM Group | same permissions wale users ka bucket |
