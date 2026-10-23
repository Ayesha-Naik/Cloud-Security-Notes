# Class 9 — AWS aur IAM (Identity and Access Management) Poori Detail Mein

## 1. AWS kya hai?

**AWS (Amazon Web Services)** = Amazon ka cloud platform, jahan se tum **200 se zyada services** (compute, storage, database, networking, security, AI) **internet ke zariye rent par** le sakti ho, aur **jitna use karo utna pay** karti ho.

**Plain meaning:** AWS ek bohot bada **"digital shehar"** hai. Tum is mein apna plot (account) leti ho, aur jo bhi chahiye (server, storage, database) wahan se utha leti ho. Building, bijli, security guard, sab AWS ka kaam hai.

**Ye cheezein yaad rakho:**
- **Region** = duniya ka ek geographical area jahan AWS ke data centers hain (jaise N. Virginia, Stockholm)
- **Availability Zone (AZ)** = ek Region ke andar alag-alag data center groups, taake ek jagah masla ho to doosri jagah system chalta rahe
- **Account** = tumhara apna private hissa AWS mein, jahan tumhare saare resources rehte hain

**Example:** AWS ek **bijli company** jaisi hai. Tum apna power plant nahi lagati, bas connection leti ho aur meter ke hisaab se bill deti ho. Account tumhara **ghar ka connection** hai, aur Region **tumhara shehar** hai.

**Is class ka sawal:** Jab itni saari services aur itna saara data ek account mein ho, to **kaun andar aa sakta hai aur kya kar sakta hai**, ye kaun decide karega? Is ka jawab hai **IAM**.

---

## 2. IAM kya hai?

**IAM (Identity and Access Management)** = AWS ki wo service jo decide karti hai ke **kaun** (identity) AWS mein **kya kar sakta hai** (access).

**Plain meaning:** IAM tumhare AWS account ke darwaze par khada **security guard** hai. Har request par wo do sawal poochta hai:
1. **Tum kaun ho?** → **Authentication**
2. **Tumhe ye karne ki ijazat hai?** → **Authorization**

**IAM ki khaas baatein (exam ke liye):**
- IAM **bilkul free** hai
- IAM ek **global service** hai (kisi ek Region tak limited nahi, poore account mein same)
- Ye **"Security IN the cloud"** ka sabse bada tool hai, yaani **customer ki zimmedari** (Shared Responsibility Model)

**Authentication vs Authorization:**

| Term | Sawal | Example |
|---|---|---|
| **Authentication** | Tum **kaun** ho? | Username + password + MFA se login |
| **Authorization** | Tum **kya kar sakti** ho? | Login ke baad S3 padh sakti ho, lekin EC2 delete nahi kar sakti |

**Example (Airport):** **Passport dikhana** = Authentication (saabit kiya tum kaun ho). **Boarding pass** = Authorization (kaunsi flight, kaunsi seat par ja sakti ho). Passport valid ho lekin boarding pass kisi aur flight ka ho, to tum us flight mein nahi baith sakti.

---

## 3. Root User — Sabse Khatarnak Account

Jab tum AWS account banati ho, pehla login **root user** hota hai (tumhari email se). Isko **unlimited power** hoti hai.

**Best practices:**
- Root par **MFA zaroor ON** karo
- Root ko **rozana ke kaam mein use mat karo**, kaam ke liye IAM users banao
- Root ke **access keys mat banao** (ya delete kar do)
- **Strong, unique password** rakho

**Example:** Root user ghar ki **master key** hai jo har almari aur locker kholti hai. Roz usay jeb mein nahi ghumate, locker mein band rakhte hain, aur rozana ke liye chhoti keys (IAM users) use karte hain.

---

## 4. IAM Ke Building Blocks

IAM ke **paanch building blocks** hain. In sab ko ek ek karke samajhte hain.

### Block 1 — IAM User
**User** = ek **person ya ek application ki permanent identity**, jiska apna alag login aur credentials hote hain.

**Example:** Company mein **Sara** naam ki employee hai. Uske liye ek alag IAM user banta hai, jisse wo apne credentials se AWS mein login karti hai. Agar Sara company chhod de, to sirf uska user delete karna hota hai, baaki kisi ka access nahi badalta.

### Block 2 — IAM Group
**Group** = **users ka ek bucket** jinhe **same permissions** chahiye. Group ko permission do, andar ke sab users ko wo **automatically** mil jati hai.

**Example:** "Developers" naam ka group banao. Naya developer aaye to bas usay group mein daal do, usay sab developer wali permissions mil jayengi. Har banday ko alag alag permission nahi deni padti.

**Yaad rakho:** Group mein **sirf users** ho sakte hain, group ke andar group nahi ban sakta. Aur group koi **login identity nahi** hai, group se sign in nahi karte.

### Block 3 — IAM Role
**Role** = **permissions ka ek set jo temporarily pehna ja sakta hai** kisi user, application, ya AWS service ke zariye. Role kisi ek person ke sath **permanently juda nahi** hota, aur iske **temporary credentials** hote hain jo khud expire ho jate hain.

**Role ke do hisse:**

| Hissa | Sawal |
|---|---|
| **Trust policy** | **Kaun** is role ko pehen (assume) sakta hai? |
| **Permissions policy** | Pehenne ke baad **kya kar sakta** hai? |

**Example:** Ek **EC2 server** ko S3 bucket se files padhni hain. Server ke andar password rakhne ki bajaye, server ek role **assume** karta hai jisme "S3 padhne ki permission" hai. Kahin password likha hi nahi, to leak hone ka khatra bhi nahi.

**Role kab use karte hain:**
- AWS service ko doosri service tak access dena (EC2 se S3, Lambda se DynamoDB)
- Doosre AWS account ke logon ko **temporary** access dena
- Federation (company login se AWS mein aana)

**Yaad rakhne ka trick:** User = **permanent ID card**. Role = **visitor badge** jo kaam ke waqt pehna aur kaam khatam hote hi utar gaya.

### Block 4 — IAM Policy
**Policy** = ek **JSON document** jo exactly batata hai ke **kya allowed hai aur kya denied hai**. Policy ko user, group, ya role ke sath **attach** kiya jata hai.

**Policy ke main hisse (JSON ke andar):**

| Element | Matlab | Example value |
|---|---|---|
| `Version` | policy language ka version | `2012-10-17` |
| `Statement` | rules ki list | ek ya kai rules |
| `Effect` | Allow ya Deny | `Allow` |
| `Action` | kaunsa kaam | `s3:GetObject` |
| `Resource` | kis cheez par (ARN se) | `arn:aws:s3:::my-bucket/*` |
| `Condition` | optional shart | sirf kisi khaas IP se, ya sirf MFA ke sath |

**Policy ki types:**
- **AWS managed policies** = AWS ki bani banai, ready to use (jaise `AmazonS3ReadOnlyAccess`)
- **Customer managed policies** = jo tum khud likhti ho apni zaroorat ke hisaab se
- **Inline policies** = kisi ek user/group/role ke sath seedha jori hui, sirf usi ke liye

**Do bunyadi rules (bohot zaroori):**
- **Default sab deny hota hai** (**implicit deny**). Tum jab tak "Allow" na likho, kuch bhi allowed nahi.
- **Explicit Deny hamesha jeetta hai.** Agar kahin saaf "Deny" likha ho, to das Allow rules bhi usay override nahi kar sakti.

**AWS ka decision flow:** Pehle check hota hai **koi Explicit Deny hai?** Haan to **DENIED**. Nahi to check hota hai **koi Allow hai?** Haan to **ALLOWED**. Nahi to **implicit deny**.

**Example:** Ek security guard pehle apni **banned list** dekhta hai (explicit deny). Agar naam us list mein hai to kisi bhi card se andar nahi ja sakti. Agar naam list mein nahi, tab wo tumhara **access card** (allow) check karta hai.

**ARN kya hai:** **Amazon Resource Name** = AWS mein har resource ka **unique address**. Policy mein "kis cheez par" batane ke liye use hota hai. Jaise `arn:aws:s3:::my-bucket/*` ka matlab hai us ek bucket ke andar sab kuch.

### Block 5 — Principle of Least Privilege
Ye koi alag service nahi, balki **ek usool** hai jo baaki chaaron blocks par lagta hai.

**Least Privilege** = kisi bhi user, group, ya role ko **sirf utni hi permissions do jitni uske kaam ke liye zaroori hain, us se zyada nahi.**

**Kaise lagu karte hain:**
- Shuru mein **kam permission** do, zaroorat pade to baad mein badhao
- `AdministratorAccess` sirf bohot kam logon ko do
- Policy mein `Action: *` aur `Resource: *` (sab kuch sab par) se **bacho**
- Jo permissions use nahi ho rahi, unhe **hata do**

**Example:** Ek developer ko sirf ek S3 bucket se files **padhni** hain. Usay admin access dene ki bajaye aisi policy do jo sirf **us bucket ka read-only** access de. Agar uska account hack bhi ho jaye, to hacker sirf wahi ek bucket padh sakega, poora account nahi uda sakega.

**Office Building Analogy (paanchon ek sath):**
- **User** = employee ka ID badge
- **Group** = department, jahan sab ke badge same darwaze kholte hain
- **Role** = visitor badge jo koi temporarily le sakta hai
- **Policy** = likha hua rule ke kaunsa badge kaunsa darwaza kholega
- **Least Privilege** = har badge sirf utne darwaze kholta hai jitne us bande ke kaam ke liye zaroori hain

---

## 5. MFA — Password Chori Hone Se Bachne Ka Pehla Hathiyar

**MFA (Multi-Factor Authentication)** = login ke liye **do ya zyada saboot**, sirf password nahi.

| Factor | Matlab | Example |
|---|---|---|
| **Something you KNOW** | jo tumhe pata hai | Password, PIN |
| **Something you HAVE** | jo tumhare paas hai | Phone app ka 6-digit code, hardware key |
| **Something you ARE** | jo tum khud ho | Fingerprint, face scan |

**Example (ATM):** ATM ko **card** (jo tumhare paas hai) aur **PIN** (jo tumhe pata hai) dono chahiye. Sirf ek chura lene se paisa nahi nikalta. MFA AWS login ke liye yahi karta hai.

**Ye kyun kaam karta hai:** Agar hacker ne password chura bhi liya, to wo **tumhare phone ke bina** login nahi kar sakta.

---

## 6. Password Chori Hone Se Kaise Bachein (Prevention)

**Password se related:**
- **Strong, lamba, unique password** use karo (har jagah alag)
- **Password manager** use karo
- **IAM password policy** set karo: minimum length, uppercase/lowercase/number/symbol, password expiry, purana password dobara use na ho sake
- **MFA har user par ON** karo, root par to zaroor

**Access keys se related (bohot zaroori):**
- Access keys **kabhi code mein mat likho**
- **GitHub par kabhi push mat karo.** Tum apne notes aur labs GitHub par daalti ho, to dhyan rakho ke koi `.env` ya credentials file repo mein na chali jaye. Bots public repos ko **seconds mein scan** kar ke leaked keys use kar lete hain.
- Jahan ho sake **keys ki jagah Roles** use karo (kyunki roles ke credentials temporary hote hain)
- **Purani aur unused keys delete karo**, aur baaki keys ko **regularly rotate** karo

**Aur bhi practices:**
- Root user ko roz use mat karo
- **Billing alarm** lagao taake achanak bill badhe to pata chale
- **Phishing** se hoshiyar raho (fake AWS login page, "account suspend ho jayega" wali emails)
- Public WiFi par sensitive login se bacho, ya VPN use karo

**Example:** Password ek **ghar ki chaabi** hai. Usay darwaze ke bahar **chatai ke neeche** (code ya GitHub mein) rakhna aur phir hairan hona ke chor kaise aaya, ye galat hai.

---

## 7. Agar Password ya Keys Chori Ho Jayein To Kya Karein (Incident Response)

Is mein **tezi** sabse zaroori hai. Ye steps order mein follow karo:

1. **Turant password badlo** aur **MFA ON** karo (agar nahi tha)
2. **Compromised access keys ko Deactivate karo**, phir delete karo (IAM console se, ya CLI se)
3. **Active sessions revoke karo**, taake hacker ke chalu temporary credentials bhi band ho jayein
4. **Check karo hacker ne kya kiya:** **CloudTrail** logs dekho (kisne, kab, kaunsa action kiya), aur **IAM credential report** dekho
5. **Unknown resources dhundo aur delete karo:** koi naye EC2 instances (aksar crypto mining ke liye), naye IAM users, naye roles, naye access keys, kisi aur Region mein chalte resources
6. **Bill check karo** ke kahin achanak kharcha to nahi hua
7. Agar nuqsaan bada ho to **AWS Support se rabta** karo
8. **Wajah dhundo aur theek karo:** keys kahan leak hui (GitHub? koi app?), aur dobara na ho iske liye rotation, MFA, aur least privilege lagao

**Example:** Ye aise hai jaise tumhari chaabi chori ho jaye. Pehle **lock badlo** (keys deactivate), phir dekho **chor ne ghar mein kya kya haath lagaya** (CloudTrail), jo cheezein badli hain unhe wapas karo, aur aakhir mein pata karo **chaabi kahan se gayi** taake dobara na ho.

---

## 8. Access Management Kya Hai?

**Access Management** = ye **poora process** ke organization mein **kis ko, kis cheez tak, kab tak, aur kis wajah se** access diya jaye, aur wo sahi bana rahe.

**Iske hisse:**

| Hissa | Matlab |
|---|---|
| **Identity creation** | naya user/role banana jab zaroorat ho |
| **Access request & approval** | koi access maange to approval ke baad hi dena |
| **Permission assignment** | groups aur policies ke zariye permissions dena |
| **Monitoring** | dekhte rehna kaun kya kar raha hai |
| **Review (audit)** | waqt waqt par check karna ke kis ko kitni access chahiye |
| **Removal** | jab kaam khatam ya banda chala jaye to access hata dena |

**Access Request ka matlab:** Jab koi banda naye access ki **darkhwast** kare, to wo **sahi wajah** ke sath ho, **approve** ho, aur **sirf zaroori access** diya jaye (least privilege). Zaroorat khatam hote hi wapas le li jaye.

**Example:** Ek **library card** system socho. Naya member form bharta hai (request), librarian check karke approve karta hai, usay sirf kuch sections ka card milta hai (least privilege), aur saal ke aakhir mein card renew hota hai ya band (review aur removal).

**AWS ke tools jo access management mein madad karte hain:**

| Tool | Kaam |
|---|---|
| **IAM Access Analyzer** | dikhata hai kaunsa resource bahar ke logon ke sath share hua hai, aur unused access |
| **IAM Credential Report** | account ke saare users aur unke password/keys/MFA ki halat ek report mein |
| **Last accessed information** | dikhata hai kaunsi permission kab aakhri baar use hui, jo use nahi hui wo hata do |
| **CloudTrail** | har API call ka record (kisne, kab, kya kiya) |
| **AWS Organizations aur SCP** | kai accounts par upar se limits lagana |
| **IAM Identity Center** | ek login se kai accounts/apps tak access (single sign-on) |

---

## 9. Federation aur IAM Identity Center (Short)

**Federation** = logon ko AWS mein **unki pehle se maujood identity** (jaise company ka Microsoft/Google login) se aane dena, naya IAM user banaye bagair. Dono systems ek doosre par **trust** karte hain.

**IAM Identity Center** (pehle AWS SSO) = **single sign-on**, ek hi login se **kai AWS accounts aur applications** tak access.

**Example:** "**Login with Google**" jaisa. Har website par naya password banane ki bajaye ek hi Google account se kai jagah chale jate hain. Isi tarah, ek company login se AWS ke kai accounts khul jate hain.

---

## 10. IAM Security Best Practices (Ek Jagah)

1. **Root user** ko lock karke rakho, MFA ON, rozana use nahi
2. **Har insaan ka alag IAM user** (ya Identity Center), shared login nahi
3. **Users ko groups mein** daalo, permissions group ko do
4. **Least privilege** hamesha
5. **MFA** sab users par
6. **Strong password policy** set karo
7. **Roles use karo** applications aur AWS services ke liye, access keys ki jagah
8. **Access keys rotate karo** aur unused delete karo
9. **Credentials kabhi code ya GitHub mein nahi**
10. **CloudTrail ON** rakho, aur **billing alarm** lagao
11. **Regular review**, access analyzer aur credential report se

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| AWS | Amazon ka cloud platform, pay-as-you-go services |
| IAM | AWS ki service jo kaun kya kar sakta hai ye control karti hai (free, global) |
| Authentication | tum kaun ho, ye saabit karna |
| Authorization | tumhe kya karne ki ijazat hai |
| Root user | account ka owner, unlimited power, rozana use nahi |
| IAM User | ek person/app ki permanent identity |
| IAM Group | same permissions wale users ka bucket |
| IAM Role | temporary badge, temporary credentials, trust + permissions policy |
| IAM Policy | JSON document jo Allow/Deny batata hai |
| Implicit deny | Allow na ho to khud-ba-khud deny |
| Explicit Deny | hamesha jeetta hai |
| ARN | resource ka unique address |
| Least Privilege | sirf utni permission jitni kaam ke liye zaroori hai |
| MFA | password + doosra factor (phone code, fingerprint) |
| Access keys | programmatic access ki chaabi, code/GitHub mein kabhi nahi |
| Key rotation | keys ko regularly badalna |
| Credentials leak hon to | deactivate keys, password badlo, sessions revoke, CloudTrail check, unknown resources delete |
| Access Management | kis ko kya access, request, approve, monitor, review, remove ka poora process |
| Access Analyzer | bahar share hue resources aur unused access dikhata hai |
| Credential Report | saare users ki password/keys/MFA ki report |
| CloudTrail | har API call ka record |
| Federation | existing login (Microsoft/Google) se AWS mein aana |
| IAM Identity Center | single sign-on, ek login kai accounts |
