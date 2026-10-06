# Class 7 — Servers, Apache vs Nginx, Ports & Security Groups, Hosting Lab

## 1. Server kya hai?

**Server** = ek **computer (ya virtual machine)** jo **doosre computers (clients) ko service deta hai** — jaise files, website, data, ya koi aur resource.

**Plain meaning:** "Server" koi khaas machine nahi hai — ye **sirf ek computer hai jo kisi kaam ke liye chal raha hai**. Jo kaam wo karta hai, usi se uska naam milta hai.

**Types of servers (kaam ke hisaab se naam):**

| Server Type | Kaam |
|---|---|
| **Web Server** | Website files (HTML, CSS, JS) deta hai browser ko |
| **Database Server** | Data store/manage karta hai (jaise MySQL, PostgreSQL) |
| **Virtualization Server** | Ek bade physical server ko kai virtual machines mein baantta hai (jaise hypervisor) |

**Example:** Socho tumhare paas 3 computer hain — ek sirf website dikhata hai (**Web Server**), ek sirf data store karta hai (**Database Server**), aur ek baaki computers ko "virtual slices" mein baant ke chalata hai (**Virtualization Server**). Teenon alag kaam karte hain, isliye unka naam alag hai — lekin teeno asal mein sirf **"computers jo kisi ko service de rahe hain"** hain.

---

## 2. Ek server sab kuch vs alag web server

**Server sirf ek computer hai.** Website serve karna **ek kaam** hai, isliye hum uske liye khaas software install karte hain (jaise Nginx) aur use **baaki sab se alag** rakhte hain.

**Agar website, app, aur database sab ek hi server par ho:** "all breached" ho sakte hain — **ek break-in se attacker site, code aur data teeno le jata hai.**

**Alag karne ke fayde:**

| Fayda | Matlab |
|---|---|
| **Security** | Agar ek server break ho bhi jaye, **break-in chhota reh jata hai** (sirf us server tak limited) |
| **Speed** | Har machine **apne ek kaam ke liye tuned** hoti hai — fast chalti hai |
| **Scaling** | Database ko touch kiye bagair **web servers add** kar sakte ho |
| **Fixing** | Ek masla, **ek hi jagah check karni** padti hai |

**Example:** Socho tumhare ghar mein **kitchen, bedroom, aur locker room** sab ek hi kamre mein ho — agar chor ek darwaza tod de, to sab kuch chala jata hai. Lekin agar teeno alag kamron mein hon alag locks ke sath, to ek kamra break hone se baaki do **safe** rehte hain.

---

## 3. The Stack: 5 Layers

Ek website **layers** (parton) par bani hoti hai, ek doosre ke upar. Jab kuch kharab ho, pata lagana hota hai **kaunsi layer** mein masla hai.

**Layers (top se bottom):** Security Group se shuru hoti hai, phir EC2 instance, phir Linux, phir Nginx, aur aakhir mein Website files.

| Layer | Kya hai | Agar ye break ho to kya hota hai |
|---|---|---|
| **Security Group** | AWS ka firewall | Request andar hi nahi aa payegi |
| **EC2 instance** | Virtual server | Server hi down ho jayega |
| **Linux** | Operating System | Server boot/chal nahi payega |
| **Nginx** | Web server software | Port 80 pe koi sun nahi raha hoga |
| **Website files** | HTML, CSS, JavaScript | **404 Not Found**, ya purana page dikhega |

**Website files ka detail:** Tumhari HTML, CSS aur JavaScript. Agar ye tootein to browser mein **404 Not Found** ya ek **purana page** dikhta hai.

**Example:** Ye bilkul ek **building** jaisa hai — security guard (Security Group) darwaze par khada hai, phir building khud (EC2), phir building ka foundation/structure (Linux), phir reception desk (Nginx) jo tumhe sahi kamre tak le jati hai, aur aakhir mein wo kamra jahan asli saman (Website files) rakha hai. Agar koi bhi layer kharab ho, poori chain tootti hai.

---

## 4. Web Server kya hai (Technical tareeqe se)?

**Browsers HTTP bolte hain. Tumhari HTML files HTTP nahi boltin.** Web server in dono ke **beech mein khada hota hai**: ye port 80 pe sunta hai, file dhoondta hai, ek status code lagata hai, aur reply bhejta hai.

**Poora flow:** Browser ek request bhejta hai — Web server tak pahunchti hai — Web server jawab bhejta hai — Browser ko jawab wapas milta hai.

**Step by step:**
1. Browser ek **request** bhejta hai: "GET /" (mujhe home page chahiye)
2. Ye request **Web server** tak pahunchti hai
3. Web server file dhoondta hai aur ek **status code** lagata hai (jaise 200 = success)
4. Jawab (response) wapas **Browser** ko bhej diya jata hai

**Important baat:** Agar koi web server program chal hi nahi raha, to **port 80 pe koi sunne wala nahi hota**. Browser ko milta hai: **"connection refused"**.

**Example:** Ye aise hai jaise tum ek **restaurant** mein order dene jao. Tum waiter (Browser) se bolti ho "mujhe biryani chahiye" (GET request). Waiter kitchen (Web server) jata hai, plate taiyar karwata hai, aur tumhe serve kar deta hai (200 + response). Agar restaurant mein **koi waiter hi na ho**, tumhara order kahin jata hi nahi — "connection refused" jaisa.

---

## 5. Apache pehle, phir Nginx (History)

| Saal | Event |
|---|---|
| **1995** | Apache aata hai |
| **1999** | **C10K problem** samne aati hai: ek saath 10,000 connections kaise serve karein? |
| **2004** | **Nginx release** hota hai, isi problem ko solve karne ke liye |

**Apache ka model:** har connection ke liye **ek process ya thread** banta hai. Bohot **flexible** hai (modules, `.htaccess`), lekin **har connection ke sath memory badhti jaati hai**.

**Nginx ka model:** **chand workers hi hazaron connections ko juggle** kar lete hain. **Kam memory**, static files bohot **fast** serve karta hai, aur **built-in proxying** bhi deta hai.

Rough idea ke liye: Apache ke style mein 10,000 connections ke liye memory **hazaron MB** tak lag sakti hai, jabke Nginx ke event loop style mein yehi kaam sirf **kuch sau MB** mein ho jata hai.

**Note:** Modern Apache (event MPM) ne ye gap kaafi kam kar diya hai. **Koi bura nahi hai — workload ke hisaab se choose karo.**

**Example:** Apache aise hai jaise **har customer ke liye ek alag waiter** rakhna — personal service milti hai, lekin jitne customer badhein utne waiters chahiye (memory badhti hai). Nginx aise hai jaise **chand smart waiters** jo ek saath kai tables handle kar lete hain, tez bhi aur kam staff bhi chahiye.

---

## 6. Nginx kya-kya cover karta hai?

| Feature | Kya karta hai |
|---|---|
| **Static web server** | HTML, CSS, images **serve** karta hai |
| **Reverse proxy** | Requests ko **apps ki taraf forward** karta hai |
| **Load balancer** | Traffic ko **multiple servers** mein baantta hai |
| **HTTPS front door** | **TLS certificates** handle karta hai |
| **Caching** | Repeat requests ke jawab **yaad rakhta hai** (dobara process nahi karna padta) |
| **Access control** | Paths **block** karta hai, request rates **limit** karta hai |

**Load Balancing kaise kaam karta hai:** Agar 3 servers hain (A, B, C), to Nginx har request **round robin** tareeqe se baant deta hai — pehli request Server A ko, doosri Server B ko, teesri Server C ko, phir wapas A... isse koi ek server **overload** nahi hota.

**Example:** Nginx ek **smart receptionist** ki tarah hai jo sirf files nahi deti — wo calls forward bhi karti hai (reverse proxy), line mein logon ko barabar baantti hai (load balancer), entry pass check karti hai (access control), aur bar-bar poochi gayi baat yaad rakh leti hai taake dobara na poochna pade (caching).

---

## 7. Ports and Security Groups

**IP address machine ko dhoondta hai. Port us machine par service ko dhoondta hai. Security Group decide karta hai internet kaunse ports tak pahunch sakta hai.**

| Port | Service | Kisko reach karni chahiye |
|---|---|---|
| **22** | SSH (remote login) | Sirf tumhara apna IP, **kabhi poora internet nahi** |
| **80** | HTTP (website) | Everyone (sab) |
| **443** | HTTPS (encrypted website) | Everyone, jab certificates set ho jayein |
| **3000** | App behind Nginx | Koi public nahi — **sirf Nginx hi isse baat karta hai** |

**Rule:** **Minimum open karo.** Har khula port ek **attack surface** hai.

**Example:** Socho tumhare ghar ke **4 darwaze** hain. Main gate (port 80/443) sab ke liye khula rehta hai kyunki guests wahi se aate hain. Lekin **store room ka darwaza** (port 22, SSH) sirf **ghar ke malik ki chaabi** se khulta hai. Aur ek **internal darwaza** (port 3000) jo sirf ghar ke andar se access hota hai, bahar se koi seedha nahi aa sakta — sirf reception (Nginx) wahan tak jati hai.

---

## 8. Request ko Follow Karna (Troubleshooting Tareeqa)

Jab bhi browser mein website nahi khulti, teen cheezein check karni chahiye taake pata chale masla kahan hai:

1. **Security Group mein port 80 open hai?**
2. **Nginx chal raha hai (running)?**
3. **index.html file maujood hai?**

Agar teeno theek hon, to request successfully Browser se Security Group se Nginx tak pahunchti hai aur wahan se index.html file tak jati hai — result milta hai **200 OK**, matlab Nginx ne file dhoondh li aur wapas bhej di.

**Example:** Ye checklist bilkul pizza delivery jaisi hai — agar (1) tumhara darwaza khula hai, (2) delivery boy ke paas sahi address hai, aur (3) pizza shop mein pizza bana hua hai — tabhi pizza tum tak pahunchega. Koi ek bhi cheez miss ho, order fail ho jayega.

---

## 9. Website Host Karna — Zaroori Files aur Steps (Short Summary)

**Nginx kahan files rakhta hai:**

| Path | Kya hai |
|---|---|
| `/etc/nginx/nginx.conf` | Configuration (rules) |
| `/usr/share/nginx/html` | Website files (document root) |
| `/var/log/nginx/` | access.log, error.log |
| `/usr/sbin/nginx` | Program khud |

**Main steps:**
- Nginx install karna: `sudo dnf install -y nginx` — ye Nginx download karta hai, program `/usr/sbin` mein, settings `/etc/nginx` mein rakhta hai
- Apna HTML likhna: `sudo nano index.html` se title, heading, paragraph likho, save karo (`Ctrl+O` → Enter), exit karo (`Ctrl+X`)
- Config test karna aur Nginx ko reload/restart karna — taake naye changes apply ho jayein

**Result:** Browser mein apne EC2 ka Public IP daalne par apni website live dikhti hai — Nginx se, HTTP protocol se, port 80 par serve hoti hai.

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| Server | computer jo doosron ko service deta hai |
| Web Server | website files deta hai |
| Database Server | data store/manage karta hai |
| Virtualization Server | ek machine ko kai virtual machines mein baantta hai |
| Alag web server | security, speed, scaling, fixing sab aasan hota hai |
| The Stack (5 layers) | Security Group → EC2 → Linux → Nginx → Website files |
| Web server ka kaam | Browser ki HTTP request ko samajhna, file dhoondhna, response bhejna |
| C10K Problem | 10,000 connections ek saath serve karne ki challenge (1999) |
| Apache | process/thread-per-connection, flexible, zyada memory |
| Nginx | event loop, kam memory, fast static files, built-in proxy |
| Nginx ke features | static server, reverse proxy, load balancer, HTTPS, caching, access control |
| Port 22 | SSH — sirf apna IP |
| Port 80/443 | HTTP/HTTPS — everyone |
| Port 3000 (example) | App behind Nginx — sirf Nginx hi talk karta hai |
| Security Group Rule | minimum ports khulay rakho |
| /etc/nginx/nginx.conf | Nginx ki settings |
| /usr/share/nginx/html | website files yahan rehti hain |
