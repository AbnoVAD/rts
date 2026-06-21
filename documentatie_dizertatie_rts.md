# Cuprins propus

1. Introducere
2. Capitolul I. Stadiul actual al cercetărilor în domeniu
   2.1 Evoluția jocurilor de strategie
   2.2 Caracteristicile esențiale ale genului RTS
   2.3 Relevanța temei în contextul dezvoltării de jocuri
   2.4 Exemple de direcții și influențe conceptuale
3. Capitolul II. Obiectivele și ipotezele cercetării
   3.1 Obiectivele generale ale lucrării
   3.2 Obiective specifice
   3.3 Ipotezele cercetării
   3.4 Metodologia de lucru
   3.5 Criterii de evaluare a rezultatelor
4. Capitolul III. Prezentarea teoretică a aplicației
   4.1 Conceptul general al aplicației
   4.2 Structura gameplay-ului
   4.3 Sistemul economic
   4.4 Sistemul de construcție și dezvoltare a bazei
   4.5 Unitățile controlabile
   4.6 Interacțiunea cu inamicii
   4.7 Condițiile de reușită și eșec
   4.8 Sistemul de interacțiune cu unitățile
   4.9 Rolul interfeței în experiența de strategie
5. Capitolul IV. Prezentarea aplicației din punct de vedere tehnologic
   5.1 Arhitectura generală a sistemului
   5.2 Tehnologii utilizate
   5.3 Implementarea sistemului global
   5.4 Implementarea sistemului de construcție
   5.5 Implementarea castelului și a producției
   5.6 Implementarea unităților și a inamicilor
   5.7 Implementarea meniului și a interfeței
   5.8 Utilizarea resurselor grafice și sonore
   5.9 Gestionarea stărilor și a fluxului de joc
   5.10 Considerații privind testarea și stabilitatea
   5.11 Limitele proiectului și justificarea alegerilor tehnice
6. Concluzii și propuneri
7. Bibliografie

# Introducere

Prezenta lucrare își propune analiza, proiectarea și implementarea unei aplicații de tip joc de strategie în timp real, realizată în motorul Godot și orientată către mecanici specifice genului RTS, precum colectarea resurselor, construcția de clădiri, controlul unităților și apărarea în fața unor valuri succesive de inamici. Alegerea acestei teme a fost motivată de interesul pentru jocurile de strategie, dar și de dorința de a construi un proiect complex, în care sunt integrate atât concepte de game design, cât și principii de arhitectură software, programare orientată pe obiect și gestionarea stărilor într-o aplicație interactivă.

Jocurile de strategie ocupă de multă vreme un loc important în industria jocurilor video, deoarece ele solicită simultan capacitatea de analiză, planificarea și luarea deciziilor sub presiunea timpului. Spre deosebire de alte genuri, în care reflexele sau componenta narativă pot domina experiența, un joc de strategie pune accent pe modul în care jucătorul își organizează resursele, își distribuie forțele și reacționează la evoluția dinamică a situației de pe hartă. Din acest motiv, strategia reprezintă un domeniu de studiu relevant atât pentru dezvoltarea jocurilor, cât și pentru analiza comportamentului utilizatorului în contexte de decizie.

Actualitatea temei este dată de faptul că jocurile de strategie continuă să evolueze și să se reinventeze, atât în zona titlurilor comerciale, cât și în zona independentă. În prezent, există numeroase produse care combină elemente de RTS, tower defense, survival și management economic, ceea ce confirmă interesul constant al publicului pentru acest tip de experiență. Totodată, dezvoltarea unor astfel de aplicații devine mai accesibilă datorită motoarelor moderne de joc, care oferă instrumente mature pentru animație, navigație, interfață, audio, persistență și organizare modulară a conținutului. Godot Engine este unul dintre aceste medii de dezvoltare, fiind apreciat pentru flexibilitate, rapiditate în prototipare și structurarea clară a proiectelor pe scene și noduri.

Prin realizarea acestei aplicații s-au urmărit mai multe obiective. În primul rând, s-a dorit construirea unei baze funcționale de joc, care să includă un sistem de resurse, un sistem de construcții și o logică de supraviețuire în fața unor atacuri succesive. În al doilea rând, s-a urmărit implementarea unor unități care pot fi selectate și controlate de jucător, cu comportamente diferite în funcție de rolul lor strategic. În al treilea rând, proiectul a vizat integrarea unui sistem global de stare care să gestioneze valurile de inamici, salvarea progresului și condițiile de victoria sau eșec. Nu în ultimul rând, lucrarea a urmărit realizarea unei interfețe clare, a unor efecte vizuale și sonore coerente și a unei arhitecturi care să poată fi extinsă în viitor.

Pentru a accelera implementarea și pentru a obține o prezentare vizuală coerentă, proiectul a inclus și asset-uri gratuite preluate de pe platforma itch.io, selectate în funcție de stilul artistic al jocului și de compatibilitatea lor cu cerințele tehnice ale motorului [12]. Utilizarea unor astfel de resurse a reprezentat o decizie practică, permițând concentrarea efortului asupra mecanicilor de joc și a structurii aplicației.

Din punct de vedere metodologic, lucrarea pornește de la o analiză a domeniului jocurilor de strategie, continuă cu definirea obiectivelor și ipotezelor de cercetare, apoi prezintă mecanicile teoretice ale aplicației și, în final, evidențiază soluțiile tehnologice utilizate în implementare. Abordarea este una aplicativă, întrucât rezultatul final nu este doar o reflecție teoretică asupra genului, ci și un prototip funcțional care pune în evidență modul în care conceptele analizate pot fi transpuse într-un produs interactiv.

Lucrarea este structurată în patru capitole principale, urmate de concluzii și bibliografie. Primul capitol prezintă evoluția jocurilor de strategie și contextul actual al domeniului. Capitolul al doilea formulează obiectivele și ipotezele cercetării. Capitolul al treilea descrie aplicația din punct de vedere teoretic, cu accent pe mecanicile de joc și pe modul în care acestea se combină într-o experiență coerentă. Capitolul al patrulea prezintă aplicația din perspectiva tehnologică, detaliind arhitectura generală a sistemului și tehnologiile folosite. În final sunt formulate concluziile lucrării și sunt propuse direcții de dezvoltare ulterioară.

# Capitolul I. Stadiul actual al cercetărilor în domeniu

## 1.1 Evoluția jocurilor de strategie

Jocurile de strategie reprezintă unul dintre cele mai vechi și mai complexe genuri din industria jocurilor video. Specificul lor constă în faptul că jucătorul nu se bazează în principal pe reacții reflexe sau pe controlul direct al unui singur personaj, ci pe capacitatea de a gestiona resurse, de a anticipa acțiuni și de a lua decizii cu impact pe termen mediu și lung. În acest sens, jocurile de strategie solicită atât gândire analitică, cât și adaptabilitate, ceea ce le conferă o valoare aparte în peisajul jocurilor interactive.

Primele forme ale jocurilor de strategie au fost strâns legate de jocurile de masă și de simulările tactice. Multe dintre acestea reproduceau, într-o formă abstractă, lupta pentru teritoriu, controlul resurselor sau mișcarea coordonată a unităților. Odată cu dezvoltarea calculatoarelor personale, principiile acestor jocuri au fost transpuse în mediul digital. Inițial, majoritatea titlurilor de strategie utilizau o structură pe rânduri, în care fiecare jucător își executa mutările secvențial. Această abordare permitea o analiză mai riguroasă a poziției de joc, însă limita ritmul și intensitatea experienței.

Ulterior, a apărut modelul de strategie în timp real, care a schimbat radical modul în care sunt percepute astfel de jocuri. Într-un RTS, acțiunea nu se oprește între mutări, iar jucătorul este nevoit să gestioneze simultan construcția bazei, producția de unități, colectarea resurselor și apărarea împotriva adversarului. Această schimbare a introdus o nouă dimensiune a complexității, deoarece atenția jucătorului este împărțită între mai multe sarcini care evoluează în paralel. Din acest motiv, jocurile RTS au devenit repere importante în evoluția genului și au influențat numeroase alte tipuri de jocuri.

Unul dintre elementele definitorii ale genului este economia internă a jocului. În cele mai multe titluri de strategie, succesul nu depinde doar de forța militară, ci și de modul în care sunt administrate resursele. Jucătorul trebuie să decidă când să investească în infrastructură, când să producă unități și când să păstreze resurse pentru situații viitoare. Acest echilibru între economie și apărare a fost preluat și în aplicația realizată, în care aurul, lemnul și carnea au roluri diferite și condiționează acțiunile jucătorului.

Pe măsură ce genul a evoluat, mecanicile au devenit tot mai sofisticate. Jocurile de strategie moderne includ adesea sisteme de construcție modulară, animații complexe, AI adversă, formări de luptă, posibilități de upgrade și niveluri de dificultate ajustabile. Totodată, accentul nu mai cade exclusiv pe amploarea armatei, ci și pe calitatea feedback-ului oferit jucătorului. Interfața, sunetele, efectele vizuale și claritatea informației au devenit parte integrantă din experiența de joc. Această evoluție poate fi observată și în proiectul de față, unde elementele de prezentare sunt integrate într-un mod funcțional și coerent.

În literatura de specialitate și în practica dezvoltării de jocuri, RTS-ul este considerat un gen care pune în valoare designul sistemic. Spre deosebire de jocurile care depind predominant de o poveste liniară, strategia în timp real este definită de interacțiunea dintre subsisteme: economie, luptă, construcție, explorare și reacția la presiune. De aceea, un astfel de joc poate fi folosit ca exemplu pentru studiul complexității emergente, deoarece rezultatul partidei nu este determinat de o singură acțiune, ci de suma deciziilor luate de-a lungul timpului.

În perioada recentă, jocurile de strategie au cunoscut și o reconfigurare către forme mai accesibile. Multe titluri indie preferă să reducă amplitudinea controlului și să concentreze experiența pe un set clar de mecanici, precum apărarea bazei, construcția de așezări sau gestionarea unui număr redus de unități. Această orientare a contribuit la apariția unor jocuri mai ușor de înțeles, dar care păstrează totuși profunzimea strategică. Proiectul realizat în cadrul acestei lucrări se înscrie în această direcție, oferind o experiență clară și directă, însă suficient de bogată pentru a evidenția principiile fundamentale ale genului.

O altă tendință importantă este integrarea inteligenței artificiale și a comportamentelor adaptive. În jocurile vechi, adversarii erau adesea previzibili și se limitau la mișcări simple. În schimb, proiectele moderne folosesc mecanisme de urmărire a țintelor, evitarea obstacolelor, selecția priorităților și reacții dinamice la acțiunile jucătorului. În aplicația dezvoltată, aceste idei apar în comportamentul unităților inamice, care pot urmări baza, pot ataca ținte și pot interacționa cu scenariul de joc într-un mod credibil.

Dintr-o perspectivă istorică, evoluția jocurilor de strategie reflectă progresul tehnic al industriei și maturizarea publicului. Pe măsură ce platformele hardware au devenit mai performante, dezvoltatorii au putut introduce mai multe entități simultane, hărți mai mari, animații mai bogate și sisteme de simulare mai elaborate. Totuși, fundamentul genului a rămas același: un joc de strategie este, în esență, o confruntare între decizii, resurse și timp. Acest fundament este prezent și în proiectul de față, care valorifică simplitatea mecanicilor de bază pentru a construi o experiență funcțională și echilibrată.

În concluzie, studiul evoluției jocurilor de strategie evidențiază faptul că tema aleasă pentru această lucrare este relevantă și actuală. Un proiect RTS bine structurat poate servi drept studiu de caz pentru înțelegerea modului în care sistemele de joc se influențează reciproc și pentru identificarea unui model coerent de dezvoltare a unei aplicații complexe în Godot.

## 1.2 Etapele consacrării genului RTS

Un prim moment important în evoluția jocurilor de strategie a fost apariția titlurilor care au definit formula clasică a genului RTS. Aceste jocuri au consolidat ideea că o bază funcțională, producția de resurse și comanda simultană a unităților pot fi combinate într-un sistem de joc coerent, în care decizia rapidă și planificarea pe termen mediu devin la fel de importante.

În această etapă de consacrare, dezvoltatorii au experimentat cu diverse forme de reprezentare a câmpului de luptă, cu tipuri variate de resurse și cu modalități diferite de control al unităților. Rezultatul a fost apariția unor reguli care s-au repetat apoi în numeroase titluri: construcția bazei, extinderea teritoriului, colectarea resurselor și confruntarea cu adversari controlați de inteligență artificială [1].

Pentru lucrarea de față, această etapă este relevantă deoarece a stabilit fundamentele pe care se sprijină și aplicația realizată: un nucleu central, o logică economică și un sistem de apărare care devine progresiv mai dificil de susținut.

## 1.3 De la formula clasică la jocurile hibride

Pe măsură ce genul s-a maturizat, numeroase jocuri au început să combine strategia în timp real cu mecanici din alte categorii, precum tower defense, supraviețuire, management de bază sau acțiune tactică. Această hibridizare a făcut genul mai accesibil pentru jucătorii noi și a permis dezvoltatorilor să reducă uneori complexitatea controlului, păstrând însă provocarea strategică.

O astfel de orientare a dus la apariția unor experiențe în care centrul jocului nu mai este controlul unui imperiu vast, ci apărarea unei baze, gestionarea unui număr limitat de resurse și reacția la atacuri repetitive. Această tendință este foarte apropiată de structura proiectului implementat, în care accentul cade pe rezistență, organizare și adaptare la valuri de inamici [2].

Din punct de vedere al designului, formulele hibride au demonstrat că genul RTS poate fi restructurat fără să își piardă identitatea. Mai mult, ele au arătat că strategia poate fi prezentată într-o formă mai compactă, adecvată proiectelor cu o durată de dezvoltare mai redusă sau cu obiective de cercetare bine delimitate.

## 1.4 Relevanța actuală a jocurilor de strategie

Tema jocurilor de strategie rămâne relevantă deoarece oferă un mediu excelent pentru integrarea mai multor discipline: programare, design de interacțiune, grafică 2D, inteligență artificială, analiză de sistem și echilibrare a mecanicilor. Spre deosebire de jocurile care se bazează doar pe o secvență de acțiuni prestabilite, un RTS presupune emergența unor situații noi, rezultate din interacțiunea continuă a mecanicilor. Această calitate îl transformă într-un subiect valoros pentru cercetare și implementare.

În plus, proiectele de acest tip sunt utile și din perspectivă educațională. Ele permit exersarea unei game largi de abilități tehnice, de la manipularea obiectelor și a resurselor până la organizarea logicii prin semnale și evenimente. Mai mult, un RTS oferă ocazia de a lucra cu sisteme care trebuie să fie suficient de simple pentru a fi înțelese de jucător, dar suficient de bogate pentru a susține replayability-ul.

Din perspectiva industriei, jocurile de strategie continuă să fie apreciate pentru modul în care recompensează gândirea sistemică. Un jucător de RTS trebuie să observe, să compare, să prioritizeze și să anticipeze. Aceste abilități sunt transferabile și în alte domenii, iar pentru aceasta genul are o valoare aparte nu doar ca divertisment, ci și ca exercițiu cognitiv.

## 1.5 Influențe conceptuale asupra proiectului

Deși proiectul nu urmărește să reproducă un titlu consacrat, el preia anumite principii cunoscute din jocurile de strategie moderne. De exemplu, ideea de bază centrală care produce unități și de valuri succesive de inamici trimite la mecanicile de apărare a bazei întâlnite frecvent în jocurile hibride. În același timp, sistemul de construcție și gestionare a resurselor evocă formula clasică a RTS-urilor bazate pe dezvoltare economică.

O influență conceptuală importantă este și ideea de unități cu roluri distincte. Jocurile de strategie reușite nu oferă de regulă doar soldați generici, ci clase de unități complementare, fiecare cu un avantaj și cu o vulnerabilitate. Această logică a fost integrată și în proiect, unde unitățile jucătorului au funcții diferite și cer o abordare tactică variată.

Un alt element preluat conceptual este accentul pe feedback. Indiferent de complexitatea mecanicilor, un joc de strategie trebuie să comunice clar starea internă a sistemului. Afișarea resurselor, a obiectivelor și a stării bazei este, prin urmare, parte din designul jocului și nu o simplă anexă grafică. Acest principiu a fost urmărit în întreaga implementare.

# Capitolul II. Obiectivele și ipotezele cercetării

## 2.1 Obiectivele generale ale lucrării

Obiectivul general al lucrării constă în proiectarea și implementarea unei aplicații de tip joc de strategie în timp real, în care jucătorul să poată construi o bază funcțională, să administreze resurse, să controleze unități și să apere un obiectiv central în fața unor valuri de inamici. Lucrarea urmărește, prin urmare, atât obținerea unui produs funcțional, cât și demonstrerea posibilității de a construi o arhitectură de joc coerentă în cadrul unui motor modern precum Godot.

Un alt obiectiv general este acela de a evidenția relația dintre teoria jocurilor de strategie și implementarea efectivă a mecanicilor de joc. Din această perspectivă, proiectul nu se limitează la o simplă demonstrație tehnică, ci devine un instrument de analiză a modului în care conceptele de game design se transformă în funcționalități concrete. Astfel, lucrarea îmbină componenta aplicativă cu cea analitică.

## 2.2 Obiective specifice

Pentru a susține obiectivul general, au fost stabilite mai multe obiective specifice. Primul dintre acestea a fost realizarea unui sistem de resurse care să influențeze toate deciziile importante ale jucătorului. În cadrul jocului, resursele nu au doar rol decorativ, ci reprezintă o condiție de posibilitate pentru construcția clădirilor și pentru dezvoltarea bazei.

Al doilea obiectiv specific a fost implementarea unui sistem de construcție a clădirilor pe hartă, cu feedback vizual pentru poziționare și cu reguli de validare a plasării. Acest mecanism este esențial într-un RTS, deoarece baza este elementul prin care jucătorul își organizează apărarea și producția.

Al treilea obiectiv a fost dezvoltarea unor unități controlabile direct de către jucător. Aceste unități trebuie să poată fi selectate, mutate și implicate în luptă, iar comportamentul lor trebuie să fie suficient de clar pentru a permite coordonarea tactică. Totodată, fiecare tip de unitate trebuie să aibă un rol distinct.

Al patrulea obiectiv a fost implementarea unui sistem de valuri de inamici, care să crească progresiv presiunea asupra jucătorului și să îi testeze capacitatea de organizare. Valurile trebuie să fie integrate într-un flux logic al nivelului, astfel încât jocul să alterneze între momente de pregătire și momente de atac.

Al cincilea obiectiv a fost realizarea unei interfețe care să ofere informații relevante, precum timpul rămas până la următorul val, obiectivul curent și starea jocului. O interfață bine construită este importantă mai ales într-un joc de strategie, unde utilizatorul trebuie să proceseze rapid mai multe informații.

Al șaselea obiectiv a fost integrarea unui sistem de salvare a progresului, astfel încât starea curentă a jocului să poată fi păstrată și reluată ulterior. Această funcționalitate transformă aplicația dintr-un simplu prototip într-un sistem cu începutul unei persistențe reale.

## 2.3 Ipotezele cercetării

Pornind de la obiectivele formulate, lucrarea se bazează pe mai multe ipoteze. Prima ipoteză este că un joc RTS 2D poate fi implementat într-un mod eficient în Godot, folosind o arhitectură modulară bazată pe scene, noduri și scripturi GDScript. Această ipoteză pornește de la premisa că motorul oferă instrumentele necesare pentru navigație, animație, audio, interfață și gestionarea resurselor într-un format accesibil.

A doua ipoteză este că separarea clară a responsabilităților între subsisteme îmbunătățește atât calitatea codului, cât și ușurința extinderii ulterioare. Într-un proiect de strategie, unde există multe obiecte care interacționează între ele, o arhitectură bine definită reduce dependențele directe și face sistemul mai ușor de întreținut.

A treia ipoteză este că o combinație de feedback vizual, feedback sonor și mecanici clare de joc crește gradul de înțelegere al utilizatorului și îmbunătățește experiența generală. Prin urmare, animațiile, efectele sonore și elementele UI nu sunt tratate ca adaosuri estetice, ci ca părți integrante ale funcționării jocului.

A patra ipoteză este că un sistem de comportament bazat pe reguli clare de mișcare, atac și evitare a obstacolelor poate susține o experiență de joc credibilă și echilibrată, fără a fi necesară implementarea unor mecanisme avansate de inteligență artificială. În proiect, această ipoteză este susținută prin modul în care inamicii și unitățile reacționează la context, își aleg țintele și își ajustează deplasarea în raport cu situația de pe hartă.

## 2.4 Metodologia de lucru

Metodologia lucrării a fost una iterativă. În prima etapă au fost analizate cerințele generale ale unui joc RTS și au fost identificate mecanicile de bază necesare. În etapa următoare a fost proiectată structura logică a aplicației, cu separarea pe subsisteme. Ulterior a fost realizată implementarea propriu-zisă, fiecare componentă fiind testată și ajustată în funcție de comportamentul observat în joc.

Această metodă a permis nu doar construirea unei aplicații funcționale, ci și rafinarea progresivă a mecanicilor. În special în cazul unui joc de strategie, unde interdependența dintre sisteme este foarte mare, prototiparea și testarea repetată sunt esențiale pentru obținerea unui rezultat coerent.

# Capitolul III. Prezentarea teoretică a aplicației

## 3.1 Conceptul general al aplicației

Aplicația realizată reprezintă un joc de strategie în timp real în care jucătorul are rolul de apărător al unei baze. Acesta pornește de la un nucleu central, sub forma unui castel, și trebuie să construiască treptat clădiri, să genereze unități și să își organizeze apărarea în raport cu presiunea exercitată de valurile de inamici. Ideea principală este aceea de a crea o experiență strategică în care dezvoltarea economică și lupta defensivă sunt interdependente.

Din punct de vedere conceptual, jocul este construit pe ideea de progres prin supraviețuire. Fiecare val de inamici constituie o provocare, iar jucătorul trebuie să își optimizeze resursele pentru a depăși etapa respectivă. În același timp, jocul permite o anumită libertate în organizarea bazei, ceea ce oferă utilizatorului posibilitatea de a adopta stiluri de joc diferite.

## 3.2 Structura gameplay-ului

Gameplay-ul poate fi împărțit în mai multe faze. Prima fază este cea de pregătire, în care jucătorul analizează starea resurselor și decide ce clădiri să ridice. A doua fază este cea de consolidare, în care apar unități noi, iar baza este extinsă și întărită. A treia fază este cea de confruntare, în care valurile de inamici atacă și jucătorul trebuie să își folosească unitățile și clădirile pentru a apăra obiectivele importante.

Această structură creează un ciclu de joc clar și ușor de urmărit. Jucătorul nu este copleșit de toate mecanicile simultan, ci avansează gradual. Din punct de vedere teoretic, această abordare este eficientă deoarece combină accesibilitatea cu profunzimea strategică.

## 3.3 Sistemul economic

Sistemul economic este fundamentul tuturor celorlalte mecanici. În joc există trei resurse principale: aur, lemn și carne. Acestea sunt utilizate pentru construcția de clădiri și pentru anumite acțiuni asociate bazei. Fiecare resursă are o semnificație strategică distinctă, iar echilibrul dintre ele influențează ritmul de dezvoltare.

Aurul poate fi considerat resursa monetară de bază, lemnul reprezintă materialul de construcție, iar carnea este o resursă specială legată de producția sau întreținerea unor unități. Din perspectivă de design, această împărțire este utilă deoarece introduce mai multe niveluri de decizie și împiedică simplificarea excesivă a jocului.

## 3.4 Sistemul de construcție și dezvoltare a bazei

Construcția este una dintre mecanicile centrale ale aplicației. Jucătorul poate amplasa clădiri pe terenul valid, iar fiecare clădire are o funcție proprie. Unele construcții au rol economic, altele rol defensiv, iar altele contribuie la producerea de unități. Procesul de plasare este însoțit de o previzualizare a poziției, astfel încât jucătorul să primească feedback înainte de confirmarea deciziei.

Teoretic, acest sistem oferă două avantaje majore. În primul rând, îl ajută pe jucător să ia decizii spațiale mai bune. În al doilea rând, creează o relație directă între resurse și progresul bazei, ceea ce este caracteristic jocurilor de strategie. În lipsa unei construcții bine integrate, jocul ar pierde din identitatea genului.

## 3.5 Unitățile controlabile

Aplicația include unități care pot fi selectate și comandate direct. Aceste unități sunt concepute pentru a răspunde la comenzile jucătorului și pentru a interacționa cu inamicii în mod autonom atunci când este necesar. Fiecare unitate are un set de atribute proprii, precum viață, viteză, putere de atac și comportament defensiv.

Rolurile unităților sunt diferite. Unele sunt orientate spre atac direct, altele spre susținere sau vindecare, iar altele oferă un echilibru între mobilitate și rezistență. Această diferențiere este importantă, deoarece permite formarea de compoziții tactice și încurajează utilizatorul să gândească în termeni de sinergie, nu doar de număr de unități.

## 3.6 Interacțiunea cu inamicii

Inamicii sunt organizați în valuri și au rolul de a pune presiune asupra bazei. Aceștia urmăresc ținte, se deplasează prin hartă, atacă unități și clădiri și contribuie la crearea unui sentiment de pericol constant. Din punct de vedere teoretic, această presiune este esențială, deoarece obligă jucătorul să ia decizii rapide și să își mențină baza activă.

Comportamentul inamicilor este construit astfel încât să fie suficient de inteligibil, dar și credibil. Ei nu sunt doar elemente decorative, ci participanți activi la sistemul de joc, care influențează ritmul partidei și modul în care jucătorul își organizează apărarea.

## 3.7 Condițiile de reușită și eșec

Un joc de strategie are nevoie de obiective clare pentru a menține interesul jucătorului. În aplicația de față, succesul este asociat cu supraviețuirea și cu îndeplinirea obiectivului final al nivelului, în timp ce eșecul apare atunci când baza nu mai poate rezista și castelul este distrus.

Acest tip de structură este potrivit pentru un RTS de dimensiune medie, deoarece oferă o formă clară de progres și un punct final recognoscibil. În același timp, permite extinderea ulterioară prin adăugarea de niveluri noi, obiective suplimentare sau noi condiții de victorie.

# Capitolul IV. Prezentarea aplicației din punct de vedere tehnologic

## 4.1 Arhitectura generală a sistemului

Arhitectura aplicației este construită pe principiile specifice motorului Godot, adică pe utilizarea scenelor, nodurilor și scripturilor atașate componentelor de joc [3][4]. Această abordare permite organizarea logicii pe module independente și facilitează reutilizarea elementelor. În locul unui cod monolitic, proiectul folosește componente separate pentru nivel, unități, clădiri, efecte, meniuri și sistemul global.

La nivel de proiect, se pot distinge câteva subsisteme principale. Scena nivelului coordonează desfășurarea partidei, afișarea timerului, schimbarea muzicii și verificarea stării globale. Sistemul global păstrează resursele, starea valurilor și informațiile despre progres. Un alt subsistem important este managerul de construcții, care permite plasarea clădirilor în mod valid și controlat. În paralel, sistemul de unități gestionează comportamentul personajelor mobile și interacțiunea cu inamicii.

Un avantaj major al acestei arhitecturi este separarea clară între date globale și comportament local. Valorile precum resursele, numărul de valuri, starea jocului și progresul nivelului sunt păstrate la nivel global, în timp ce fiecare unitate sau clădire are scriptul ei propriu. Această separare reduce complexitatea logică și face codul mai ușor de întreținut.

În proiect, această structură poate fi observată în scriptul [global.gd](/F:/Godot/rts/System/global.gd), unde sunt stocate resursele și valurile, în [global_player.gd](/F:/Godot/rts/System/global_player.gd), unde sunt administrate personajele active ale jucătorului, în [building_manager.gd](/F:/Godot/rts/Unit_buildings/Build%20Manager/building_manager.gd), unde este controlată construcția, și în [castle.gd](/F:/Godot/rts/Unit_buildings/Castle/castle.gd), unde este descris nucleul bazei.

## 4.2 Tehnologii utilizate

### Godot Engine 4

Godot Engine a fost ales pentru dezvoltarea proiectului datorită suportului său puternic pentru jocuri 2D, a modului clar de organizare a scenelor și a flexibilității oferite de sistemul de noduri [3][5][6]. Pentru un proiect RTS, aceste avantaje sunt esențiale, întrucât permit definirea separată a unităților, a clădirilor, a interfeței și a logicii de nivel.

### GDScript

GDScript este limbajul principal folosit pentru implementarea logicii de joc. El este bine integrat în motor și permite o scriere rapidă a codului, ceea ce este util în fazele de prototipare și testare [5]. În proiectul de față, toate subsistemele importante sunt scrise în GDScript.

### Sisteme de mișcare și navigație

Pentru unități și inamici a fost utilizat `NavigationAgent2D`, împreună cu mecanisme de evitare a obstacolelor și de ajustare a traseului [7][10]. Această soluție permite deplasarea credibilă pe hartă și evitarea blocajelor în timpul confruntărilor.

### Interfață și prezentare

Interfața este construită cu ajutorul nodurilor `Control`, al etichetelor și al panourilor vizuale [3][9]. În meniul principal și în HUD sunt folosite elemente de stilizare, fonturi predefinite și adaptare la rezoluție, astfel încât experiența utilizatorului să rămână coerentă indiferent de dimensiunea ferestrei.

### Audio și efecte

Pentru a crește imersiunea, proiectul include muzică de fundal, sunete pentru acțiuni și efecte asociate construcției, atacului și distrugerii [11]. Acestea au rol funcțional, deoarece oferă feedback imediat, dar contribuie și la atmosfera generală a jocului. O parte dintre resursele vizuale și sonore utilizate în proiect au fost preluate gratuit de pe itch.io, ceea ce a ajutat la realizarea rapidă a unui prototip coerent și la menținerea unui stil unitar al prezentării [12].

### Salvare și persistență

Sistemul de salvare utilizează un fișier JSON local pentru a reține datele importante ale jocului. Această decizie este potrivită pentru un proiect de dimensiune medie, deoarece simplifică persistența și permite reluarea progresului fără a introduce mecanisme de stocare mai complexe.

## 4.3 Implementarea sistemului global

Sistemul global este responsabil pentru administrarea resurselor, a valurilor, a stării jocului și a salvării. În practică, acest script funcționează ca o memorie centrală a aplicației. El conține valorile curente pentru aur, lemn și carne, stabilește durata dintre valuri și decide când începe un nou atac.

Un aspect important este folosirea semnalelor. Atunci când începe sau se termină un val, sistemul global emite semnale care pot fi recepționate de alte componente, precum scena nivelului sau anumite obiecte UI. Acest mod de comunicare este preferabil apelurilor directe, deoarece păstrează independența componentelor și facilitează extinderea proiectului.

Tot în acest sistem sunt definite funcțiile de salvare și încărcare. Această alegere este logică, deoarece resursele și progresul sunt date globale care trebuie menținute între sesiuni. Din punct de vedere arhitectural, centralizarea acestor informații este o soluție eficientă.

## 4.4 Implementarea sistemului de construcție

Managerul de construcții are rolul de a gestiona întregul flux de la alegerea unei clădiri până la plasarea sa pe hartă. Când jucătorul selectează o clădire, sistemul generează o versiune de tip „ghost”, care urmărește poziția mouse-ului și este folosită pentru validarea poziției. Dacă terenul este adecvat și resursele sunt suficiente, construcția poate fi confirmată.

În acest mod, jocul oferă un feedback vizual foarte clar. Clădirea previzualizată poate fi colorată diferit în funcție de validitatea plasării, ceea ce reduce erorile utilizatorului și face procesul mai intuitiv. Această abordare este foarte comună în jocurile de strategie și reprezintă o soluție eficientă pentru interacțiunea spațială.

De asemenea, managerul de construcții este capabil să redea o clădire deja existentă într-o poziție nouă. Astfel, jocul poate susține și mecanisme de mutare a structurilor, nu doar de construire inițială. Această funcționalitate sporește flexibilitatea sistemului și îl face mai apropiat de practicile moderne din gen.

## 4.5 Implementarea castelului și a producției

Castelul este elementul central al bazei și una dintre cele mai importante structuri ale jocului. El trece prin mai multe stări: construcție, activ și distrus. În starea activă, castelul poate genera unități și poate reacționa la atacurile inamice. În starea distrusă, jocul se încheie, ceea ce conferă castelului un rol de obiectiv critic.

Din punct de vedere tehnologic, castelul este implementat ca obiect static, cu propriile sale animații, efecte audio și mecanici de interacțiune. El este și un punct de legătură între sistemul economic și sistemul de unități, deoarece produce entități sau resurse în funcție de regulile jocului.

## 4.6 Implementarea unităților și a inamicilor

Unitățile jucătorului și inamicii sunt implementați prin scripturi separate, dar folosesc mecanisme comune precum detecția de vecinătate, mișcarea pe hartă, animațiile și schimbarea stărilor. Această organizare permite definirea clară a rolurilor: unele unități sunt orientate spre atac direct, altele spre susținere, iar inamicii au comportamente centrate pe atacarea bazei și a unităților.

În cazul unităților jucătorului, selecția și comenzile sunt gestionate printr-un sistem de input dedicat. Jucătorul poate selecta una sau mai multe unități și le poate trimite într-o poziție anume. Unitățile folosesc `NavigationAgent2D` pentru deplasare și mecanisme suplimentare pentru evitarea blocajelor, separarea de aliați și alinierea în formație.

Inamicii au, la rândul lor, mecanisme de urmărire a țintei și de atac. În cazul boss-ului goblin, comportamentul este mai complex: acesta poate alege cea mai potrivită țintă, poate menține distanța optimă și poate lansa atacuri speciale. Această diferențiere între unitățile obișnuite și cele de tip boss crește varietatea jocului.

## 4.7 Implementarea meniului și a interfeței

Meniul principal este construit pentru a oferi o experiență clară și coerentă încă de la început. Acesta conține elemente vizuale adaptate la rezoluție, un fundal discret și texte stilizate. Totodată, el include acțiuni simple, precum pornirea jocului sau închiderea aplicației.

În timpul jocului, interfața afișează informații precum timpul până la următorul val, starea obiectivului și mesajele de final de nivel sau game over. Această soluție este importantă deoarece ajută jucătorul să înțeleagă contextul și să ia decizii corecte.

## 4.8 Utilizarea resurselor grafice și sonore

Aplicația se bazează pe resurse vizuale și sonore externe, integrate în proiect și folosite pentru a crea coerență estetică. Sprite-urile pentru unități și clădiri, fonturile utilizate în interfață și fișierele audio pentru acțiuni reprezintă o parte importantă a produsului final.

Din perspectivă tehnologică, integrarea acestor resurse confirmă faptul că un joc nu este doar un ansamblu de reguli, ci și o experiență senzorială completă. Fără feedback vizual și sonor, chiar și cele mai bine concepute mecanici ar fi dificil de perceput și de înțeles de către utilizator.

# Concluzii și propuneri

Realizarea acestui proiect a demonstrat că un joc de strategie în timp real poate fi construit într-o manieră modulară și eficientă folosind motorul Godot. Aplicația include mecanisme esențiale ale genului, precum resurse, construcții, unități controlabile, valuri de inamici, salvare a progresului și condiții clare de reușită sau eșec. Toate aceste elemente formează un sistem coerent, în care fiecare subsistem susține funcționarea întregului joc.

Din punct de vedere al obiectivelor asumate, proiectul și-a atins în mare parte scopurile. A fost realizat un sistem funcțional de resurse, un manager de construcții, o bază centrală cu rol strategic, unități controlabile, inamici care atacă în valuri și o interfață care oferă informații relevante jucătorului. În plus, sistemul de salvare și folosirea semnalelor arată o abordare matură a structurii aplicației.

Lucrarea are și o valoare metodologică, deoarece pune în evidență modul în care conceptele de game design pot fi transpuse într-o implementare concretă. Separarea clară a subsistemelor, folosirea unui limbaj dedicat motorului de joc și integrarea resurselor multimedia demonstrează că dezvoltarea unui RTS nu este doar o problemă de programare, ci și una de organizare, echilibru și claritate a experienței.

În ceea ce privește dezvoltările viitoare, proiectul oferă numeroase direcții de extindere. Poate fi adăugată o varietate mai mare de clădiri și unități, pot fi create niveluri suplimentare cu terenuri diferite, iar AI-ul inamic poate fi rafinat pentru a oferi comportamente mai diverse. De asemenea, pot fi introduse mecanici de upgrade, sisteme de cercetare, obiective secundare, misiuni specializate sau chiar moduri de joc alternative.

O altă direcție de dezvoltare ar putea fi îmbunătățirea sistemului de economie, astfel încât resursele să poată fi produse și consumate într-un mod mai complex. Totodată, sistemul de salvare poate fi extins pentru a păstra mai multe informații despre starea jocului, nu doar resursele și nivelul curent. Într-o etapă ulterioară, jocul ar putea beneficia și de un mod multiplayer, ceea ce i-ar crește semnificativ valoarea strategică.

În concluzie, proiectul realizat își îndeplinește rolul de lucrare de dizertație prin faptul că integrează cercetarea teoretică, designul de joc și implementarea software într-un produs unitar. El demonstrează că un RTS 2D poate fi construit cu succes într-un mediu accesibil precum Godot și poate constitui baza pentru dezvoltări ulterioare mai complexe.

Utilizarea asset-urilor gratuite de pe itch.io a avut un rol important și din perspectivă practică, deoarece a redus timpul necesar producerii de conținut grafic și sonor și a permis orientarea resurselor către mecanicile principale ale jocului [12].

# Bibliografie

1. WIRED. „Age of Empires IV and Real-Time Strategy Games' Rocky History.” Accesat 16 iunie 2026. https://www.wired.com/story/age-of-empires-iv-real-time-strategy-games-history
2. WIRED. „The Fall and Rise of Real-Time Strategy Games.” Accesat 16 iunie 2026. https://www.wired.com/story/fall-and-rise-real-time-strategy-games
3. Godot Engine Documentation. „Godot Docs: Stable Branch.” Accesat 16 iunie 2026. https://docs.godotengine.org/en/stable/
4. Godot Engine Documentation. „Godot Docs: Stable Branch.” Accesat 16 iunie 2026. https://docs.godotengine.org/en/stable/
5. Godot Engine Documentation. „GDScript Basics.” Accesat 16 iunie 2026. https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html
6. Godot Engine Documentation. „Node2D.” Accesat 16 iunie 2026. https://docs.godotengine.org/en/stable/classes/class_node2d.html
7. Godot Engine Documentation. „NavigationAgent2D.” Accesat 16 iunie 2026. https://docs.godotengine.org/en/stable/classes/class_navigationagent2d.html
8. Godot Engine Documentation. „TileMapLayer.” Accesat 16 iunie 2026. https://docs.godotengine.org/en/stable/classes/class_tilemaplayer.html
9. Godot Engine Documentation. „Signals.” Accesat 16 iunie 2026. https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html
10. Godot Engine Documentation. „Using Navigation.” Accesat 16 iunie 2026. https://docs.godotengine.org/en/stable/tutorials/navigation/index.html
11. Godot Engine Documentation. „Audio.” Accesat 16 iunie 2026. https://docs.godotengine.org/en/stable/tutorials/audio/index.html

12. itch.io. „Game Assets.” Accesat 19 iunie 2026. https://itch.io/game-assets

# Anexă. Text extins pentru integrare în capitolele principale

## A1. Jocurile de strategie ca formă de simulare interactivă

Jocurile de strategie pot fi privite nu doar ca produse de divertisment, ci și ca forme de simulare interactivă. În esență, ele modelează sisteme în care resursele, timpul și deciziile sunt interdependente. Această caracteristică le face valoroase în analiza comportamentului decizional, deoarece jucătorul este pus în situația de a evalua simultan opțiuni multiple și de a anticipa consecințele fiecărei alegeri.

În cazul unui RTS, simularea devine și mai interesantă deoarece nu există pauze în desfășurarea proceselor. Resursele sunt colectate, unitățile se mișcă, inamicii atacă și baza trebuie apărată în același timp. De aici rezultă o experiență dinamică, în care jucătorul trebuie să fie atent la mai multe niveluri de informație. Acest aspect justifică utilizarea jocurilor de strategie ca temă de cercetare, întrucât ele oferă un cadru realist pentru studiul reacției umane la sisteme complexe.

## A2. Echilibrul dintre complexitate și accesibilitate

Unul dintre cele mai importante obiective ale designului unui RTS este găsirea echilibrului dintre complexitate și accesibilitate. Dacă jocul este prea simplu, el își pierde profunzimea strategică. Dacă este prea complex, devine greu de înțeles și de jucat. În proiectul de față, acest echilibru a fost urmărit prin păstrarea unui număr clar de resurse și prin definirea unor mecanici ușor de urmărit.

Jucătorul trebuie să înțeleagă rapid ce are de făcut: să construiască, să producă, să apere și să supraviețuiască. Totuși, chiar dacă regulile de bază sunt ușor de urmărit, combinarea lor produce situații strategice interesante. Această combinație între simplitatea regulilor și complexitatea rezultatelor este una dintre cele mai apreciate calități ale jocurilor de strategie bine proiectate.

## A3. Rolul resurselor în structura jocului

Resursele constituie baza aproape tuturor deciziilor importante din joc. Ele funcționează ca o limită, dar și ca un instrument de progres. În momentul în care jucătorul primește o anumită cantitate de aur, lemn sau carne, el este obligat să decidă dacă investește imediat sau dacă păstrează resursele pentru o etapă mai dificilă.

Această decizie are o valoare strategică deoarece, în general, resursele investite într-o direcție nu mai pot fi utilizate în alta. De exemplu, o investiție agresivă în construcții defensive poate oferi siguranță pe termen scurt, dar poate întârzia extinderea bazei. În schimb, o strategie economică prea lentă poate lăsa jucătorul vulnerabil în fața valurilor de inamici. Jocul beneficiază tocmai de această tensiune.

## A4. Clădirile ca elemente funcționale ale bazei

Clădirile nu sunt simple obiecte vizuale, ci unități funcționale care contribuie la ritmul jocului. În proiect, ele pot avea rol economic, defensiv sau de producție. Unele clădiri susțin economia, altele creează unități, iar altele protejează baza în mod direct. Această diversitate permite organizarea bazei ca un sistem viu, nu ca o simplă colecție de sprite-uri.

Procesul de construcție este important și din punct de vedere al experienței utilizatorului. Când jucătorul vede previzualizarea clădirii pe hartă, el poate evalua mai bine dacă poziția este avantajoasă. În plus, feedback-ul de culoare care indică locul valid sau invalid reduce erorile și ajută la o învățare mai rapidă a regulilor de plasare.

## A5. Selectarea și formarea unităților

Unitățile controlabile sunt centrul acțiunii dintr-un RTS. Jucătorul trebuie să poată selecta rapid mai multe unități și să le trimită într-o zonă dorită fără a pierde controlul asupra lor. În proiectul realizat, această nevoie este abordată printr-un sistem de selecție și prin calculul unei formații de deplasare, astfel încât unitățile să nu se suprapună excesiv.

Această alegere are un avantaj dublu. Pe de o parte, îmbunătățește lizibilitatea vizuală, deoarece unitățile se deplasează într-o formă mai ordonată. Pe de altă parte, introduce un comportament tactic mai plauzibil, asemănător cu cel întâlnit în jocurile de strategie consacrate. Unitățile nu sunt doar împinse în aceeași direcție, ci încearcă să mențină o organizare relativ logică în raport cu ținta comandată.

## A6. Designul valurilor de inamici

Sistemul de valuri este o soluție foarte potrivită pentru jocurile de apărare și strategie, deoarece creează o structură naturală a tensiunii. Fiecare val oferă un interval de timp înainte de atac, iar acest interval este folosit de jucător pentru pregătire. Ulterior, odată cu apariția valului, jocul trece într-o fază intensă de apărare și reacție.

Această alternanță are un efect puternic asupra ritmului jocului. Perioadele de liniște relativă permit planificarea, iar perioadele de atac testează eficiența planului. În cadrul proiectului, numărul limitat de valuri creează și un obiectiv clar al nivelului, ceea ce ajută la structurarea experienței.

## A7. Sistemul de salvare ca element de maturitate tehnică

Un joc care include salvarea progresului oferă utilizatorului o experiență mai apropiată de un produs complet. Salvarea este importantă nu doar pentru confort, ci și pentru demonstrarea maturității tehnice a aplicației. Ea arată că jocul nu există doar în timpul sesiunii curente, ci poate conserva o stare și o poate reface ulterior.

Din punct de vedere conceptual, salvarea are și o valoare metodologică. Ea obligă dezvoltatorul să identifice exact ce date sunt esențiale pentru repornirea jocului și ce date sunt temporare. În proiect, salvarea este centrată pe nivel, aur, lemn și carne, deoarece acestea sunt informațiile critice pentru continuarea jocului.

## A8. Arhitectura orientată pe scene și modularitate

Godot încurajează o organizare pe scene și noduri, iar acest aspect a fost valorificat în proiect pentru a crea un sistem modular. Fiecare entitate importantă este separat definită, astfel încât să poată fi reutilizată, modificată și testată independent. Această abordare reduce foarte mult riscul de a introduce erori în părți îndepărtate ale codului atunci când se modifică o mecanică.

Modularitatea este o calitate esențială într-un proiect de strategie, deoarece sistemele sunt numeroase și puternic interdependente. Dacă economia, construcțiile, unitățile și valurile ar fi implementate într-un singur script mare, mentenanța ar deveni rapid dificilă. Prin urmare, alegerea arhitecturii pe module este una justificată atât practic, cât și teoretic.

## A9. Feedback-ul vizual și auditiv

În proiect, feedback-ul vizual și auditiv are un rol mai important decât simpla ornamentare. Când o clădire se construiește, când o unitate este atacată sau când baza intră într-o stare critică, jucătorul trebuie să primească un semnal clar și imediat. Sunetele, animațiile și culorile contribuie la această claritate.

În designul de joc, feedback-ul de calitate scade ambiguitatea și crește satisfacția. Jucătorul simte că jocul reacționează la acțiunile sale și că informațiile importante sunt comunicate suficient de rapid. Într-un RTS, acest lucru este crucial, deoarece de multe ori utilizatorul trebuie să ia decizii în câteva secunde.

## A10. Contribuția proiectului la dezvoltarea personală și academică

Pe lângă valoarea sa tehnică, proiectul are și o componentă formativă. El oferă ocazia de a exersa organizarea unui sistem software complex, de a înțelege mai bine relația dintre design și implementare și de a aplica în practică principii studiate teoretic. Pentru un student, realizarea unui RTS reprezintă o provocare relevantă, deoarece combină multe concepte într-un singur produs.

Din această perspectivă, lucrarea demonstrează nu doar faptul că proiectul funcționează, ci și că procesul de realizare a lui a avut o valoare educațională reală. Este o aplicație care poate fi prezentată atât ca rezultat tehnic, cât și ca studiu de caz pentru înțelegerea dezvoltării de jocuri în Godot.

## A11. Despre proiectarea unităților și diferențierea rolurilor

Într-un joc de strategie, diversitatea unităților este importantă deoarece determină varietatea tacticilor posibile. Dacă toate unitățile ar avea aceleași caracteristici, jocul s-ar reduce la o simplă acumulare numerică și și-ar pierde din profunzime. De aceea, în proiect au fost urmărite diferențe clare între tipurile de unități, fie că este vorba despre viteza de mișcare, rezistență, tipul de atac sau rolul în luptă.

Această diferențiere are și un efect asupra procesului de învățare al jucătorului. Pe măsură ce înțelege specializarea fiecărei unități, utilizatorul își dezvoltă o strategie proprie de utilizare a resurselor și a formațiilor. Unitatea mai robustă poate fi folosită în prima linie, în timp ce unitățile de atac la distanță sau de suport pot fi protejate și plasate în spate. În acest fel, jocul devine mai interesant și mai apropiat de principiile clasice ale RTS-ului.

Din punct de vedere tehnic, fiecare unitate este implementată astfel încât să își poată gestiona propriul ciclu de viață. Ea detectează inamicii, reacționează la comenzi, actualizează animațiile și modifică starea internă în funcție de context. Această autonomie locală reduce dependențele și face codul mai ușor de extins.

## A12. Logica de navigație și evitarea blocajelor

Unul dintre cele mai dificile aspecte tehnice într-un joc cu multe entități mobile este navigația. Dacă unitățile nu se deplasează corect, jocul devine frustrant, iar strategia este înlocuită de probleme de coliziune sau de blocare. De aceea, proiectul folosește sistemul de navigație al motorului împreună cu mecanisme suplimentare de evitare și redirecționare.

În practică, acest lucru înseamnă că unitățile nu merg direct către o țintă într-un mod rigid, ci calculează o cale și o ajustează în funcție de obstacole și de poziția altor entități. Dacă o unitate rămâne blocată, mecanismul de recuperare încearcă să o scoată din situația respectivă printr-o schimbare temporară de direcție. Astfel, se evită situațiile în care entitățile stau inerte într-un punct al hărții.

Această soluție este importantă mai ales într-un RTS, unde pot exista mai multe unități într-o zonă restrânsă. Fără un astfel de sistem, jocul ar pierde fluiditate și ar deveni greu de controlat. Din această cauză, navigația nu este doar o problemă tehnică izolată, ci un element care influențează direct calitatea gameplay-ului.

## A13. Managementul stărilor ca instrument de clarificare a comportamentului

Stările interne ale entităților sunt un instrument fundamental pentru orice joc complex. În loc ca o unitate să reacționeze haotic la fiecare eveniment, ea trece prin stări bine definite, iar fiecare stare limitează și organizează comportamentul posibil. Această logică este prezentă atât la nivel de joc, cât și la nivel de unități și clădiri.

De exemplu, o unitate poate fi inactivă, în mișcare, în luptă, în apărare sau moartă. În fiecare dintre aceste stări, animația, mișcarea și răspunsul la input sunt diferite. Un avantaj major al acestei metode este previzibilitatea. Jucătorul înțelege mai ușor ce poate face unitatea și în ce moment. Totodată, dezvoltatorul poate controla mai bine tranzițiile și poate preveni combinațiile de acțiuni incompatibile.

La nivel de clădire, stările sunt la fel de importante. O construcție nu este doar „prezentă” sau „absentă”, ci poate fi în construcție, activă sau distrusă. Fiecare stare are propriile efecte vizuale și propriile consecințe asupra jocului. Din acest motiv, managementul stărilor contribuie atât la claritatea logică, cât și la coerența vizuală a aplicației.

## A14. Echilibrarea economică și rolul progresiei

Un joc de strategie devine satisfăcător atunci când progresia economică este bine balansată. Dacă resursele se acumulează prea ușor, jocul pierde tensiunea. Dacă sunt prea puține, jucătorul nu poate experimenta suficient și frustrarea crește. În proiect, echilibrul a fost urmărit prin stabilirea unor costuri diferite pentru clădiri și prin limitarea cantității maxime de resurse.

Progresia economică are un impact direct asupra ritmului de joc. În primele momente, jucătorul este obligat să facă alegeri moderate și să construiască treptat. Pe măsură ce avansează, el poate extinde baza și poate adopta strategii mai agresive. Această curbă de progres este importantă deoarece creează senzația de creștere și de control.

Din perspectivă teoretică, progresia bine calibrată este una dintre cele mai puternice motivații dintr-un RTS. Jucătorul simte că fiecare resursă colectată contribuie la ceva concret și că fiecare construcție deschisă îi oferă o nouă opțiune strategică. În lipsa acestei legături între economie și rezultat, jocul ar părea gol și lipsit de sens.

## A15. Interfața ca mediator între sistem și utilizator

Interfața are rolul de a traduce starea internă a jocului într-o formă accesibilă utilizatorului. Într-un sistem complex, jucătorul nu poate observa direct toate variabilele, astfel încât UI-ul trebuie să le sintetizeze și să le prezinte clar. În proiect, timerul, obiectivele, starea nivelului și mesajele importante sunt tocmai astfel de elemente de mediere.

Un design eficient al interfeței trebuie să respecte două principii: lizibilitatea și discreția. Pe de o parte, informațiile trebuie să fie ușor de citit. Pe de altă parte, ele nu trebuie să acopere inutil zona de joc. În aplicația de față, s-a urmărit o prezentare elegantă, cu text clar și cu elemente stilizate, dar fără supraîncărcare vizuală.

Din punct de vedere academic, UI-ul este important deoarece influențează direct percepția utilizatorului asupra calității aplicației. O mecanică bună, dar prost prezentată, este adesea percepută ca fiind mai slabă decât este în realitate. De aceea, interfața nu este un accesoriu, ci un element care face posibilă înțelegerea jocului.

## A16. Observații asupra mecanicii de apărare

Apărarea bazei constituie centrul conflictului în aplicația realizată. Jucătorul nu urmărește o simplă acumulare de resurse, ci trebuie să protejeze o structură esențială împotriva atacurilor repetate. Această situație transformă fiecare decizie de construcție într-o alegere strategică între risc și siguranță.

Mecanica de apărare este susținută de mai multe straturi. La nivel structural, există clădiri care cresc capacitatea de rezistență a bazei. La nivel tactic, există unități care pot interveni direct în luptă. La nivel temporal, există valurile de inamici care obligă jucătorul să își planifice apărarea în avans. Această suprapunere de straturi produce o experiență mai bogată decât un simplu duel individual.

În jocurile de apărare, succesul nu depinde de o singură acțiune decisivă, ci de consistența strategiei. Proiectul urmărește tocmai această idee, făcând ca menținerea bazei și rezistența la valuri să fie mai importante decât acțiunile izolate.

## A17. Calitatea experienței și ritmul de joc

Ritmul este un element esențial în orice joc, dar în special în jocurile de strategie. Dacă momentele de pregătire sunt prea lungi, jocul poate deveni monoton. Dacă atacurile sunt prea dese, jucătorul nu mai are timp să construiască și să planifice. În proiect, alternanța dintre pregătire și atac încearcă să mențină acest echilibru.

Un ritm bun are și un efect emoțional. Jucătorul simte că are timp să se organizeze, apoi este pus sub presiune și trebuie să reacționeze. Această variație între control și urgență este una dintre sursele principale ale satisfacției într-un RTS. De aceea, gestionarea timpului dintre valuri și a duratei confruntărilor este foarte importantă.

În plus, ritmul este susținut și de sunet și animație. Schimbarea muzicii în momentul în care începe un val, de exemplu, transmite imediat că jocul intră într-o fază mai tensionată. Acest tip de sincronizare între sistem și prezentare crește intensitatea experienței.

## A18. Posibile direcții de cercetare și extindere

Lucrarea de față poate constitui punctul de plecare pentru mai multe direcții de cercetare ulterioare. Una dintre cele mai evidente ar fi studiul comportamentului AI într-un context de strategie, prin introducerea unor adversari mai complecși, capabili să adopte tactici diferite în funcție de situație. O altă direcție ar putea fi analiza echilibrului economic și a modului în care costurile și producția influențează deciziile jucătorului.

De asemenea, proiectul ar putea fi extins prin introducerea unei hărți mai mari, a unor mecanici de explorare și a unor obiective secundare. O astfel de extindere ar crește foarte mult profunzimea jocului și ar permite studierea mai atentă a relației dintre strategie și spațiu. În plus, o eventuală componentă multiplayer ar deschide discuții suplimentare despre sincronizare, comunicare și echilibrare competitivă.

Prin urmare, proiectul nu trebuie privit ca un punct final, ci ca o bază solidă pentru îmbunătățiri. Tocmai această capacitate de a fi extins și reinterpretat îi oferă valoare academică și practică.
