# Class 22 – DynamoDB Part 2 (Data Types, CRUD, Read, Indexes, Capacity, Security)

## Topics Covered
1. Pichli class ka quick recap
2. DynamoDB Data Types
3. SQL table vs DynamoDB item (whiteboard example)
4. CRUD Operations
5. CRUD ka flow: UI, API, Database
6. Data Read karna: GetItem, Query, Scan
7. SQL query vs DynamoDB ka sochne ka tareeqa
8. Secondary Index (GSI aur LSI)
9. On-demand vs Provisioned Capacity
10. RCU aur WCU (calculation ke saath)
11. Security (IAM, Encryption, Backups, Least Privilege)

---

## 1. Quick Recap

| Cheez | Matlab |
|---|---|
| DynamoDB | AWS ki fully managed NoSQL (key-value aur document) database |
| Table | Related records ka collection (jaise `Students`) |
| Item | Table ka ek record |
| Attribute | Item ke andar ki ek maloomat (Name, Age, City) |
| Primary key | Item ko unique pehchanti hai (Partition key, aur optional Sort key) |

---

## 2. DynamoDB Data Types

**Definition:** Attribute mein alag alag qisam ki values store ho sakti hain. Beginners ke liye common types ye hain:

| Type | Kya store karta hai | Example |
|---|---|---|
| **String (S)** | Text | `"Ayesha"` |
| **Number (N)** | Numbers | `21` |
| **Boolean (BOOL)** | True ya false | `true` |
| **List (L)** | Ordered collection | `["AWS", "Linux"]` |
| **Map (M)** | Named values ka group | `{"City": "Lahore"}` |
| **Null (NULL)** | Khaali (null) value | `null` |
| **Binary (B)** | Binary data | Bytes |
| **String / Number Set** | Ek hi type ki **unique** values | `{"AWS", "Linux"}` |

**Analogy:** Form ke alag alag khaane. Naam ka khaana text, umar ka khaana number, "active hai ya nahi" ka khaana haan ya na.

**Yaad rakhne wale farq:**
- **List** mein order hota hai aur duplicate ho sakte hain. **Set** mein sirf unique values hoti hain.
- **Map** ke andar nayi named values (nested data) ho sakti hain, jaise address ke andar city aur street.

**Alag data types wala record:**

    {
      "StudentID": "ST004",
      "Name": "Sara",
      "Age": 22,
      "Active": true,
      "Skills": ["AWS", "Linux"],
      "Address": { "City": "Lahore" },
      "Remarks": null
    }

Yahan `Name` String, `Age` Number, `Active` Boolean, `Skills` List, `Address` Map aur `Remarks` Null hai.

---

## 3. SQL Table vs DynamoDB Item (Whiteboard Example)

Sir ne ek `Student` table banayi:

| id | Name | Roll no | Course | Date |
|---|---|---|---|---|
| 1 | Ali | 1 | AWS | 1-1-25 |
| 2 | Umar | 2 | AWS | 7-1-25 |

DynamoDB mein wahi ek record **ek item (JSON jaisa document)** hota hai:

    {
      "id": 1,
      "Name": "Ali",
      "Roll_no": 2,
      "Course": "AWS"
    }

**Key point:** DynamoDB mein table ke liye sirf **key attribute** (jaise `Roll_no`) pehle se tay hota hai. Baqi attributes har item mein alag ho sakte hain, jaise kisi item mein `Date` ho aur kisi mein na ho.

**Primary key ka example (whiteboard):** Sir ne `Roll_no` ko key banaya (1, 2, ...). Is se `Roll_no` de kar item seedha mil jata hai.

---

## 4. CRUD Operations

**Definition:** CRUD data par hone wale **chaar bunyadi kaam** hain. Ye database ke records ke saath rozmarra ka cycle hai.

| Kaam | Matlab | DynamoDB API | Sir ka aasan matlab |
|---|---|---|---|
| **C**reate | Table mein naya item daalo | `PutItem` | Upload = create |
| **R**ead | Table se item nikalo | `GetItem` | Read = retrieve |
| **U**pdate | Ek ya zyada attributes badlo | `UpdateItem` | Update = fix the file |
| **D**elete | Item hata do | `DeleteItem` | Delete = kill the existence |

**Analogy (almari ki file):**
- Create = nayi file rakhna
- Read = file nikaal kar dekhna
- Update = file mein ghalti theek karna
- Delete = file phaar kar phenk dena

**Example:**
- `PutItem`: naya student `ST005` add karo.
- `GetItem`: `ST005` ka record nikalo.
- `UpdateItem`: `ST005` ki City badlo.
- `DeleteItem`: `ST005` ko hata do.

**Gotchas:**
- `PutItem` same primary key par item **overwrite** kar sakta hai.
- `UpdateItem` sirf kuch attributes badalta hai, poora item nahi.
- `DeleteItem` ke baad item wapas nahi aata (backup na ho to).

---

## 5. CRUD Ka Flow: UI, API, Database

Sir ne whiteboard par flow dikhaya:

**UI (user ka screen), phir API, phir Database.**

| Step | Kya hota hai |
|---|---|
| 1 | User **UI** par kuch karta hai (form bhara, button dabaya) |
| 2 | UI **API** ko request bhejti hai (`PutItem`, `GetItem`, `UpdateItem` ya `DeleteItem`) |
| 3 | **API** database se baat karti hai |
| 4 | **Database** kaam karta hai aur jawab API ke zariye UI tak wapas jata hai |

**Analogy:** Restaurant mein customer (UI) order deta hai, waiter (API) kitchen (database) tak pohanchata hai, aur khana (jawab) wapas laata hai. Customer kitchen mein nahi jata.

**Example (online student portal):**
- Student registration form bhara, API `PutItem` karti hai.
- Profile page khola, API `GetItem` karti hai.
- Phone number badla, API `UpdateItem` karti hai.
- Account band kiya, API `DeleteItem` karti hai.

**Security link:** UI seedha database se baat nahi karti. Beech mein API hoti hai jahan permission aur validation lagti hai.

---

## 6. Data Read Karna: GetItem, Query, Scan

Ye teeno operations information nikalne ke liye hain, lekin **alag tareeqe se kaam karte hain.**

| Operation | Kya karta hai | Kab use karein | Example |
|---|---|---|---|
| **GetItem** | **Poori primary key** de kar **ek item** nikalta hai | Ek item ki pooori key maloom ho | Student `ST001` ko nikalo |
| **Query** | **Partition key** (aur sort key par optional condition) se items dhoondta hai | Partition key maloom ho | Customer `C001` ke saare orders |
| **Scan** | **Poori table (ya index)** parhta hai | Sach mein poori table check karni ho | Poori table mein jahan Product = Laptop |

**Analogy:**
- **GetItem:** Kitaab ka exact number pata hai, seedha uthao.
- **Query:** Almari ka number pata hai, us almari ki saari files dekho.
- **Scan:** Poori library ki har kitaab ek ek karke dekhna.

**Beginner rule:**
- **GetItem** ek maloom item ke liye.
- **Query** jab partition key maloom ho.
- **Scan** sirf tab jab sach mein poori table ke items dekhne hon.

> **Zaroori:** Scan bohat zyada data examine kar sakta hai, isliye targeted lookups ke liye aksar **kam efficient** (sust aur mehnga) hota hai. Bari table par **targeted Query Scan se behtar** hoti hai.

---

## 7. SQL Query vs DynamoDB Ka Sochne Ka Tareeqa

Sir ne whiteboard par SQL query likhi:

    Select id, Name, Roll no, Course from Student table where date = "1-1-25";

**SQL mein:** Tum kisi bhi column (jaise `date`) par condition laga sakti ho aur database khud dhoond leta hai.

**DynamoDB mein sawal ye hota hai:** "Mere paas kaun si key hai?"

| Tumhare paas kya hai | Use karo |
|---|---|
| Poori primary key (jaise `Roll_no`) | `GetItem` |
| Sirf partition key | `Query` |
| Koi aur attribute (jaise `Date`) jo key nahi hai | Ya to `Scan`, ya us attribute par **index** banao |

**Example:** `Date = 1-1-25` wale students dhoondne hain, lekin table ki key `Roll_no` hai.
- Seedha raasta: `Scan` karke date filter karo (poori table parhi jayegi, sust).
- Behtar raasta: `Date` par **Global Secondary Index (GSI)** banao, phir us par Query karo.

**Isi liye** DynamoDB mein table design karne se **pehle** socha jata hai ke data kin tareeqon se dhoondna hai (access patterns).

---

## 8. Secondary Index

**Masla:** Primary key table ke items ko pehchanti hai. Lekin kabhi kabhi application ko **kisi aur attribute** se data dhoondna hota hai.

**Example:** Students table ki primary key `StudentID` hai, lekin application ko students **Email** se bhi dhoondne hain.

**Hal:** **Secondary index** is doosre access pattern ko support karta hai.

**Analogy:** Kitaab ke peeche ka **index page**. Naam ke bajaye topic se dhoondne ka doosra raasta.

| Index | Kaise kaam karta hai | Kab banta hai |
|---|---|---|
| **GSI** (Global Secondary Index) | **Alag partition key** aur optional sort key use kar sakta hai | **Table banne ke baad bhi add** ho sakta hai |
| **LSI** (Local Secondary Index) | **Wahi partition key**, lekin **alag sort key** | **Table banate waqt hi** banana padta hai |

**Beginners ke liye:** Ye samjho ke index kyun hote hain aur **GSI aur LSI ka farq yaad rakho.** Detailed index design baad mein aata hai.

**Yaad rakhne ki trick:**
- **G**lobal = **G**hair (bilkul alag) key, baad mein bhi lag sakta hai.
- **L**ocal = **L**ocked partition key, sort key alag, sirf table banate waqt.

**Gotcha:** Index ka apna storage aur cost hota hai, isliye sirf zaroori index banao.

---

## 9. On-demand vs Provisioned Capacity

DynamoDB ko read aur write requests handle karne ke liye **capacity** chahiye. AWS do main capacity modes deta hai.

| Mode | Kaise kaam karta hai |
|---|---|
| **On-demand** | Requests ke hisaab se pay karo. Pehle se read/write capacity set karne ki zaroorat nahi. **Unpredictable traffic aur beginner labs ke liye achha.** |
| **Provisioned** | Tum read aur write capacity khud set karti ho. **Auto Scaling** configure ho sakti hai. Tab useful jab traffic predictable ho aur capacity plan ki ja sake. |

**Analogy:**
- **On-demand** = taxi. Jitna chalo utna kiraya.
- **Provisioned** = monthly pass. Pehle se tay, sasta agar roz use ho.

**Kab kya chunein:**

| Situation | Mode |
|---|---|
| Naya app, load maloom nahi | On-demand |
| Practice lab | On-demand |
| Stable traffic jo pehle se pata ho | Provisioned |
| Cost ko control karna ho (predictable load) | Provisioned + Auto Scaling |

---

## 10. RCU aur WCU

**Definition:** Ye provisioned capacity mein read aur write ki ginti ki units hain.

| Unit | Matlab | Kitna kaam karti hai |
|---|---|---|
| **RCU** (Read Capacity Unit) | Read throughput | **4 KB** tak ke item ka **1 strongly consistent read per second**, ya **2 eventually consistent reads per second** |
| **WCU** (Write Capacity Unit) | Write throughput | **1 KB** tak ke item ka **1 write per second** |

**Do tarah ki reads:**

| Type | Matlab |
|---|---|
| **Strongly consistent** | Hamesha sabse taza data milta hai |
| **Eventually consistent** | Ho sakta hai chand lamhon baad ka data mile, lekin sasta hai (aadhi RCU) |

### Calculation ke examples

| Sawal | Hal |
|---|---|
| 4 KB item, 1 strongly consistent read per second | **1 RCU** |
| 4 KB item, 2 eventually consistent reads per second | **1 RCU** |
| 8 KB item, 1 strongly consistent read per second | 8 / 4 = **2 RCU** |
| 1 KB item, 1 write per second | **1 WCU** |
| 3 KB item, 10 writes per second | har write 3 WCU, 10 x 3 = **30 WCU** |

**Trick:** Reads ke liye item ka size **4 se divide** (upar ko round karo). Writes ke liye item ka size **KB mein** (upar ko round karo).

> **Cost reminder:** Cost **requests ya provisioned capacity, storage, backups, indexes, data transfer aur optional features** par depend karti hai. Hamesha **AWS pricing page aur billing dashboard** check karo.

---

## 11. Security

DynamoDB ki hifazat ke liye **kai layers** use karo: access control, encryption, secure connections aur recovery planning.

| Layer | Kya karti hai | Sawal jo hal karti hai |
|---|---|---|
| **IAM permissions** | Control karti hai kaun items parh, likh ya delete kar sakta hai | **Data kaun access kar sakta hai?** |
| **Encryption at rest (KMS)** | DynamoDB stored data ko encrypt karta hai. AWS KMS key-management options deta hai | **Stored data kaise mehfooz hai?** |
| **Encryption in transit (HTTPS/TLS)** | Application aur DynamoDB ke beech communication ko protect karta hai | **Safar mein data kaise mehfooz hai?** |
| **Backups / PITR** | Backups aur Point-in-Time Recovery se accidental changes ya deletion ke baad data wapas aa sakta hai | **Ghalti ho jaye to data kaise wapas aaye?** |

### Least Privilege

Har user ya application ko **sirf wahi permissions do jo use chahiye.**

**Example:** Jo application sirf student records **parhti** hai, usay table **delete** karne ki permission nahi milni chahiye.

**IAM policy ka example sochna:**
- Application ka role sirf `Students` table par `GetItem` aur `Query` allow kare.
- `DeleteItem`, `DeleteTable` ya doosri tables ki permission na ho.

**Pichli classes se link:**
- IAM least privilege wohi concept hai jo AWS IAM class mein sikha tha.
- CloudTrail DynamoDB ke API calls (jaise `DeleteTable`) record kar leta hai.
- Agar kisi hacker ne data delete kiya, to **backup aur PITR** se wapas laya ja sakta hai (jaise EC2 delete wale scenario mein snapshot/AMI kaam aate hain).

---

## Common Galtiyan aur Gotchas

1. Sochna ke DynamoDB mein SQL ki tarah kisi bhi column par condition laga kar tez search ho jayegi. Key ya index chahiye.
2. Har kaam ke liye `Scan` use karna. Bari table par ye sust aur mehnga hai.
3. `PutItem` se same key par purana item overwrite kar dena.
4. LSI ko baad mein banane ki koshish karna. LSI sirf table banate waqt banta hai, GSI baad mein bhi.
5. Provisioned mode mein capacity kam rakhna (requests reject hongi) ya zyada rakhna (bill barhega).
6. RCU ke liye strongly aur eventually consistent ka farq bhool jana.
7. Application ko DynamoDB par full access dena. Least privilege lagao.
8. Backups ya PITR ke bagair important data rakhna.
9. UI ko seedha database tak access dena. Beech mein API rakho.

---

## Quick Revision

| Topic | Yaad rakhne wali baat |
|---|---|
| Data types | String (S), Number (N), Boolean, List, Map, Null, Binary, Sets |
| List vs Set | List ordered (duplicate ho sakte), Set sirf unique values |
| Map | Named values ka group, nested data |
| Item vs SQL row | DynamoDB item flexible hai, har item mein alag attributes ho sakte hain |
| CRUD | Create, Read, Update, Delete |
| CRUD APIs | PutItem, GetItem, UpdateItem, DeleteItem |
| Flow | UI, phir API, phir Database |
| GetItem | Poori primary key, ek item |
| Query | Partition key (aur sort key condition), related items |
| Scan | Poori table, sust aur mehnga |
| Beginner rule | GetItem (ek item), Query (partition key maloom), Scan (sirf zaroorat par) |
| SQL vs DynamoDB | SQL mein kisi bhi column par where, DynamoDB mein key ya index chahiye |
| Secondary index | Doosre attribute se dhoondne ka raasta |
| GSI | Alag partition key, table banne ke baad bhi add ho sakta hai |
| LSI | Wahi partition key, alag sort key, sirf table banate waqt |
| On-demand | Requests ke hisaab se pay, unpredictable traffic aur labs ke liye |
| Provisioned | Capacity khud set, Auto Scaling, predictable traffic ke liye |
| RCU | 4 KB tak ka 1 strongly consistent read per second (ya 2 eventually consistent) |
| WCU | 1 KB tak ka 1 write per second |
| Cost | Requests/capacity, storage, backups, indexes, data transfer par depend, pricing page check karo |
| IAM | Kaun parh, likh ya delete kar sakta hai |
| Encryption at rest | Stored data encrypted, KMS se keys |
| Encryption in transit | HTTPS/TLS se safar mein protection |
| Backups / PITR | Accidental change ya deletion ke baad recovery |
| Least privilege | Sirf wahi permissions jo zaroori hon |
| Sabse zaroori baat | Pehle socho data kaise dhoondna hai, phir key aur index chuno, aur permissions kam se kam do |
