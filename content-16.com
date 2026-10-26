# Class 16 – Amazon CloudWatch (Monitoring aur Logging)

## Topics Covered
1. CloudWatch kya hai
2. Six Concepts ka overview
3. Metrics (numbers)
4. Logs (records)
5. Alarms (warnings)
6. Dashboards (ek screen)
7. Logs Insights (logs mein search)
8. CloudWatch Agent (extra server data)
9. Sab kuch ek saath kaise kaam karta hai
10. CloudWatch vs CloudTrail
11. Security ke nazariye se CloudWatch

---

## 1. CloudWatch Kya Hai?

**Definition:** CloudWatch AWS resources ka **security camera aur health monitor** hai. EC2, Lambda aur ECS kaam karte hain, aur CloudWatch unhe **dekhta rehta hai aur kuch ghalat ho to batata hai**.

**Analogy:** Hospital mein patient ke bed ke saath monitor laga hota hai. Wo dil ki dhadkan, temperature aur oxygen dikhata hai, aur kuch bigre to alarm bajata hai. Doctor har waqt patient ke paas nahi baitha hota.

**CloudWatch se tum kya kar sakti ho:**

| Kaam | Matlab |
|---|---|
| See what is happening | Abhi kya ho raha hai dekho |
| Find problems | Masla pakdo |
| Investigate why | Wajah dhoondo |
| Get alerts | Khud notification pao |
| View on one screen | Sab kuch ek jagah dekho |

**Kaun kaun data bhejta hai:** EC2 server, Lambda function, ECS container (aur bhi bohat si AWS services). Sab ka data CloudWatch ke paas jama hota hai.

**Example:** Tumhari website EC2 par chal rahi hai. Raat ko 3 baje CPU 95% par chala jaye. CloudWatch ke bina tumhe subah customers ki shikayat se pata chalega. CloudWatch ke saath tumhe usi waqt email aa jayegi.

---

## 2. The Six Concepts

| # | Concept | Ek line mein | Analogy |
|---|---|---|---|
| 1 | Metrics | Numbers | Body temperature |
| 2 | Logs | Events ka record | Diary |
| 3 | Alarms | Warnings | Smoke detector |
| 4 | Dashboards | Sab ek screen par | Car dashboard |
| 5 | Logs Insights | Logs mein search | Diary mein search |
| 6 | CloudWatch Agent | Server ka extra data | Extra sensors |

---

## 3. Metrics (Numbers)

**Definition:** Metric **waqt ke saath ek measurement** hai. Example: EC2 server ka CPU usage.

**Analogy:** Thermometer sirf ek number batata hai. Akela number nahi batata ke tum kitni sehatmand ho, usay samajhna padta hai.

**Example:** CPU usage ka graph waqt ke saath upar jata hai aur aaj 85% par pohanch gaya. Graph se pata chalta hai ke server par load barh raha hai.

**Kuch common metrics:**

| Service | Metric examples |
|---|---|
| EC2 | CPUUtilization, NetworkIn, NetworkOut, DiskReadOps |
| Lambda | Invocations, Errors, Duration, Throttles |
| ECS | CPU aur memory utilization |
| S3 | Bucket size, number of objects |

**Zaroori terms:**

| Term | Matlab |
|---|---|
| Namespace | Metrics ka folder, jaise `AWS/EC2`, `AWS/Lambda` |
| Dimension | Metric ko specific cheez se jodta hai, jaise kaun si instance ID |
| Period | Data kitne seconds ke gap par jama hota hai |
| Statistic | Average, Sum, Maximum, Minimum |

**Monitoring ke do levels (EC2):**
- **Basic monitoring:** har 5 minute baad data, free
- **Detailed monitoring:** har 1 minute baad data, paid

---

## 4. Logs (Records)

**Definition:** Log ek **likhi hui line** hai jo batati hai ke tumhari app ke andar kya hua.

**Analogy:** Diary. Jab kuch toot jaye to diary parh kar pata chalta hai ke kyun.

**Example log:**

- `10:01:02 File uploaded successfully`
- `10:01:05 Processing started`
- `10:01:09 ERROR Access denied`
- `10:02:00 Function finished`

Yahan ERROR wali line batati hai ke 10:01:09 par **Access denied** aaya. Ye aksar IAM permission ka masla hota hai, jaise Lambda ke role ko S3 ki permission na ho.

**Metrics aur Logs ka farq:** Metric batata hai **kitna** (CPU 85%), log batata hai **kya hua aur kyun** (Access denied).

**Logs ki organization:**

| Term | Matlab |
|---|---|
| Log group | Ek application ya service ke logs ka collection, jaise ek Lambda function ka |
| Log stream | Group ke andar ek source ka sequence, jaise ek instance ya ek run |
| Retention | Logs kitne din rakhne hain (never expire ya 1 din se lekar saalon tak) |

**Gotcha:** Retention set na karo to logs hamesha jama hote rehte hain aur bill barhta hai.

**Lambda aur logs:** Lambda function apne logs khud CloudWatch Logs mein bhejta hai, lekin uske **execution role** ko log likhne ki permission honi chahiye.

---

## 5. Alarms (Warnings)

**Definition:** Alarm ek **metric par nazar rakhta hai**, aur agar rule toot jaye to warning uthata hai.

**Analogy:** Smoke detector aag nahi bujhata, wo sirf tumhe jaga deta hai.

**Example rule:** "CPU 5 minute tak 80% se upar rahe" to alarm bajao.

**Alarm ki teen states:**

| State | Matlab |
|---|---|
| OK | Sab theek, metric limit ke andar |
| ALARM | Rule toot gaya, metric limit se bahar |
| INSUFFICIENT DATA | Abhi itna data nahi ke faisla ho sake (naya alarm ya data aana band) |

**Alarm ke baad kya hota hai:**
- **SNS** (Simple Notification Service) ke zariye **email ya SMS** bhej sakta hai
- Auto Scaling chala sakta hai (server barha do)
- EC2 par action le sakta hai (stop, reboot, recover)

**Yaad rakho:** CloudWatch khud masla theek nahi karta. Wo tumhe noticed karne aur investigate karne mein madad deta hai, aur alarm notification bhej sakta hai.

---

## 6. Dashboards (Ek Screen)

**Definition:** Dashboard zaroori graphs ko **ek hi screen par side by side** dikhata hai.

**Analogy:** Gaari ka dashboard speed, fuel aur engine light ek saath dikhata hai. Har cheez ke liye alag screen nahi kholni parti.

**Example dashboard:**

| Panel | Dikhata hai |
|---|---|
| EC2 CPU | CPU ka graph |
| Lambda errors | Errors ki ginti (jaise 2) |
| ECS performance | Containers ka graph |
| Alarm status | Kitne alarms ALARM state mein hain (jaise 1) |

**Faida:** EC2, Lambda, ECS sab ki sehat ek nazar mein, ek jagah dikhti hai. Team meeting ya incident ke waqt bohat kaam aata hai.

---

## 7. Logs Insights (Logs Mein Search)

**Definition:** Logs Insights **sirf ek search tool** hai jo CloudWatch Logs mein query chala kar jawab nikalta hai.

**Analogy:** Diary mein har wo din dhoondna jab kuch ghalat hua tha.

**Example:** Hazaron log lines mein se sirf wo lines nikalni jinme `ERROR` likha ho, aur dekhna ke kis waqt sabse zyada errors aaye.

**Yaad rakho:** Logs Insights data **jama nahi karta**. Wo sirf jama shuda logs mein dhoondta hai.

---

## 8. CloudWatch Agent (Extra Server Data)

**Masla:** EC2 default mein sirf basic numbers bhejta hai, jaise CPU, network. **Memory aur disk usage default mein CloudWatch ko nahi milte.**

**Hal:** **CloudWatch Agent** install karo.

**Definition:** Agent ek **software hai jo tum khud server par set up karti ho**. Wo extra data CloudWatch ko bhejta hai:

| Agent kya bhejta hai |
|---|
| Memory used |
| Disk used |
| Chune hue log files (jaise Apache ya Nginx ke logs) |

**Analogy:** Mareez ke saath extra sensors laga dena jo wo cheezein napte hain jo basic monitor nahi napta.

**Important farq:** Agent ek **software** hai jo server par chalta hai. Logs Insights sirf **search tool** hai. Dono ke kaam alag hain.

**Gotcha:** Agent chalane ke liye EC2 ke IAM role ko CloudWatch mein likhne ki permission chahiye (jaise `CloudWatchAgentServerPolicy`).

---

## 9. Sab Kuch Ek Saath Kaise Kaam Karta Hai

**Example:** S3 mein ek file upload hoti hai aur ek Lambda function usay process karta hai.

| Step | Kya hota hai |
|---|---|
| 1 | File S3 mein upload hoti hai |
| 2 | Lambda function chalta hai aur code run karta hai |
| 3 | Lambda **metrics** bhejta hai: kitni baar chala, kitne errors |
| 4 | Lambda **logs** bhejta hai: kya ghalat hua |
| 5 | Errors barh jayen to **Alarm** bajta hai |
| 6 | Alarm **SNS email** bhej deta hai |
| 7 | **Dashboard** metrics aur alarms ek screen par dikhata hai |

**Poori kahani:** Metrics batate hain *kuch ghalat hai*, Alarm *tumhe jagata hai*, Logs batate hain *kya aur kyun ghalat hua*, Dashboard *sab ek jagah dikhata hai*.

---

## 10. CloudWatch vs CloudTrail

Dono ke naam milte julte hain, lekin kaam alag hain.

| Point | CloudWatch | CloudTrail |
|---|---|---|
| Sawal | Resources **kaisi perform** kar rahi hain? | **Kisne kya kiya** AWS account mein? |
| Data | Metrics, logs, alarms | API calls ka record (kaun, kab, kahan se) |
| Analogy | Hospital ka health monitor | Building ka visitor register |
| Example | CPU 95% hai | Kisi ne S3 bucket delete kiya |

**Security mein dono saath use hote hain.** Pehle wale class mein credential theft ke baad CloudTrail dekhna sikha tha. CloudWatch us CloudTrail ke events par alarm laga sakta hai.

---

## 11. Security Ke Nazariye Se CloudWatch

Cloud security engineer ke liye CloudWatch sirf performance ka tool nahi hai:

| Use case | Example |
|---|---|
| Suspicious activity ka alarm | Root user login hone par alert |
| Failed login ka alarm | Bohat saari failed console logins |
| Unexpected CPU spike | Server par crypto-mining ho sakti hai |
| Application logs | `Access denied` errors se permission ke masle ya attack ke attempts pakre jate hain |
| Central logging | Sab servers ke logs ek jagah, taake attacker apne server ke logs na mita sake |
| Dashboards | SOC team ke liye ek screen par security overview |

**Example:** Raat ko achanak EC2 ka CPU 100% par chala jata hai aur network out bohat barh jata hai. CloudWatch alarm email bhejta hai. Tum check karti ho to pata chalta hai ke kisi ne server par miner chala diya tha.

---

## Common Galtiyan aur Gotchas

1. Sochna ke memory aur disk usage default mein dikhega. Iske liye **CloudWatch Agent** chahiye.
2. Maan lena ke alarm masla theek kar dega. Alarm sirf batata hai, action tum set karti ho.
3. Log retention set na karna. Logs hamesha jama hote hain aur cost barhti hai.
4. Alarm banana lekin SNS topic subscribe na karna. Alarm bajega magar email nahi aayegi.
5. CloudWatch aur CloudTrail ko ek hi cheez samajhna.
6. Lambda ya EC2 ke role mein logs likhne ki permission na dena, to logs aayenge hi nahi.

---

## Quick Revision

| Topic | Yaad rakhne wali baat |
|---|---|
| CloudWatch | AWS resources ka security camera aur health monitor |
| Metrics | Waqt ke saath numbers (CPU 85%), thermometer jaisa |
| Logs | Likhe hue events ka record, diary jaisa |
| Log group / stream | Group = service ke logs, stream = ek source ka sequence |
| Retention | Logs kitne din rakhne hain, set karna zaroori hai |
| Alarms | Metric par rule, toot jaye to warning (smoke detector) |
| Alarm states | OK, ALARM, INSUFFICIENT DATA |
| SNS | Alarm ke baad email ya SMS bhejne ki service |
| Dashboards | Graphs aur alarms ek screen par, car dashboard jaisa |
| Logs Insights | Sirf search tool, logs mein query chalata hai |
| CloudWatch Agent | Server par install hone wala software, memory, disk aur custom logs bhejta hai |
| Basic vs Detailed | EC2 par 5 minute (free) vs 1 minute (paid) |
| CloudWatch vs CloudTrail | Performance aur logs vs kisne kya kiya (API calls) |
| Sabse zaroori baat | CloudWatch masla khud theek nahi karta, dekhne, dhoondne aur alert karne mein madad deta hai |
