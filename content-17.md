# Class 17 – AWS CloudTrail (Account Activity ki Recording)

## Topics Covered
1. CloudTrail kya hai
2. CloudTrail kyun chahiye
3. CloudTrail kaise kaam karta hai
4. CloudTrail Event kya hai (important fields)
5. Event types: Management, Data, Insights
6. Event History vs Trail
7. Log storage: S3 aur CloudWatch Logs
8. Log File Integrity Validation
9. Security use cases (investigation example)
10. CloudTrail kya nahi karta (Limits)
11. Related services: CloudWatch, GuardDuty, Security Hub, CloudTrail Lake
12. Final Recap

---

## 1. CloudTrail Kya Hai?

**Definition:** AWS CloudTrail tumhare **AWS account ki activity record karta hai**. Ye batata hai ke **kaun si action request hui, kab hui, kis identity ne ki, aur kaun se AWS resources involve the.**

**Analogy:** CloudTrail AWS ka **activity logbook** hai, jaise building ke gate par visitor register hota hai: kaun aaya, kis waqt, kis ke paas gaya, kahan se aaya.

**Example:** Agar koi IAM user banata hai, security group badalta hai, ya EC2 instance stop karne ki koshish karta hai, to CloudTrail us API activity ko record kar sakta hai.

> **Important:** CloudTrail kisi ki screen ki video record nahi karta. Wo AWS services ke zariye hui requests ki **structured event details** record karta hai.

---

## 2. CloudTrail Kyun Chahiye?

Socho koi important AWS setting achanak badal gayi. Tumhe **saboot (evidence)** chahiye ke kya hua. CloudTrail in sawalon ka jawab deta hai:

| Sawal | Matlab |
|---|---|
| Who? | Kis identity ne request ki: IAM user, role session, AWS service ya koi aur identity |
| What? | Kaun si action: jaise user banana ya bucket policy badalna |
| When? | Event kis waqt hua |
| Which resource? | Kaun sa AWS resource involve tha (agar record hua ho) |
| From where? | Source IP address aur client ki information |
| Did it work? | Error record hui ya nahi, aur response kya tha |

### Common Uses

| Use | Matlab |
|---|---|
| Security investigations | Shak wali ya ghair mutawaqqe activity ki jaanch |
| Auditing | AWS account mein hui actions ka review |
| Troubleshooting | Fail hui API requests ya achanak changes ki wajah dhoondna |
| Compliance | Audit requirements ke liye activity records mehfooz rakhna |
| Accountability | Samajhna ke kis identity ne request ki |

> **Important:** CloudTrail **evidence** deta hai. Wo khud faisla nahi karta ke action malicious tha ya nahi, aur wo action ko khud rokta bhi nahi.

**Example:** Subah tumhari S3 bucket public mili. CloudTrail se pata chalta hai ke raat 2 baje kis user ne bucket policy badli aur kis IP se.

---

## 3. CloudTrail Kaise Kaam Karta Hai?

| Step | Kya hota hai |
|---|---|
| 1 | Ek identity ya AWS service request karti hai |
| 2 | Koi AWS service wo API request receive karti hai |
| 3 | CloudTrail jahan applicable ho wahan ek **event record** karta hai |
| 4 | Event ko dekha ya analysis ke liye store kiya ja sakta hai |

**Example:** Jab koi user S3 bucket banata hai, to AWS Console AWS ko request bhejta hai. CloudTrail us request ko `CreateBucket` event ke taur par record kar sakta hai.

**Key point:** Console ki bohat si actions peeche AWS APIs call karti hain. CloudTrail supported API activity record karta hai chahe wo **Console, command-line tool (CLI), SDK, ya kisi automated service** se aayi ho.

---

## 4. CloudTrail Event Kya Hai?

**Definition:** Event ek **record** hai jo kisi activity ya API request ko describe karta hai. Isme wo details hoti hain jo samjhati hain ke request kya thi.

**Event ke important fields:**

| Field | Kya batata hai |
|---|---|
| `eventTime` | Kab hua |
| `eventName` | Kaun si action, jaise `CreateBucket`, `RunInstances` |
| `eventSource` | Kaun si service, jaise `s3.amazonaws.com` |
| `userIdentity` | Kis identity ne ki (user, role, root, service) |
| `sourceIPAddress` | Request kis IP se aayi |
| `userAgent` | Kis tool se (Console, CLI, SDK) |
| `awsRegion` | Kaun se Region mein |
| `requestParameters` | Request mein kya bheja gaya |
| `errorCode` / `errorMessage` | Agar fail hui to kyun (jaise `AccessDenied`) |

**Note:** Har event mein har field hone ki guarantee nahi hoti.

**Example:** `eventName = DeleteBucket`, `userIdentity = user ali`, `sourceIPAddress = 203.0.113.9`, `errorCode = AccessDenied`. Matlab ali ne bucket delete karne ki koshish ki lekin permission na hone ki wajah se fail hua.

---

## 5. Event Types

| Type | Kya record karta hai | Example | Note |
|---|---|---|---|
| Management events | Account ke resources par **control** wali actions (control plane) | User banana, security group badalna, EC2 launch karna | Zyadatar yehi dekhe jate hain |
| Data events | Resources ke **andar ka data** access (data plane) | S3 object ka GetObject/PutObject, Lambda invoke | **Default mein off**, bohat zyada volume, alag se enable karna padta hai (paid) |
| Insights events | Ghair mamooli API activity (achanak spike, error rate) | Achanak bohat zyada `RunInstances` calls | Alag se enable karna padta hai (paid) |

**Read vs Write:** Management events mein **read-only** (dekhna, jaise List/Describe) aur **write** (badalna, jaise Create/Delete) dono hote hain. Security mein write events par zyada tawajjo hoti hai.

**Example:** Management event batata hai ke kisi ne S3 bucket **banaya**. Data event batata hai ke kisi ne us bucket se **file download** ki. Agar tumne data events enable nahi kiye to file download ka record nahi milega.

---

## 6. Event History vs Trail

| Point | Event History | Trail |
|---|---|---|
| Kya hai | Console mein built-in recent activity view | Tumhari banai hui configuration jo events ko store karti hai |
| Setup | Default mein ON, kuch karna nahi | Khud banana padta hai |
| Kitna purana | Sirf **90 din** | Jab tak tum S3 mein rakhna chaho |
| Cost | Free | Pehli copy ke management events free, baqi paid |
| Kya dekh sakte ho | Management events | Management, data, insights (jo tum choose karo) |
| Search aur analysis | Basic filters | S3, Athena, CloudWatch ke zariye |

**Analogy:** Event History CCTV ka wo screen hai jo sirf pichle 90 din dikhata hai. Trail wo system hai jo footage ko hamesha ke liye archive mein rakhta hai.

**Zaroori baat:** Agar tumhe 90 din se purani activity chahiye, to **Trail banana zaroori hai.**

**Trail ke options:**
- **Multi-region trail:** Saare Regions ki activity ek hi trail mein (recommended, taake attacker kisi doosre Region mein kaam kare to bhi pakra jaye).
- **Organization trail:** AWS Organizations ke saare accounts ek jagah.

---

## 7. Logs Kahan Store Hote Hain?

| Destination | Kaam |
|---|---|
| **S3 bucket** | Long-term storage, compliance, baad mein analysis |
| **CloudWatch Logs** | Logs par alarms aur metric filters lagane ke liye (real-time alerting) |
| **SNS** (optional) | Naye log file aane par notification |

**Example:** Trail S3 bucket mein logs rakhta hai (archive). Saath hi CloudWatch Logs mein bhi bhejta hai taake "root user login hua" par alarm bajaya ja sake. Isse pichli class (CloudWatch) ka link bhi jurta hai.

**Gotcha:** CloudTrail logs ka S3 bucket **bohat protected** hona chahiye (public nahi, sirf zaroori access, MFA delete ya versioning).

---

## 8. Log File Integrity Validation

**Masla:** Agar attacker ne apne kaam ke baad CloudTrail logs mein se apni activity delete ya badal di to?

**Hal:** **Log file integrity validation** enable karo. CloudTrail logs ke **hash (SHA-256) aur digital signature** wali digest files banata hai. Baad mein check kiya ja sakta hai ke logs **badle ya delete to nahi hue**.

**Analogy:** Register ke har page par seal aur stamp. Koi page phaare ya badle to pata chal jata hai.

---

## 9. Security Use Case (Investigation Example)

**Scenario:** Raat ko ek EC2 instance achanak launch hui aur bill barhne laga.

| Step | Kya karna hai |
|---|---|
| 1 | CloudTrail Event History mein `RunInstances` event dhoondo |
| 2 | `userIdentity` dekho: kis user ya role ne launch ki |
| 3 | `sourceIPAddress` dekho: kis IP se aayi, kya ye pehchani hui IP hai |
| 4 | `userAgent` dekho: Console tha ya CLI/SDK |
| 5 | Agar kisi user ki access key ka kaam lagay to us key ko **deactivate** karo |
| 6 | Dekho us identity ne aur kya kya kiya (aur events filter karo) |

Ye wahi incident response wali sequence hai jo credential theft ke topic mein sikhi thi.

**Important events jin par alert lagana chahiye:**
- Root user ka login ya use
- IAM policy ya user mein badlav
- Security group ya NACL mein badlav
- CloudTrail ko band (`StopLogging`) ya delete karna
- Bohat saari `AccessDenied` errors

---

## 10. CloudTrail Kya Nahi Karta (Limits)

| Limit | Matlab |
|---|---|
| Khud block nahi karta | Unauthorized actions ko automatically nahi rokta |
| Event History sirf 90 din | Management events ko hamesha ke liye nahi rakhta |
| S3 object operations default mein nahi | Jab tak relevant data events configure na kiye jayen |
| Har field ki guarantee nahi | Har event mein har field maujood nahi hota |
| Akeli IP ya username saboot nahi | Sirf source IP ya username dekh kar malicious nahi kaha ja sakta |
| Replacement nahi | Monitoring, access controls, incident response aur secure configuration ka badal nahi |

---

## 11. Related Services

Ye services alag alag kaam karti hain. **CloudTrail activity record karta hai**, baqi services monitor, analyze, correlate aur respond karne mein madad deti hain.

| Service | Kaam | CloudTrail se link |
|---|---|---|
| Amazon CloudWatch | Logs aur metrics collect aur monitor karta hai, alarms uthata hai | CloudTrail events CloudWatch Logs mein bheje ja sakte hain (configure karne par) |
| Amazon GuardDuty | Supported data sources analyze karke shak wali activity pakadta hai aur security findings deta hai | CloudTrail events us ka ek data source hain |
| AWS Security Hub | Alag alag AWS security services ki findings ek jagah jama aur manage karta hai | GuardDuty jaisi services ki findings aggregate karta hai |
| CloudTrail Lake | Event data ko store karta hai aur **SQL** se query aur analysis karne deta hai | CloudTrail ka apna feature |

**Example flow:** CloudTrail activity record karta hai, GuardDuty us mein shak wali activity dhoondta hai, Security Hub sab findings ek dashboard par dikhata hai, aur CloudWatch alarm tumhe notify karta hai.

---

## 12. Final Recap

- CloudTrail = **AWS account ka activity logbook** (kaun, kya, kab, kahan se, kya natija).
- **Event History** 90 din ke management events free dikhata hai. Lambi muddat ke liye **Trail** banao.
- Logs **S3** mein archive karo aur **CloudWatch Logs** mein alerting ke liye bhejo.
- **Multi-region trail** aur **log file integrity validation** enable rakho.
- Management events default hain, **data events aur insights alag se** enable hote hain.
- CloudTrail **evidence** deta hai, khud rokta ya faisla nahi karta.

---

## Common Galtiyan aur Gotchas

1. Sochna ke Event History hamesha ke liye record rakhti hai. Wo sirf 90 din hai.
2. Data events enable kiye baghair S3 file downloads ka record dhoondna.
3. Trail sirf ek Region mein banana aur attacker ka doosre Region mein kaam miss kar dena.
4. CloudTrail logs wale S3 bucket ko protect na karna.
5. CloudTrail aur CloudWatch ko ek hi samajhna. CloudTrail = kisne kya kiya, CloudWatch = resources kaisi chal rahi hain.
6. Sirf IP ya username dekh kar kisi ko malicious qarar de dena.

---

## Quick Revision

| Topic | Yaad rakhne wali baat |
|---|---|
| CloudTrail | AWS account ka activity logbook, API activity record karta hai |
| Kya batata hai | Who, What, When, Which resource, From where, Did it work |
| Kaise kaam karta hai | Request, AWS service, CloudTrail event record, view ya store |
| CreateBucket example | S3 bucket banane ki request CreateBucket event ban jati hai |
| Event | Activity ka record, fields: eventTime, eventName, userIdentity, sourceIPAddress, errorCode |
| Management events | Resources par control actions (create, delete, modify), zyadatar yehi |
| Data events | S3 object, Lambda invoke jaisi data actions, default off aur paid |
| Insights events | Ghair mamooli API activity ka pata lagata hai, paid |
| Event History | Default ON, free, sirf 90 din, management events |
| Trail | Lambi muddat ke liye logs store karta hai, multi-region aur organization trail |
| Storage | S3 (archive) aur CloudWatch Logs (alerting) |
| Integrity validation | Logs ke hash aur signature se pata chalta hai ke logs badle to nahi |
| Limit | Khud block nahi karta, evidence deta hai |
| CloudWatch | Logs aur metrics monitor karta hai aur alarms uthata hai |
| GuardDuty | Shak wali activity pakad kar findings deta hai |
| Security Hub | Alag services ki findings ek jagah jama karta hai |
| CloudTrail Lake | Event data par SQL query |
| Sabse zaroori baat | CloudTrail record karta hai, baqi services monitor aur respond karne mein madad deti hain |
