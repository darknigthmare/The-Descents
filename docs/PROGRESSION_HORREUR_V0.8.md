# De la perception incertaine à l’Enfer — progression de l’horreur

**The Tower Descent — version 0.8.0 — direction confirmée le 25 novembre 2026.**

Cette annexe fixe la progression demandée pour la campagne : hallucinations discrètes, manifestations de plus en plus persistantes, rencontres humaines dangereuses, découverte d’expériences avec une dimension infernale, puis arrivée réelle en Enfer. Elle complète les scènes, les étages, les props, le bestiaire et les règles de gameplay. Les éléments de campagne sont des spécifications à produire ; leur description n’étend pas le périmètre jouable du prototype.

## 1 Vérité du récit et savoir du joueur

L’Enfer existe réellement dans la fiction. Pelagos ne l’a pas inventé, mais le programme SILLAGE a appris à capter ses résonances, à stabiliser une frontière et à faire passer de la matière. La campagne conduit Alex de l’autre côté de cette frontière. Le matériel, les témoins et les conséquences conservées établissent une traversée physique. Le dénouement ne transforme pas les expériences, les personnes ou les secours accomplis en rêve.

Au début, Alex ignore cette réalité. Une fatigue, un reflet, une personne cachée ou une mauvaise transmission peuvent encore expliquer ce qui est perçu. Il faut laisser au joueur le temps de regarder une deuxième fois, d’en parler ou de poursuivre sa mission. Les premières anomalies ne lui retirent ni sa compétence, ni le contrôle de son corps, ni le crédit accordé à sa parole.

Le doute évolue. Dans les étages intermédiaires, des phénomènes durent et sont constatés par d’autres. Les laboratoires établissent des expériences matérielles. Le bunker révèle la destination infernale de ces expériences. La traversée en donne l’expérience directe. Une fois ces preuves réunies, l’écriture cesse d’entretenir artificiellement l’hypothèse que tout vient de la fatigue ; les incertitudes portent alors sur les intentions, les appels imités et les routes.

Les références servent des choix précis : proximité et violence humaine inquiétantes pour l’inspiration Condemned ; recherches ouvrant un accès infernal et découverte d’un monde hostile pour l’inspiration Doom. Les noms, personnages, architectures et créatures du projet restent originaux. Alex conserve son métier, ses moyens de secours et sa vulnérabilité au fil de cette évolution.

## 2 Périmètre actuel et campagne à construire

| Couche | État en 0.8 | Portée |
| --- | --- | --- |
| Toit et étages 30–25 | Jouables, secours et effondrement conservés | Trois personnes, refuge, journal et épilogue existants |
| Manifestations des 29, 28 et 26 | Présentations intégrées au même monde | Perceptions discrètes sans poursuite ni dégâts |
| Humains E11–E13 | Conception détaillée | Rencontres, gestes défensifs et négociations à produire |
| Laboratoires et bunker | Conception détaillée | Preuves des essais et accès à P666 à construire |
| P666 et I01–I04 | Conception détaillée | Franchissement, Enfer physique et retour à construire |

La clôture SC06 au refuge 25 reste celle de la tranche jouable. Elle ne montre ni découverte complète du programme, ni brèche ouverte, ni retour final d’Alma. Le SC10 du contrôle SILLAGE conserve son identifiant de campagne ; il n’est pas remplacé par l’épilogue du prototype.

## 3 Carte de l’escalade

| Palier | Espaces | Ce que le joueur apprend | Expression principale |
| --- | --- | --- | --- |
| Doute discret | Toit–25 | Quelque chose mérite une seconde lecture | Aperçu périphérique, trace humide, présence immobile récurrente |
| Répétition et rencontre | 24–17 | Les témoignages se recoupent ; certains humains sont dangereux | Routine répétée, faux appel vérifiable, barricade, poursuite limitée |
| Paranormal matériel | 16–6 et Hespérie | Une partie des phénomènes résiste aux explications ordinaires | Distance contradictoire, objet suivi entre deux lieux, témoin indépendant |
| Expérimentation | Socle, bains, cavernes et bunker | SILLAGE a transféré de la matière vers une dimension infernale | Chambres d’essai, registres, équipements étrangers et brèche instrumentée |
| Traversée infernale | P666 puis I01–I04 | Alex se trouve réellement de l’autre côté | Géographie étrangère, créatures corporelles, ligne de retour et fermeture |

Ces paliers gouvernent l’éligibilité du contenu, pas une minuterie globale. Une longue pause, une recherche minutieuse ou un haut niveau de stress ne déclenchent pas un démon en avance. Les personnes secourues et les refuges restent des points de stabilité. Les secteurs intermédiaires peuvent croiser menace humaine et phénomène paranormal sans confondre leurs règles.

## 4 Manifestations réellement présentées dans la 0.8

Le réalisateur `horror_director.gd` reçoit le contexte de mission et échantillonne une horloge de présentation. `horror_presentation.gd` construit les silhouettes et les traces sans collider hostile. La géométrie de traversée, les positions des rescapés et la génération ne sont pas remplacées par ces effets.

| Lieu | Présentation actuelle | Rythme et lecture |
| --- | --- | --- |
| Suites 29 | Silhouette humaine périphérique | Distance horizontale de 3,2 à 12 m ; après 2,6 s de calme compatible, présence de 3,4 s au maximum ; le regard direct la dissipe en 0,6 s ; une occurrence |
| Archives 28 après impact | Huit empreintes humides au sol | À 12 m au maximum ; après 3 s de calme compatible, apparition sur 5,5 s ; les traces restent ensuite en place |
| Spa 26 | Silhouette humaine immobile | Distance horizontale de 3,1 à 13 m ; après 4 s de calme compatible, présence de 6 s ; une réapparition possible après 20 s et 1 s de regard détourné ; deux occurrences au maximum |

L’aperçu des suites ne reçoit pas un carton annonçant « hallucination ». Le joueur peut avoir cru voir un employé ou une forme derrière un obstacle. Les rayons de visibilité évitent de consommer le déclenchement derrière une cloison ; l’effet n’oblige pas à tourner la caméra. L’empreinte des archives reste compatible, à ce stade, avec une personne ayant marché dans un bâtiment humide. Sa durée la distingue de l’aperçu, mais ne prouve pas seule une origine infernale.

Au spa, la répétition donne une présence plus insistante. Elle ne poursuit pas Alex, n’a pas de collision d’attaque et ne prélève ni santé ni stress. Nora formule une perception : « J’ai cru voir quelqu’un près du bassin… Je ne sais plus. Ne me laissez pas ici. » Elle ne commande plus de repousser une créature physiquement confirmée. L’ancienne poursuite du prototype est retirée de ce premier secteur.

Chaque occurrence peut émettre le court bruit spatial original `uncertain_steps.wav` : 1,6 seconde, mono, 24 kHz. Son volume reste discret et il ne contient aucune instruction indispensable. Ce bruit n’est pas une transmission reçue et ne s’ajoute pas à `radio.history`. Les documents réellement récupérés et les messages effectivement reçus restent les seules sources correspondantes du journal. Les silhouettes ne créent aucun nom, reçu de secours ou preuve de brèche par simple affichage.

## 5 Priorités, pause et continuité actuelles

Les gestes de secours, la corde, l’incident actif et la radio opérationnelle ont priorité sur les nouvelles manifestations. Les menus, le journal, les inspections, les cinématiques et le bilan ne doivent pas devenir des scènes de déclenchement ambiant. La présentation ne soustrait pas des secondes au temps d’intervention ni des ressources au joueur. Les points sûrs conservent leurs conditions existantes.

À l’ouverture de la pause, du journal ou d’une inspection, les sons courts facultatifs sont arrêtés et ne redémarrent pas à la reprise ; leur numéro d’occurrence reste consommé. Les horloges et les visuels de présentation sont figés puis repris. Cette distinction évite de relancer un bruit déjà entendu ou resté en attente de démarrage sonore.

La fusée conserve ses vingt secondes de lumière et la baisse de stress de dix points. Les silhouettes sont masquées pendant cette durée. Le résultat n’est pas présenté comme un exorcisme ni comme un recul physique : aucune IA n’est repoussée ou téléportée. Les traces au sol restent des repères du lieu. Le mode mouvements réduits ne demande pas de secousse ou de mouvement rapide de caméra pour comprendre l’effet ; aucun flash n’est requis.

Le schéma de sauvegarde reste **3**. L’horloge de présentation est transitoire. À la reprise, les aperçus fugaces des étages déjà visités sont traités comme consommés afin de ne pas rejouer automatiquement le même étonnement. Les traces stables des archives sont restaurées à partir de l’état après impact et de la présence du 28 parmi les étages déjà visités. Cette reconstruction ne prétend pas savoir qu’Alex les a regardées : aucun reçu d’observation n’est fabriqué. Une nouvelle intervention repart avec son propre état de présentation.

Les contrôles de validation vérifient la pureté des données, les priorités, la pause, la visibilité, la borne des occurrences et l’absence de dégâts. Les captures natives examinent les compositions réelles. Ces deux formes de preuve restent distinctes d’une partie humaine complète et de l’écoute du mixage sur une machine cible.

## 6 Des étages hauts aux premières rencontres humaines

A24 et A23 doivent laisser respirer après le refuge : personnes à aider, histoire du lieu et anomalie comparable à une première occurrence. À A22, un faux appel vient d’une réserve différente de celle où se trouve une personne réelle. Une vérification contextuelle suffit à préserver cette différence. Le joueur apprend qu’une voix peut mentir sans conclure que tous les appels sont faux.

A21 introduit E11, le Retranché, derrière une barricade observable. Il prévient, serre son outil, suit un déplacement et garde sa réserve. La scène confirme d’abord qu’il s’agit d’un humain réel. Alex peut garder ses distances, parler, ouvrir une séparation ou prendre le détour. Le cuisinier et l’agente d’entretien du secteur ne deviennent pas automatiquement des ennemis ; ils conservent leur chaîne de secours.

A19 et A18 relient des habitants à retrouver à la menace E12, le Débusqueur. Le joueur voit une porte utilisée, entend un appui et découvre la poche dont l’agresseur est sorti. Une recherche limitée et une fatigue lisible rendent la fuite possible. La menace ne traverse pas les murs pour maintenir la tension et ne s’installe pas dans le refuge 20 ou 15.

La fréquence reste écrite. Prévoir une seule règle nouvelle par rencontre initiale, une séparation visible et une respiration après la sortie. Deux silhouettes au fond d’un couloir ne doivent pas devenir automatiquement deux attaquants au contact. Un humain dangereux garde un objectif, un territoire et une relation ; il ne remplit pas une simple liste de cibles à éliminer.

## 7 Quand le paranormal devient incontestable

A17 fournit deux enregistrements et un témoin dont les informations peuvent être comparées. A14 permet de mesurer une distance ordinaire et de poser un repère. A13 introduit ensuite une contradiction forte : un objet numéroté et un témoin demeurent continus alors que les connexions de la salle changent. Le contraste vient de la répétition d’une opération fiable.

Les retours comptent. Un objet déplacé reste à sa nouvelle place ; une marque faite par Alex demeure lisible depuis l’autre entrée ; le témoin peut confirmer ce qu’il a vu pendant qu’Alex était ailleurs. La scène n’a pas besoin d’une explosion de lumière ni d’un message de l’interface disant au joueur quoi croire. Elle doit cependant être assez nette pour que l’histoire puisse avancer vers une certitude partagée.

Les humains E13, Fidèles du protocole, occupent une partie des locaux SILLAGE. Ils tentent de maintenir des circuits et de protéger des données. Leur violence peut se produire pendant qu’un phénomène matériel se manifeste à côté, mais les objectifs restent séparés : préserver une distance ou isoler l’humain, puis traiter le dispositif. Un effet surnaturel ne donne pas à un corps humain une invulnérabilité non annoncée.

Le passage d’Hespérie au 6 révèle des tentatives de confinement antérieures au désastre. Le bâtiment abandonné possède une histoire matérielle, des balises anciennes et des routes d’équipes disparues. La dégradation actuelle n’efface pas les traces qui prouvent la poursuite des expériences.

## 8 Ce que les expériences faisaient

La couverture de SILLAGE associe maintenance prédictive et mémoire émotionnelle. Ses directions ont progressivement déplacé les objectifs vers le franchissement et l’exploitation d’une dimension infernale. Les dossiers ne donnent pas seulement un nom inquiétant au laboratoire : ils montrent actions, autorisations et résultats.

| Programme de fiction | But recherché | Pièce de preuve | Conséquence dans la campagne |
| --- | --- | --- | --- |
| Résonance | Capter les motifs étrangers depuis Nacre | Enregistrement daté et capteur indépendant | Voix et routines répétées |
| Comparaison | Vérifier qu’une matière étrangère traverse | Caisson P53 et registre P54 | Fin de l’explication par simple effet sensoriel |
| Stabilisation | Maintenir une ouverture assez longtemps | Collecteur P55, porte P56 et journal d’essai | Chambres d’observation et contamination locale |
| Transfert | Déplacer matériel et personnes | Identifiants suivis à l’aller et au retour | Équipements Pelagos retrouvés en Enfer |
| Exploitation | Soutenir durablement les liaisons | Appuis d’amarrage, stations et décisions de Sorel | Nécessité d’une intervention au-delà du seuil |

Ces protocoles sont fictifs et exprimés par des fonctions de jeu. Le joueur ne doit pas mémoriser une suite de jargon ni recevoir une procédure industrielle réaliste. Une chambre présente ce qui devait entrer, ce qui est revenu et la décision prise ensuite. Le local suivant peut montrer une personne qui en a subi les conséquences.

La chaîne des preuves croise au moins trois types de support : objet matériel, document daté et témoignage ou enregistrement indépendant. Le même récit recopié sur trois écrans ne fournit pas trois confirmations. Les pièces centrales peuvent être retrouvées par des routes différentes ; une lecture facultative enrichit la responsabilité de Sorel sans conditionner la compréhension du dernier acte.

Pelagos a découvert la frontière et l’a exploitée malgré les avertissements. Le typhon, le tsunami et les secousses demeurent des désastres distincts ; le programme a aggravé l’état local et les risques du complexe. Cette causalité évite de faire disparaître l’opération de secours derrière une explication unique des phénomènes.

## 9 Le bunker et le dernier seuil du côté de Nacre

B01 relie le contrôle d’accès à la date d’isolement. B02 présente les personnes et les environnements d’essai. B03 expose le collecteur. B04 confronte le joueur aux circuits et aux humains qui veulent les maintenir. B05 rassemble les pièces de transfert. B06 enseigne les trois liaisons : énergie, motif et réponse. Chacune doit produire un effet local que le joueur a pu observer avant la résolution finale.

Le repère **666** garde son origine de classement : puits 6, boucle 6, seuil 6. Il désigne le sas P666, pas six cent soixante-six étages à produire. Le fait que le numéro ait une origine administrative n’ôte rien à la destination : il ouvre une dimension infernale réelle.

Avant le franchissement, Alex vérifie l’amarrage P57, le premier segment P58 et la possibilité de retour. Le matériel indispensable est fourni ou récupérable à proximité. Une visite du jardin des Marées non effectuée plusieurs heures plus tôt ne doit pas rendre cette transition insoluble. La scène conserve les personnes déjà mises à l’abri et annonce les conséquences du départ.

## 10 I01 — Le rivage des cendres

Le premier espace infernal commence par un appui stable. Derrière Alex, le cadre de la brèche et la balise gardent la même identité. Devant lui, un bassin de cendres et des arches étrangères ouvrent un horizon impossible depuis l’île. Un élément de mobilier Pelagos, numéroté comme dans le registre, est pris dans une matière locale. Le franchissement est continu ; aucun réveil ne le requalifie en rêve.

La première action consiste à confirmer l’autre extrémité de la ligne, lire le relief et ouvrir un trajet court vers le prochain appui. Le joueur dispose d’un temps d’observation avant une menace. La chaleur et les matières sont des signes d’environnement ; aucun dégât invisible ne commence pendant la découverte. Budget de parcours cible : huit à douze minutes, sans chronomètre imposé.

## 11 I02 — Les galeries de contrainte

Les galeries alternent volumes bas, sillons de chaînes et puits ouverts sur une architecture plus vaste. P58 fournit une direction de retour tangible. Des traces d’Alma ou d’une autre personne isolée rejoignent ce trajet ; elles servent à trouver un passage réel, sans transformer la personne en clé biologique.

E14, le Pénitent des chaînes, garde une zone annoncée par ses sillons. Le joueur observe une amplitude, rejoint un couvert puis immobilise une attache dans un dispositif préparé. Une voie de contournement reste possible après compréhension. Le transfert d’une personne se déroule lorsque le passage est sécurisé. Budget cible : dix à quinze minutes, avec point de reprise après l’ouverture de la route.

## 12 I03 — Les ouvrages d’extraction

Le secteur mêle une structure infernale gigantesque et des équipements Pelagos clairement ajoutés après coup. Le collecteur P55 apparaît de l’autre côté du passage avec les mêmes marquages de série : la preuve des expériences devient une géographie. Des câbles et postes provisoires indiquent le chemin de ceux qui ont essayé d’exploiter le lieu.

E15, le Souffleur de scories, menace une traversée depuis un ouvrage alimenté. Sa cavité s’ouvre avant la projection ; les appuis offrent un abri complet. Dériver une alimentation crée un arrêt lisible. Le joueur peut alors réparer une liaison ou permettre le passage d’une personne. Budget cible : dix à quinze minutes. Les lectures longues se trouvent à l’abri du cycle d’attaque.

## 13 I04 — Le nœud du Chœur et le retour

I04 révèle le réseau qui entretient la brèche. Les stations P59 donnent trois actions correspondant aux enseignements de B06. Le Chœur bas E10 agit par réponses et liaisons ; le Gardien E16 protège physiquement des accès. Le joueur doit distinguer le système à isoler de l’obstacle corporel à contourner ou à mettre en défaut.

Chaque objectif accompli ouvre un appui durable. Une accalmie permet de confirmer les personnes regroupées et la ligne de retour. Le jeu peut faire revenir les motifs sonores des étages hauts, mais les noms des personnes sauvées ne deviennent pas des victimes sacrifiées pour alimenter le mécanisme. Les variantes de résolution affectent les preuves, la liaison et le coût de sortie, avec conséquences annoncées.

Le sas P60 confirme ensuite le retour du côté de Nacre. La ventilation, la matière connue et un appel authentifié reconstruisent les repères. La galerie SORTIE conduit au jour et à l’évacuation possible. Le résultat humain et les preuves gouvernent l’épilogue de campagne. Budget cible du nœud : six à neuf minutes, puis sortie respirée ; toutes ces durées restent à éprouver en production.

## 14 Personnages, envies et responsabilités

Alex veut conserver des résultats nommables : personnes trouvées, transmises, encore à chercher. Sa peur évolue de l’erreur de secours vers l’incertitude sur une route de retour, sans annuler sa compétence. Varga veut tenir le poste et ne confirme que ce qu’elle peut établir. Inès cherche une chaîne de preuves exploitable ; elle ne devine pas les règles d’une dimension en lisant un écran. Malik garde ses propres personnes et peut devenir un témoin indépendant d’une contradiction.

Alma cherche des adultes fiables et laisse des repères concrets. Sa présence au-delà du bassin relève d’une séparation écrite avec continuité, sans violence graphique infligée à l’enfant. Les objets, témoins et trajets conservent son existence autonome. Sorel veut préserver les données et une capacité de contrôle ; elle connaît la réalité de l’ouverture avant Alex. Sa rétention d’information et ses autorisations sont des actes, pas un monologue final destiné à expliquer tous les bruits.

Les humains E11–E13 ont des buts différents : protéger un territoire, prendre un avantage sur une personne isolée ou maintenir les essais. Leur apparence perturbée ne suffit pas à prédire leur décision. Les fiches proposent des états, des signaux et des sorties qui rendent la confrontation jouable. Les motivations ne deviennent pas des jauges psychologiques cachées.

## 15 Gameplay conservé et extensions nécessaires

Les gestes du début restent utiles : observer, baliser, créer un appui, couper un danger, rejoindre une personne, confirmer le transfert. Les profondeurs changent ce qui menace ces gestes. Les outils gagnent de nouvelles interactions préparées, comme bloquer une chaîne ou isoler une station. Les extensions ne doivent pas rendre inutiles les habitudes de secours apprises dans les tours.

Le combat humain futur exige une garde ou poussée clairement annoncée, une portée sans traversée de mur, une récupération lisible, des territoires et une possibilité de désengagement. Les statistiques proposées d’E11–E13 sont des points de départ ; leur validation dépend des distances réelles, du portage et du temps nécessaire pour comprendre un geste. La coopération avec un témoin et la séparation par une porte doivent être des issues efficaces.

Les créatures infernales ajoutent des volumes et des attaques matérielles distinctes. Leurs dommages, annonces, cycles et limites figurent dans E14–E16. Elles ne copient pas la règle perceptive d’E00 : une silhouette qui s’efface sous le regard et une créature qui occupe physiquement un passage demandent des réponses différentes. La lampe aide à lire ; elle n’est pas une solution universelle.

Les ressources restent abstraites et lisibles. L’air représente une réserve respiratoire de jeu ; une couleur infernale ne la vide pas arbitrairement. Les secteurs dangereux possèdent une source annoncée et une sortie. Une dépense indispensable reçoit son matériel avant l’épreuve. Les appuis certifiés, la pause et les lectures gardent leur fonction de repos et de préparation.

## 16 Direction visuelle, son et scènes

La montée visuelle part du quotidien : linge, eau, verre, reflets, silhouettes à taille humaine. La persistance apparaît ensuite par répétition et continuité matérielle. Les humains dangereux occupent les mêmes portes et angles que le joueur. Les laboratoires exposent des fonctions, des numéros et des erreurs de confinement. L’Enfer élargit l’échelle et la matière sans supprimer la lisibilité des appuis.

Le son suit le même parcours : bruit court interprétable, motif répété, témoignages croisés, machines d’essai, acoustique étrangère. Les appels opérationnels gardent la priorité. Une peur ne dépend pas d’un volume excessif ni d’un flash. Les informations utiles disposent d’un autre support, et une voix enregistrée reste identifiée comme telle.

SC12 présente une première confrontation humaine observable ; SC13 fait corroborer le transfert matériel ; SC14 accompagne le franchissement physique ; SC15 rend jouable le premier appui en Enfer. SC11 conserve l’orchestration du seuil, des objectifs finaux et du retour. Les détails de caméra, durée, passage et reprise sont inscrits dans [Scènes et cinématiques](SCENES_CINEMATIQUES.md). Les titres à l’écran restent ceux qu’Alex peut connaître à ce moment, sans révélation prématurée depuis l’accueil.

## 17 Critères de production et ordre de réalisation

La prochaine tranche sous le 25 doit d’abord éprouver un humain E11 dans un niveau court, avec observation, sommation, défense, détour et reprise. La seconde construit une preuve persistante avec un témoin. La troisième assemble une salle d’essai complète et sa chaîne de documents. Une transition P666–I01 vient ensuite démontrer continuité des personnes, matériel, appui et retour. Les grands panoramas infernaux attendent que ce passage puisse être joué sans perte de progression.

La recette de chaque étape pose des questions concrètes : le joueur distingue-t-il perception et menace corporelle ; comprend-il ce que veut l’humain ; voit-il le signal avant le coup ; peut-il préserver une personne ; sait-il pourquoi l’expérience constitue une preuve ; retrouve-t-il son matériel après la brèche ; peut-il revenir sans dépendre d’un objet facultatif oublié ? Les résultats doivent venir d’essais réels, pas du seul nombre de fiches écrites.

Le catalogue actuel comprend **64 props P01–P64**, **E00 perceptif et 16 archétypes de campagne E01–E16**, ainsi que les secteurs et scènes décrits ici. Les rapports de livraison distinguent les manifestations effectivement intégrées des fonctions futures. Cette annexe fixe une direction de production complète sans annoncer une campagne infernale déjà jouable.
