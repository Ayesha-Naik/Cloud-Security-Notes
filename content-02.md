# Class 2 — Deployment Models, Design Principles & AWS Well-Architected Framework

## 1. Cloud Deployment Models

Deployment model batata hai ke infrastructure **kahan hosted hai** — poora cloud mein, poora khud ke paas, ya dono mila kar.

### a) On-Premises (Private Data Center)
- Sab kuch **apni company ki building** mein, apne servers pe hota hai
- Poora control tumhara hota hai, lekin poori zimmedari bhi tumhari hai (maintenance, security, cost)
- **Example:** Bohot purani bank branches jo apna khud ka server room rakhti thi — koi cloud use nahi karti thi

### b) Public Cloud
- Infrastructure ek **third-party provider** (AWS, Azure, GCP) ke paas hota hai, jo shared resources multiple customers ko deta hai
- Sabse common aur cost-effective model
- **Example:** Netflix apni poori video streaming service AWS (public cloud) par chalata hai — apna khud ka data center nahi banaya

### c) Private Cloud
- Cloud jaisi flexibility milti hai, lekin infrastructure **sirf ek hi organization** ke liye dedicated hoti hai (shared nahi)
- Zyada security/control chahiye hone par use hota hai (jaise banks, government)
- **Example:** Ek bank apna khud ka "cloud-style" data center banaye jo sirf usi bank ke liye ho, kisi aur customer ke saath share na ho

### d) Hybrid Cloud
- **On-premises + Public Cloud** dono ka mix — kuch data/apps company ke apne servers pe, kuch cloud pe
- Sensitive data on-premises rakhte hain, baaki scalable workloads cloud pe bhejte hain
- **Example:** Ek hospital apna patient database on-premises (extra security ke liye) rakhta hai, lekin apni website aur appointment booking system AWS (public cloud) pe chalata hai

### e) Multi-Cloud
- Ek se zyada cloud providers (jaise AWS + Azure dono) ek saath use karna — kisi ek provider pe depend na hona
- **Example:** Ek company apna backup AWS pe aur apna main app Azure pe rakhe — agar ek provider down ho jaye to doosra chalta rahe

---

## 2. Design Principles (Cloud System Design ke Bunyadi Usool)

### a) Scalability
**Scalability** = system ki capacity ke mutabiq resources **badhana ya ghatana** — jab traffic/load zyada ho to system uske hisaab se adjust ho sake.

**Horizontal Scaling (Scale Out):**
- **Zyada machines/servers add karna** — load ko multiple servers mein baant dena
- **Example:** Ek website pe traffic badh gaya — ek server ki jagah 5 servers laga diye, load balancer un sab mein traffic baant deta hai
- Yaad rakho: Horizontal = "**out**" (zyada instances add karna, side mein failna)

**Vertical Scaling (Scale Up):**
- **Ek hi machine ki power badhana** — jaise RAM, CPU zyada laga dena
- **Example:** Ek server slow ho gaya — usi server ka RAM 8GB se 32GB kar diya, CPU upgrade kar diya
- Yaad rakho: Vertical = "**up**" (usi machine ko upar/strong banana)
- **Limitation:** Ek had ke baad machine ko aur upgrade nahi kar sakte (hardware limit aa jaati hai) — isliye large-scale systems horizontal scaling prefer karte hain

### b) High Availability (HA)
- System **hamesha (24/7) available/chalta rahe**, chahe koi part fail ho jaye
- Isko achieve karne ke liye multiple servers, multiple locations (regions/zones) mein system chalaya jata hai
- **Example:** Google search kabhi "down" nahi hota — kyunki duniya bhar mein multiple data centers pe ye chal raha hai, ek jagah issue ho to doosri jagah se serve ho jata hai

### c) Elasticity
- System **khud-ba-khud (automatically) resources badhaye ya ghataye**, load ke hisaab se — bina manually kuch karo
- Scalability aur elasticity mein farq: Scalability = capacity badhane/ghatane ki **ability**; Elasticity = ye process **automatic** hona
- **Example:** Eid ya sale ke din ek online shopping app pe traffic achanak 10x ho jata hai — AWS Auto Scaling khud-ba-khud extra servers laga deta hai, aur raat ko traffic kam hone par khud hi servers wapas kam kar deta hai (paisa bachane ke liye)

### d) Single Point of Failure (SPOF)
- Wo **ek hi component** jisme agar kharabi aaye to **poora system down** ho jaye
- Achi design mein SPOF ko hamesha khatam kiya jata hai (backup/redundancy laga kar)
- **Example:** Agar ek website ka sirf **ek** hi server hai aur wo crash ho jaye — poori website down ho jayegi. Ye server "Single Point of Failure" hai. Isko fix karne ke liye 2+ servers rakhte hain.

### e) Fault Tolerance
- System mein **koi part fail ho jaye, phir bhi system chalta rahe** — bina user ko pata chale
- Redundancy (backup components) se achieve hota hai
- **Example:** Airplane mein 2-4 engines hote hain — agar ek engine fail ho jaye, plane baki engines se udh sakta hai. Cloud systems mein bhi agar ek server fail ho, baaki servers kaam jaari rakhte hain.

### f) Disaster Recovery (DR)
- Agar koi **bada disaster** ho jaye (poora data center down, natural disaster, cyber attack) — system ko wapas chalu karne ka **plan aur process**
- Backup data aur alag location (region) mein recovery setup rakha jata hai
- **Example:** Ek company ka primary data center Karachi mein hai. Agar wahan flood/earthquake aa jaye, DR plan ke zariye system foran Lahore ke backup data center se chalna shuru ho jata hai — data loss minimum hota hai

---

## 3. The AWS Well-Architected Framework — 6 Pillars

Ye **AWS ka official rulebook** hai achhe cloud systems banane ke liye. Ye database concept **nahi** hai — ye khaas AWS ka apna framework hai, isliye ismein dhyan se focus karna. Ismein **6 pillars** hain (inhe har system ke liye 6 quality checks samjho).

| Pillar | Simple Lafzon Mein |
|---|---|
| 1. Operational Excellence | Systems ko achhe se chalana aur monitor karna; improve karte rehna; tasks automate karna |
| 2. Security | Data aur systems ko protect karna; control karna kaun kya access kar sakta hai |
| 3. Reliability | System failure se recover ho jaye aur zaroorat ke waqt kaam kare |
| 4. Performance Efficiency | Computing resources ko achhe se use karna; fast rehna; waste na karna |
| 5. Cost Optimization | Faaltu spending avoid karna; sirf utna pay karo jitni zaroorat hai |
| 6. Sustainability | Environmental impact kam karna; energy efficiently use karna |

**Memory hook:** "Operate Securely — Reliable, Performant, Cheap, Sustainable." → **O, S, R, P, C, S**

**Example (poore framework ko ek scenario mein samjho):** Socho tum ek online store bana rahi ho AWS pe:
- **Operational Excellence:** Automated alerts lagati ho taake server down hone par turant pata chale
- **Security:** Customer ka payment data encrypt karti ho, sirf authorized log access kar sakein
- **Reliability:** Multiple servers rakhti ho taake ek fail ho to doosra chal sake
- **Performance Efficiency:** Sirf utna hi server size use karti ho jitni zaroorat hai, na zyada na kam
- **Cost Optimization:** Raat ko jab traffic kam ho to servers automatically kam kar deti ho (elasticity)
- **Sustainability:** AWS ke un regions ko choose karti ho jo renewable energy zyada use karte hain

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| On-Premises | poora infrastructure khud ki building mein |
| Public Cloud | shared, third-party provider (AWS/Azure) ka infrastructure |
| Private Cloud | dedicated cloud sirf ek organization ke liye |
| Hybrid Cloud | on-premises + public cloud ka mix |
| Multi-Cloud | ek se zyada cloud providers ek saath use karna |
| Horizontal Scaling | zyada machines add karna (scale out) |
| Vertical Scaling | ek machine ki power badhana (scale up) |
| High Availability | system hamesha chalta rahe, koi part fail ho tab bhi |
| Elasticity | resources ka automatic badhna/ghatna load ke hisaab se |
| Single Point of Failure | wo ek component jiske fail hone se poora system down ho jaye |
| Fault Tolerance | ek part fail ho phir bhi system chalta rahe |
| Disaster Recovery | bade disaster ke baad system ko wapas chalu karne ka plan |
| AWS Well-Architected Framework | AWS ka 6-pillar rulebook: Operational Excellence, Security, Reliability, Performance Efficiency, Cost Optimization, Sustainability |
