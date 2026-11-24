# The Tower Descent

## Bible de conception du jeu

**Version 0.6.0 — Mise en scène du prototype et dossier de production détaillé — 24 novembre 2026**

**Création et direction du projet : Darknigthmare. Dépôt : The-Descents.**

Cette bible développe les notes fondatrices en une campagne de sauvetage et d’horreur à la première personne. Elle décrit l’univers, les personnages, les systèmes, les possibilités du joueur, la progression des étages et les règles de génération. Les noms propres, la chronologie, les révélations et les fins ci-dessous constituent une proposition de canon originale que la direction du projet peut faire évoluer.

Le prototype 3D Godot 0.6.0 conserve un toit jouable et six étages, du 30 au 25, avec rappel, exploration, trois rescapés et un refuge. Les deux tours commencent intactes ; l’effondrement d’Hespérie est observé depuis la baie Est du 29. Bravo se replie vers l’intérieur et les personnes confirmées apparaissent au poste médical du toit. La radio ordonne ses sous-titres, conserve les trente-deux dernières transmissions et peut faire revenir un fragment de Bravo après Samuel. L’ouverture de marque et l’accueil contextuel de la 0.4 sont conservés. La 0.5 anime l’approche des deux appareils, leurs portes et le débarquement des six membres de toit ; elle enrichit les volumes des hélicoptères, des sauveteurs et du littoral. Douze objets examinables donnent une lecture des lieux qui évolue avec l’incident et les réceptions médicales confirmées. La 0.6 rend le portage visible à la première personne, met en scène le panier et le câble du treuil, puis accompagne les personnes reçues jusqu’à l’abri. Elle ajoute un ciel maritime stratifié, une pluie extérieure et des réglages de volume, sensibilité, champ de vision et regard inversé accessibles avant et pendant la partie. Les annexes [Sauvetage](SAUVETAGE_V0.6.md), [Ambiance](AMBIANCE_V0.6.md) et [Confort](CONFORT_V0.6.md) précisent ces contrats. La campagne complète, les personnages et voix définitifs, les souterrains, la coopération et le portage Unreal Engine 5 restent à produire. Le [rapport de livraison](ETAT_DE_LIVRAISON.md) distingue les fonctions vérifiées, les exports et les limites des essais.

Le [Catalogue des étages](CATALOGUE_ETAGES.md) précise les trente niveaux de campagne et leur périmètre jouable. Les dossiers [Effondrement en direct](EFFONDREMENT_EN_DIRECT.md), [Communications et équipes](COMMUNICATIONS_ET_EQUIPES.md), [Props et interactions](PROPS_INTERACTIONS.md), [Ennemis et statistiques](ENNEMIS_STATISTIQUES.md), [Scènes cinématiques](SCENES_CINEMATIQUES.md) et [Gameplay détaillé](GAMEPLAY_DETAILLE.md) complètent cette bible. Les fiches d’objets, rencontres et scènes constituent des spécifications de production, avec des valeurs initiales à éprouver ; leur présence dans le document ne signifie pas qu’elles existent dans le moteur.

## 1 Intention du jeu

Plusieurs équipes de secours arrivent sur les deux tours de luxe encore debout au-dessus d’une île dévastée. Aube et Hespérie sont droites, séparées et visiblement intactes : le joueur découvre des façades continues et deux toits utilisables. Sous les nuages, seuls des morceaux de ville émergent encore. Les hélicoptères déposent les équipes sur les deux bâtiments puis quittent la zone avant la fermeture de la fenêtre météo. Les derniers mots des pilotes annoncent une attente sans durée certaine.

Après le premier sauvetage et le départ des appareils, Alex rejoint la baie Est du 29 pour repérer l’équipe d’Hespérie. Une alerte, une réplique et une rupture se succèdent sous ses yeux : Hespérie bascule partiellement vers Aube et frappe les étages hauts. La scène se déroule dans le monde jouable, avec regard et déplacement libres. Le bâtiment voisin demeure partiellement debout, appuyé sur Aube ; sa nouvelle silhouette, les dégâts et la dégradation des communications persistent. L’opération organisée du début devient une intervention isolée au sein d’un lieu qui vient de changer.

Le joueur doit descendre, reconnaître les étages, trouver les survivants et leur ouvrir un chemin vers le toit. Chaque niveau l’éloigne des voix, des lumières et de l’organisation visibles au départ. Les radios restent longtemps crédibles, puis certaines réponses deviennent trop rapides. Des espaces paraissent avoir souffert d’un autre désastre, bien antérieur à celui de la veille. Le joueur conserve une responsabilité concrète : ramener des personnes vivantes, même lorsqu’il ne sait plus entièrement à qui il parle.

L’identité du jeu repose sur la continuité entre le métier et l’horreur. Le casque, la lampe, le harnais, le marquage des pièces et les appels radio servent d’abord à travailler. Les mêmes gestes deviennent ensuite des moyens de vérifier la réalité. Une corde indique physiquement la direction du retour. Une balise enregistre la position d’un survivant. Un témoin peut confirmer qu’un couloir a changé. L’équipement donne des prises au joueur dans un monde qui commence à lui échapper.

### Promesse au joueur

« Descendre là où personne ne peut plus venir vous chercher, pour que d’autres puissent remonter. »

Le plaisir principal vient d’une décision préparée puis exécutée : repérer un appui, franchir un vide, isoler un danger, rejoindre une voix et transformer une personne perdue en personne sauvée. L’horreur doit compliquer cette décision sans supprimer la compréhension de ce que le joueur peut tenter.

### Fiche de direction

| Élément | Proposition de conception |
|---|---|
| Genre | Aventure de sauvetage, exploration verticale, horreur et survie mesurée |
| Caméra principale | Première personne avec corps, mains et matériel visibles à terme |
| Mode de référence | Campagne solo, présence d’autres équipes dans la fiction |
| Public | Joueurs appréciant l’exploration, la tension et les objectifs humains |
| Plateforme initiale | PC clavier et souris ; manette prévue après validation de la boucle |
| Durée de campagne cible | 8 à 12 heures pour un premier parcours, à confirmer par essais |
| Durée du prototype cible | 10 à 25 minutes selon exploration et maîtrise des commandes |
| Structure | Étages écrits à la main, variations procédurales contrôlées |
| Combat | Défense, détour, éclairage et outils ; vulnérabilité durable du secouriste |
| Progression | Accès, connaissance, confiance, routes de secours et état des personnes |
| Ton | Catastrophe crédible, présence humaine, malaise, horreur souterraine |
| État visuel du prototype | Géométrie de blocage et éclairage d’ambiance ; direction finale distincte |

Les références initiales renseignent des intentions : la tour comme monde vertical, la diversité de ses activités, les opérations de secours dans un bâtiment brisé et un sous-sol qui transforme la lecture du lieu. Elles ne fournissent ni personnages, ni musique, ni décors à reproduire. La bande sonore doit être originale. Le lien de sirène des notes reste une référence d’intention sonore ; aucun enregistrement de cette vidéo n’est réputé intégré au projet.

## 2 Les principes qui gouvernent toutes les décisions

### Le sauvetage reste utile

Un rescapé sauvé n’est jamais révélé rétroactivement comme une fausse personne uniquement pour annuler l’effort du joueur. Des appels peuvent être imités, des silhouettes peuvent être fausses et un interlocuteur peut mentir. En revanche, une évacuation confirmée par le réseau et inscrite au registre reste acquise. Cette règle protège la valeur des choix et évite que l’ambiguïté rende toute action indifférente.

### La verticalité possède un coût lisible

Descendre paraît simple tant que l’on possède une ligne de retour, du matériel et un binôme joignable. Remonter avec un blessé impose de sécuriser des relais. Chaque modification structurelle doit être annoncée par des signes : tension de la ligne, bruit d’un appui, poussière, flèche d’une poutre, réaction d’un survivant. Le jeu peut surprendre le joueur par un événement, mais un système régulier ne doit pas le tuer sans signal exploitable.

### L’inquiétude progresse par contradictions

Les premiers événements ont plusieurs explications. Une porte fermée peut avoir été poussée par la déformation de la tour. Une radio peut capter un enregistrement. Un reflet peut être brouillé par l’eau. Les contradictions deviennent ensuite vérifiables : deux témoins entendent la même phrase, une vidéo montre une pièce qui n’existe plus, une balise apparaît à deux endroits. Les actes suivants introduisent des phénomènes matériels qui ne dépendent plus uniquement de la perception d’Alex.

### Le refuge tient sa promesse

Un refuge certifié est un espace de repos réel. Le joueur peut y sauvegarder, écouter, trier son équipement et reprendre son souffle. Aucun ennemi n’y apparaît à l’improviste, aucune ressource de secours indispensable n’y est empoisonnée et aucune cinématique ne le transforme sans avertissement en piège. Le monde peut être entendu à travers les murs. La sécurité elle-même ne devient pas un mensonge.

### La génération respecte un récit

Le restaurant reste au 30, la baie d’observation de l’effondrement au 29 et le jardin d’enfants au 27. Le choc principal touche les étages hauts 29/28. La liaison basse du 6, encombrée par des dégâts secondaires, demeure un accès futur à Hespérie. La génération choisit les pièces secondaires, certains obstacles et les situations de sauvetage ; elle ne déplace ni l’événement majeur ni son ordre. L’état intact puis l’état après impact sont communs à toutes les graines.

## 3 L’île de Nacre et le complexe Orphée

Nacre est une petite île fictive au large d’un littoral tropical, reliée auparavant au continent par navettes rapides et hélicoptères. Son économie récente s’est construite autour d’une marina, d’un port technique, d’un quartier de commerces, de villas, de jardins suspendus et d’un hôtel résidentiel conçu comme une destination autonome. Les quartiers de personnel et les anciennes infrastructures occupent les parties plus basses, rarement visibles dans les images promotionnelles.

Le complexe Orphée appartient au groupe Pelagos. Il comprend la tour **Aube**, exploitée et occupée, et la tour **Hespérie**, fermée au public à la suite de travaux structurels officiellement interminables. Hespérie accueille encore des personnels techniques ; des signaux à vérifier justifient l’envoi d’une équipe sur son toit. Sa fermeture ne signifie donc pas qu’elle est vide. Les deux tours partagent un socle technique et plusieurs anciennes passerelles de service. Les plans commerciaux montrent des volumes indépendants. Les plans de maintenance révèlent des conduites, des locaux et des niveaux entremêlés.

Aube comporte trente étages de programme principal au-dessus d’un socle et d’une terrasse basse. Hespérie est plus ancienne : ses rénovations successives ont recouvert des espaces entiers sans les démolir. Au début de la mission, les deux volumes sont intacts et aucune tour ne s’appuie sur l’autre. La réplique survenue pendant la descente provoque la rupture partielle d’Hespérie : sa partie haute se déplace vers Aube, frappe la façade des niveaux 29/28 puis s’immobilise contre elle. La partie inférieure reste en place ; le noyau intérieur et le puits utilisés pour les six étages jouables d’Aube conservent une circulation stable. La géométrie après impact prépare des contraintes de campagne, sans prétendre simuler toute la mécanique d’une structure réelle.

### La catastrophe récente

Un typhon a d’abord détruit les protections côtières, inondé les parties basses et isolé Nacre. Un séisme régional distinct, survenu pendant la crise, a ravagé une partie de l’île et provoqué un tsunami qui a aggravé la submersion. Les deux tours ont conservé leur intégrité visible jusqu’à l’arrivée des secours. La nouvelle réplique provoque leur premier effondrement visible pendant la mission. Le typhon n’est pas présenté comme la cause d’un tremblement de terre. L’origine précise de chaque désastre n’est pas une énigme que le joueur doit résoudre pour terminer le jeu.

Au début de la mission, l’eau s’est partiellement retirée mais les défenses et les drainages sont détruits. Le socle, les parkings et plusieurs rues demeurent noyés. Les marées, les nouvelles vagues et les conduites rompues peuvent encore faire varier le niveau dans certains volumes. Tous les étages bas ne sont donc pas uniformément sous l’eau : des niveaux surélevés, des volumes étanches et des poches d’air expliquent les espaces explorables.

L’opération aérienne bénéficie d’une courte accalmie. Le danger annoncé est le retour du vent, la faible visibilité et les débris, non une promesse précise de reprise à une heure fixe. Les deux toits reçoivent les équipes ; Aube accueille le poste médical et le treuil principal. Les itinéraires intérieurs lui ramènent les survivants pour une évacuation aérienne ultérieure. Après le choc, Varga continue d’y confirmer les prises en charge malgré une liaison dégradée. Une personne treuillée et enregistrée au toit reste sauvée.

### Ce qui préexistait au désastre

Les fondations de l’île reposent sur un réseau de cavités et une pierre sombre qui transmet certaines vibrations de façon inhabituelle. Des habitants plus anciens avaient établi une règle pratique : ne jamais répondre à une voix venue d’un puits lorsque personne n’était censé s’y trouver. Cette tradition n’est pas écrite comme une vérité magique universelle ; elle constitue une mémoire locale que Pelagos a choisi de traiter comme une curiosité touristique.

Sous les installations modernes subsiste un établissement abandonné, construit avant les tours : bains, galeries, chambres techniques, abris et bassins d’eau douce. Plus bas encore, un bunker de recherche entoure plusieurs cavités. Les travaux de Pelagos n’ont pas créé ce qui s’y trouve. Ils ont établi des moyens de l’écouter, de l’enregistrer et, finalement, de lui répondre.

## 4 Chronologie et secret central

Les dates relatives permettent de déplacer l’année de l’action sans réécrire les âges des personnages.

| Période | Événement et conséquence narrative |
|---|---|
| Plus de quarante ans avant | Construction des premiers bains et d’une station d’observation géologique ; récits de voix dans les cavités |
| Vingt-deux ans avant | Pelagos rachète l’île et lance la construction d’Orphée ; une partie du personnel historique reste en place |
| Dix-sept ans avant | Ouverture d’Hespérie ; premiers essais d’isolation acoustique révélant des phénomènes reproductibles |
| Onze ans avant | Mise en service d’Aube ; laboratoires et locaux de stockage intégrés au programme hôtelier |
| Huit ans avant | Lancement du programme SILLAGE sous couvert de traitement du stress et de maintenance prédictive |
| Cinq ans avant | Incident dans Hespérie ; disparition de personnels ; fermeture officielle pour travaux |
| Quatorze mois avant | Eva Sorel autorise la reprise de certains essais dans les sous-sols malgré des signaux incompatibles avec les modèles |
| Six semaines avant | Alarmes incohérentes, voix de personnes absentes, consommation électrique nocturne et départs de salariés |
| Deux jours avant | Les équipes tentent d’arrêter SILLAGE ; une procédure d’isolement échoue et des accès sont verrouillés |
| Veille de la mission | Typhon, séisme régional et tsunami ravagent la ville ; les deux tours restent droites et visiblement intactes |
| Jour de la mission, arrivée | Équipes réparties sur les deux toits ; départ des hélicoptères ; premier sauvetage dans Aube |
| Jour de la mission, descente au 29 | Nouvelle réplique, effondrement partiel d’Hespérie vers Aube, impact aux étages hauts ; réseau de secours diminué |
| Jour de la mission, suite | Descente dans le complexe transformé ; plusieurs personnes disparaissent dans des volumes absents des plans |

### Le programme SILLAGE

SILLAGE étudie la persistance de motifs acoustiques et sensoriels dans les matériaux de Nacre. L’objectif commercial annoncé consiste à mesurer l’état d’un bâtiment en comparant ses réponses vibratoires dans le temps. Une branche clinique étudie ensuite la mémoire émotionnelle, officiellement pour traiter les conséquences d’un traumatisme. Pelagos découvre que certains espaces restituent des séquences beaucoup plus complètes qu’un simple enregistrement.

Les chercheurs appellent ces phénomènes des **empreintes**. Une empreinte peut reproduire un bruit, une routine, une silhouette ou le trajet d’une personne. Dans les premières expériences, elle répète. Dans les dernières, elle semble attendre une réponse. L’accident d’Hespérie correspond au moment où une empreinte a cessé de suivre la séquence qu’on lui fournissait.

Pelagos entretient une confusion commode entre anomalie instrumentale, fatigue des employés et défaut de protocole. Ce choix crée une responsabilité humaine claire. Les victimes du programme ne sont pas uniquement des savants imprudents : agents de nettoyage, maintenance, soignants et résidents ont subi des décisions qu’ils ne pouvaient pas évaluer.

### Registre de vérité réservé aux auteurs

| Question | Réponse de conception | Ce que le joueur peut établir |
|---|---|---|
| La catastrophe a-t-elle été provoquée par Pelagos ? | Non. Le groupe a aggravé les risques locaux et caché des dommages antérieurs. | Documents structurels, maintenance différée, chronologie distincte des désastres |
| Toutes les apparitions sont-elles des hallucinations ? | Non. Certaines sont des perceptions altérées ; d’autres laissent une trace matérielle indépendante. | Témoins, balises, objets déplacés et enregistrements croisés |
| Une maladie mentale explique-t-elle le mal ? | Non. Le stress modifie les perceptions, sans servir de diagnostic ou de cause morale. | Alex peut douter sans que la narration le disqualifie |
| Les rescapés confirmés sont-ils réels ? | Oui. Le registre de sauvetage est fiable. | Confirmation par relais et réaction d’autres personnes |
| Alma existe-t-elle ? | Oui. Elle a une histoire, des liens et une trajectoire indépendants d’Alex. | Registre scolaire, objets personnels, témoin vivant, présence avant la chute |
| Que veulent les empreintes ? | Les empreintes simples répètent. Une présence plus profonde apprend à exploiter les réponses humaines. | Différences de comportement entre répétition et adaptation |
| SILLAGE a-t-il inventé la présence ? | Non. Il lui a donné des structures, une énergie et un vocabulaire. | Archives antérieures au programme et motifs identiques dans les cavernes |
| Peut-on comprendre entièrement le niveau 666 ? | Non. Son fonctionnement local est jouable, son origine demeure partiellement ouverte. | Règles observables, retour possible, traces conservées |

La résolution établit les actes de Pelagos et permet de fermer un passage. Elle n’oblige pas le scénario à expliquer chaque apparition par une unique phrase scientifique ou religieuse. Les entités profondes peuvent rappeler l’enfer sans confirmer une cosmologie précise.

## 5 Personnages et équipes

### Alex Morel

Alex est un ou une secouriste spécialisé dans les interventions verticales. Le prénom, le nom d’appel et une voix par défaut permettent d’écrire les dialogues, tandis qu’une personnalisation raisonnable du visage, de la voix et de la présentation peut être ajoutée après le prototype. Le personnage possède une compétence professionnelle réelle dans la fiction, mais aucune connaissance du site ou de son secret.

Son arc n’impose pas un passé traumatique destiné à expliquer l’horreur. Alex commence avec une mission, des habitudes et une confiance dans la coordination. La descente le confronte à des limites : tout vérifier prend du temps, tout sauver seul est impossible, et certaines décisions doivent être partagées. Son évolution consiste à reconstruire une méthode d’action avec les autres, même lorsque le commandement et les plans ne suffisent plus.

### Capitaine Leïla Varga

Varga dirige le poste sur le toit. Sa voix donne des objectifs courts, confirme les sauvetages et reconnaît les incertitudes. Elle ne transforme pas chaque minute de silence en ordre urgent. Elle peut demander un repli et être contredite par des informations que le joueur apporte. Elle ne sait rien du bunker au début.

À mesure que les liaisons se dégradent, le joueur apprend à distinguer son indicatif, son rythme et ses procédures de vérification. Une imitation ne doit pas être démasquée uniquement parce que sa comédienne change de voix : le contenu et la situation doivent fournir des indices accessibles.

### Malik Serra

Malik constitue le binôme de terrain d’Alex dans la campagne. Il est envoyé sur une ligne parallèle pour atteindre une cage d’ascenseur. Ses messages donnent d’abord l’impression d’une opération collective. Les deux itinéraires se croisent et se séparent selon l’état du bâtiment. Son rôle ne consiste pas à ouvrir à distance toutes les portes : il gère ses propres blessés et dépend parfois du joueur.

Son absence peut être inquiètante sans être constamment suspecte. Certaines coupures sont normales. Une scène importante demande au joueur de comparer ce qu’il voit à ce que Malik décrit, puis de trouver une preuve physique de leur position respective. Malik peut survivre ou être perdu selon les routes de secours établies, mais sa perte n’est pas imposée pour fabriquer une motivation.

### Inès Valen

Inès est l’opératrice des communications et de la cartographie de crise. Elle travaille depuis un point de coordination hors de l’île, puis utilise les relais encore disponibles. Elle distingue une donnée fiable d’une estimation et reconnaît lorsqu’un plan est ancien. Ses annotations font évoluer la carte sans donner une connaissance surnaturelle du bâtiment.

Elle introduit la comparaison des horodatages, les appels enregistrés et les codes de vérification. Son conflit dramatique porte sur l’accès aux archives Pelagos : respecter les circuits ordinaires ferait perdre un temps que les survivants n’ont pas. Ses décisions restent centrées sur l’opération, sans la transformer en solution informatique universelle.

### Alma

Alma, dix ans, est la fille d’une employée de maintenance du complexe. Elle connaît des trajets de service et certaines sonneries qu’elle entendait en attendant sa mère. Elle n’est ni une enfant prophète ni une clé biologique obligatoire. Son observation attentive et sa mémoire concrète l’aident à comprendre des détails que les adultes pressés ont négligés.

Elle a été déplacée hors du jardin d’enfants du 27 avant l’arrivée du joueur. Ses traces apparaissent progressivement. Alex la rejoint près du socle au moment où une nouvelle rupture compromet un transfert. Après la chute dans un ancien bassin, une présence l’emporte dans une galerie. La campagne suivante vise à la retrouver et à réunir d’autres personnes isolées ; Alma garde des moyens d’agir, laisse des repères et peut aider Alex au retour.

La mise en scène de ce passage repose sur la séparation et la peur, sans violence graphique dirigée contre elle. Les informations nécessaires pour la retrouver ne dépendent pas d’un cri difficile à entendre.

### Eva Sorel

Sorel dirige la branche SILLAGE de Pelagos. Son discours commence par des explications techniques exactes sur certains phénomènes, ce qui rend ses omissions plus dangereuses. Elle a autorisé la reprise des essais après l’incident d’Hespérie. Elle cherche à récupérer des données et à isoler l’accès profond avant que l’enquête ne les rende publiques.

Elle peut aider concrètement à ouvrir un sas ou à stabiliser un relais. Cette aide ne gomme pas sa responsabilité. Son choix final dépend de ce que le joueur a documenté et de sa capacité à lui retirer les moyens de décider seule. Un discours ne remplace pas les preuves et une confrontation physique n’est pas l’unique issue.

### Les autres équipes

Les groupes de secours possèdent des indicatifs simples : **Corde**, **Médical**, **Échelle** et **Relais**. Corde et Médical s’installent sur Aube, sous le commandement de Varga. Le détachement **Bravo**, qui réunit Échelle et Relais, est déposé sur Hespérie pour localiser les personnels techniques et vérifier les signaux. Deux hélicoptères et des groupes visibles sur chaque toit matérialisent cette répartition dans la maquette 0.6.0 ; Bravo se replie à couvert et les sauvés sont visibles au poste médical. La 0.6 donne des poses de treuil et d’accompagnement à deux membres d’Alpha. Les rencontres détaillées, le portage des caisses, le contact des mains et les animations de travail définitives appartiennent à la production de campagne.

Bravo cesse de répondre lors de l’impact. Le journal porte « liaison perdue », sans déclarer les équipiers morts. Une reprise ambiguë de son indicatif plus bas pourra préparer les phénomènes d’imitation ; elle doit être distinguée d’une confirmation humaine vérifiée. Varga demeure joignable par intermittence et les victimes prises en charge restent au registre. La police sécurisera les zones d’arrivée et les archives dans la campagne lorsqu’elle le pourra.

La population comprend des touristes, des travailleurs, des résidents, des techniciens et des personnes âgées. Le statut social change leurs connaissances et leurs relations, jamais la valeur mécanique d’une vie sauvée. Un salarié peut connaître une galerie utile ; un client peut retrouver la liste d’un groupe ; une personne très blessée peut transmettre un renseignement décisif sans devoir être transformée en objet de quête.

## 6 Déroulement de la campagne

### Acte un Les personnes au-dessus de l’eau

Les deux toits installent la dimension collective : groupes distincts, matériel, météo, rotors et échanges courts. Les façades intactes contrastent avec la ville noyée. La première descente atteint le restaurant du 30 et permet de treuiller Ana. Une fois ce transfert confirmé et les hélicoptères partis, Varga demande une observation de Bravo depuis la baie Est du 29. L’approche et le regard vers Hespérie déclenchent l’événement : avertissement 8 s, réplique 6 s, effondrement 7 s et impact 4 s, puis état permanent après impact. Aucun chronomètre global ne fait s’écrouler la tour pendant que le joueur apprend le rappel ou aide Ana.

Le joueur rejoint ensuite Samuel au 28 dans un environnement qui vient d’être frappé. Le 27 ménage une respiration, puis le spa introduit une menace plus nette. Le refuge du 25 ferme la boucle de sauvetage. La ligne intérieure, les prises en charge et le retour au toit restent utilisables malgré le détour latéral imposé par les dégâts.

Des étages plus bas introduisent les conférences, les commerces, les cuisines et les résidences. Les habitants racontent des versions différentes de la soirée précédant la catastrophe. L’une des équipes retrouve une zone détruite depuis longtemps alors qu’elle figure comme récemment rénovée. À la fin de cet acte, le joueur sait que le désastre visible n’explique pas tout.

### Acte deux Ce que la tour contenait

La partie médiane relie les services du bâtiment, des bureaux condamnés, une clinique, les laboratoires et des archives administratives. Le joueur peut choisir des détours qui améliorent le réseau d’évacuation, sauvent des personnes et rendent les preuves plus solides. Les phénomènes commencent à interagir avec les objets.

Une traversée future d’Hespérie, accessible par la liaison basse du 6 et ses débris secondaires, donne un espace plus ancien, presque privé de communication. Le joueur y voit des tentatives de secours datant de plusieurs années. Le contraste ne doit pas être celui d’un décor gratuit : certaines balises portent des règles encore utiles et les supports techniques expliquent les liaisons entre les tours.

### Acte trois La dernière route vers le toit

Les niveaux bas combinent submersion, coupures de courant, machines bloquées et répliques. Plusieurs routes préparées plus haut deviennent précieuses. La mise en scène de la catastrophe ne remplace pas les décisions de sauvetage : il reste possible de revenir au refuge, de transmettre une liste de personnes et de renoncer à un détour.

Alex retrouve Alma près du niveau 1 et tente de l’amener vers la terrasse intermédiaire. Un grondement profond précède une réplique et la rupture d’un volume de service. La corde amortit une partie de la chute avant la séparation d’un appui. Alex et Alma tombent dans un ancien bassin enfoui. La scène est écrite, annoncée et non simulée comme un accident arbitraire de la commande de rappel.

Quand Alex reprend conscience, la route supérieure est condamnée. Une silhouette emporte Alma vers les galeries. Le joueur conserve sa lampe, une radio endommagée et une partie de l’équipement ; il récupère rapidement le minimum nécessaire pour agir. Les rescapés déjà transférés au réseau supérieur restent sauvés.

### Acte quatre Sous le nom de la ville

Les anciens bains, les cavernes et le bunker montrent les différentes couches d’occupation de Nacre. Des survivants de la crise récente et des personnes retenues par le programme peuvent encore être retrouvés. Les traces d’Alma fournissent un fil concret. L’objectif n’est pas de tuer une hiérarchie de monstres, mais de reconstituer une route de retour et de couper le mécanisme qui entretient le passage.

Le dernier espace est désigné **666** par un ancien système de repérage SILLAGE : puits 6, boucle 6, seuil 6. Les interfaces ont concaténé ces trois valeurs. À proximité, les numéros d’étage se répètent ou deviennent incohérents. Il ne s’agit pas de six cent soixante-six niveaux à produire ni d’un ascenseur qui descend arbitrairement de plusieurs kilomètres.

Dans cette profondeur, des fragments d’espaces déjà traversés se réassemblent selon une logique de réponse. Le joueur reconnaît le restaurant, le jardin d’enfants ou un refuge, mais seul le refuge réel possède la signature physique et les confirmations apprises. Un espace imité ne porte jamais le statut de refuge certifié dans l’interface.

### Épilogue

Une route technique permet de rejoindre une ouverture plus éloignée des tours. L’accalmie peut enfin rendre possible l’évacuation. Les personnes sauvées, les relais établis, les preuves sorties et le traitement du seuil déterminent l’épilogue. Une vue de l’île au matin montre les tours à distance et donne un sens aux chemins parcourus.

## 7 Fins et conséquences

Les fins reposent sur des états enregistrés, pas sur une réponse finale isolée. Les variables principales sont le nombre de personnes prises en charge, les pertes évitables, les relais fonctionnels, la survie d’Alma et de Malik, les preuves indépendantes et l’état du seuil. Une fin ne doit pas exiger de ramasser tous les objets pour être humainement satisfaisante.

| Fin | Conditions de principe | Résultat |
|---|---|---|
| Le jour revient | Alma retrouvée, route de retour viable, seuil isolé, preuves suffisantes | Évacuation et enquête indépendante ; les témoignages concordent malgré des zones d’ombre |
| Ceux qui remontent | Priorité aux survivants et évacuation obtenue, preuves incomplètes | Des vies sont sauvées ; Pelagos contrôle encore une partie du récit public |
| La porte fermée | Isolement du seuil accompli avec coût majeur ou retour d’Alex impossible | Les autres peuvent sortir ; un témoignage ou un enregistrement porte les conséquences du choix |
| Une voix de plus | Réseau livré à SILLAGE, séparation non résolue et seuil maintenu | Évacuation apparente ou relais relancé ; une réponse impossible révèle que la présence voyage encore |

Les conditions exactes doivent rester auditables dans les outils de développement. Le joueur voit les conséquences et les témoignages, sans devoir lire un score caché. La fin sombre n’est pas la punition d’une option d’accessibilité, d’une difficulté réduite ou d’un temps de pause élevé.

Un retour anticipé au toit constitue un repli de mission jouable et sauvegardable, pas automatiquement un générique définitif. Le joueur peut se rééquiper et repartir tant que l’acte narratif l’autorise. La fermeture après la chute fait l’objet d’un point de sauvegarde distinct qui conserve aussi l’état d’avant la rupture.

## 8 La boucle de jeu

Chaque étage organise une petite opération complète : **observer, sécuriser, rejoindre, vérifier, aider, transmettre, reprendre la descente**. Le joueur aperçoit une destination et un problème avant d’avoir la solution. Un appel, une lumière de secours ou une silhouette fournit un objectif ; la carte et les instruments permettent de le situer.

La première reconnaissance répond à trois questions : où peut-on marcher, que risque-t-on à traverser, et comment revenir avec quelqu’un ? La sécurisation peut consister à établir un ancrage, couper une alimentation locale, déplacer un obstacle simple, utiliser un extincteur, poser une balise ou ouvrir une porte de service.

Une fois la personne rejointe, le joueur évalue ses possibilités dans un dialogue court. Certaines peuvent marcher. D’autres nécessitent un accompagnement, une stabilisation abstraite ou l’installation d’un point de transfert. La fin de l’opération est une confirmation par un relais, visible et audible. Le journal conserve le nom, le lieu et l’état.

Le joueur peut passer un étage provisoirement. La carte indique les zones non vérifiées et les personnes localisées. Les urgences scriptées doivent être explicites ; le jeu n’active pas en secret un chronomètre mortel à l’entrée de chaque niveau. Cette règle permet d’explorer sans nier le contexte de crise.

### Actions permanentes

À terme, Alex marche, court brièvement, s’accroupit, franchit de petits obstacles, saute dans des limites réalistes pour l’équipement, s’accroche, descend et remonte en rappel. Il peut examiner, déplacer un objet léger, ouvrir, marquer, appeler, rassurer et utiliser un outil. Les actions dépendent de la position, de l’encombrement et de la situation du harnais.

Les grands franchissements sont préparés et lisibles. Le jeu ne demande pas une succession de sauts précis au-dessus du vide avec un blessé sur le dos. La compétence vient de la lecture du lieu, de la gestion d’une ligne et du choix d’une route.

## 9 Le rappel et les points d’appui

La corde constitue un système de déplacement et un élément visuel central. Le joueur voit la ligne, son point de départ et les changements de direction. Au début, elle relie directement au toit. Plus bas, les relais créent une chaîne de segments dont l’état peut être consulté.

Le prototype teste une descente contrôlée dans un axe vertical avec balancement latéral limité. La campagne pourra ajouter des franchissements obliques, des changements de ligne et des transferts de personnes. Le modèle physique doit privilégier une commande prévisible, compatible avec le clavier et les options contre le mal des transports.

### États de déplacement proposés

| État | Action du joueur | Limite et retour visuel |
|---|---|---|
| Au sol | Marcher, courir, s’accroupir, examiner | Vitesse réduite en portant du matériel ou en accompagnant |
| Préparation | Choisir un point utilisable et connecter la ligne | Validation claire de la surface et du trajet |
| En suspension | Descendre, remonter, freiner, se décaler | Longueur, angle et vitesse représentés sans encombrer l’écran |
| En appui | Stabiliser contre une paroi ou une plateforme | Mouvement amorti ; accès à certaines interactions |
| Changement de relais | Confirmer le nouveau segment | Transition protégée ; aucune rupture par un double clic accidentel |
| Accompagnement | Guider une personne vers un relais sécurisé | Limitation de vitesse et surveillance de sa progression |

Les ancrages fixes du bâtiment ne consomment pas d’objet. Un point improvisé utilise un consommable de jeu et exige une surface marquée comme adaptée par le système. Une façade décorative ne devient pas un appui valable uniquement parce que le joueur possède un piton. Les limites de simulation sont assumées : les valeurs d’effort et la pose sont des abstractions, pas un tutoriel d’intervention réelle.

Un indicateur de tension signale une combinaison défavorable d’angle, de mouvement ou d’appui. Les premières occurrences enseignent la correction. La rupture d’une ligne pour cause de ressource manquante ne peut survenir si la génération a rendu obligatoire une dépense supérieure au matériel accessible.

La progression conserve toujours un trajet sûr vers le dernier refuge pendant les actes supérieurs, sauf événement narratif annoncé. Les grands changements structurels possèdent une sauvegarde préalable et une solution secondaire validée. Après la chute, le nouveau réseau de retour est reconstruit dans un autre espace.

## 10 Équipement et ressources

L’inventaire distingue le matériel permanent et les consommables. Les objets permanents définissent les verbes du jeu ; leur disparition ne doit pas supprimer durablement une action indispensable. Les consommables permettent des solutions plus rapides, plus sûres ou plus discrètes. Les objets de preuve ne prennent pas la place d’un équipement de survie dans une grille punitive.

| Matériel | Utilité de conception | Coût ou limite | Lecture dans l’interface |
|---|---|---|---|
| Lampe de casque | Lire les pièces et les marquages | Éclairage orienté ; panne ponctuelle écrite, évitable dans les modes confort | Faisceau, témoin, réglage d’intensité |
| Radio | Appels, confirmation, triangulation narrative | Portée dépendant des relais ; messages mémorisables | Indicatif, horodatage, transcription |
| Harnais et corde | Descente, remontée et ligne de retour | Distance et état des appuis | Segment actif et prochain point sûr |
| Ancrages consommables | Créer un relais autorisé | Stock limité ; alternative garantie sur route principale | Nombre et prévisualisation |
| Hache de secours | Dégager une ouverture légère et se défendre | Temps, bruit, matériaux compatibles | Icône d’action et durée prévue |
| Extincteur | Franchir un foyer limité, dégager une visibilité | Charge ; incapable d’éteindre tout incendie | Charge et zone d’effet |
| Fusée de signalisation | Éclairer, attirer un regard, repousser certaines présences | Usage unique et durée courte | Halo, minuterie discrète |
| Pistolet de détresse | Signaler au loin et interagir avec certains obstacles | Munitions rares ; pas une arme principale | Visée et nombre de cartouches |
| Bouteille respiratoire | Traverser fumées et zones d’air impropre | Autonomie compressée pour le jeu ; gestion par zone | Réserve en pourcentage clairement nommée |
| Détecteur d’atmosphère | Alerte d’environnement dangereux | Mesure locale, délai court | État sûr, douteux ou dangereux avec texte |
| Télémètre | Évaluer une traversée et vérifier une distance impossible | Ligne de vue et surfaces compatibles | Distance et stabilité de lecture |
| Balise | Marquer un refuge, un rescapé ou une anomalie | Stock ; récupération sur certains supports | Identifiant, couleur et dernier statut |
| Kit de secours | Stabilisation abstraite d’un blessé | Stock lié aux situations annoncées | Progression et résultat, sans gestes médicaux détaillés |
| Marqueur | Pièces fouillées et sens de circulation | Usage illimité ou stock non contraignant | Signes cohérents visibles dans le monde |

La jauge respiratoire indique la réserve de la bouteille, pas le pourcentage d’oxygène contenu dans l’air. Une autre lecture traite l’atmosphère. Le jeu ne confond pas essoufflement, stress et manque d’oxygène. Les zones sûres suspendent les dépenses de survie et offrent les moyens de repartir.

Le prototype peut regrouper certains outils sous des interactions simples. Le périmètre réel doit alors être indiqué dans sa notice : une action « sécuriser » ne prouve pas que tout le système d’extincteur, de respiration et de transport a été produit.

## 11 Les survivants comme personnes

Les survivants possèdent un nom, une raison d’être là, un objectif immédiat, une mobilité, une information utile éventuelle et une réaction après prise en charge. Une courte variation de dialogue apporte plus qu’une longue série de personnages interchangeables.

La valeur d’un sauvetage n’est pas mesurée par le nombre de points de prestige obtenus. Le résultat apparaît dans les refuges, les communications et l’épilogue : un cuisinier prépare de l’eau chaude, une technicienne rétablit un éclairage, une famille se retrouve, une personne refuse de quitter le lieu tant qu’un proche manque. Ces conséquences donnent du poids à l’exploration.

### États logiques de sauvetage

1. **Signalé** : une source fiable ou incertaine indique une présence.
2. **Localisé** : le joueur voit ou confirme la personne.
3. **Contact établi** : la personne répond et ses besoins sont compris.
4. **Stabilisé** : le danger immédiat est traité par une action abstraite.
5. **Route sécurisée** : le trajet vers le relais est utilisable.
6. **En transfert** : la personne rejoint le point sûr ou y est acheminée.
7. **Prise en charge confirmée** : le relais accuse réception et le registre est mis à jour.

Les étapes peuvent être condensées pour une personne autonome et détaillées pour une scène principale. La campagne doit montrer au moins quelques transferts complets pour rendre crédibles les transferts ensuite résumés. Le prototype peut utiliser une confirmation par balise et relais ; sa notice doit parler de ce transfert abstrait, pas d’une simulation complète d’évacuation par corde.

### Situations réutilisables

Une personne bloque sur un passage transparent. Une autre protège un collègue et refuse de bouger sans nouvelle. Un touriste ne comprend pas la langue d’Alex, mais suit des gestes et une lumière. Un technicien blessé peut décrire un circuit. Une personne entend une voix qui lui promet un trajet plus court. Un secouriste isolé connaît les procédures, mais a perdu sa radio.

Les dialogues de réassurance proposent des informations sincères. Le joueur peut dire qu’il a établi une route, qu’un relais attend ou qu’il ne sait pas encore quand les hélicoptères reviendront. Une fausse promesse ne devient pas systématiquement la meilleure option chiffrée.

## 12 Stress et perception

Le stress traduit une pression momentanée : effort, visibilité réduite, proximité d’une menace ou séparation. Il peut modifier le souffle, la stabilité de la lampe, certains sons internes et la précision d’une interaction. Il ne doit pas empêcher arbitrairement le joueur de marcher ou de répondre à une commande.

Un repos au refuge, une communication vérifiée, une action de sauvetage réussie et une zone bien éclairée diminuent cette pression. Le jeu récompense la méthode et les liens humains. Il évite un système où la vue d’une créature retire mécaniquement une « santé mentale » qui déterminerait la moralité du personnage.

Les manifestations perceptives sont de trois familles. Les **erreurs ordinaires** proviennent du bruit, de la fatigue ou de reflets. Les **empreintes** restituent un événement antérieur. Les **intrusions** adaptent leur comportement à la présence du joueur. L’interface ne révèle pas immédiatement la famille, mais chaque cas possède des indices vérifiables.

### Vérifier une apparition

Le joueur peut comparer le son à un message archivé, regarder une balise, demander à un témoin, marquer un mur, mesurer une distance ou revoir la pièce depuis une autre ouverture. Aucun test ne résout tout. Une empreinte peut être visible sur un appareil ; une intrusion peut manipuler un objet. Le sens vient de plusieurs observations concordantes.

Les options de confort conservent les informations utiles. Désactiver les acouphènes, les secousses ou les flashes remplace ces signaux par du texte, une animation lente ou une indication visuelle stable. Un joueur malentendant doit pouvoir comprendre qu’une réponse radio précède l’appel qui la provoque.

## 13 Présences et adversaires

Le bestiaire définit des comportements avant des silhouettes. Les premières rencontres ne commencent pas par une jauge de vie. L’objectif est d’observer une règle, de préparer une action puis de traverser ou de protéger quelqu’un.

| Présence | Apparence et rôle | Règle observable | Contrejeu | Limite de fréquence |
|---|---|---|---|---|
| La Rémanence | Personne répétant une routine à travers une pièce détruite | Rejoue une séquence fixe et ne poursuit pas | Attendre, suivre à distance, comparer les traces | Introduite avant les menaces physiques |
| Le Répondant | Voix de secours ou d’un proche à la radio | Répond sans connaître un détail récent vérifié | Code contextuel, coupure volontaire, relais authentifié | Jamais sur chaque appel |
| Le Noyé sec | Silhouette humaine couverte de dépôts dans un espace pourtant sec | Se rapproche pendant un bruit continu masquant ses pas | Arrêter une machine, écouter, éclairer un passage | Un foyer actif à la fois |
| Le Porteur | Grande forme ramassée qui déplace des personnes ou objets | Évite la lumière directe persistante, protège certains seuils | Deux sources coordonnées, détour, porte lourde | Rencontre scénarisée puis rares reprises |
| Les Veilleurs | Silhouettes liées aux postes d’observation SILLAGE | Réagissent à une émission active, pas à tout mouvement | Couper la radio, poser un leurre, traverser dans le silence | Exclus des refuges certifiés |
| Les Creuseurs | Faune cavernicole altérée, basse et rapide | Défend des nids et suit vibrations au sol | Passer haut, ralentir, détourner par un objet | Zones identifiées par traces |
| Les Déliés | Victimes transformées, encore sensibles à certains repères humains | Alternent agitation et reconnaissance | Distance, appel nommé, passage protégé | Aucune exécution obligatoire |
| Le Contremaître | Ancien responsable de la zone technique pris dans une répétition | Vérifie des circuits selon un trajet annoncé | Comprendre sa ronde et lui rendre une séquence inoffensive | Une séquence importante |
| La Chambre qui écoute | Menace spatiale, sans corps unique | Réplique les réponses et modifie les sorties non surveillées | Marquage, témoins, balises et silence coordonné | Réservée aux profondeurs |
| Le Chœur bas | Présence finale faite de fragments et d’appels superposés | Maintient le seuil grâce aux relais qui lui répondent | Couper ou détourner les liaisons dans un ordre déduit | Un finale en plusieurs objectifs |

Les personnes mutilées des notes deviennent des victimes identifiables et des présences tragiques, pas une collection décorative de corps. Les niveaux d’explicite peuvent être réglés. Les animaux cavernicoles conservent un comportement territorial compréhensible avant leurs variantes anormales.

### Défense et échec

Une hache repousse et interrompt ; une fusée crée un délai ; un extincteur masque ou ouvre une route ; une porte ralentit. Ces actions ont une utilité concrète, mais ne permettent pas de nettoyer toute la tour. Les menaces majeures se résolvent par une modification de la situation.

Une première erreur donne un coût lisible : perte de position, chute amortie, lampe désaxée, blessure légère ou besoin de repli. Les échecs mortels restent possibles selon la difficulté, mais leurs causes doivent être compréhensibles au retour au checkpoint. Un survivant ne meurt pas à cause d’un blocage de navigation de l’IA ; le système doit le repositionner ou suspendre la menace en cas d’erreur technique.

## 14 Génération procédurale contrôlée

La campagne possède une colonne vertébrale écrite. Chaque étage a une fonction d’origine, un volume principal reconnaissable, une scène, un indice éventuel et une transition. La génération choisit à l’intérieur de ce cadre. Une graine et une version de générateur permettent de reproduire le même parcours.

### Structure d’un étage

Un étage est un graphe de pièces et de passages. Ses nœuds minimaux sont l’arrivée, un point de lecture, un objectif ou une exploration optionnelle, une sortie et, lorsque nécessaire, un relais de retour. Les arêtes possèdent des conditions : passage libre, étroit, enfumé, verrouillé, vertical ou escortable. Le graphe logique est validé avant la mise en place des décorations.

Les modules portent des étiquettes de thème, dimensions, danger, intensité et compatibilité. Une chambre de suite ne devient pas un laboratoire sans raison narrative. Une salle sèche ne contient pas un danger électrique de submersion si aucune source d’eau ne l’explique. Un obstacle qui requiert un outil ne peut apparaître sur le seul trajet si cet outil est absent.

### Ordre de génération

1. Charger la graine, la version du catalogue, la difficulté et les événements déjà joués.
2. Placer les niveaux narratifs obligatoires et les refuges.
3. Choisir un plan compatible avec chaque thème et connecter arrivée, objectif et sortie.
4. Placer les dangers dont les prérequis sont disponibles.
5. Placer les survivants et vérifier leur chemin de transfert.
6. Distribuer les ressources en tenant compte des dépenses minimales du chemin principal.
7. Choisir les événements secondaires compatibles avec le rythme et les indices déjà acquis.
8. Ajouter mobilier, traces et variations esthétiques sans couper les volumes de navigation.
9. Valider le trajet, le budget de ressources, les collisions essentielles et les exclusions de refuge.
10. En cas d’échec, revenir à un plan de secours connu, jamais à une boucle infinie de tirages.

### Invariants de génération

La sortie reste atteignable depuis l’arrivée. Un rescapé obligatoire possède un itinéraire vers un relais. Deux dangers ne bloquent pas simultanément les deux seules issues. Une ressource indispensable est disponible avant son coût obligatoire. Un refuge certifié demeure accessible depuis son palier et ne reçoit aucun ennemi. L’indice qui permet de comprendre une règle apparaît avant son épreuve la plus sévère.

Les sauvegardes enregistrent les décisions de génération et les modifications du joueur. Charger une partie ne change pas les portes, les victimes ou les ressources parce qu’un nouveau tirage a eu lieu. Le catalogue versionné protège cette stabilité lors des mises à jour ; une sauvegarde incompatible doit être détectée et expliquée.

### Intensité et respiration

Le directeur de tension suit une fenêtre de plusieurs minutes et ne cherche pas constamment le maximum. Il choisit entre récupération, anticipation, incident et conséquence. Un gros sauvetage peut être suivi d’une pièce vide, d’un paysage ou d’un message humain. Deux rencontres longues ne se suivent pas sans possibilité de refaire le point.

La règle des notes « une entité, une zone sûre, une personne, rien ou un événement » devient une table de composition. Chaque étage possède un rôle dominant, mais peut combiner un objectif humain et un événement discret. Tous les étages ne contiennent pas un monstre. Une pièce vide peut porter une information ou donner de l’espace à l’écoute.

| Rôle dominant | Objectif du rythme | Contenu autorisé |
|---|---|---|
| Sauvetage | Investissement humain et maîtrise des outils | Personne, obstacle lisible, transfert confirmé |
| Traversée | Verticalité et lecture structurelle | Vide, machines, itinéraire et point de repos |
| Enquête | Comprendre le lieu et ses décisions | Documents, témoins, traces comparables |
| Anomalie | Mettre une règle en doute | Un phénomène principal avec contre-indices |
| Menace | Mettre en pratique une règle apprise | Adversaire, détour et issue claire |
| Refuge | Reprendre des forces et constater les résultats | Sauvegarde, radio, ravitaillement, dialogues |
| Silence | Réintroduire l’incertitude | Paysage, bruit lointain, traces sans attaque |

### Contrat de données proposé

Chaque entrée d’étage porte un identifiant stable, un numéro affiché, un thème, un acte, les variantes autorisées, les modules d’arrivée et de sortie, les objectifs, les personnes, les indices, les dangers et les invariants. Les valeurs d’équilibrage restent des données. Les scripts n’ont pas à connaître la biographie complète d’un personnage pour décider si une porte est franchissable.

Pour le prototype, un sous-ensemble de ce contrat suffit. Les six fonctions d’étage sont fixes ; la graine peut choisir des dispositions de mobilier, une position de ressource ou des détails. Il faut mesurer cette variation réellement produite avant de présenter le prototype comme une campagne procédurale complète.

## 15 Catalogue d’événements

La plupart de ces événements sont des modules de campagne proposés. Une entrée est sélectionnée selon son contexte, ses prérequis et le temps de récupération disponible. L’effondrement observé au 29, introduit en 0.2 et conservé en 0.5.0, constitue l’événement fixe du prototype ; sa présence ne dépend pas d’un tirage aléatoire. Le [dossier de séquence](EFFONDREMENT_EN_DIRECT.md) distingue son implémentation en maquette des enrichissements cinématiques futurs.

| Événement | Conditions | Action et information offertes au joueur |
|---|---|---|
| La dernière rotation | Début sur le toit | Suivre du regard le départ des appareils et recevoir l’interdiction temporaire de vol |
| Une table pour demain | Restaurant, acte un | Trouver des préparatifs plus récents que la fermeture annoncée |
| Le verre qui voyage | Sol légèrement incliné | Observer un objet rouler avant une déformation plus importante |
| Appel au mauvais indicatif | Radio stable, après tutoriel | Vérifier l’interlocuteur par un détail connu |
| Chambre occupée vide | Suites, avant première intrusion | Comparer le registre et les effets personnels sans attaque automatique |
| Le jouet interrompu | Jardin d’enfants évacué | Couper une source sonore et constater qu’un second son continue |
| Deux ombres pour une lampe | Zone d’anomalie modérée | Changer l’angle de lumière ; l’ombre indépendante fournit une direction |
| L’étage dans le reflet | Surface d’eau ou verre | Voir un état antérieur qui révèle une ouverture de service |
| Palier sous tension | Réseau électrique lisible | Isoler un circuit local et créer un passage escortable |
| Faux cri sous la gaine | Indice d’imitation déjà disponible | Envoyer une balise ou attendre une réponse cohérente |
| La porte qui respire | Proximité d’une cavité | Lire les variations de pression et ouvrir pendant la phase sûre |
| La liste incomplète | Archives | Recouper des noms avec les personnes rencontrées |
| Trois coups | Contact humain vérifié à proximité | Répondre selon un code simple puis rejoindre la personne |
| Hespérie bascule | Ana treuillée, hélicoptères partis, approche de la baie Est du 29, regard maintenu ou confirmation avec E | Alerte, réplique, rupture et impact en temps réel ; commandes libres ; détour latéral et nouvelle silhouette persistants |
| La rupture du socle | Campagne, après retrouvailles avec Alma | Préparer le transfert puis vivre la chute vers le bassin ; événement distinct du choc du 29 |
| La pièce trop longue | Après usage du télémètre enseigné | Mesurer depuis deux repères et sortir par un marquage stable |
| Lumière dans Hespérie | Avant traversée annexe | Choisir d’examiner la source ou d’enregistrer sa position |
| L’appel d’hier | Enregistrement horodaté disponible | Comparer deux messages et identifier une empreinte |
| Le survivant qui entend autrement | PNJ accompagné | Confronter les descriptions sans désigner arbitrairement un menteur |
| Retour de couverture | Près d’un refuge | Entendre les confirmations des personnes déjà prises en charge |
| Le bassin silencieux | Après la chute | Retrouver l’équipement et les repères laissés par Alma |
| La ronde du Contremaître | Bunker, après observation | Modifier un circuit pour détourner une répétition dangereuse |
| Le relais de trop | Acte final | Identifier une émission qui entretient la présence et choisir de la couper |
| Le nom dans le chœur | Preuves d’identité réunies | Isoler une voix humaine et atteindre une personne encore récupérable |
| Le premier vent calme | Épilogue | Reconnaître une amélioration météo sans annoncer trop tôt l’évacuation |

Une même graine ne répète pas trois fois le même effet de radio. Les événements d’information importante restent consultables après la scène. Les dialogues interrompus par une action urgente sont reportés dans le journal plutôt que perdus.

## 16 Espaces et modules de production

La tour doit paraître habitée avant de paraître hantée. Les modules conservent des indices de fonction : chemin des serveurs au restaurant, linge dans les suites, traces d’attente aux conférences, équipements à hauteur d’enfant au jardin, gaines et accès techniques derrière le luxe. La destruction respecte ces usages et révèle ce qu’ils cachaient.

### Familles modulaires

| Famille | Modules de base | Variations qui changent le jeu |
|---|---|---|
| Noyau vertical | Palier, gaine, cage d’escalier, local coupe-feu | Trémie ouverte, cabine bloquée, relais, passerelle décalée |
| Luxe public | Restaurant, salon, hall, exposition, boutique | Vitrage rompu, mobilier déplacé, éclairage secouru |
| Hôtel | Chambre, salle de bains, couloir, lingerie | Porte coincée, chambre communicante, passage par balcon |
| Travail | Bureau fermé, espace ouvert, archives, salle de réunion | Cloisons déplacées, dossiers accessibles, alimentation isolable |
| Famille et soins | Jardin d’enfants, salle calme, infirmerie, dortoir | Repères personnels, lits transportables, traces d’évacuation |
| Eau et loisirs | Spa, piscine, vestiaires, salle de sport | Niveau d’eau, courant coupé, fenêtre vers l’extérieur |
| Service | Cuisine, réserve, atelier, ventilation, local réseau | Machine bloquée, conduit étroit, point de ravitaillement |
| Hespérie | Chambre ancienne, couloir condamné, cage inclinée | Vieille signalétique, traces d’incident, appuis décalés |
| Sous-sol | Parking, quai, filtration, citerne, galerie | Submersion, sas, pompe, véhicule immobilisé |
| Recherche | Salle d’essai, observation, archives, alimentation | Interverrouillage, empreinte active, témoin protégé |
| Profondeur | Cavité, faille, bassin, seuil, chambre impossible | Réponse acoustique, visibilité, routes observées |

Chaque module doit être livré avec dimensions, sockets, volumes de navigation, points d’interaction, limites d’éclairage, identifiants d’audio et variantes de destruction. Les objets purement décoratifs évitent les collisions compliquées dans les chemins étroits. Le plan de production privilégie d’abord les quelques modules nécessaires à une boucle complète de sauvetage.

### La mer comme repère

La mer n’est pas un fond immobile. Sa ligne rappelle la profondeur gagnée, les reflets changent selon l’heure et les ruines permettent d’identifier l’orientation. Les premières vues portent loin. Plus bas, les mêmes bâtiments sont vus à hauteur de leurs derniers étages. Un bateau retourné, une enseigne et un clocher peuvent constituer trois repères constants.

Le vent se manifeste dans les bâches, les câbles, les rideaux et les embruns. La pluie et les particules ne doivent pas masquer durablement l’objectif ou créer une charge graphique incompatible avec le prototype. Les détails lointains restent simplifiés.

## 17 Direction visuelle et sonore

### Palette et lumière

Le haut de la tour associe le bleu froid de la tempête à des îlots ambrés de secours et à des restes de luxe crème, bois sombre et métal. Les couleurs servent d’orientation : balises de secours lisibles, matériels de service distincts des panneaux commerciaux, indices importants reconnaissables sans être entourés d’un contour permanent.

Hespérie conserve des tons fanés, des verts de signalétique ancienne et une lumière plus sèche. Le bunker utilise un éclairage fonctionnel dur et des surfaces conçues pour être lavées. Les profondeurs reprennent des couleurs du monde supérieur dans des associations déplacées. Le rouge est rare, afin de conserver sa force lorsqu’il signale un danger ou une émission SILLAGE.

La lisibilité prime sur le noir absolu. Une scène inquiétante garde une silhouette, un contraste ou un point d’appui. Un réglage de luminosité ne détruit pas l’énigme ; les indices reposent aussi sur les formes, les sons et les réactions.

### Son

Le mixage commence chargé sur le toit : rotors, radio, personnes, bâches, pas et sirènes lointaines. Les couches disparaissent progressivement au cours de la descente. Les sons structurels prennent leur place : dilatation, claquements, eau, câbles et vibrations sourdes. Un événement peut être effrayant par la disparition d’un fond sonore plutôt que par une hausse brutale du volume.

Les voix authentiques possèdent un traitement radio cohérent avec la distance et les relais. Les imitations utilisent des incohérences de contexte et de temporalité. Il faut éviter de coder toutes les fausses voix avec le même filtre démoniaque, qui supprimerait l’intérêt de la vérification.

La sirène d’intention des notes doit inspirer une création sonore propre : cycles lents, modulation, réflexion entre façades et impression de source éloignée. Les niveaux sonores restent réglables ; un événement essentiel possède des sous-titres descriptifs et une représentation alternative. Les bruits de souffle et les acouphènes disposent de réglages séparés.

### Musique

La musique se concentre sur les transitions et quelques résultats humains. Un sauvetage peut faire apparaître un motif bref, reconnaissable à l’épilogue. Les explorations longues utilisent des textures discrètes qui laissent l’écoute du lieu utile. Le thème final ne transforme pas automatiquement la réussite en victoire triomphale : il laisse place à ce qui a été perdu.

## 18 Interface et accessibilité

Le HUD montre d’abord la situation : étage, objectif immédiat, état de la ligne et ressources actuellement utiles. Les informations de santé ou d’atmosphère apparaissent lorsque leur variation demande une décision. Un journal donne les personnes rencontrées, les indices, les communications et les routes établies.

La carte est une coupe verticale complétée par des plans simples d’étages. Elle distingue **vu**, **vérifié**, **sûr**, **inaccessible** et **à recontrôler**. Une route connue ne s’efface pas parce qu’une anomalie veut désorienter le joueur ; elle peut être marquée comme contradictoire. Le joueur garde le moyen de comparer ses observations.

Les interactions utilisent des verbes précis : examiner, appeler, poser, couper, transférer. Le jeu évite une touche unique qui accomplit sans explication dix gestes différents. Une interaction longue dispose d’une option bascule ou maintien. Les textes sont redimensionnables et les couleurs importantes doublées par un symbole ou un mot.

### Options à prévoir

- Remappage clavier et manette, profils AZERTY et QWERTY, sensibilité séparée et inversion d’axe.
- Champ de vision réglable, désactivation du balancement de tête, du flou de mouvement et des secousses de caméra.
- Réduction des flashes, des effets de contraste soudains, des acouphènes et de la respiration amplifiée.
- Sous-titres des paroles et des sons utiles, avec indicatif, direction facultative et taille configurable.
- Aides au rappel, amortissement du balancement et maintien automatique au repos.
- Modes de difficulté séparant pression des ressources, tolérance aux erreurs et intensité des menaces.
- Pauses réelles en solo ; aucune dépense de ressources dans les menus de pause.
- Niveau d’explicite ajustable pour les corps, sans disparition des informations narratives nécessaires.

La coopération future exigera des règles différentes de pause et de sauvegarde. Elle ne doit pas être annoncée comme active tant qu’elle n’existe pas. Le prototype commence par une navigation et des commandes compréhensibles sur ordinateur.

## 19 Sauvegarde et persistance

Un refuge certifié offre une sauvegarde explicite. Des points automatiques protègent les transitions majeures, les sauvetages confirmés et l’entrée dans un nouveau secteur. Une sauvegarde automatique avant la chute demeure distincte de celle qui suit, afin de permettre une reprise claire et de faciliter le débogage.

La campagne devra conserver la graine, la version du générateur, les étages révélés, les objets consommés, les appuis posés, les portes modifiées, les personnes prises en charge, les indices lus et les événements déjà déclenchés, avec les préférences dans un fichier indépendant.

Le schéma courant du prototype est le schéma 3. Il conserve `incident_state`, introduit par la 0.2 et limité à `intact` ou `aftermath`, puis ajoute `transmissions` et `radio_events`. Un point sûr précède l’avertissement ; un autre suit la stabilisation. Les phases intermédiaires restent des états de session : interrompre la séquence reprend avant son départ. Charger l’après-impact restaure les dégâts, les figures du registre médical et l’historique radio sans rejouer les anciens sous-titres. Les schémas 1 et 2 sont d’abord validés dans leur forme d’origine, puis migrés en lecture ; ils commencent avec un historique et des événements radio vides. Le schéma 1 donne `intact` pour une mission en cours, `aftermath` pour une mission terminée ; le schéma 2 conserve son état. Le fichier n’est réécrit qu’au prochain checkpoint réussi. Les préférences et la présentation d’accueil sont indépendantes de cette progression.

La mort ou l’abandon d’une session ne relance pas toute la campagne depuis le toit. Le mode de référence reprend au dernier état sûr. Un mode sans retour peut être étudié plus tard, mais ne doit pas dicter la difficulté ni les sauvegardes du mode principal.

Le joueur distingue une partie nouvelle d’une reprise. Le prototype utilise des points de reprise autorisés plutôt qu’une position arbitraire dans une scène de destruction ; la notice doit expliquer le retour avant l’avertissement en cas d’interruption. Aucune donnée locale n’est présentée comme synchronisée dans le cloud sans service réel.

## 20 Ouverture détaillée de la campagne

L’ouverture possède deux niveaux de finition distincts. La 0.5.0 met en scène la mer, les deux tours, l’atterrissage des appareils et le débarquement des équipes géométriques dans une approche temps réel de vingt-huit secondes, passable. Les volumes intérieurs de cabine, portes coulissantes et poses de marche sont présents. Le jeu d’acteurs, les gestes de prise en charge et le doublage décrits ci-dessous restent une cible de campagne. Le [découpage cinématique](SCENES_CINEMATIQUES.md) donne les durées, les caméras, les textes, les transitions et les règles de reprise de la présentation actuelle.

### Approche

La première image vient de l’intérieur d’un hélicoptère. La radio explique ce qui est connu et ce qui manque : nombre exact de personnes inconnu, accès maritimes compromis, deux bâtiments hauts encore debout. À travers la porte, le joueur distingue une rue sous l’eau puis les deux tours encore droites et séparées. Un autre appareil s’aligne sur le toit d’Hespérie tandis que celui d’Alex rejoint Aube. Un équipier vérifie visuellement le harnais d’Alex.

Le jeu permet de regarder et d’écouter pendant le trajet. Une option abrège cette introduction après la première partie. Les commandes fondamentales ne sont pas noyées dans une liste pendant que le paysage porte l’information essentielle.

### Toit

Alex débarque près d’une zone balisée sur Aube. Corde et Médical installent le poste ; de l’autre côté, Bravo accuse réception de sa dépose sur Hespérie. Dans la cinématique cible, un blessé est pris en charge, un secouriste tire une caisse à l’abri du vent et un autre désigne l’accès au puits de service. Varga donne une mission immédiate : reconnaître les six premiers niveaux jusqu’au point de maintenance et établir un relais.

Le joueur peut voir le toit comme future destination de retour. Un point de sauvegarde et les caisses de ravitaillement expliquent comment la mission pourra durer. La reprise des vols n’est pas promise. L’hélicoptère qui part rétrécit dans les nuages et son son disparaît avant les autres bruits.

### Première descente

Un ancrage certifié et une ouverture large enseignent la connexion. Le joueur descend quelques mètres, freine, regarde une plateforme et se décale. La première personne à sauver est visible avant d’être atteignable. Le trajet ne comporte aucune apparition agressive : il doit faire comprendre la relation entre ligne, étage et retour.

Au restaurant, un détail paraît légèrement faux : une table a été préparée après l’heure annoncée d’évacuation. Cela n’interrompt pas le sauvetage. Le premier transfert confirmé donne une voix humaine et une réaction du toit. La confiance dans le système précède son érosion.

### La baie Est et le choc

Après Ana et le départ des appareils, l’objectif devient : « Rejoindre la baie Est du 29 et repérer Bravo sur Hespérie. » L’arrivée dans la zone et un regard maintenu vers l’autre tour déclenchent la scène ; E sur l’observation offre une confirmation explicite. Une alerte donne le temps de reconnaître l’abri intérieur, puis la réplique déplace Hespérie vers le joueur. La caméra reste sous son contrôle. Les bris de façade, la poussière et les bruits donnent le choc ; les commandes et la route du puits restent utilisables.

Le passage latéral touché est remplacé par un détour. Varga confirme qu’Aube tient et que les sauvés sont toujours au toit. Bravo ne répond plus. Le joueur rejoint Samuel, dont la réaction appartient désormais à l’après-impact.

### Premières contradictions

Les suites conservent l’indice antérieur au désastre ; les bureaux possèdent des archives datées d’avant le typhon. Le 27 donne une respiration après la catastrophe. Si Samuel est confirmé au toit et si la radio reste libre pendant six secondes continues, un fragment de Bravo peut s’y répéter. Après cet écho, Varga attend deux secondes de calme au 27, au 25 ou au toit pour confirmer qu’elle a reçu le fragment mais qu’aucun contact direct avec Bravo n’est établi. L’échange n’est requis ni pour descendre ni pour terminer ; il attend la fin du rappel, du portage et du treuillage. Le spa fournit une anomalie plus forte. Le refuge permet de confronter les indices et, depuis le bilan, de relire les transmissions.

## 21 Le prototype du dépôt

### Objectif de validation

Le prototype doit répondre à des questions concrètes. Le rappel donne-t-il envie de descendre ? Le joueur comprend-il comment quitter la ligne pour explorer un étage puis la reprendre ? Un sauvetage, même abstrait, constitue-t-il un objectif plus motivant qu’une simple collecte ? La présence d’une seconde tour et de la ville noyée rend-elle la situation lisible ? Le premier événement étrange gagne-t-il en force après plusieurs actions ordinaires ?

### Périmètre de la tranche

| Zone | Fonction | Périmètre du prototype 0.5.0 |
|---|---|---|
| Toit | Arrivée et briefing | Approche temps réel, deux tours intactes, deux appareils, équipes en maquette, réception nominative des rescapés et première ligne |
| 30 | Restaurant panoramique | Ana Rios, maître d’hôtel, première rescapée et apprentissage de l’exploration |
| 29 | Suites de l’hôtel | Chambre 2908, ravitaillement, baie Est et effondrement en direct avec dégâts persistants |
| 28 | Bureaux et archives | Samuel Breton, deuxième rescapé ; réaction et sauvetage après impact |
| 27 | Jardin d’enfants évacué | Dessin des deux tours, respiration mécanique et écho facultatif de Bravo après Samuel |
| 26 | Spa et piscine technique | Nora Haddad, kinésithérapeute, troisième rescapée ; Relevé SILLAGE 06 et anomalie |
| 25 | Refuge de maintenance | Sécurité, bilan avec journal consultable, ravitaillement et balise vers le toit |

La réussite de la tranche exige l’incident achevé, les trois rescapés pris en charge et l’envoi de la balise depuis le refuge. La progression de référence comprend le sauvetage d’Ana, l’observation de Bravo et le choc du 29, puis Samuel et Nora. Un joueur qui atteint le refuge sans avoir observé Hespérie doit recevoir un objectif de retour explicite. Les trois positions de rescapés sont 30, 28 et 26. Les indices se trouvent aux 29, 27 et 26. Les ravitaillements se trouvent aux 29 et 25. Ces points doivent rester cohérents entre le code, la notice, les essais et le catalogue.

### Ce que cette version ne prouve pas

Un personnage géométrique ne constitue pas un personnage final animé. Une balise de sauvetage ne démontre pas un transport réaliste de blessé. Six étages générés à partir de règles simples ne constituent pas trente niveaux finalisés. Une ambiance sonore de prototype ne remplace pas un enregistrement et un mixage professionnels. Une exécution sous Godot ne prouve pas qu’un projet Unreal Engine 5 a été compilé.

Ces limites doivent être dites simplement, sans retirer sa valeur au prototype : il sert à tester les gestes, la structure et la tension avant d’investir dans une production lourde.

### Critères de réussite fonctionnelle

- Une partie nouvelle commence dans un état reproductible et propose un objectif clair.
- Le joueur atteint chacun des six étages sans traverser un mur ni rester bloqué dans le puits.
- Les deux tours commencent intactes ; l’effondrement requiert le premier sauvetage, le départ des appareils et l’observation depuis le 29.
- La pause fige les quatre phases ; le regard reste libre ; une interruption reprend avant la scène ou dans l’état stabilisé, selon le dernier point sûr.
- Les sauvés, le refuge et le trajet intérieur restent accessibles après le choc ; les dégâts ne disparaissent pas au rechargement.
- Les commandes de rappel, de déplacement et d’interaction restent distinctes et compréhensibles.
- Chaque rescapé peut être confirmé une seule fois ; le compteur ne dépend pas d’appuis répétés.
- Les personnes confirmées restent visibles et nommées au toit ; la reconstruction de ce registre ne crée aucun obstacle.
- Les alertes interrompent l’affichage ordinaire sans effacer les transmissions reçues de la fenêtre d’historique ; les événements facultatifs ne se répètent pas après une sauvegarde réussie.
- L’introduction peut être passée dès son départ ; le menu ne révèle que le dernier point sûr d’une sauvegarde valide et n’avance pas la mission.
- Les ressources ne se dupliquent pas et les interactions restent accessibles après une reprise.
- L’anomalie ne condamne pas le trajet obligatoire ni le refuge.
- La victoire demande l’incident achevé, les trois prises en charge et la balise ; elle ne s’active pas seulement en arrivant au niveau 25.
- La pause, la nouvelle partie et la reprise ne laissent pas la souris ou les commandes dans un état incohérent.

## 22 Architecture technique cible

Le prototype sous Godot sépare le mouvement, la construction des niveaux, l’état de mission, l’interface et les données. Les géométries simples servent à vérifier le jeu. Les futurs assets peuvent remplacer ces volumes en conservant leurs sockets et leurs règles.

Le projet final sous Unreal Engine 5 pourra reprendre les mêmes contrats de données et les mêmes machines à états. La décision de moteur devra tenir compte des compétences de l’équipe, des coûts d’itération, de la plateforme et du résultat des essais. La bible décrit des systèmes indépendants d’un moteur ; elle ne suppose pas qu’un transfert de projet soit automatique.

### Composants fonctionnels proposés

| Domaine | Responsabilité |
|---|---|
| Contrôleur joueur | Marche, caméra, interaction, états au sol et sur corde |
| Système de corde | Segments, points d’appui, longueur, transitions et contraintes |
| Gestionnaire de mission | Objectifs, confirmations, progression et condition de fin |
| Catalogue d’étages | Thèmes, modules, objectifs, dangers et invariants |
| Générateur | Sélection déterministe, placement, validation et solution de secours |
| Directeur de tension | Fenêtres d’intensité, exclusions, événements et récupération |
| Gestionnaire de survivants | États de prise en charge, déplacement et transfert |
| Journal | Personnes, preuves, communications et repères de carte |
| Sauvegarde | État versionné de la partie et restauration |
| Couche audio | Ambiance, événements, voix, sous-titres et réglages |

La physique complète des deux tours n’est pas une exigence du premier jalon. Des états de destruction préparés et des événements contrôlés peuvent produire une meilleure lisibilité et une production plus fiable. Une simulation plus poussée doit démontrer son utilité avant de remplacer cette approche.

## 23 Plan de production

### Jalon un Boucle jouable

Le toit et les étages 30 à 25 permettent de tester la descente, l’exploration, les interactions, les trois rescapés et le refuge. La révision 0.2 ajoute l’arrivée auprès de deux tours intactes et la séquence du 29, avec état persistant après impact. Les priorités restent le contrôle, les collisions, les conditions de victoire, la reprise et la lisibilité. La direction visuelle est suggérée par la composition et l’éclairage.

### Jalon deux Tranche représentative

Le même secteur reçoit des assets mieux définis, des animations de mains et de matériel, une vraie séquence de transfert, une voix radio, un ennemi avec une règle observable et une sauvegarde complète. Le travail doit rester concentré sur quelques étages afin d’obtenir une mesure fiable du coût de production d’un niveau.

### Jalon trois Tours supérieures

Les étages 24 à 15 introduisent les conférences, commerces, cuisines, résidences et clinique. Le générateur utilise plusieurs variantes de plans validés. Les témoins et les preuves structurent les objectifs secondaires. La performance est mesurée avec plusieurs étages proches chargés en même temps.

### Jalon quatre Tours basses et Hespérie

Les niveaux 14 à 1, les laboratoires, la liaison basse endommagée du 6 et le trajet dans Hespérie développent les conséquences du choc déjà vécu au 29. La chaîne de refuges, les retours et les déplacements de survivants sont éprouvés. La chute se termine sur une petite zone jouable, pas uniquement une cinématique.

### Jalon cinq Profondeurs et conclusion

Les bains enfouis, cavernes, bunker, seuil 666 et fins deviennent jouables. Le projet vérifie que les règles apprises plus haut restent utiles. Les preuves et les personnes sauvées produisent des conséquences visibles. L’extension Mountain Hole reste séparée de ce chemin critique.

### Jalon six Finition

Les essais portent sur la compréhension des objectifs, l’accessibilité, la navigation, les temps de chargement, les sauvegardes et les variations de difficulté. Les doublages et les animations finales sont intégrés à partir de scripts stabilisés. Un éventuel mode coopératif exige un jalon spécifique, après une campagne solo solide.

Aucun calendrier ni budget ferme n’est déduit de cette liste. Les estimations doivent être construites après mesure du temps nécessaire à la tranche représentative et inventaire des ressources disponibles.

## 24 Risques de conception et décisions de maîtrise

| Risque concret | Conséquence | Décision proposée |
|---|---|---|
| Trop d’étages interchangeables | Fatigue et oubli de la géographie | Fonction fixe, silhouette propre et scène distincte par niveau |
| Trop d’ennemis | Le sauvetage disparaît derrière le combat | Rencontres rares, règles nettes, longs espaces humains |
| Procédural sans validation | Partie impossible ou personne inaccessible | Graphe validé, ressources garanties, plan de secours |
| Rappel trop réaliste à contrôler | Frustration et inconfort | Simulation assistée, vitesse limitée, freinage prévisible |
| Tout expliquer par un rêve | Les efforts perdent leur poids | Registre de sauvetage fiable et preuves matérielles |
| Transformer chaque refuge en piège | Plus de respiration ni de confiance | Sanctuarisation explicite des refuges certifiés |
| Trop de systèmes dès le départ | Prototype jamais terminé | Six étages, trois personnes et une condition de fin vérifiable |
| Enfant réduit à un objet | Récit mécanique et faible attachement | Alma agit, laisse des repères et possède des relations |
| Coopération ajoutée trop tôt | Réécriture des interactions et de l’horreur | Solo de référence, contrats préparés, réseau plus tard |
| Rupture entre fiction et interfaces | Joueur trompé par un faux objectif | Journal fiable sur faits confirmés, doute marqué comme doute |

## 25 Extension Mountain Hole

Mountain Hole reprend le vocabulaire de descente et de sauvetage dans un massif continental. Une cavité s’ouvre après un événement géologique et expose les vestiges d’une station liée au programme SILLAGE. L’opération commence en extérieur, avec camp de base, accès montagneux, entrée de grotte et descente vers un réseau plus ancien.

L’extension doit apporter une géographie et des gestes nouveaux : parois naturelles, ponts de corde, communications interrompues par la roche, météo en surface et points d’appui moins réguliers. Elle conserve les refuges fiables, les personnes à retrouver et les règles observables des présences.

Elle n’est pas nécessaire pour comprendre la conclusion de Nacre. Une preuve ou un témoin peut annoncer l’existence d’un autre site sans retirer sa résolution à la campagne principale. Les nouveaux modules naturels doivent être développés après la validation des modules des cavernes du jeu de base.

## 26 Guide de ton pour les dialogues

Les professionnels parlent en phrases courtes pendant les actions et prennent davantage de temps au refuge. Les personnages peuvent avoir peur, plaisanter ou se taire sans perdre leur compétence. La radio évite les longues explications au moment où le joueur franchit un vide.

**Varga, au départ :** « On les remonte jusqu’ici. Pour les appareils, je vous donnerai une heure quand les pilotes pourront m’en donner une. »

**Malik, premières minutes :** « J’ai deux portes et une cage d’ascenseur. Sur le plan, c’est l’inverse. Je te marque ce que je vois. »

**Une rescapée :** « Je vous ai entendus hier. La même voix. Je croyais que vous aviez déjà trouvé l’escalier. »

**Inès, après comparaison :** « Je garde les deux enregistrements. Je ne sais pas encore ce que ça signifie. Je sais seulement qu’ils ont le même bruit de fond. »

**Alma, retrouvée :** « J’ai laissé les flèches près du sol. Les grandes personnes regardent toujours les panneaux. »

**Sorel :** « Nous avons appris à mesurer ce qui restait. Nous n’avions pas prévu que quelque chose apprenne à nous mesurer. »

**Alex, après un transfert :** « Prise en charge confirmée. Je note le nom et je continue. »

Ces exemples fixent une intention. Le [dossier Effondrement en direct](EFFONDREMENT_EN_DIRECT.md) propose les prises de parole, indications de jeu et déclencheurs de l’arrivée et de la rupture du 29. Les répliques proposées restent à enregistrer ; leur présence dans le dossier ne signifie pas qu’un doublage est livré. Le scénario de campagne devra appliquer la même discipline aux autres scènes.

## 27 Registre des décisions ouvertes

Le nom public peut rester **The Tower Descent**, avec **The-Descents** comme nom de dépôt. Le pluriel pourra désigner une collection de campagnes si Mountain Hole devient un chapitre autonome. Le prototype ne nécessite pas de trancher ce point de marque.

La personnalisation complète d’Alex, le nombre exact de survivants de la campagne, la présence jouable de Malik, les durées de ressources, la taille finale des étages et le degré de violence explicite devront être confirmés après la première tranche. Le catalogue propose des situations et non un engagement à produire toutes leurs variantes simultanément.

## 28 Dossier de production 0.5.0

La révision ajoute des spécifications transversales assez précises pour préparer une nouvelle tranche sans confondre conception et livraison. Le catalogue fournit trente fiches d’assemblage : volumes proposés, circulation, accessoires, rythme, sauvegarde et contrôle du retour. Les étages 24 à 1 restent à construire ; la fiche d’un étage déjà représenté décrit aussi des enrichissements non intégrés.

Le dossier de props comporte **52 entrées P01 à P52**. Chaque fiche donne fonction, dimensions, état actuel, interaction cible, états, retour sonore, placement et points de validation. Le dossier de menaces sépare **E00**, silhouette réellement programmée au spa, de **dix archétypes de campagne E01 à E10**, avec comportements, valeurs initiales, signaux, contre-jeu, limites de génération et persistance. L’absence de points de vie sur une voix ou une empreinte est un choix fonctionnel, pas une fiche incomplète.

Le gameplay détaillé consigne les paramètres actuels de déplacement, corde, ressources, portée d’interaction, treuillage et dangers. Il expose leurs simplifications : pas de capsule basse, interactions de mission sélectionnées par proximité, inspections soumises à la visée et à la visibilité, portage abstrait, menace au mouvement direct, fusée à effet global. Les plages proposées pour l’accompagnement et les nouvelles interactions restent à essayer. Les motivations, objectifs et peurs des personnages relient leur rôle mécanique à leurs décisions narratives, sans leur inventer des statistiques psychologiques déjà simulées.

La présentation livrée comprend un prologue de marque de **15 secondes**, un accueil contextuel issu d’une sauvegarde validée et une arrivée de **28 secondes**, en quatre plans et quatre communications sous-titrées. Les préférences sont chargées avant le prologue, les séquences peuvent être passées et leur horloge ne consomme pas le temps de mission. Les scènes de retrouvailles avec Alma, de rupture du socle et de seuil disposent de storyboards textuels de production ; elles ne sont pas des cinématiques jouables supplémentaires de la 0.5.0.

La priorité suivante est d’éprouver la compréhension des gestes et des personnes, puis de remplacer progressivement les silhouettes et matériaux de maquette. Les objectifs de finition ne doivent pas masquer les contrats déjà établis : toute vie confirmée reste sauvée, tout refuge certifié tient sa promesse et toute reprise reconstruit une intervention cohérente.

La ligne directrice reste stable : une opération humaine et méthodique descend dans un lieu qui exploite les voix, les souvenirs et les gestes de secours. Le joueur conserve des moyens de vérifier, des personnes à protéger et des routes à construire. Les deux tours visibles au début deviennent progressivement une petite partie de ce qu’il a traversé.
