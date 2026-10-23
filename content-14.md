# Class 14 — AWS Lambda (Serverless Computing)

## 1. Lambda Kya Hai?

**AWS Lambda** = ek **serverless compute service** hai, jisme tum apna code **bina kisi server manage kiye** chala sakti ho. Tum bas apna code upload karti ho, aur Lambda use **jab zaroorat ho tabhi** run karta hai.

**Plain meaning:** EC2 par tumhe **hamesha ek server chalana** padta hai (chahe traffic ho ya na ho, server chalta rehta hai aur bill lagta hai). Lambda mein aisa nahi — code **sirf tab chalta hai jab koi isay trigger (shuru) kare**. Kaam khatam, code **khud-ba-khud ruk** jata hai.

**Example:** EC2 ko socho ek **dukan** jo 24/7 khuli rehti hai, chahe customer aaye ya na aaye — bijli, kiraya sab chalta rehta hai. Lambda ko socho ek **vending machine** ki tarah — jab koi button dabata hai (trigger), tabhi machine kaam karti hai; baaki waqt wo bilkul **off** rehti hai, koi cost nahi lagti.

---

## 2. Lambda "Serverless" Kyun Kehlata Hai?

**Serverless** ka matlab ye nahi ke server hota hi nahi — server to hota hai, lekin **tumhe uska koi fikr nahi karna padta**. AWS khud background mein server manage karta hai.

**Tum kya manage karti ho:** Sirf apna **code aur permissions**.

**AWS kya manage karta hai:** **OS, server, patching, scaling** — sab kuch.

**Example:** Ye wahi "Security OF the cloud vs Security IN the cloud" wali baat hai jo Shared Responsibility Model mein padhi thi — Lambda mein AWS **zyada se zyada** cheezein manage karta hai, tumhari zimmedari **sabse kam** ho jati hai (jaisa Class 4 mein EC2 vs RDS vs Lambda table mein dekha tha).

---

## 3. Lambda Kaise Kaam Karta Hai?

**Teen main cheezein samajhni zaroori hain:**

### a) Function
Tumhara **actual code** — jo ek specific kaam karta hai (jaise ek image resize karna, ek email bhejna, ek database update karna).

### b) Trigger (Event Source)
Wo cheez jo function ko **chalati (invoke karti) hai**. Lambda khud se kabhi nahi chalta — isay **hamesha koi trigger** karta hai.

**Common triggers:**

| Trigger | Kab chalta hai |
|---|---|
| **API Gateway** | Jab koi HTTP request aaye (jaisa Class 11 mein serverless route mein dekha) |
| **S3** | Jab kisi bucket mein naya file upload ho |
| **DynamoDB Streams** | Jab database mein koi change ho |
| **CloudWatch Events / EventBridge** | Scheduled time par (jaise har raat 12 baje) |
| **SNS/SQS** | Jab koi message queue mein aaye |

### c) Execution Role
Lambda function ki apni **IAM Role** (jaisa Class 10/11 mein Role padha tha) — ye decide karti hai Lambda **kaunsi AWS services tak access** kar sakta hai (jaise S3, DynamoDB).

**Example:** Function ek **chef** hai jo khana banata hai. Trigger wo **ghanti** hai jo chef ko batati hai "ab khana banao" (jaise koi order aaya). Execution Role chef ka **ID card** hai jo use batata hai "tum sirf kitchen ke fridge tak ja sakte ho, baaki kamron mein nahi."

---

## 4. Lambda Kyun Use Karte Hain? (Benefits)

**Koi server management nahi:** Patching, scaling, OS updates — kuch bhi nahi karna, AWS khud sambhalta hai.

**Automatic scaling:** Agar ek saath 1 request aaye ya 1000, Lambda **khud-ba-khud scale** ho jata hai — har request ke liye ek **naya function instance** chal sakta hai.

**Pay-per-use pricing:** Tum sirf **utna hi pay karti ho jitna code actually chala** (milliseconds ke hisaab se) — agar code nahi chal raha, **koi bill nahi**.

**Event-driven:** Lambda **kisi bhi event** par trigger ho sakta hai — bohot flexible hai, chhote-chhote automation tasks ke liye perfect.

**Example:** Socho tumhari website par **kabhi-kabhi** koi image upload hoti hai jise resize karna hai. EC2 pe ye kaam karne ke liye tumhe **hamesha ek server chalana** padega, chahe din mein sirf 2-3 baar image upload ho. Lambda se tum sirf **jab image upload ho tabhi** code chalati ho — baaki waqt **zero cost**.

---

## 5. Lambda Ki Limitations (Jo Yaad Rakhni Zaroori Hain)

**Maximum execution time:** Ek Lambda function **15 minute se zyada** nahi chal sakta — agar koi kaam isse zyada waqt leta hai, Lambda sahi tool nahi hai.

**Memory limit:** Lambda function ko **128 MB se 10 GB** tak memory di ja sakti hai.

**Cold start:** Agar Lambda function **lambe waqt se use nahi hua**, to pehli request thodi **slow** ho sakti hai (kyunki AWS ko naya environment taiyar karna padta hai) — isay **"cold start"** kehte hain. Agar function **regularly use** ho raha ho, to subsequent requests **fast** hoti hain (warm start).

**Statelessness:** Har Lambda invocation **independent** hoti hai — function **apna purana data yaad nahi rakhta** (jab tak tum khud kahin store na karo, jaise S3 ya DynamoDB mein).

**Example (Cold Start):** Ye aise hai jaise ek **dukaan** bohot der se band thi — pehla customer aate hi dukandar ko **shutter kholna, lights on karna** padega (thoda time lagega). Lekin agar dukaan **pehle se khuli** ho (recent use), to agla customer **turant serve** ho jayega.

---

## 6. Lambda Supported Languages

Lambda **multiple programming languages** support karta hai:
- Python
- Node.js (JavaScript)
- Java
- Go
- C# (.NET)
- Ruby
- Custom runtimes (koi aur language bhi use kar sakte ho container image ke zariye)

---

## 7. Lambda Ka Real-World Use Case (Class 11 Se Link)

Jaisa Class 11 mein **Route C (Serverless Route)** mein dekha tha:

Request flow: **API Gateway** request receive karta hai → **Lambda invoke** hota hai → Lambda apni **execution role** ke sath chalta hai → zaroorat padne par **DynamoDB** se data leta hai → response wapas bhejta hai.

**Ye poora flow isliye possible hai kyunki:**
- Koi EC2 instance **chalu rakhne ki zaroorat nahi**
- Sirf **jab request aaye**, Lambda **turant** chalta hai
- Response dene ke baad Lambda **khud ruk** jata hai

**Example:** Ye aise hai jaise ek **on-demand taxi service** — koi permanent driver 24/7 khada nahi rehta. Jab bhi koi ride book karta hai (trigger), ek driver (Lambda instance) **turant assign** hota hai, ride complete hoti hai, aur driver **free** ho jata hai agli booking ke liye.

---

## 8. Lambda vs EC2 — Quick Comparison

| Factor | EC2 | Lambda |
|---|---|---|
| Server management | Tum khud manage karti ho | AWS khud manage karta hai |
| Pricing | Jitni der instance chale, utna pay | Sirf code chalne ke time ka pay (milliseconds) |
| Scaling | Khud configure karna padta hai (Auto Scaling) | Automatic, built-in |
| Best for | Long-running applications, full control chahiye | Short tasks, event-driven automation |
| Max execution time | Koi limit nahi (jab tak chalta rakho) | 15 minute max |

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| Lambda | serverless compute — code bina server manage kiye chalana |
| Serverless | server hota hai, lekin AWS khud manage karta hai |
| Function | Lambda ke andar tumhara actual code |
| Trigger | wo event jo function ko invoke (chalu) karta hai |
| Execution Role | Lambda ki IAM Role — decide karti hai kis service tak access hai |
| Pay-per-use | sirf code chalne ke time ka pay, warna zero cost |
| Automatic scaling | Lambda khud-ba-khud zyada requests handle kar leta hai |
| Max execution time | 15 minutes |
| Memory range | 128 MB se 10 GB |
| Cold start | lambe waqt baad pehli request thodi slow hoti hai |
| Statelessness | har invocation independent hoti hai, purana data yaad nahi rehta |
| API Gateway + Lambda | common combo — HTTP request par Lambda trigger hota hai |
