# Class 4 — Root User, Least Privilege, MFA, Encryption, KMS & Federation

## 1. The Root User — aur isko protect kyun karna zaroori hai

Jab tum pehli baar AWS account banati ho, to tumhe ek **root user** milta hai — ye account ke **original owner ka login** hota hai (tumhari email se). Isko **complete, unlimited power** milti hai har cheez par. Yehi power isko **khatarnak** banati hai.

**Plain meaning:** Root user poore account ki **master key** hai. Agar kisi ne ye chura li, to poora account uska ho gaya. Isliye AWS kehta hai: isko bohot zyada protect karo aur **rozana ke kaam mein lagbhag kabhi use mat karo**.

**Example:** Ye aise hai jaise ghar ki **master key** jo har darwaza, almari aur locker khol sakti hai. Tum roz us master key ko jeb mein le kar nahi ghoomti — tum ek alag chhoti key (IAM user) use karti ho aur master key ko locker mein band rakhti ho.

### Root user ke best practices (yaad rakho)
- Root user par **MFA (Multi-Factor Authentication) ON karo** — ye **#1 protection** hai
- Root user ko **everyday tasks ke liye use mat karo** — daily kaam ke liye **IAM users** banao
- Root user ke **access keys mat banao** (agar pehle se hain to delete kar do)
- **Strong, unique password** use karo

**Example:** Agar tum roz root user se login karti ho aur ek din tumhara password leak ho jaye, to hacker ke paas poore account ka control hoga. Agar tum IAM user se kaam karti ho aur root par MFA laga hai, to hacker ko root tak pahunchna bohot mushkil hoga.

### Wo cheezein jo SIRF root user kar sakta hai
Kuch khaas tasks ke liye root hi chahiye — exam mein ye pooch sakte hain:
- AWS **account settings badalna** (account name, email, root password)
- AWS **account close karna**
- AWS **Support plan change ya cancel karna**
- IAM users ki permissions wapas restore karna, jab koi (admin samet) khud ko lock out kar le *(ye point mera add kiya hua hai, sir ke page se check kar lena, na ho to delete kar do)*
- Kuch special sign-ups (jaise AWS GovCloud) *(ye bhi mera add kiya hua hai, page se check kar lena, na ho to delete kar do)*

**Example:** Agar tum chahti ho ke account ki registered email change ho ya poora AWS account band ho jaye, to IAM user (chahe admin ho) ye nahi kar sakta — root user se login karna hi padega.

---

## 2. The Principle of Least Privilege

**Least Privilege** = kisi user, group ya role ko **sirf utni hi permissions dena jitni uske kaam ke liye zaroori hain, us se zyada bilkul nahi.** Ye AWS security ka sabse important usool hai. *(Ye standard definition hai, sir ke page se check kar lena.)*

**Plain meaning:** Pehle kam permission do. Agar zaroorat pade to baad mein badhao. Shuru mein "sab kuch allowed" dena galat approach hai.

**Example:** Office mein ek naya intern aata hai jise sirf files padhni hain. Use poori building ki master key dene ki bajaye, sirf usi kamre ki chaabi di jaati hai jahan usay kaam karna hai. Agar wo galti kare ya uska account hack ho jaye, to nuqsaan sirf usi ek kamre tak rehta hai.

**AWS mein example:** Ek developer ko sirf ek S3 bucket se files **padhni** hain. Use `AdministratorAccess` dene ki bajaye, ek aisi policy do jo sirf **us bucket ka read-only access** de. Ab agar us developer ka password chori bhi ho jaye, to hacker sirf wo ek bucket padh payega, poora account delete nahi kar sakega.

**IAM ke sath link:** Least Privilege IAM ke Users, Groups, Roles aur Policies ke through hi lagu hota hai. Tum IAM policy mein likhti ho ke kis ko kya allowed hai, aur Least Privilege kehta hai ke wo policy **kam se kam** allow kare.

**Ye kyun zaroori hai:**
- **Galti se nuqsaan kam hota hai:** jis ke paas delete ki permission hi nahi, wo galti se bhi delete nahi kar sakta
- **Hack hone par damage limit hota hai:** chori hua account sirf utna hi kar payega jitni uski permissions thi
- **Root user se link:** isi wajah se root user (unlimited power) ko rozana use nahi karte, aur kaam ke liye limited IAM users banate hain

**EXAM ANGLE:** Agar sawaal mein aaye "sirf zaroori permissions dena" ya "minimum access dena" → **Principle of Least Privilege**.

---

## 3. MFA & Authentication Methods

**MFA (Multi-Factor Authentication)** = login ke liye **do ya zyada saboot (proofs)** maangna, sirf password nahi. Agar kisi ne tumhara password chura bhi liya, to **doosre factor ke bina andar nahi ja sakta**.

**ATM Analogy:** ATM ko **card** chahiye (jo tumhare paas hai) **aur PIN** chahiye (jo tumhe pata hai). Do factors. Sirf ek chura lene se kaam nahi chalta. MFA AWS login ke liye yehi karta hai.

### Factor ki types
| Factor | Matlab | Example |
|---|---|---|
| **Something you KNOW** | jo tumhe pata hai | Password ya PIN |
| **Something you HAVE** | jo tumhare paas hai | Phone app ka code, hardware key |
| **Something you ARE** | jo tum khud ho | Fingerprint, face scan |

MFA in mein se **kam az kam do** factors combine karta hai. AWS mein common MFA = **tumhara password + phone ki app se 6-digit code**.

**Example (poora scenario):** Tum AWS mein login karti ho. Pehle password daalti ho (**something you know**), phir AWS ek 6-digit code maangta hai jo tumhare phone ki authenticator app mein har kuch second baad badalta hai (**something you have**). Ab agar hacker ke paas sirf password hai, to phone ke bina wo login nahi kar payega.

---

## 4. Encryption — at rest & in transit

**Encryption** = data ko **scramble** karna taake sirf wohi padh sake jiske paas **sahi key** ho. Agar chor encrypted data chura le, to uske liye wo **bekaar garbage** hai.

### Data ki do states jinhe protect karna hai

**Encryption at rest** = data ko protect karna jab wo **stored** hai (disk par, database mein, storage bucket mein pada hai).

**Encryption in transit** = data ko protect karna jab wo **network par move** kar raha hai (tumhare computer aur AWS ke beech travel kar raha hai). Ye **TLS/SSL** use karta hai — wahi cheez jo website ko "**https**" banati hai.

**Money Analogy:**
- **Encryption at rest** = paisa ghar ki **tijori (safe) mein locked**
- **Encryption in transit** = paisa **locked armored truck** mein move ho raha hai
- Tum paisa dono jagah protect karti ho — **rakhe hue bhi aur chalte hue bhi**

**Example:** Ek online shop ka customer data S3 bucket mein pada hai — ye **at rest** hai, isko encrypt karna hai taake bucket leak bhi ho jaye to data padha na ja sake. Jab customer apna card number website par bhejta hai, wo data internet par **travel** kar raha hai — ye **in transit** hai, jise https (TLS) protect karta hai.

---

## 5. AWS KMS — Key Management Service

**AWS KMS** = wo AWS service jo **encryption keys banati aur manage karti hai**. Kyunki encryption ko keys chahiye, KMS wo jagah hai jahan tum in keys ko **safely store aur control** karti ho.

*(Ek related service **CloudHSM** hai, jo keys ke liye **dedicated hardware** deti hai — bas iska naam pehchanna kaafi hai.)*

**Example:** Tumne apna data lock kar diya (encrypt kiya) — ab **lock ki chaabi (key)** kahan rakhogi? Agar chaabi kahin bhi pari rahe to lock ka fayda khatam. KMS ek **secure chaabi-ghar** hai jahan chaabiyan bani hoti hain, rakhi jaati hain aur sirf authorized logon ko milti hain.

**EXAM ANGLE:**
- "Stored data ko protect karna" = **encryption at rest**
- "Network par move hote data ko protect karna" = **encryption in transit (TLS)**
- "Kaunsi service encryption keys manage karti hai?" → **AWS KMS**

---

## 6. Federation & IAM Identity Center

Ye do thode bade words hain jo exam mein aate hain — simple rakh ke samjhte hain.

### Federation (Federated Identity)
**Federation** = logon ko AWS mein login karne dena **apni pehle se maujood identity** se (jaise company ka Microsoft/Google login), naya AWS user banane ki bajaye. Dono systems ek doosre par **trust** karte hain.

**"Login with Google" Analogy:** Bohot si websites tumhe naya password banane ki bajaye **Google account se sign in** karne deti hain. Federation wahi idea hai AWS ke liye — apna **existing company login** use karke AWS access karo.

**Example:** Ek company ke 500 employees hain jo pehle se Microsoft account se office mein login karte hain. Har employee ke liye alag AWS IAM user banane ki bajaye, company federation set karti hai — ab employees **apne usi Microsoft login se** seedha AWS mein ja sakte hain.

### IAM Identity Center
**IAM Identity Center** (pehle ka naam **AWS SSO**) = **single sign-on** ki service — **ek hi login** jisse user ko **multiple AWS accounts aur applications** tak access mil jaye *(screenshot mein ye line adhoori thi, ye standard definition hai)*.

**Example:** Ek company ke paas 5 alag AWS accounts hain (development, testing, production...). Har account ke liye alag login yaad rakhne ki bajaye, employee **ek baar login** karta hai IAM Identity Center mein aur wahan se apne allowed sab accounts mein ja sakta hai — jaise ek hi ID card se office ke saare darwaze khul jaate hain.

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| Root User | account ka original owner, unlimited power (master key) |
| Root best practice | MFA ON, daily kaam mein use nahi, access keys nahi, strong password |
| Root-only tasks | account settings badalna, account close karna, support plan change/cancel |
| Least Privilege | sirf utni permissions do jitni kaam ke liye zaroori hain, us se zyada nahi |
| MFA | login ke liye 2+ saboot (password + ek aur factor) |
| Something you know | password / PIN |
| Something you have | phone app code / hardware key |
| Something you are | fingerprint / face scan |
| Encryption | data ko scramble karna, sirf sahi key wala padh sake |
| Encryption at rest | stored data ki protection (disk, database, bucket) |
| Encryption in transit | network par move hote data ki protection (TLS/SSL, https) |
| AWS KMS | encryption keys banane aur manage karne wali service |
| CloudHSM | keys ke liye dedicated hardware (sirf naam yaad rakho) |
| Federation | existing identity (Microsoft/Google) se AWS login karna |
| IAM Identity Center | single sign-on — ek login, multiple accounts/apps (pehle AWS SSO) |
