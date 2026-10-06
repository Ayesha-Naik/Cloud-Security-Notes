# Class 8 — Amazon S3 (Simple Storage Service)

## 1. S3 kya hai, aur ye exist kyun karta hai?

**Amazon S3 (Simple Storage Service)** = AWS ki **object storage** service hai. Tum apni files (jinhe "**objects**" kehte hain) **naam (key) se store aur fetch** karti ho — HTTPS ya AWS API ke zariye. **Iske liye koi server tumhe khud nahi chalana padta.**

**Plain meaning:** EC2 par agar tum files store karna chahti ho, to tumhe pehle ek **poora server** chalana padta hai — uska OS, uski disk, uski maintenance sab tumhara kaam. S3 mein aisa kuch nahi — tum bas file bhejti ho, AWS use store kar leta hai. **Server ka koi concept hi nahi hai tumhare liye.**

**Compare karo — files EC2 par rakho vs S3 mein rakho:**

Agar files tum **EC2** par rakhti ho, to **tumhe khud handle karna padta hai:** OS, disk size, disk failure, patching, backups, scaling, availability — **sab kuch tumhara zimma.**

Agar files tum **S3** mein rakhti ho, to AWS khud disk failure, patching, scaling, availability sambhal leta hai — tum sirf apni file bhejti ho aur wapas mangti ho.

**S3 mein typically kaisi files rakhi jaati hain:** images, backups, logs, PDFs, software packages, static website files, data lakes.

**Example:** Socho tumhe apni family ki **photos** safe rakhni hain. **EC2 par rakhna** aise hai jaise tum khud ek almari khareedo, uska lock lagao, usko deemak se bachao, kabhi khanda ho jaye to repair karo — **har cheez tumhari zimmedari**. **S3 mein rakhna** aise hai jaise tum ek **bank locker** mein photos rakh do — bank khud locker room ki security, fire-safety, maintenance sab sambhalta hai, tum sirf photo le jao ya rakho.

---

## 2. Teen Kisam ki Storage (Object vs Block vs File)

AWS mein storage **teen tareeqon** se milti hai, har ek ka alag kaam hai:

| Storage Type | Service | Kya hai |
|---|---|---|
| **Object** | **S3** | Poori files, unke "**key**" (naam) se API/HTTP ke zariye fetch hoti hain. **Bohot bada scale** sambhal sakti hai. |
| **Block** | **EBS** | Ek **raw disk** jo ek EC2 instance ke sath attach hoti hai. Tum khud uspar ek filesystem banati ho. |
| **File** | **EFS** | Ek **shared filesystem** jisse **kai servers ek sath mount** kar sakte hain. |

**Kaunsa kab use hota hai:** Agar tumhe **ek EC2 instance ka boot disk aur uski files** rakhni hain, to wo **Block (EBS)** hota hai, kyunki ek instance ka boot disk ek **raw, dedicated disk** hota hai jo sirf usi instance ke sath juda rehta hai.

**Example:**
- **S3** aise hai jaise ek **post office** — tum ek parcel (object) ek address (key) likh kar bhej deti ho, wo kahin bhi se access ho sakta hai.
- **EBS** aise hai jaise tumhare **apne ghar ki almari** — sirf ek ghar (ek EC2 instance) ke sath judi hai.
- **EFS** aise hai jaise ek **shared library** — kai log (servers) ek sath usi jagah se kitabein (files) nikaal aur rakh sakte hain.

---

## 3. Bucket, Object, Key

S3 mein teen bunyadi cheezein hain:

| Term | Matlab |
|---|---|
| **Bucket** | **Container** — ye khud ek file nahi hai, balke ek "box" hai jisme files rakhi jaati hain |
| **Object** | **Stored data** — plus metadata, ek key, aur version info |
| **Key** | Object ka **unique naam** us bucket ke andar — isi se object ko pehchana jata hai |

**Bucket naming rules:**
- **3 se 63 characters** ke beech
- Sirf **lowercase letters, numbers, hyphens** (dots allowed hain lekin recommend nahi kiye jaate)
- **Letter ya number se start aur end** honi chahiye
- Bucket names **saari AWS accounts mein unique** honi chahiye (ek partition ke andar)
- **Buckets ke andar buckets nahi** ban sakte

Bucket aise hai jaise ek **building ka naam** (jaise "Green Towers") — khud koi flat nahi hai. Object ek **flat ke andar ka saman** hai, aur Key us flat ka **flat number** hai jisse tum usay dhoondh sakti ho (jaise "Flat 302"). Poora address milta hai: "Green Towers, Flat 302."

**Example (real life scenario):** Socho college mein ek **student portal** hai. Teacher us portal mein ek button par click karta hai "**Muzammil ka result dekho**" — ye button andar se ek S3 key ko fetch kar raha hota hai (bucket mein se exact file dhoondh kar lata hai). Teacher ko pata bhi nahi chalta ke S3 kaam kar raha hai — bas ek click se sahi file mil jaati hai, kyunki bucket aur key ka system organize tareeqe se bana hota hai.

**Important baat:** Sirf **link/address hona** iska matlab ye nahi ke koi bhi wo file khol sakta hai — ye depend karta hai **permissions** par. Jaise college portal mein bhi **sirf wahi teacher** us student ka result dekh sakta hai jise us class ki **permission** di gayi ho — baaki koi bhi teacher wahi link try kare, use **access denied** milega. Isko hum section 6 mein detail se dekhenge.

---

## 4. Regions — Data kahan rehta hai?

**Bucket ka naam global hai** (poori duniya mein unique). Lekin **bucket ka data sirf us ek Region mein rehta hai jo tumne choose kiya** — jab tak tum khud **replication** set na karo.

**Region choose karte waqt ye cheezein socho:**

| Factor | Kyun zaroori hai |
|---|---|
| **Latency** | Data ko un apps/users ke **paas** rakho jo use padhte hain, taake speed achhi rahe |
| **Compliance** | Kuch **qawaneen (laws)** batate hain ke data **kahan store** hona chahiye |
| **Price** | **Har Region ki rates alag** hoti hain |
| **Disaster recovery** | Agar **ek Region fail** ho jaye to kya hoga — ye ek design decision hai |

**Example:** Agar tumhare saare customers Pakistan mein hain, lekin tumne apna bucket **Australia** ke Region mein bana diya, to har request ko **lambi duri** tai karni padegi — website slow lagegi. Isliye data **usi area ke qareeb** rakhte hain jahan log use access kar rahe hon.

---

## 5. Durability vs Availability

Ye do words **bohot confuse** hote hain, lekin inka matlab bilkul alag hai:

**Durability ka sawal hai:** Kya mera data **safe/intact rahega**, kabhi kho to nahi jayega?
**S3 Standard** iske liye **99.999999999%** (**11 nines**) ke liye design kiya gaya hai.

**Iska matlab kya hai (real example):** Agar tumhare paas **10,000,000 (1 crore)** objects hain, to 11 nines ka matlab hai — tum average mein **har 10,000 saal mein sirf 1 object** kho sakti ho.

**Availability ka sawal hai:** Kya main data **abhi, is waqt padh sakti hoon**?
Ye **storage class ke hisaab se alag** hoti hai — S3 Standard ke liye ye **99.99%** design ki gayi hai.

**Bohot important point:** **Durability ek design target hai, koi guarantee nahi ke zero loss hoga.** Ye tumhe **khud tumhari apni galti** (accidentally delete ya overwrite karna) se **bilkul nahi bachati**. Uske liye tumhe **versioning aur backups** use karni padegi.

**Example:** Durability aise hai jaise ek **bank** ka vault — bank khud kabhi tumhara paisa nahi khoyega (bohot strong guarantee). Lekin agar **tum khud** apna paisa nikaal ke phaink do (delete kar do), to bank iske liye zimmedar nahi — isi liye **versioning** zaroori hai, jo tumhe apni hi galti se bachati hai.

---

## 6. Storage Classes

**Har file ko same treatment ki zaroorat nahi hoti.** Access pattern ke hisaab se alag "storage class" choose karte hain — jitni kam access hogi, utni sasti class milti hai.

**S3 Standard** sabse common class hai, jab file **roz access** honi ho:
- **Frequent access**, koi retrieval fee nahi
- Lekin ye **sabse mehngi** class hai (main classes mein se) storage ke liye

Access pattern ke hisaab se baaki classes:

| Situation | Class |
|---|---|
| Unknown ya changing access pattern | S3 Intelligent-Tiering |
| Monthly ya kam access, instant chahiye | S3 Standard-IA |
| Re-creatable data, lowest cost chahiye | S3 One Zone-IA |
| Archive, lekin instant access chahiye | S3 Glacier Instant Retrieval |
| Archive, waiting theek hai | S3 Glacier Flexible Retrieval |
| Years-long compliance archive | S3 Glacier Deep Archive |

*(Ye standard AWS classification hai, sir ke page se ek baar confirm kar lena.)*

**General rule:** Tum **storage, requests, aur data transfer out** ke liye pay karti ho. **Jitni "colder" class, utni zyada retrieval fee aur minimum storage duration** lagti hai.

**Example:** Ye bilkul aise hai jaise tumhari **almari** mein cheezein rakhna:
- Roz pehnay jaane wale kapde — **haath ki pahunch** mein (S3 Standard, mehnga rack space lekin fast)
- Sardiyon ke kapde jo saal mein ek baar nikalti ho — **upar wali shelf** (S3 Standard-IA, nikalna thoda mushkil lekin rakhna sasta)
- Purani files jo kabhi nahi dekhni, bas record ke liye rakhni hain — **store room/basement** (Glacier, nikalna waqt leta hai lekin bohot sasta)

---

## 7. Kaun Object ko Touch Kar Sakta Hai? (Permissions)

Har request ke liye do sawaal poochay jaate hain:

**Authentication ka sawal hai:** **Tum kaun ho?** — IAM user, role, ya anonymous (bina kisi identity ke)?

**Authorization ka sawal hai:** **Tumhe kya karne ki ijazat hai?** — Read, upload, delete, list?

**Rule:** **Default hamesha "deny" hota hai.** Aur agar kahin par **explicit Deny** likha ho, to wo **hamesha jeetega**, chahe kitni bhi "Allow" rules kyun na hon.

**Real example (ek anonymous request ka scenario):**
Agar koi **Anonymous (bina kisi credentials ke)** user kisi object ko access karne ki koshish kare, aur:
- Block Public Access **ON** hai
- Bucket policy public read allow **nahi** karti
- IAM policy bhi allow **nahi** karti

To result hoga **403 Access Denied** — kyunki koi bhi rule anonymous user ko allow nahi kar rahi, aur default khud hi deny hai.

**Example:** Ye aise hai jaise ek **office building** mein entry — default se **koi bhi andar nahi aa sakta** jab tak reception desk (bucket policy) ya tumhari ID card (IAM policy) tumhe specifically allow na kare. Aur agar security guard ne tumhara naam **"blacklist" (explicit deny)** kar diya ho, to chahe tumhare paas sab se valid ID card bhi ho, tum **phir bhi andar nahi ja sakti** — deny hamesha jeetega.

---

## 8. Important Facts (Yaad Rakhne Wali Baatein)

**Strong consistency:** Ek successful write ke **turant baad**, agli koi bhi read wahi updated data dikhayegi — koi delay/lag nahi.

**Object size:** Ek object **5 TB tak** ho sakta hai. Ek single PUT request sirf **5 GB tak** ka hoti hai — usse bada file upload karne ke liye **multipart upload** use karna padta hai.

**Secure defaults:** Naya bucket banate waqt: **Block Public Access ON** hota hai, **ACLs disabled** hoti hain, aur objects **encrypted at rest** (SSE-S3) hoti hain — matlab AWS **by default secure** rakhta hai.

**Versioning:** **Off by default.** Isko **ON karne se** tum accidental overwrites ya deletes se **recover** kar sakti ho.

**Static website hosting:** S3 **HTTP** par ek poori website serve kar sakta hai. **HTTPS** ke liye **CloudFront** add karna padta hai.

**S3 vs Nginx on EC2 compare:** **S3 website** mein koi server patch nahi karna. **EC2 + Nginx** mein poora control milta hai, lekin poori responsibility (patching, security, scaling) bhi tumhari.

**Example (Strong consistency ka):** Tumne ek file S3 mein upload ki — turant hi agar koi doosra insan wahi file padhne ki koshish kare, use **wahi latest version** milegi, purana data kabhi nahi dikhega. Ye badi baat hai kyunki kai cloud systems mein thoda "delay" hota hai naye data ko sab jagah dikhne mein, lekin S3 ye guarantee deta hai.

**Example (Secure defaults ka):** Jab tum naya bucket banati ho, AWS ka default rawaiya hai: "**jab tak tum khud na kaho, main kisi ko access nahi doonga**." Ye ek **aacha habit** hai AWS ka, kyunki real duniya mein bohot saare data breaches isi wajah se hue hain ke logon ne galti se "public" wala button ON kar diya tha.

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| S3 | object storage service — files ko key se store/fetch karna, koi server chalane ki zaroorat nahi |
| Object Storage (S3) | poori files, key se fetch, huge scale |
| Block Storage (EBS) | ek EC2 instance se attached raw disk |
| File Storage (EFS) | shared filesystem, kai servers mount kar sakte hain |
| Bucket | container, khud file nahi hai |
| Object | stored data + metadata + key + version |
| Key | object ka unique naam bucket ke andar |
| Region | wo jagah jahan bucket ka data actually store hota hai |
| Durability | data kabhi loss nahi hoga (S3 Standard = 11 nines) |
| Availability | data abhi padha ja sakta hai (S3 Standard = 99.99%) |
| Storage Classes | access pattern ke hisaab se cost/speed trade-off (Standard, IA, Glacier...) |
| Authentication | tum kaun ho (IAM user/role/anonymous) |
| Authorization | tumhe kya karne ki ijazat hai |
| Default deny | koi bhi explicit allow na ho to request reject hoti hai |
| Explicit Deny | hamesha sab Allow rules par jeetta hai |
| Strong consistency | write ke turant baad, agli read updated data dikhati hai |
| Object size limit | max 5 TB; single PUT max 5 GB, uske upar multipart upload |
| Secure defaults | naye bucket: Block Public Access ON, ACLs disabled, encryption ON |
| Versioning | off by default, overwrite/delete se recovery ke liye ON karo |
| Static website hosting | S3 HTTP serve kar sakta hai; HTTPS ke liye CloudFront chahiye |
