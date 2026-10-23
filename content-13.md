# Class 13 — Anatomy of a Web Request (EC2 Route vs Serverless Route)

## 1. Ek Web Request Ka Poora Safar

Jab koi user browser mein `mycompany.com` type karta hai, uski request **kai layers** se guzarti hai pehle tak ke tumhara server ya application usay jawab de. Har layer ek alag kaam karti hai — DNS, security, network entry, load balancing, aur aakhir mein tumhara app ya database.

In layers ko teen categories mein baanta ja sakta hai:

| Category | Matlab |
|---|---|
| **Global edge** | AWS ke duniya bhar mein failay hue edge locations — request yahan se shuru aur khatam hoti hai |
| **Inside your VPC** | Tumhare apne private network ke andar — yahan tumhara control hota hai |
| **AWS-managed service, outside your VPC** | AWS khud manage karta hai, VPC ke bahar, lekin tumhare account se juda hota hai |

**Example:** Ye aise hai jaise tum kisi bade **shehar ke airport** se guzar kar ek **private housing society** mein pahunch rahi ho. Pehle **immigration aur customs** (global edge — DNS, security checks) se guzarna padta hai, phir **society ke gate** (VPC entry) se andar jana padta hai, aur aakhir mein **apne ghar** (tumhara app/database) tak pahunchti ho.

---

## 2. Route A — EC2 Based Request (Traditional Server Route)

Ye wo route hai jab tumhara backend ek **EC2 instance** par chal raha ho.

### Step 1: Route 53 DNS Question Ka Jawab Deta Hai (Global edge)

Jab browser poochta hai "`mycompany.com` ka address kya hai?", **Route 53** (AWS ki DNS service) ek **nearby CloudFront edge location** ka address deta hai (alias record ke zariye). Is step mein **koi page data move nahi hota** — ye sirf ek **naam dhoondhne (name lookup)** ka kaam hai.

**Kaise kaam karta hai:** Pehle browser aur operating system apne **khud ke cache** check karte hain. Agar wahan jawab na mile, to ek **resolver** DNS ki hierarchy follow karta hai jab tak wo **Route 53** (tumhare domain ke liye authoritative server) tak nahi pahunch jata. Jawab milne ke baad use **TTL (time duration) ke liye cache** kar liya jata hai, taake baar-baar yehi sawaal na poochna pade.

**Example:** Ye aise hai jaise tum kisi dost se poochti ho "fulan ka ghar kahan hai?" — agar tumhe pehle se pata ho (cache), to turant jawab mil jata hai. Agar nahi pata, to tum kisi aur se poochti ho, wo kisi aur se — jab tak asli jaan-ne wala (Route 53) nahi milta.

### Step 2: CloudFront Edge Location (Global edge)

Request ab **CloudFront** (AWS ka CDN — Content Delivery Network) ke **nearest edge location** tak pahunchti hai — jo user ke **geographically qareeb** hota hai, taake speed achhi rahe.

### Step 3: Shield aur WAF Isay Inspect Karte Hain (Global edge)

Yahan request **security checks** se guzarti hai:
- **Shield** — DDoS attacks (bulk traffic se server ko overload karne ki koshish) se bachata hai
- **WAF (Web Application Firewall)** — malicious patterns (jaise SQL injection, suspicious requests) ko detect karke block karta hai

### Step 4: Internet Gateway — VPC Mein Entry (Inside your VPC)

CloudFront request ko tumhare **origin** (yahan ALB ka DNS naam) ki taraf forward karta hai. Ye request **Internet Gateway (IGW)** ke zariye tumhare **VPC** mein dakhil hoti hai.

**Kaise kaam karta hai:** IGW **sirf VPC ko internet se jodta hai** — ye khud se **koi port nahi kholta**. Ye bas ek darwaza hai, security decisions aage ki layers karti hain.

**Example:** IGW aise hai jaise tumhare **housing society ka main gate** — gate khud kisi ko permission nahi deta, bas ye raasta khol deta hai. Andar security checks (security groups) alag se hote hain.

### Step 5: Route Table aur NACL (Public Subnet) (Inside your VPC)

Request **public subnet** mein aati hai, jahan **route table** (traffic ko sahi raaste par bhejti hai) aur **NACL (Network Access Control List — subnet level firewall)** check karte hain ke ye traffic aage jane ki ijazat rakhta hai.

### Step 6: Application Load Balancer (ALB) (Inside your VPC)

**ALB** public subnets mein khada hota hai aur request ko **accept** karta hai.

**Kaise kaam karta hai:** ALB ka apna **security group** port ko allow karta hai. Ek **listener rule** (jaise path `/users` ke hisaab se) decide karti hai ke request **kaunse target group** ko jayegi, aur **health checks** ye yaqeeni banate hain ke traffic sirf un targets (EC2 instances) ko jaye jo **healthy** hain.

**Best practice:** ALB **TLS khud khatam** kar sakta hai ACM certificate (AWS Certificate Manager) ka use karke. Aur sabse achha tareeqa ye hai ke **sirf CloudFront ko hi ALB tak pahunchne ki ijazat** ho — koi bhi direct internet se ALB tak na aa sake.

**Example:** ALB ek **receptionist** ki tarah hai jo har aane wale ko check karti hai — "tumhe kis department jana hai?" (listener rule), aur sirf unhi staff members (healthy targets) ki taraf bhejti hai jo **abhi available** hain, na ke jo chhutti par hon (unhealthy).

### Step 7: Private Subnet Checks, Phir EC2 Ka Security Group (Inside your VPC)

ALB request ko **private subnet** mein khade ek **EC2 instance** ki taraf forward karta hai. **Private subnet ka NACL** ise allow karta hai, aur **instance ka security group** kehta hai: "**sirf ALB ke security group se aayi traffic accept karo**" — kisi aur se nahi.

**Kaise kaam karta hai:** ALB private instance tak **VPC ke local route** ke zariye pahunchta hai — ye traffic kabhi public internet par nahi jata, VPC ke **andar hi andar** rehta hai.

**Example:** Ye aise hai jaise society ke reception (ALB) ke baad tumhe **ek aur internal darwaza** milta hai jo sirf reception ke bheje hue logon ko hi andar jaane deta hai — koi bahar se seedha is darwaze tak nahi pahunch sakta.

### Step 8: Tumhara App Instance Par Chalta Hai (Inside your VPC)

Ek **web server ya app process** (jaise Nginx, Apache, ya Node.js port 3000 par) **hamesha chalta rehta hai**. Ye request ko receive karta hai, tumhara code run karta hai, aur response taiyar karta hai.

**Kaise kaam karta hai:** Tum khud **OS, patches, aur capacity** manage karti ho (ye EC2 hai, isliye zimmedari tumhari). Ek **instance profile** (IAM Role jo instance ko attach hoti hai) app ko **AWS permissions deta hai bina kisi key store kiye** — jaisa Class 10 mein Role ke bare mein padha tha.

### Step 9: Database Jawab Deta Hai (Inside your VPC)

App jo bhi data chahiye hota hai, wo **database** se mangta hai (jo bhi VPC ke andar chal raha ho), aur database jawab deta hai.

### Step 10: Response Wapas Jata Hai (Global edge)

Poora process reverse order mein hota hai — jawab EC2 se ALB, VPC se CloudFront, aur aakhir mein **browser** tak wapas pahunchta hai.

---

## 3. Route C — Serverless Request (Lambda Based)

Agar backend **EC2 ki jagah serverless (Lambda)** se bana ho, to pehle 3 steps **same** rehte hain (Route 53, CloudFront, Shield/WAF), lekin uske baad ka raasta **bilkul alag** hota hai — aur ye saari services **AWS-managed hoti hain, tumhare VPC ke bahar**:

### Step 4: API Gateway — API Ka Front Door (AWS-managed, outside your VPC)

**API Gateway** wo jagah hai jahan API requests **enter** karti hain — ye ALB jaisa kaam karta hai, lekin specifically APIs ke liye.

### Step 5: Lambda Invoke Hota Hai (AWS-managed, outside your VPC)

API Gateway request ko ek **Lambda function** ki taraf bhejta hai, jo **invoke (trigger)** ho jata hai.

### Step 6: Tumhara Function Apni Execution Role Ke Sath Chalta Hai (AWS-managed, outside your VPC)

Lambda function run hota hai apni **execution role** (ek IAM Role) ke sath — **koi server khud manage nahi karna padta**, AWS khud sab sambhal leta hai.

### Step 7: DynamoDB Apni API Ke Zariye Jawab Deta Hai (AWS-managed, outside your VPC)

Agar data chahiye ho, to Lambda **DynamoDB** (AWS ki serverless database) se **apni API ke zariye** data mangta hai.

### Step 8: Response Wapas Jata Hai (Global edge)

Jawab usi raaste se wapas jata hai — Lambda se API Gateway, phir CloudFront, aur browser tak.

**Example (Route A vs Route C ka farq):** EC2 route (Route A) aise hai jaise tumhara **apna poora ghar** hai jisme tum khud bijli, pani, safai (OS, patches, capacity) sambhalti ho. Lambda route (Route C) aise hai jaise tum ek **hotel room** book karti ho — tumhe sirf apna kaam karna hai, baaki (maintenance, staff, cleaning) hotel (AWS) khud sambhalta hai.

---

## 4. In Dono Routes Ko Samajhne Ka Tareeqa

Teen labels jo har step ke sath aate hain, unka matlab:

| Label | Matlab |
|---|---|
| **Global edge** | AWS ke duniya bhar ke edge locations — DNS, CDN, aur security filtering yahan hoti hai |
| **Inside your VPC** | Tumhare khud ke network ke andar — jahan tum security groups, subnets, aur routing khud control karti ho |
| **AWS-managed service, outside your VPC** | Serverless services jo AWS khud chalata hai, tumhein infrastructure ka koi fikr nahi karna padta |

**Yaad rakhne wali baat:** Chahe backend **EC2** ho ya **Lambda**, request ka **pehla hissa (DNS → CloudFront → Shield/WAF) hamesha same** rehta hai. **Farq sirf ye hai ke "VPC ke andar jaake kya hota hai"** — EC2 route mein tum VPC ke andar poora control rakhti ho, Lambda route mein AWS-managed services VPC ke **bahar** se kaam karti hain.

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| Route 53 | DNS service — domain naam ko address mein badalta hai |
| CloudFront | CDN — nearest edge location se content deliver karta hai |
| Shield | DDoS attacks se bachata hai |
| WAF | malicious request patterns ko block karta hai |
| Internet Gateway (IGW) | VPC ko internet se jodta hai, khud koi port nahi kholta |
| NACL | subnet-level firewall |
| Route Table | traffic ko sahi raaste par bhejti hai |
| Application Load Balancer (ALB) | public subnet mein khada ho kar traffic ko healthy targets tak baantta hai |
| Security Group | instance-level firewall — sirf allowed source se traffic accept karta hai |
| Private Subnet | wo subnet jahan EC2 instance directly internet se access nahi hota |
| Instance Profile | EC2 ko di gayi IAM Role jo bina key ke AWS permissions deti hai |
| API Gateway | API requests ka front door (serverless route mein) |
| Lambda | serverless function jo request par invoke (trigger) hota hai |
| Execution Role | Lambda function ki apni IAM Role |
| DynamoDB | AWS ki serverless database |
| Global edge | DNS, CDN, security — duniya bhar ke edge locations par |
| Inside your VPC | tumhara private network, jahan tumhara control hai |
| AWS-managed, outside your VPC | serverless services jo AWS khud manage karta hai |
