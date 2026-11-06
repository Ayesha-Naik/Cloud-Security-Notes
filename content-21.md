# Class 21 – Amazon DynamoDB (NoSQL Database)

## Topics Covered
1. Database kya hai
2. DynamoDB kya hai
3. DynamoDB ki khaas baatein (Managed, Fast, Flexible, Serverless)
4. SQL vs NoSQL
5. Data structure: Table, Item, Attribute
6. Primary Key: Partition Key aur Sort Key
7. Data Types
8. CRUD Operations
9. Data Read karna: GetItem, Query, Scan
10. Indexes
11. Capacity aur Cost
12. Security
13. Console Practical ka flow

---

## 1. Database Kya Hai?

**Definition:** Database ek jagah hai jahan data **organized tareeqe se store** hota hai, aur application usay **dhoond sakti ya badal sakti** hai.

**Analogy:** Ek bari **almari ki files**. Har file mein ek record hai, aur ek clerk jaldi se sahi file nikaal ke de deta hai.

**Example:** Online shopping website ko customers, products, orders aur delivery details yaad rakhni hoti hain. Ye sab database mein jama hota hai. Student management app mein har student ki ID, name, age aur course database mein hota hai.

**Flow:** Application request bhejti hai, database data par kaam karta hai, aur application ko response milta hai.

---

## 2. Amazon DynamoDB Kya Hai?

**Definition:** DynamoDB AWS ki ek **fully managed NoSQL database service** hai (key-value aur document database). Ye **kisi bhi scale par single-digit millisecond performance** deti hai.

**Latency kya hai?** Latency matlab **request bhejne se jawab milne tak ka waqt**. DynamoDB ki latency bohat kam hoti hai (chand milliseconds), chahe data bohat zyada ho ya requests bohat zyada hon.

**Analogy:** Ek aisa **super-fast clerk** jo chahe 10 files ho ya 10 crore, har baar chand milliseconds mein sahi file nikaal ke deta hai.

> **Yaad rakho:** DynamoDB ek **database service** hai. Ye virtual machine, file storage ya networking service nahi hai.

---

## 3. DynamoDB Ki Khaas Baatein

| Feature | Matlab |
|---|---|
| **Managed by AWS** | Infrastructure maintenance, software patching aur service operations AWS karta hai. Tumhe database server install ya maintain nahi karna padta |
| **Fast at scale** | Aisi applications ke liye jinhein high request volumes par consistent, low-latency data access chahiye |
| **Flexible records** | Ek hi table ke items mein **alag alag attributes** ho sakte hain (key design follow karte hue) |
| **Serverless database** | Tum database use karte ho bina database servers ko seedha manage kiye |

### DynamoDB kahan use hota hai?
- Shopping carts aur product information
- User profiles aur application sessions
- Online games aur player scores
- IoT device readings aur application events

**Example:** Online game mein lakhon players ke scores har second update hote hain. DynamoDB itne load par bhi tez rehta hai.

---

## 4. SQL vs NoSQL

Databases data ko alag tareeqon se organize karte hain. Do common tareeqe: **SQL (relational)** aur **NoSQL**.

| Type | Kaise store karta hai | Examples |
|---|---|---|
| **SQL database** | Related **tables** mein, **rows aur columns** ke saath. Structured data aur relationships ke liye | MySQL, PostgreSQL |
| **NoSQL database** | **Non-relational** data models, jaise **key-value** aur **document**. DynamoDB key-value aur document database hai | Amazon DynamoDB |

### Comparison

| Feature | SQL database | DynamoDB |
|---|---|---|
| Data organization | Tables, **rows** aur **columns** | Tables, **items** aur **attributes** |
| Relationships | Joins aur foreign keys use ho sakte hain | Relationships aksar **keys aur application logic** mein design hote hain |
| Schema | Records add karne se pehle define hota hai | Flexible attributes, sirf **key attributes** table ke liye define hote hain |
| Best suited to | Complex relational queries | Known access patterns aur high-scale **key-based access** |

> **Important:** NoSQL ka matlab **"no structure" nahi hai.** DynamoDB mein bhi rules, data types aur primary keys hote hain. Bas ye traditional relational model use nahi karta.

**Naming ka farq (yaad rakhne ke liye):**

| SQL | DynamoDB |
|---|---|
| Table | Table |
| Row | **Item** |
| Column | **Attribute** |

---

## 5. Data Structure: Table, Item, Attribute

DynamoDB data ko **tables** mein organize karta hai. **Table mein items** hote hain, aur **har item mein attributes** hote hain.

| Cheez | Matlab | Example |
|---|---|---|
| **Table** | Related records ka collection | `Students` |
| **Item** | Table ka ek individual record | Student `ST001` ka record |
| **Attribute** | Item ke andar maloomat ka ek tukra | `Name`, `Age`, `City` |
| **Primary key** | Wo key jo table mein item ko **unique** pehchanti hai | `StudentID` |

**Safar:** Table (`Students`), phir Item (ek student ka record), phir Attributes (ID, Name, Age).

**Ek table mein bohat se items hote hain, aur har item ke apne attributes hote hain.**

### SQL table aur DynamoDB item ka farq (class ka example)

SQL table (rows aur columns):

| id | Name | Roll no | Course |
|---|---|---|---|
| 1 | Ali | 1 | AWS |
| 2 | Umar | 2 | AWS |

DynamoDB mein wahi record ek **item (JSON document jaisa)** hota hai:

    {
      "id": 1,
      "Name": "Ali",
      "Roll_no": 2,
      "Course": "AWS"
    }

DynamoDB table mein sirf **key attribute** (jaise `Roll_no`) pehle se define karna zaroori hai. Baqi attributes har item mein alag ho sakte hain.

### Example student item

    {
      "StudentID": "ST001",
      "Name": "Ayesha",
      "Age": 21,
      "City": "Islamabad",
      "Course": "AWS"
    }

**Flexible records ka example:** Ek item mein `Phone` attribute ho sakta hai aur doosre mein nahi. Dono ek hi table mein rah sakte hain. SQL mein har row ke saare columns hote hain.

---

## 6. Primary Keys: Partition Key aur Sort Key

> **Ye sabse important concept hai.**

**Definition:** Primary key table mein **har item ko pehchanti hai.** DynamoDB do tarah ke primary key designs support karta hai.

**Analogy:** Library mein har kitaab ka **unique number**. Number se kitaab seedha mil jati hai.

### Type 1: Partition Key Only (Simple Primary Key)

Har item ki **partition key ki value unique** hoti hai. Students table mein `StudentID` har student ko pehchan sakta hai.

| StudentID (Partition key) | Name | City |
|---|---|---|
| ST001 | Ayesha | Islamabad |
| ST002 | Hamza | Lahore |
| ST003 | Bilal | Karachi |

### Type 2: Partition Key + Sort Key (Composite Primary Key)

Composite primary key mein **dono** hote hain, partition key aur sort key. **Dono ka combination unique hona chahiye.** Is se **ek partition key par kai related items** ho sakte hain.

| CustomerID (Partition key) | OrderDate (Sort key) | Product |
|---|---|---|
| C001 | 2026-01-01 | Laptop |
| C001 | 2026-01-05 | Mouse |
| C002 | 2026-01-02 | Keyboard |

**Partition key customer ke records ko group karti hai. Sort key us group ke andar individual records ko alag karti hai** (aur unhein order mein rakhti hai).

**Analogy:** Partition key = **almari ka number** (C001 ki almari). Sort key = **almari ke andar files ki tarteeb** (date ke hisaab se).

### Farq ek nazar mein

| Point | Partition key only | Partition key + Sort key |
|---|---|---|
| Unique kya hona chahiye | Sirf partition key | **Dono ka combination** |
| Kab use karein | Har item alag ho (student, user) | Ek entity ke kai related records (customer ke orders) |
| Fayda | Simple | Ek group ke records ko order mein aur range mein dhoond sakte hain |

**Gotchas:**
- Primary key **table banate waqt** chunni padti hai, baad mein badal nahi sakti.
- Aisi partition key chuno jis ki values **bohat zyada aur barabar** hon, warna ek partition par load aa jata hai (hot partition).
- Partition key akeli unique na ho to sort key lagao.

---

## 7. DynamoDB Data Types

Attributes alag alag qisam ki values store kar sakte hain. Beginners ke liye common types:

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

**Ghalat fehmi se bacho:**
- **List** mein order hota hai aur duplicate ho sakte hain. **Set** mein sirf unique values hoti hain.
- **Map** ke andar dobara values (nested data) ho sakti hain.

### Alag data types wala record

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

## 8. CRUD Operations

CRUD = **C**reate, **R**ead, **U**pdate, **D**elete. Data par chaar bunyadi kaam.

| Kaam | DynamoDB operation | Matlab |
|---|---|---|
| **Create** | `PutItem` | Naya item add karo (primary key wala item pehle se ho to replace ho jata hai) |
| **Read** | `GetItem`, `Query`, `Scan` | Data parho |
| **Update** | `UpdateItem` | Item ke kuch attributes badlo |
| **Delete** | `DeleteItem` | Item hata do |

**Example:** Naye student `ST005` ko `PutItem` se add karo, `UpdateItem` se uski City badlo, aur `DeleteItem` se hata do.

**Gotcha:** `PutItem` same primary key par **purana item overwrite** kar deta hai. Naya sa lagne wala kaam purana data kho sakta hai.

---

## 9. Data Read Karna

| Operation | Kya karta hai | Speed |
|---|---|---|
| **GetItem** | **Poori primary key** de kar **ek item** nikalo | Sabse tez |
| **Query** | **Partition key** (aur zarurat par sort key ki condition) de kar **related items** nikalo | Tez |
| **Scan** | **Poori table** parh kar filter lagana | Sabse sust aur mehnga |

**Example (CustomerID C001):**
- `GetItem`: C001 aur 2026-01-01 de kar ek specific order.
- `Query`: C001 ke saare orders ya January ke orders.
- `Scan`: Poori table dekh kar jahan Product = Laptop.

> **Best practice:** Jahan tak ho `Scan` se bacho, `Query` ya `GetItem` use karo. Isi liye primary key **access pattern** (tum data kaise dhoondogi) ke hisaab se design hoti hai.

---

## 10. Indexes

**Masla:** Primary key ke bagair kisi doosre attribute (jaise `City`) se dhoondna ho to sirf `Scan` bachta hai, jo sust hai.

**Hal:** **Secondary Index** banao. Ye same data par ek **doosri key** deta hai taake us se bhi tez `Query` ho sake.

| Index | Matlab |
|---|---|
| **GSI** (Global Secondary Index) | Bilkul **alag partition key (aur sort key)** ke saath nayi view |
| **LSI** (Local Secondary Index) | **Wahi partition key**, lekin **alag sort key**. Table banate waqt hi banta hai |

**Analogy:** Kitaab ke peeche ka **index page**. Naam se nahi, topic se dhoondne ka doosra raasta.

**Example:** Students table `StudentID` se hai. `City` ka GSI bana do to "Lahore ke saare students" tez mil jayenge.

**Gotcha:** Index ka apna storage aur write cost hota hai, isliye sirf zaroorat ke index banao.

---

## 11. Capacity aur Cost

DynamoDB ki cost **tumhare data store karne aur reads/writes** par hoti hai. Do capacity modes:

| Mode | Kaise kaam karta hai | Kab use karein |
|---|---|---|
| **On-demand** | Jitni requests karo utna hi pay karo, capacity pehle batani nahi padti | Load pehle se maloom na ho, ya bohat badalta ho |
| **Provisioned** | Tum pehle se **read aur write capacity** batati ho | Load predictable ho, cost control chahiye |

**Analogy:** On-demand = **taxi** (jitna chalo utna kiraya). Provisioned = **monthly pass** (pehle se tay).

**Zaroori:** Naye cheez on karne se pehle AWS ka pricing page check karo, kyunke pricing waqt ke saath badalti hai.

---

## 12. Security

| Cheez | Kya karta hai |
|---|---|
| **IAM** | Kaun table ko parh, likh ya delete kar sakta hai (least privilege) |
| **Encryption at rest** | Store hua data encrypted hota hai (AWS KMS se) |
| **Encryption in transit** | Data HTTPS ke zariye jata hai |
| **CloudTrail** | DynamoDB ke API calls ka record (kisne table delete ki) |
| **Backups** | On-demand backup aur Point-in-time recovery (PITR) se data wapas laya ja sakta hai |
| **VPC endpoint** | Private network se, internet ke bagair DynamoDB tak pohanchna |

**Security tip:** Application ko sirf zaroori table aur zaroori actions ki permission do (jaise sirf `GetItem` aur `PutItem`), poori DynamoDB ki nahi. Is ki wajah wohi hai jo IAM least privilege class mein sikhi thi.

**Example IAM policy ka matlab:** Lambda function ke role ko sirf `Students` table par `GetItem` allow ho, to wo koi aur table nahi parh sakta aur kuch delete nahi kar sakta.

---

## 13. Console Practical Ka Flow

AWS Console mein:

| Step | Kya karna hai |
|---|---|
| 1 | DynamoDB service kholo (Search mein DynamoDB) |
| 2 | **Create table** dabao |
| 3 | Table ka naam do (jaise `Students`) |
| 4 | **Partition key** do (jaise `StudentID`, type String) |
| 5 | Zarurat ho to **Sort key** bhi do |
| 6 | Settings (capacity mode) rehne do ya chuno, phir **Create table** |
| 7 | **Explore items** mein jao aur **Create item** se data add karo |
| 8 | Attributes add karo aur alag data types try karo |
| 9 | Items ko **Query** ya **Scan** se dekho |

**Cleanup:** Practical ke baad banai hui table delete kar do taake cost na lage.

---

## Common Galtiyan aur Gotchas

1. Sochna ke NoSQL ka matlab koi structure nahi. Primary key aur data types phir bhi hote hain.
2. Primary key baad mein badalna. Ye table banate waqt hi tay hoti hai.
3. Aisi partition key chunna jis ki values kam hon, to ek partition par load aa jata hai.
4. Har baar `Scan` use karna. Ye poori table parhta hai aur mehnga hai.
5. `PutItem` se same key par purana item overwrite kar dena.
6. SQL jaisi complex joins ki ummeed karna. DynamoDB ko known access patterns ke liye design karte hain.
7. Table ko IAM permissions ke bagair ya bohat zyada permissions ke saath chhor dena.
8. Practical ke baad table ya extra resources delete na karna.
9. List aur Set ko ek hi samajhna. Set mein sirf unique values hoti hain.

---

## Quick Revision

| Topic | Yaad rakhne wali baat |
|---|---|
| Database | Organized data store jahan se app data dhoond ya badal sakti hai |
| DynamoDB | AWS ki fully managed NoSQL (key-value aur document) database service |
| Latency | Request se jawab tak ka waqt, DynamoDB mein single-digit millisecond |
| Managed / Serverless | AWS infrastructure sambhalta hai, tum server manage nahi karte |
| Use cases | Shopping cart, user profiles aur sessions, game scores, IoT data |
| SQL vs NoSQL | Tables, rows, columns, joins vs tables, items, attributes, key-based access |
| NoSQL ka matlab | "No structure" nahi, bas relational model nahi |
| Table, Item, Attribute | Collection, ek record, record ka ek tukra |
| Primary key | Item ko table mein unique pehchanti hai |
| Partition key only | Har item ki partition key unique (StudentID) |
| Partition + Sort key | Dono ka combination unique, ek group ke kai items (CustomerID + OrderDate) |
| Partition key kya karti hai | Related records ko group karti hai |
| Sort key kya karti hai | Group ke andar records ko alag aur order mein rakhti hai |
| Data types | String (S), Number (N), Boolean, List, Map, Null, Binary, Sets |
| List vs Set | List ordered (duplicate ho sakte), Set sirf unique values |
| CRUD | PutItem, GetItem/Query/Scan, UpdateItem, DeleteItem |
| GetItem / Query / Scan | Ek item / related items / poori table (sabse sust) |
| Index | Doosri key se tez dhoondna (GSI aur LSI) |
| Capacity modes | On-demand (jitna use utna pay) vs Provisioned (pehle se tay) |
| Security | IAM, encryption, CloudTrail, backups, VPC endpoint |
| Sabse zaroori baat | DynamoDB mein pehle ye socho ke data kaise dhoondna hai, phir uske hisaab se primary key chuno |
