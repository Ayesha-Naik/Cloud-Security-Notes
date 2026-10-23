# Class 10 — IAM Policies in Depth (Writing a Keycard)

## 1. Policy Likhna — "Keycard" Banane Ka Tareeqa

Ek IAM policy ko socho ek **keycard** ki tarah jo tum kisi user ko dete ho. Jab tak policy nahi likhi jati, **koi rule hi nahi hota** — aur jab koi rule hi na ho, to **sab kuch by default deny** ho jata hai.

**Plain meaning:** Agar tum kisi IAM user ko bana kar usay **koi bhi policy attach nahi karti**, to wo user **kuch bhi nahi kar sakta** — na file download kar sakta hai, na upload, kuch nahi. AWS ka default rawaiya hamesha "**na**" hota hai jab tak tum khud "**haan**" na likho.

**Example:** Ye aise hai jaise ek naya employee office join kare aur usay **koi bhi ID card na diya jaye** — wo kisi bhi darwaze se andar nahi ja sakta, chahe wo building mein khada bhi ho. Jab tak HR usay ek card na de jisme specifically likha ho "ye darwaze khulenge," wo kahin nahi ja sakta.

---

## 2. Scenario — Sirf Upload Allow Karna

Maan lo goal ye hai: ek user ko **sirf** ek file **upload** karne ki ijazat honi chahiye. **Na reading, na deleting, na listing.**

Jab tak koi rule nahi likha jata, policy kuch is tarah dikhti hai: Version "2012-10-17", aur Statement ek khaali array `[]`. `Statement: []` ka matlab hai **statement array khaali hai** — koi rule hi exist nahi karta.

**Is khaali policy ke sath har request ka result:**

| Request | Result |
|---|---|
| Download lecture.pdf | Implicit deny |
| Download student-records.csv | Implicit deny |
| Upload website.html | Implicit deny |
| Delete lecture.pdf | Implicit deny |
| List the bucket's files | Implicit deny |
| Stop the EC2 server | Implicit deny |

**"Implicit deny" ka matlab:** Koi rule ne specifically isay allow nahi kiya, isliye **chupke se khud-ba-khud deny** ho gaya — koi "explicit no" nahi likha, bas **sannata (silence)** hai, aur sannata = deny.

**Example:** Ye aise hai jaise tumne kisi se poocha "kya main ye kar sakti hoon?" aur **koi jawab hi na mile** — khamoshi ka matlab hota hai "nahi."

---

## 3. s3:GetObject Allow Karna — Ek Galat Fehmi

Agar koi `s3:GetObject` (download karne ki permission) saari files par allow kar de, to policy mein ek Statement add hoga jisme Effect "Allow" hoga, Action "s3:GetObject" hoga, aur Resource ek bucket ke andar sab files (jaise `training-files/*`) ko point karega.

**Result:**

| Request | Result |
|---|---|
| Download lecture.pdf | **Allowed** |
| Download student-records.csv | **Allowed** |
| Upload website.html | Implicit deny |
| Delete lecture.pdf | Implicit deny |
| List the bucket's files | Implicit deny |
| Stop the EC2 server | Implicit deny |

**Important baat:** Is policy ka maqsad tha **sirf upload** allow karna, lekin yahan `GetObject` (download) allow kar diya gaya — jo galat action hai. Isi wajah se **sab kuch download ho sakta hai** (lecture.pdf bhi, student-records.csv bhi) — jo **nahi hona chahiye tha** agar goal sirf upload tha.

**Example:** Ye aise hai jaise tumne kisi ko "andar aao" ka card diya, lekin galti se "**kisi bhi file ko padh sakte ho**" wala card de diya, jabke tumhara irada tha "**sirf naya kagaz jama karwa sakte ho**" wala card dena. Action galat choose hone se poora maqsad hi badal gaya.

---

## 4. ARN — Kisi Bhi Cheez Ka "Address"

**ARN (Amazon Resource Name)** = AWS mein **har resource ka unique address**. Policy likhte waqt tumhe batana padta hai "**kis cheez par**" ye rule lagu hoga — wahi ARN se hota hai.

ARN format kuch is tarah hota hai: `arn:aws:s3:::training-files/*`

ARN ke parts:

| Part | Matlab |
|---|---|
| `arn` | ye batata hai ye ek ARN hai |
| `aws` | AWS partition |
| `s3` | service ka naam (yahan S3) |
| *(khali)* | region/account — S3 ke liye ye **khali rehta hai** |
| `training-files` | bucket ka naam |
| `/*` | bucket ke **andar har cheez** |

**Bohot important baat:** `/*` ka matlab hai **"is bucket ke andar sab kuch"** — **na ke account ke har bucket mein sab kuch**. Ye sirf **ek** bucket tak limited hai.

**Example:** ARN aise hai jaise tumhara **poora postal address** — ghar number, gali, shehar sab milake ek unique location batata hai. `training-files/*` ka matlab hai "us ek gali ke har ghar tak" — poore shehar tak nahi.

---

## 5. ListBucket Trap — Download Karna aur List Karna Do Alag Cheezein Hain

Ye ek common galti hai jo **har koi karta hai**: log sochte hain ke agar koi file **download** kar sakta hai, to wo **bucket ke andar ki saari files dekh (list)** bhi sakta hoga. **Ye galat hai.**

| Action | Kis par kaam karta hai |
|---|---|
| `s3:GetObject` | **Objects** par (`bucket/*`) — ek specific file download karna |
| `s3:ListBucket` | **Khud bucket** par (bina `/*` ke) — bucket ke andar ki files ki list dekhna |

**Matlab:** Ek user jo **file ka naam jaan kar** download kar sakta hai, ho sakta hai wo **bucket ki poori list** na dekh sake — kyunki ye **do alag permissions** hain aur `s3:ListBucket` ka ARN mein `/*` **nahi lagta**, kyunki wo bucket ko khud target karta hai, uske andar ki files ko nahi.

**Example:** Ye aise hai jaise ek **library** mein tumhe exact kitab ka naam pata ho (jaise "Chemistry Book — Shelf 5, Row 2") to tum **wahi kitab** nikal sakti ho — lekin tumhe **poori library ka index/catalogue dekhne ki ijazat nahi** di gayi. Kitab ka naam jaanna aur poori library ki list dekhna — do alag permissions hain.

---

## 6. Do Rules Jo Sab Ko Confuse Karte Hain

**Rule 1 — Sab kuch by default deny hota hai.** Tumhe **kabhi bhi** "deny" likhne ki zaroorat nahi un cheezon ke liye jo tumne allow hi nahi ki thi. Wo **khamoshi se khud-ba-khud deny** ho jati hai — isko **implicit deny** kehte hain.

**Rule 2 — Explicit Deny hamesha jeetta hai.** Agar tum ne **saaf-saaf "Deny"** likh diya kisi cheez ke liye, to wo **har "Allow" rule ko overrule** kar degi — **chahe das aur rules usay allow kar rahi hon.**

**Example:** Implicit deny aise hai jaise tumne kisi ko kuch nahi bola — isliye wo khud-ba-khud "nahi" samajh lega. Explicit deny aise hai jaise tumne **saaf-saaf, zabaan se "nahi"** keh diya — chahe das log uske haq mein bol rahe hon, tumhara "nahi" sab par **bhari** padega.

---

## 7. IAM Roles — Ek Badge Jo Expire Ho Jata Hai

**Sawaal:** Agar tumhara EC2 server (ek application) ko S3 se data padhna ho, to wo **apni pehchaan kaise sabit kare**? Server ke andar password store karna **khatarnak** hoga.

**Jawab: IAM Role** — ye ek **temporary badge** hai jo koi bhi (server, application) "pehen" sakta hai, aur jise **wapas utarna bhi aasan hai** — kyunki iske andar **koi permanent password nahi** hota.

**Role ke do hisse hote hain:**

| Hissa | Sawaal jo ye jawab deta hai |
|---|---|
| **Trust Policy** | **Kaun** is role ko "pehen" (assume) sakta hai? |
| **Permissions Policy** | Role pehenne ke baad **kya kiya ja sakta hai**? |

**Poora flow (example — EC2 ka S3 padhna):** EC2 app, jiske andar koi password store nahi hota, ek Role (jaise "ReadTrainingFiles") assume karti hai. Us role ki Trust Policy kehti hai "sirf EC2 service ye role pehen sakti hai," aur uski Permissions Policy kehti hai "s3:GetObject allowed hai." In temporary permissions se EC2 app Private S3 bucket tak access pati hai.

**Step by step samajh:**
1. **EC2 app** ke andar **koi password nahi** hota
2. Wo **Role** ko "assume" karti hai (pehenti hai)
3. **Trust Policy** check karti hai: "kya EC2 service ko ye role pehenne ki ijazat hai?" — agar haan, to allow
4. Ek baar role pehenne ke baad, **Permissions Policy** decide karti hai ke role ke zariye **kya kaam** kiya ja sakta hai (jaise `s3:GetObject`)
5. In temporary permissions se EC2 app **S3 bucket** tak access pati hai

**Example:** Role aise hai jaise ek **visitor ka temporary badge** kisi office mein. **Trust Policy** = reception desk decide karti hai "kaun badge le sakta hai" (jaise sirf registered appointments wale). **Permissions Policy** = badge khud batata hai "ye badge pehen kar kaunse kamron mein jaa sakte ho." Badge **permanent nahi hai**, kaam khatam hote hi wapas kar diya jata hai — isliye koi password chori hone ka khatra hi nahi.

---

## 8. AWS Kaise Decide Karta Hai — Allow ya Deny

Jab bhi koi request aati hai, AWS ek **fixed flow** follow karta hai:

**Step 1:** Kya is request ke liye koi **Explicit Deny** hai? Agar haan → **turant DENIED**, baat khatam.

**Step 2:** Agar koi Explicit Deny nahi mila, to check hota hai: kya koi **Allow rule** hai jo is request ko allow karti hai? Agar haan → **ALLOWED**.

**Step 3:** Agar koi Allow bhi nahi mila → **implicit deny** (kyunki by default sab kuch band hai).

**Yaad rakhne wali baat:** AWS **pehle Deny dekhta hai, phir Allow dekhta hai.** Isi wajah se Explicit Deny hamesha **sabse zyada taaqatwar** hota hai — chahe kitni bhi Allow rules kyun na hon.

**Example:** Ye aise hai jaise ek security guard pehle apni **"banned list"** check karta hai (explicit deny) — agar tumhara naam us list mein hai, to tumhare paas chahe kitne bhi valid cards hon, tum andar nahi ja sakti. Agar naam banned list mein nahi hai, tabhi guard tumhare **access card (allow rules)** check karta hai ke tumhe andar jaane ki ijazat hai ya nahi.

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| Khaali Statement array | koi rule nahi, sab kuch implicit deny |
| Implicit deny | koi Allow na milne par khud-ba-khud deny ho jana |
| Explicit Deny | saaf-saaf likha hua "Deny" — hamesha jeetta hai |
| ARN | AWS resource ka unique address |
| `/*` in ARN | bucket ke andar sab kuch, na ke poore account mein |
| s3:GetObject | ek specific object/file ko download karne ki permission |
| s3:ListBucket | bucket ki poori list dekhne ki permission (ye alag hai GetObject se) |
| IAM Role | temporary badge, password-free, kisi service/app ke liye |
| Trust Policy | kaun role ko assume (pehen) kar sakta hai |
| Permissions Policy | role pehenne ke baad kya kiya ja sakta hai |
| AWS decision flow | pehle Explicit Deny check, phir Allow check, warna implicit deny |
