# Class 15 — Amazon ECS (Elastic Container Service)

## 1. Image aur Container

**Image** = ek **sealed box** jiske andar tumhara app band hota hai. **Container** = wahi box **chal raha (running)** hota hai.

**Image ke andar teen cheezein hoti hain:**
- Tumhara **app code**
- **Libraries** (jo code ko chalne ke liye chahiye)
- **Settings**

Jab tum is image ko **run** karti ho, to kai alag **containers** ban sakte hain — **Container 1, Container 2, Container 3**... **Same image, many copies. Same result everywhere.**

**Example:** Image ek **packed lunch box** jaisa hai — ek hi recipe se bana hua. Container us lunch ko **khana** hai. **Ek recipe, kai lunches** — har container bilkul **same taste** dega, chahe kahin bhi khola jaye.

---

## 2. App Container Ke Andar Kaise Jata Hai?

**Tareeqa:** Ek **short instruction file** likho, usse ek **image build** karo, use **store** karo, aur **ECS ko run** karne do.

**Poora flow:**

Your code + Dockerfile → **build** → Image → **push** → ECR (image storage) → **pull** → ECS runs it

**Step by step:**
1. **Your code + Dockerfile** — tumhara app code aur ek instruction file
2. **Build** — is se ek **Image** banti hai
3. **Push** — image ko **ECR (Elastic Container Registry — image storage)** mein bhej diya jata hai
4. **Pull** — **ECS** wahan se image ko utha kar **run** kar deta hai

**Dockerfile kya hai:** Ye **instruction file** hoti hai jo batati hai image kaise banegi. Ek website ko pack karne wali Dockerfile mein jaisi lines hoti hain:

`COPY site/ /usr/share/nginx/html` — mera website files add karo
`EXPOSE 80` — app port 80 par sunta hai

**Example:** Ye aise hai jaise tum kisi dost ko **recipe card** (Dockerfile) deti ho, wo us recipe se **khana bana** leta hai (Image build), khana ek **container (fridge)** mein store kar deta hai (ECR), aur jab zaroorat ho (ECS) khana **nikal kar serve** kar deta hai.

---

## 3. ECS Ke Paanch Zaroori Alfaaz

Ye **paanch cheezein** yaad kar lo, aur **ECS samajh mein aa jayega.**

| Term | Matlab |
|---|---|
| **Image** | tumhara **packed app** |
| **Task definition** | **recipe card** — kaunsi image use karni hai, kitni memory chahiye, kaunsa port |
| **Task** | tumhare app ki **ek running copy** |
| **Service** | **manager** — tum kehti ho "3 tasks chalte rehne chahiye" aur ye yaqeeni banata hai |
| **Cluster** | wo **jagah jahan services aur tasks rehte hain** |

**Poora structure:**

Image → Task definition (how to run it) → is se **Tasks** banti hain → Tasks ek **Service** ke andar chalti hain (jo kehti hai "keep 3 tasks running") → ye sab ek **Cluster** ke andar hota hai

**Har Task, Task Definition se bana hota hai** — jaise har lunch usi **ek recipe** se banta hai.

**Restaurant Analogy (poora set ek sath samajhne ke liye):**
- **Image** = **ingredients** (khana banane ka saman)
- **Task definition** = **recipe card** (kaise banana hai)
- **Task** = **ek dish jo serve ho rahi hai**
- **Service** = **the manager** — jo yaqeeni banata hai hamesha sahi tadaad mein dishes bani rahein
- **Cluster** = **poora restaurant** — jahan ye sab kuch hota hai

**Example:** Socho tumhara apna **dhaba** hai — Image tumhare **sabzi/masale** hain, Task Definition ek **recipe card** hai jisme likha hai "2 plate chawal, dal, roti," Task ek **serve hoti hui plate** hai, Service wo **manager** hai jo kehta hai "hamesha 3 plates ready rakho," aur Cluster poora **dhaba** hai jahan ye sab chal raha hai.

---

## 4. Service Kya Karti Hai? (Self-Healing)

**Service ka kaam:** Agar koi **Task crash** ho jaye, Service khud **naya Task start** kar deti hai. **Tumhe kuch bhi nahi karna padta.**

**Poora cycle:**

1. **All fine** — 3 tasks chal rahe hain
2. **One crashes** — ek task fail ho jata hai, ab sirf **2 running** hain
3. **Service fixes it** — Service khud ek **naya task start** karti hai, aur wapas **3 tasks** chalne lagte hain

**Example:** Ye aise hai jaise ek dukaan mein **3 counters khulay** hon. Agar ek counter wala staff **beemar ho kar chala jaye**, manager (Service) **turant dusra banda** us jagah bhej deta hai — customer ko pata bhi nahi chalega kuch hua tha. **Counters hamesha 3 hi rehte hain.**

---

## 5. Cluster Kya Hai?

**Cluster** = wo **jagah jahan tumhare Services aur Tasks rehte hain aur chalte hain.** Ye ek **logical grouping** hai — jaise ek ghar jisme kai kamre (Services) hon, aur har kamre mein log (Tasks) reh rahe hon.

**Cluster ke andar "power" kahan se aati hai?** Tasks ko chalne ke liye **computing power** chahiye hoti hai, aur **Cluster hi ye power deta hai.** Ye power do tareeqon se mil sakti hai: **Fargate** (AWS khud deta hai) ya **EC2** (tum khud manage karti ho) — isko agle section mein detail se dekhte hain.

**Example:** Cluster ek **building** jaisa hai jisme kai offices (Services) hain, aur har office mein kai employees (Tasks) kaam kar rahe hain. Building (Cluster) khud kaam nahi karta — ye bas wo **jagah** hai jahan sab kuch organize hoke rehta hai.

---

## 6. Fargate ya EC2? (Cluster Ke Peeche Ki Power)

Dono hi tumhare **containers chalate hain** — **farq sirf itna hai ke servers ka khayal kaun rakhta hai.**

| | ECS + Fargate | ECS + EC2 |
|---|---|---|
| **Containers** | Your containers | Your containers |
| **Servers** | **AWS looks after them** | **You look after them** |
| **Fayda/Nuqsan** | Tum sirf **app ke bare mein sochti ho** | **Zyada control, zyada kaam** |

**Example:** **Fargate = taxi lena.** Tumhe gaadi ki fikar nahi — bas safar karo, baaki (petrol, maintenance, driver) company sambhalti hai. **EC2 = apni gaadi rakhna.** Tumhara **poora control** hota hai gaadi par, lekin **maintenance, petrol, service** sab tumhara kaam hai.

**Recommendation jo page khud deta hai:** "**Start with the taxi**" — matlab Fargate se shuru karo, agar baad mein zyada control chahiye ho to EC2 ki taraf jao.

---

## Quick Revision

| Cheez | Matlab |
|---|---|
| Image | sealed box jisme app packed hai |
| Container | wahi image chal rahi (running) hai |
| Dockerfile | instruction file jo batati hai image kaise banegi |
| ECR | image storage — jahan image push hoti hai |
| Task definition | recipe card — kaunsi image, kitni memory, kaunsa port |
| Task | app ki ek running copy |
| Service | manager — tasks ki tadaad maintain karta hai |
| Cluster | jagah jahan services aur tasks rehte hain |
| Self-healing | agar task crash ho, service khud naya task start kar deti hai |
| Fargate | AWS servers khud manage karta hai — taxi lene jaisa |
| EC2 (ECS ke sath) | tum khud servers manage karti ho — apni gaadi jaisa |
