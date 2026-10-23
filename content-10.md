# Class 10 — EC2 Hardening (Server ko Secure Banana)

## 1. Hardening kya hai?

**Hardening** = ek server (yahan EC2 instance) ko **default, out-of-the-box state** se nikaal kar **extra secure** banana — taake attack surface kam se kam ho jaye.

**Plain meaning:** Jab tum ek naya EC2 instance launch karti ho, uski default settings **kaam karne ke liye** hoti hain, **sabse secure hone ke liye nahi**. Hardening ka matlab hai: ek **layer-by-layer check** karna aur har jagah "ye chahiye ya nahi" poochna, phir jo faaltu/khatarnak hai use band karna.

**Hardening ko hum layers mein todte hain**, kyunki security ek hi jagah se nahi aati — server ke har level (access, software, remote login, web server) par alag threats hote hain:

| Layer | Focus |
|---|---|
| Layer 1 | Safety — khud ko lock out na karna |
| Layer 2 | Patching — operating system update rakhna |
| Layer 3 | Remote Access — SSH ko secure karna |
| Layer 4 | Web Server — Nginx ko secure karna |

**Example:** Hardening ko socho ek **ghar ko mehfooz banana** jaisa — pehle ye check karo ke chaabi kaho kho to nahi jayegi (Layer 1), phir ghar ki cracks/kamzoriyan theek karo (Layer 2), phir darwaza kaun khol sakta hai decide karo (Layer 3), aur aakhir mein ghar ke andar ka saman (jaise website) bhi secure karo (Layer 4).

---

## 2. Layer 1 — Safety: Khud ko Lock Out Na Karna

Jab tum koi security rule change karti ho (jaise Security Group mein SSH access), **sabse bada khatra ye hai ke tum khud apna access khatam kar do** — agar naya rule galat laga, to tum **khud bhi andar nahi ja sakogi**.

**Karne wali cheezein (DO):**
- Purana SSH terminal **khula rakho** jab tak naya rule save na ho jaye
- Ek **doosra terminal** kholo aur naya connection **test** karo
- **Sirf tabhi** purana band karo jab naya connection **kaam kar raha ho confirm ho jaye**

**Na karne wali cheezein (DON'T):**
- Apna **ek hi session band kar dena** test karne se pehle
- Ye **assume kar lena ke tumhara IP kabhi nahi badlega** — home internet (ISPs) kaafi dafa IP badal dete hain

**Agar baad mein IP badal jaye:** SSH connection **chupke se timeout** ho jata hai (koi error message nahi aata, bas connect nahi hota). Fix: rule ko edit karke apna naya IP daalo. Long-term fix: **AWS Systems Manager Session Manager** use karo — isse port 22 kabhi khola hi nahi jata, aur IP change hone ka masla khatam ho jata hai.

**Example:** Ye aise hai jaise tum ghar ke **darwaze ka lock badal rahi ho** andar se — agar tum pehle purana lock tod do aur naya lock kaam na kare, to tum **khud bahar reh jaogi**. Isliye smart tareeqa ye hai: naya lock laga lo, lekin purane wale ko turant mat hatao — pehle check karo naya lock sahi se khul raha hai, tabhi purana hatao.

---

## 3. Layer 2 — Patching: Operating System Update Rakhna

**Kyun zaroori hai:** Zyadatar real-world attacks **known vulnerabilities** use karte hain jinke liye **patches pehle se maujood hain**. **Unpatched software sabse aasan darwaza hai** attacker ke liye.

**Teen commands (order mein):**
1. `sudo dnf check-update` — sirf **dekho**, kuch install mat karo
2. `sudo dnf upgrade -y` — review karne ke baad **install karo**
3. `uname -r` — **kernel version check** karo

**Exit code 100 ka matlab samajhna zaroori hai:** Ye **error nahi hai**. `check-update` command ke liye:
- **0** = system poori tarah up to date hai
- **100** = updates available hain

*(Bohot students ye 100 dekh kar ghabra jaate hain, lekin ye bilkul normal hai.)*

**dnf kya hai:** Amazon Linux ka **package manager** — iske zariye software install, remove, update aur inspect hota hai.

**Sahi order follow karo:** check → upgrade → **sirf tab reboot karo agar kernel badla ho** → dobara verify karo.

**Example:** Ye aise hai jaise tum apne mobile ke **software updates** check karti ho. Agar update available ho (exit code 100 jaisa) to ghabrane ki zaroorat nahi — bas update install karo. Lekin agar **kernel** (phone ka core system) update hua ho, to **restart** zaroori hota hai, warna naya update poori tarah apply nahi hota.

---

## 4. Layer 3 — Remote Access: SSH ko Secure Karna

SSH wo tareeqa hai jisse tum apne server mein remote se login karti ho — isliye ye **attackers ka sabse pehla target** hota hai. Chand settings badal kar ise bohot secure banaya ja sakta hai:

| Setting | Target Value | Kyun |
|---|---|---|
| `PasswordAuthentication` | **no** | Passwords ko bots 24/7 guess kar sakte hain. Keys (chaabi) ko realistically guess nahi kiya ja sakta |
| `PermitRootLogin` | **no** | "root" wo ek username hai jo **har attacker pehle se jaanta hai** |
| `PubkeyAuthentication` | **yes** | Ye tumhara **sirf raasta** hai andar aane ka, isliye ON rehna zaroori hai |
| `PermitEmptyPasswords` | **no** | Khaali password = khula darwaza |
| `MaxAuthTries` | **3** | Ek connection mein **kam guesses** milte hain — passwords off hone ke baad ek minor extra layer |
| `X11Forwarding` | **no** | Graphical forwarding jiski zaroorat nahi — isse attack surface kam hota hai |

**Settings check karne ka command:**
`sudo sshd -T | grep -iE '^(permitrootlogin|passwordauthentication|pubkeyauthentication|permitemptypasswords|x11forwarding|maxauthtries)'`

**`sshd -T` kyun use karte hain:** Ye **effective config** print karta hai (sab includes aur defaults ke baad ka asli result) — sirf config file padhne se behtar hai, kyunki file mein likha hua aur **actual applied setting** alag ho sakte hain. `-i` flag isliye zaroori hai kyunki `sshd` lowercase mein print karta hai aur `grep` case-sensitive hota hai.

**Example:** Ye aise hai jaise tum apne ghar ke darwaze par security rules lagati ho:
- Password se koi bhi guess karke andar aa sakta hai (bohot bots 24/7 try karte rehte) — isliye **sirf chaabi (key)** se hi khulne do
- "root" account ko lock kar do kyunki **har chor isko pehle try karta hai**
- Galat chaabi teen baar try karne ke baad darwaza **band ho jaye** — taake koi bots lagataar try na karta rahe

---

## 5. Layer 4 — Web Server: Nginx Security Headers

**Headers** = wo instructions jo tumhara server **visitor ke browser ko bhejta hai**, taake browser **zyada mehfooz tareeqe** se behave kare. Ye headers `/etc/nginx/nginx.conf` ke `http` block mein add kiye jaate hain:

`server_tokens off;`
`add_header X-Content-Type-Options "nosniff" always;`
`add_header X-Frame-Options "SAMEORIGIN" always;`
`add_header Referrer-Policy "strict-origin-when-cross-origin" always;`

**Har header kya karta hai:**

| Header | Kaunsa attack kam karta hai |
|---|---|
| `server_tokens off` | Nginx ka **exact version chhupata hai** responses mein — attacker ko kam jaankari milti hai |
| `nosniff` | Browser ko file type **khud se guess karne se rokta hai** (MIME sniffing tricks) |
| `X-Frame-Options` | **Clickjacking** rokta hai — koi doosri website tumhari site ko **chupke se apne andar** (hidden frame mein) embed nahi kar sakti |
| `Referrer-Policy` | Jab user kisi link par click kar ke chala jaye, to **kitni URL info doosri site ko bhejni hai**, usay limit karta hai |

**Example:** Ye headers aise hain jaise tum apni **website par board laga rahi ho** jo visitors ke "browser" (jo website ke andar ghoom raha hai) ko batate hain: "mera version mat batao kisi ko" (server_tokens off), "files ka type khud se mat badlo" (nosniff), "mujhe kisi aur site ke andar chhupa kar mat dikhao" (X-Frame-Options), aur "jab yahan se jao to meri poori detail agli site ko mat do" (Referrer-Policy).

---

## 6. The Safe Change Loop — Changes Karne ka Mehfooz Tareeqa

Jab bhi Nginx ki config mein koi change karo, **ek fixed sequence** follow karo taake galti se site down na ho jaye:

**Change → Test → Reload → Verify**

`sudo nano /etc/nginx/nginx.conf` — 1. change karo
`sudo nginx -t` — 2. syntax test karo (abhi kuch apply nahi hua)
`sudo systemctl reload nginx` — 3. bina downtime ke apply karo
`curl -I http://localhost` — 4. verify karo headers sach mein aa rahe hain

**Expected result:** `HTTP/1.1 200 OK`, `Server: nginx` (bina version ke), plus teeno headers dikhne chahiye. **200 isbaat ka proof hai ke site break nahi hui.**

**Reload vs Restart ka farq:** **Reload** config ko **gracefully re-read** karta hai (site down nahi hoti is dauran). Reload ko baar-baar chalane se bhi koi nuqsaan nahi — bas config dobara apply ho jati hai.

**Important baat:** **Sirf config file likh dena kuch sabit nahi karta.** **Sirf response (jo curl se milta hai) hi sabit karta hai ke control actually active hai.**

**Example:** Ye aise hai jaise tum apne ghar mein **naya intercom system** laga rahi ho. Sirf wire jod dena (config likhna) kaafi nahi — pehle check karo connections sahi hain (`nginx -t`), phir system ko on karo bina poori building ki bijli band kiye (`reload`), aur aakhir mein **khud call kar ke check karo** ke awaaz aa rahi hai ya nahi (`curl -I`) — tabhi pata chalega system kaam kar raha hai.

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| Hardening | server ko default state se nikaal kar extra secure banana |
| Layer 1 — Safety | khud ko lock out na karna, naya rule test karne se pehle purana session band na karo |
| AWS Systems Manager Session Manager | SSH port 22 khole bagair server access karne ka tareeqa |
| Layer 2 — Patching | OS ko update rakhna, kyunki zyadatar attacks known (patched) vulnerabilities use karte hain |
| dnf | Amazon Linux ka package manager |
| Exit code 100 (check-update) | error nahi — matlab updates available hain |
| Layer 3 — SSH Hardening | PasswordAuthentication no, PermitRootLogin no, PubkeyAuthentication yes, PermitEmptyPasswords no |
| sshd -T | SSH ki effective (asal applied) config dikhata hai |
| Layer 4 — Nginx Headers | server ki taraf se browser ko extra safety instructions |
| X-Frame-Options | clickjacking se bachata hai |
| nosniff | MIME-type guessing se bachata hai |
| Safe Change Loop | Change → nginx -t (test) → reload → curl -I (verify) |
| Reload vs Restart | reload config ko downtime ke bagair wapas apply karta hai |
