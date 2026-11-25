# Gameplay détaillé, réglages et personnages

**The Tower Descent — version 0.7.0.** Les valeurs désignées « actuelles » proviennent du prototype. Les valeurs « cibles » sont des propositions de réglage pour une prochaine tranche et doivent être éprouvées en jeu. Une fiche de conception ne signifie pas que la fonction correspondante est déjà programmée. Cette annexe complète la bible avec des contrats utilisables par la conception, l’animation, le son et les essais.

## 1 Expérience recherchée et boucles

La boucle courte est **lire un espace, rejoindre une personne, sécuriser son retour et confirmer sa prise en charge**. Une avancée doit produire une amélioration concrète : un nom ajouté au poste médical, une route balisée, un relais actif ou une preuve corroborée. Le jeu évite de demander une exploration maximale pour que le sauvetage compte.

Sur trente à quatre-vingt-dix secondes, le joueur alterne déplacement, observation et interaction. Sur quelques minutes, il réalise une boucle aller-retour avec une personne ou un objectif. À l’échelle d’un secteur, il rejoint un refuge, relit les faits puis choisit la prochaine descente. Ces durées sont des intentions de rythme ; elles ne sont pas des chronomètres imposés au prototype.

La version actuelle permet trois transferts nommés, un incident structurel et un bilan au 25. Le trajet de référence est toit, Ana au 30, observation de Bravo au 29, Samuel au 28, respiration au 27, Nora au 26 et refuge au 25. Un retour au toit reste possible. Les preuves secondaires et l’écho de Bravo enrichissent la lecture sans devenir des conditions cachées de survie.

La 0.5 ajoute douze observations facultatives réparties sur ce même parcours. Pour les lire, Alex se place à moins de 2,4 m, vise l’objet à travers un espace libre et utilise E. Le panneau suspend l’intervention jusqu’à sa fermeture ou Échap. Le registre médical et les observations de restaurant, archives et spa tiennent compte des personnes réellement reçues ; les constats distinguent les états avant et après le choc. Ces objets ne donnent ni points, ni bonus, ni collecte supplémentaire et ne modifient pas les conditions de victoire. Leur catalogue et leurs critères figurent dans [Props et interactions](PROPS_INTERACTIONS.md).

La lecture ne s’ouvre pas pendant un portage, un treuillage, le rappel ou la phase active de l’incident. Une commande de secours à moins de 1,5 m garde la priorité sur une observation voisine. Cette règle évite d’afficher une page de récit à la place d’un geste nécessaire pour ramener une personne ou reprendre la corde. Elle ne retire pas la possibilité générale de mettre le jeu en pause.

La campagne étend cette boucle avec des personnes mobiles, des points de transfert locaux, des routes de retour à préparer et une enquête sur SILLAGE. Elle doit conserver la même grammaire : signaler ce qui est certain, rendre les coûts visibles et offrir une réponse à l’action du joueur. Une nouvelle mécanique doit expliquer quel choix elle ajoute, avant d’ajouter une jauge.

## 2 Déplacement actuel

| Paramètre | Valeur livrée | Conséquence pour la conception |
| --- | --- | --- |
| Marche | 3,7 m/s avant multiplicateur du sol | Base de mesure des trajets et distances d’observation |
| Course | 6 m/s | Courte accélération, indisponible en portant une personne ou en position basse |
| Portage | 2,4 m/s | Retour plus lent, trajet garanti sans saut obligatoire |
| Position basse | 1,8 m/s | Caméra abaissée ; la capsule ne change pas encore de taille |
| Accélération horizontale | 25 m/s² | Réponse rapide dans la maquette, à reprendre avec les animations |
| Gravité et impulsion de saut | 16 m/s² ; 5,6 m/s | Franchissement simple ; saut interdit pendant le portage |
| Endurance | 0 à 100 | Course autorisée au-dessus de 5 ; consommation de 14 points/s en mouvement |
| Récupération | 11 points/s hors course ; 8 points/s sur corde | Le rappel ne consomme pas encore d’endurance |
| Capsule | Rayon 0,34 m, hauteur 1,72 m | Enveloppe réelle à utiliser pour les collisions du prototype |
| Regard | Caméra à 1,62 m, abaissée vers 1,12 m | Ne pas produire un tunnel bas en supposant une capsule accroupie |
| Caméra jouable | Champ de vision 77° par défaut, réglable de 65 à 100° | Référence des vues de lecture et de la transition depuis l’arrivée |

Le déplacement se fait dans un volume physique, mais plusieurs interactions de la maquette restent abstraites. S’accroupir baisse le regard et ralentit sans rétrécir le corps de collision. Il n’existe pas encore de franchissement animé d’une fenêtre, d’escalade libre ou de système de prise de main. Les passages de production ne doivent pas être validés sur la seule hauteur de caméra.

La sensibilité de souris utilise une base de 0,0024, multipliée par un réglage de ×0,25 à ×2,5, soit 0,0006 à 0,006. Le regard au clavier tourne à 1,5 radian/s horizontalement et 1,2 radian/s verticalement, avec inclinaison limitée à environ ±77 degrés. L’inversion verticale affecte la souris et les flèches. Sensibilité, champ de vision et volume sont appliqués immédiatement, enregistrés séparément de la mission et accessibles depuis l’accueil comme depuis la pause. Le remappage complet reste à produire ; les plages et la migration figurent dans [Confort v0.6](CONFORT_V0.6.md).

### Cibles de sensation à éprouver

Conserver une marche de 3,4 à 3,8 m/s et un portage de 2,2 à 2,6 m/s comme premières plages d’essai. Le temps de retour ne doit pas être augmenté pour simuler la gravité d’une blessure au détriment du confort. Une fatigue sonore, la posture et des pauses choisies peuvent exprimer l’effort sans immobilisation répétée.

Une capsule réellement basse, des franchissements courts et des animations de manipulation sont des travaux distincts. Chaque mouvement doit annoncer sa destination et permettre de revenir avant engagement. Les itinéraires portant une personne doivent être validés avec l’enveloppe la plus large et la caméra la moins mobile ; un effet de tête ne doit pas être nécessaire à la compréhension d’un appui.

## 3 Rappel, balises et ancrages

Le prototype utilise une ligne centrale guidée. La vitesse verticale est de **2,8 m/s**, dans l’intervalle de hauteur 6,04 à 42,04 mètres. Les étages sont espacés de six mètres ; le toit correspond à l’étage logique 31. La sortie est autorisée à moins de 0,8 m de la hauteur d’un palier et replace Alex sur un point d’arrivée préparé. Il ne s’agit pas encore d’une corde physique libre qui peut s’enrouler autour du décor.

Le déplacement latéral commande un balancement limité à ±1,8 m. Un ancrage secondaire consomme une unité et stabilise la ligne pendant **16 secondes** ; l’amplitude de l’excitation de vent passe de 0,5 à 0,14 dans le modèle de contrôle. L’action remet le balancement et sa vitesse à zéro. Cette protection aide à se placer, sans supprimer la route ni déclencher une chute scriptée à son expiration.

La ligne doit se voir depuis chaque palier et la balise de transfert doit être trouvée sans consulter la carte. Le joueur peut remonter du 25 au toit, sous réserve des états ordinaires de la mission. L’effondrement ne condamne pas ce noyau. Aucun nouvel accessoire ne doit apparaître dans le volume de sortie de corde ou entre la personne portée et sa balise.

La cible de campagne introduit des segments de rappel préparés, des points d’appui distincts et un transfert local vers un équipier. Elle conserve une surface d’arrivée visible et une reprise sûre en cas d’échec. Avant de produire des cordes dynamiques, l’équipe doit décider si une simulation ajoute un choix utile ou seulement des coincements difficiles à lire. La réponse technique peut rester une spline animée avec états et collisions soigneusement bornés.

## 4 Interaction et lisibilité

Pour les interactions de mission, le jeu cherche l’objet utilisable le plus proche au même étage, à moins de **trois mètres en distance horizontale**. Un objet consommé est ignoré. La sélection de ces commandes de mission ne vérifie pas encore une ligne de vue par rayon : un objet peut donc être proposé à travers une cloison si son placement est trop proche. Le catalogue de props doit tenir compte de cette limite et réserver des volumes sans concurrence autour des interactions essentielles.

E déclenche l’action contextuelle : corde, rescapé, balise, preuve, ravitaillement ou terminal. Le texte doit nommer la conséquence : « sécuriser », « confirmer le treuillage », « lire » ou « transmettre ». Un verbe générique identique pour tous les objets réduit la capacité du joueur à anticiper ce qui va se passer.

Pour les actions de secours, la cible prévoit une distance de manipulation adaptée à l’objet, de 1,4 à 2,2 m pour une action manuelle ordinaire, avec vérification de visibilité et priorité au regard. Il s’agit d’une plage de prototypage, pas d’un changement déjà appliqué. Les grandes balises peuvent conserver une portée plus généreuse. Toute nouvelle durée d’appui doit être testée avec annulation, clavier et options de maintien simplifié.

Un objet essentiel doit fournir au moins deux indices parmi forme, position, texte, mouvement et son. La couleur seule ne suffit pas. À l’inverse, une radio ou un corps ne doit pas être entouré d’un halo si une bonne composition permet de le trouver. Les marqueurs 3D de la maquette sont des aides de gameplay ; ils sont masqués dans les caméras de présentation.

## 5 Sauvetages et état des personnes

### Chaîne livrée

Le prototype suit une personne dans les états **présente, portée, au treuil, reçue**. L’interaction de sécurisation est instantanée. La représentation au sol disparaît pendant le portage et la vitesse d’Alex est limitée. La 0.6 affiche une représentation dédiée de la personne dans un harnais, avec sangles, poignée et mains d’Alex ; elle suit la caméra et désactive son léger balancement lorsque les mouvements sont réduits. Une seule personne peut être prise en charge à la fois.

À la balise du même étage, E commence une montée de **cinq secondes**. Le panier et la personne suivent une trajectoire absolue dans le puits, puis une dépose latérale sur la dalle du toit. La longueur du câble relie le support à la poutre ; elle reste une représentation calculée, sans simulation physique de corde. Seule la fin de la montée ajoute l’identifiant au registre des sauvés, diminue le stress de quinze points et crée un point sûr. La réception médicale au toit reconstruit ensuite la présence nommée. En partie, un équipier accompagne pendant 4,2 secondes cette personne déjà confirmée jusqu’à sa place ; une reprise de sauvegarde l’installe directement à sa pose finale. Aucun état cosmétique n’est ajouté au schéma 3.

| Personne | Identifiant | Point de départ | Réception confirmée |
| --- | --- | --- | --- |
| Ana Rios | survivor_30 | Restaurant du 30 | Silhouette allongée sur civière, nom et statut au toit |
| Samuel Breton | survivor_28 | Archives du 28 | Silhouette avec couverture jaune, nom et statut au toit |
| Nora Haddad | survivor_26 | Spa du 26 | Silhouette basse avec couverture claire, nom et statut au toit |

La réception est une projection de la liste sauvée : lui fournir plusieurs fois les mêmes noms ne crée pas de doubles. Les identifiants inconnus sont ignorés ; une nouvelle intervention la remet à vide. Les figures médicales n’ont pas de collision et ne barrent ni le départ du joueur ni le treuil.

### Cible de campagne

Ajouter les états « contact établi », « stabilisée », « suit le joueur », « attend à l’abri », « transfert en cours » et « remise à une équipe » seulement lorsqu’un scénario les utilise. Le témoin peut avoir une mobilité différente sans disposer d’une jauge cachée de docilité. Un ordre d’attente doit désigner un point réellement protégé, vérifié par le niveau.

Pour une première tranche de PNJ accompagnant, tester une marche de 1,8 à 2,2 m/s, une distance de suivi de 1,8 à 3 m et un arrêt au-delà de six mètres lorsqu’un obstacle empêche le suivi. Le joueur reçoit alors une demande claire au lieu de perdre silencieusement la personne. Les déplacements de rattrapage ne traversent pas une porte fermée et ne téléportent pas un témoin dans une zone hostile.

La stabilisation envisagée dure trois à cinq secondes avec annulation immédiate. Elle utilise un seul geste abstrait, expliqué par le contexte ; le jeu ne prétend pas enseigner une procédure de secours réelle. La diversité vient de la route, du dialogue, du matériel disponible et de la relation entre personnes, pas d’une multiplication de manipulations répétitives.

## 6 Ressources et pression actuelles

| Ressource ou effet | Valeur actuelle | Limite et lecture |
| --- | --- | --- |
| Santé initiale | 100 | Les blessures viennent des dangers programmés ; aucun système médical détaillé |
| Air initial | 100 | Consommation seulement dans les secteurs de fumée applicables |
| Stress initial | 8 sur 100 | Indicateur de pression ; ne change pas la vérité des sauvetages |
| Ancrages | 4 au départ, maximum 8 après ravitaillement | Un usage stabilise la corde pendant 16 s |
| Fusées | 3 au départ, maximum 6 après ravitaillement | Une fusée dure 20 s et réduit le stress de 10 points |
| Ravitaillement | Air remis à 100, santé +30, ancrages +2, fusées +2 | Chaque caisse est à usage unique, avec plafonds |
| Lampe | Portée lumineuse 27 m, cône 32°, énergie 1,35 | Pas de batterie consommable dans cette version |
| Appel manuel | Délai de 8 s ; stress −5 | Le contenu dépend de la situation ; un faux appel peut ajouter de la pression |

Les caisses du 29 et du 25 permettent de récupérer sans boucle de collecte infinie. La sauvegarde mémorise leur consommation. Le terminal du refuge ne doit pas être confondu avec un distributeur réinitialisé à chaque reprise.

La fusée est posée visuellement près du joueur, mais son effet sur la silhouette du spa est actuellement **global pendant vingt secondes**, sans test de rayon ou d’occlusion. C’est une simplification importante. L’équilibrage futur d’un cercle de protection demanderait une nouvelle règle visible : portée, obstruction, durée et interaction avec une personne portée. La documentation ne doit pas attribuer ce comportement spatial à la version actuelle.

### Dangers de sol et d’ambiance

Dans la fumée, l’air perd 0,65 point/s et le stress augmente de 0,12 point/s. Lorsque l’air atteint zéro, la santé perd trois points/s. Les secteurs d’eau appliquent un multiplicateur de vitesse de 0,74 ; les secteurs instables, 0,87 avec 0,07 point de stress/s. Ces valeurs sont des abstractions de jeu. Aucun calcul de noyade, d’électricité propagée dans l’eau ou de toxicologie réelle n’est simulé.

Avant l’effondrement, les dangers des 29 et 28 sont désactivés même si leur variante de secteur en prévoit un après le choc. Pendant la séquence active de catastrophe, les dangers ordinaires sont suspendus. Sur corde, le stress augmente de 0,025 point/s et la silhouette est masquée. Au toit, au 27 et au 25, le stress diminue de 1,2 point/s.

La silhouette du 26 s’active après plus de quatre secondes cumulées dans ce secteur. Elle avance à 0,72 m/s avec la lampe allumée et à 1,1 m/s sans lampe. À moins de deux mètres, elle inflige douze points de dégâts, avec trois secondes de délai avant un nouveau contact. Elle augmente le stress de 0,9 point/s lorsqu’elle est visible. Son mouvement direct n’utilise pas encore de navigation autour des obstacles. La fiche E00 du [bestiaire](ENNEMIS_STATISTIQUES.md) expose les conséquences et la différence avec les adversaires futurs.

### Cibles d’équilibrage

La prochaine tranche doit permettre une sortie raisonnable d’un secteur après la première alerte de ressource. Commencer les essais avec au moins trente secondes de marge pour rejoindre une zone respirable depuis la route principale ; conserver une réserve plus large lors du portage. Ce budget doit être calculé sur les distances réelles du niveau, pas obtenu en augmentant arbitrairement la vitesse du joueur blessé.

Le stress ne doit pas inverser les commandes, falsifier le registre des sauvés ou invalider un refuge certifié. Une cible à trois seuils peut modifier souffle, bruit périphérique et petites contradictions visuelles, avec désactivation des effets de caméra. Les seuils, durées et intensités restent à fixer après des essais de compréhension ; une jauge haute ne justifie pas n’importe quelle apparition.

## 7 Radio, preuves et connaissance

La radio sert d’abord à l’opération : localiser, demander une confirmation, annoncer le treuil et préciser un détour. Les messages normaux sont séquencés. Les urgences peuvent interrompre la présentation, mais les messages reçus sont conservés dans un journal limité aux trente-deux dernières entrées. Le journal distingue ce qui a été dit de ce qui a été confirmé.

L’appel R demande une réponse contextuelle. Pendant un portage ou un treuillage, il rappelle l’action utile avec priorité. Pendant l’incident actif, il ne concurrence pas le canal de secours. Après les trois transferts, il indique l’observation encore nécessaire ou le refuge. Au spa, avec suffisamment d’indices, une source non identifiée peut mentir sur l’état du toit ; cette phrase ne modifie ni les sauvés ni le monde.

L’écho facultatif de Bravo attend Samuel confirmé, l’après-impact et six secondes calmes au 27. La vérification attend ensuite deux secondes calmes au 27, au 25 ou au toit. Le portage, le treuil, la corde, la pause, l’arrivée et une radio occupée empêchent l’émission. Les événements sont enregistrés une seule fois. La progression principale ne dépend pas de leur écoute.

Une preuve actuelle est une interaction collectée et mémorisée.

Le dossier de la 0.7 sépare Situation, Rescapés, Indices et Transmissions. Il affiche les noms et les états réels de secours, conserve la distinction entre portage et réception, et masque le contenu des pièces non collectées. Changer de rubrique, lire ou fermer le journal ne consomme ni temps, ni ressource, ni nouvelle entrée d’historique. La campagne devra distinguer document, témoignage et observation physique. Deux occurrences d’un même enregistrement ne constituent pas deux preuves indépendantes. Le journal peut proposer « confirmé », « rapporté » et « à vérifier » sans dire au joueur quelle interprétation finale adopter.

## 8 Objectifs, sauvegarde et échec

La mission initiale se termine lorsque l’incident est achevé, les trois personnes sont confirmées et le relais du refuge est activé. Atteindre le 25 trop tôt doit donner une action de retour explicite. Lire toutes les preuves ou entendre l’écho de Bravo n’est pas nécessaire à cette réussite.

La première clôture exige la sauvegarde achevée au 25 puis lance un épilogue en jeu de quinze secondes, composé de trois plans de cinq secondes. Un échec d’écriture laisse le personnage et le HUD disponibles au refuge, signale l’erreur et permet de réessayer le relais ; aucun épilogue n’est lancé. E, Entrée ou le bouton de passage rejoint le bilan ; Échap suspend et reprend la séquence. Les mouvements réduits gardent chaque cadrage fixe. Le bilan montre les rescapés, les preuves collectées, le temps et les ressources de la mission, puis permet de rouvrir le journal, revoir l’épilogue ou revenir à l’accueil. Le chargement d’une mission achevée présente directement ce bilan. Aucun étage 24 jouable, ennemi final ou score de prestige n’est créé par cette clôture.

Le schéma courant de sauvegarde est **3**. Il conserve le monde, les personnes, ressources et objets consommés, ainsi que le journal et les événements radio. Les anciens schémas 1 et 2 sont validés et migrés en mémoire sans réécrire le fichier à la simple lecture. Les transmissions historiques ne sont pas rejouées en file de sous-titres après reprise. Les préférences de confort sont indépendantes de la mission.

Les points sûrs sont destinés aux paliers et aux confirmations de transfert. Une phase mobile de l’effondrement, une personne suspendue et une position de corde ne sont pas des états de reprise libre. L’incident est reconstruit dans un état stable. L’état médical au toit est dérivé du registre ; il ne dépend pas de la survie d’une animation.

La santé nulle ou une chute hors de l’espace jouable conduit à un échec. Le prototype détecte notamment une position verticale inférieure à deux mètres. La reprise doit restaurer les réussites du dernier point sûr et présenter le contexte. La cible de campagne pourra proposer une récupération par une équipe dans certains espaces, mais cette possibilité ne doit pas être promise dans la tranche actuelle.

## 9 Personnages : envies, objectifs, peurs et fonctions

Les fiches suivantes servent à écrire les comportements et dialogues. Leurs motivations sont des décisions de conception ; elles ne constituent pas des statistiques psychologiques simulées. Un personnage peut vouloir quelque chose sans que le jeu lui attribue une barre de confiance ou une peur chiffrée. Les valeurs de mobilité futures concernent l’accompagnement, pas la valeur d’une personne sauvée.

### Alex Morel — retrouver une méthode avec les autres

**Envie et objectif.** Alex veut terminer une intervention dont les résultats peuvent être nommés : qui a été trouvé, qui a été transmis et qui reste à chercher. L’objectif initial est le secours, puis la construction d’une route de retour quand la structure et les communications ne suffisent plus. Alex ne vient pas résoudre un traumatisme personnel servant d’explication globale à l’horreur.

**Peur et tension.** La peur centrale est de prendre une décision sur une information fausse et de laisser quelqu’un hors d’atteinte. Elle s’exprime par les choix de vérification, pas par des commentaires constants ni une incapacité artificielle à agir. Le personnage doit pouvoir demander de l’aide et reconnaître une limite.

**Fonction et états.** Personnage jouable, valeurs actuelles dans les tableaux précédents. La campagne suit des décisions et liens établis, sans imposer une personnalité unique. Les répliques automatiques restent courtes pour laisser une place à l’interprétation du joueur. Les états narratifs utiles sont mission active, personne à protéger, lien rompu et retour établi.

### Leïla Varga — tenir la promesse du poste

**Envie et objectif.** Varga veut conserver une organisation fiable alors que les moyens se réduisent. Elle tient le registre, confirme les personnes et donne un ordre de priorité compréhensible. Elle préfère dire qu’une information manque plutôt que produire une certitude rassurante.

**Peur et tension.** Elle craint de perdre un équipier en lui donnant un ordre devenu faux. L’impact la pousse à réduire la portée de ses affirmations. Elle peut accepter une contradiction documentée d’Alex ; une perte de liaison ne la rend ni omnisciente ni absente du récit.

**Fonction et état actuel.** Commandement par sous-titres, présence au toit dans la maquette. Aucun comportement tactique autonome ni compteur de moral n’est simulé. La production devra prévoir regard vers le terrain, échange avec Médical et geste de confirmation de réception. Les animations ne doivent pas la faire quitter le poste au moment où elle répond depuis celui-ci.

### Ana Rios — ne pas abandonner son équipe

**Envie et objectif.** Maître d’hôtel du restaurant, Ana veut savoir si ses collègues ont pu rejoindre un accès de service. Elle a organisé une partie de l’attente avant l’arrivée des secours. Son premier échange doit nommer une personne ou une action concrète, pas seulement décrire sa peur.

**Peur et tension.** Elle redoute qu’une évacuation individuelle signifie que les autres seront oubliés. Alex peut lui expliquer que son signalement sera transmis. Cette réponse prépare la valeur du registre et de la radio sans bloquer le premier tutoriel par une longue négociation.

**Fonction et états.** Premier sauvetage, déplacement porté dans la version actuelle, réception sur civière. La cible ajoute une courte réponse après prise en charge et un témoignage exploitable sur le restaurant. Son évacuation reste possible sans document secondaire. Elle ne doit pas devenir un verrou d’information exigeant une récompense.

### Samuel Breton — faire sortir les faits

**Envie et objectif.** Samuel se trouve dans les bureaux et archives. La conception lui donne un objectif lisible : signaler les documents antérieurs au désastre et éviter que leur existence soit confondue avec les dégâts récents. Sa profession précise et sa responsabilité dans l’organisation restent à confirmer par l’écriture de campagne.

**Peur et tension.** Il redoute que les secours interprètent tout comme la conséquence du typhon. Après le choc, il a aussi une peur immédiate de la façade et des bruits de structure. Son dialogue doit commencer par le trajet de sortie avant de proposer un contexte administratif.

**Fonction et états.** Deuxième transfert, couverture jaune au toit. Sa confirmation autorise l’écho facultatif au 27. Cette fonction d’événement ne signifie pas qu’il a provoqué le phénomène. La cible prévoit une déposition brève, datée comme un témoignage, confrontable à une preuve du secteur.

### Nora Haddad — protéger sans nier ce qu’elle a vu

**Envie et objectif.** Kinésithérapeute au spa, Nora veut retrouver les personnes qu’elle aidait et comprendre pourquoi certains appels reprennent des phrases anciennes. Elle connaît les installations ordinaires, ce qui permet de distinguer une panne habituelle d’une anomalie.

**Peur et tension.** Elle craint d’être discréditée si elle décrit une silhouette. Le dialogue doit accepter son observation tout en séparant ce qu’elle a vu de ce qu’elle en conclut. Sa profession ne fait pas d’elle une spécialiste universelle des machines ou du surnaturel.

**Fonction et états.** Troisième personne portée, réception basse avec couverture claire. La cible propose qu’elle indique une circulation sèche ou un équipement précis avant transfert. Elle ne doit pas faire déplacer le joueur au milieu du danger pour prouver qu’il la croit.

### Malik Serra — garder une capacité d’action propre

**Envie et objectif.** Binôme de terrain prévu pour la campagne, Malik veut rendre sa ligne parallèle utile. Il cherche ses propres personnes et compare le bâtiment réel aux plans. Ses succès et difficultés doivent exister même lorsqu’Alex ne le regarde pas.

**Peur et tension.** Il craint de devenir une charge pour l’autre équipe, ce qui peut le pousser à retarder une demande d’aide. Le joueur peut lui fournir un relais ou une route ; l’écriture doit montrer la conséquence avant une éventuelle séparation.

**Fonction et cible.** Allié de mission, pas compagnon autonome livré en 0.7.0. Une première version pourrait utiliser des postes préparés et des transitions contrôlées, puis une navigation locale. Les états utiles sont engagé, contact établi, route partagée, isolé et pris en charge. Sa survie future dépend de décisions documentées, jamais d’un silence aléatoire destiné à surprendre.

### Inès Valen — distinguer une estimation d’un fait

**Envie et objectif.** Inès veut produire une carte fiable avec des sources incomplètes. Elle compare horaires, indicatifs et relevés. Son envie de comprendre sert l’opération avant la curiosité pour le mystère.

**Peur et tension.** Elle redoute qu’un plan ancien soit utilisé comme une garantie. L’accès aux archives de Pelagos pose un conflit entre procédures et urgence, avec des conséquences à écrire. Elle n’accède pas automatiquement à chaque caméra ou porte.

**Fonction et cible.** Opératrice hors site à produire, aucune intelligence de cartographie distante actuellement simulée. Les outils doivent lui transmettre les faits réellement collectés. Son dialogue peut signaler une incompatibilité ; il ne doit pas dévoiler une salle que le joueur n’a jamais observée.

### Alma — rejoindre les siens et laisser un chemin

**Envie et objectif.** Alma veut retrouver sa mère et les adultes qui accompagnaient l’évacuation. Elle connaît certains trajets de service et des sonneries. Ses marques près du sol sont une stratégie concrète pour être retrouvée et aider ceux qui suivent.

**Peur et tension.** Elle craint de ne pas être reconnue dans un lieu où les voix se répètent. Elle peut hésiter devant une silhouette tout en gardant des moyens d’action. Le récit évite de lui donner une connaissance totale du seuil ou une qualité biologique magique.

**Fonction et cible.** Enfant de dix ans conçue pour la campagne, absente comme PNJ jouable du prototype. Les scènes de séparation restent sans violence graphique. Un suivi accompagné utilise des points protégés, jamais une poursuite punitive permanente. Sa voix, ses objets et ses gestes donnent plusieurs moyens de lire les indices, y compris sans son.

### Eva Sorel — conserver le contrôle du récit et du dispositif

**Envie et objectif.** Sorel veut sauver les données et empêcher que l’installation soit interprétée sans elle. Elle peut fournir une aide technique réelle tout en maintenant une dépendance au dispositif. Ses décisions passées doivent être établies par des documents et des témoins.

**Peur et tension.** Elle craint de perdre la maîtrise de ce qu’elle considère comme une découverte et de devoir répondre de ses conséquences. Cette peur explique ses omissions sans les excuser. Elle ne devient pas automatiquement un boss de combat parce qu’elle s’oppose à Alex.

**Fonction et cible.** Antagoniste humaine de la campagne, pas agent livré. Ses états proposés sont coopération limitée, négociation sous preuve, accès restreint et perte de contrôle. Les choix doivent modifier portes, données et moyens d’action de façon visible. Une dernière réplique ne peut effacer toutes les responsabilités établies.

### Bravo, Corde et Médical — une opération collective

**Envies et objectifs.** Bravo vérifie Hespérie ; Corde tient les itinéraires et Médical réceptionne les personnes sur Aube. Chaque groupe a une tâche qui explique sa place dans l’image. Leur présence doit répondre aux demandes du joueur sans transformer chaque membre en donneur de quête.

**Peur et tension.** Bravo réagit à la structure et gagne un abri. Corde doit préserver une ligne encore utile après le choc. Médical protège les personnes reçues. La perte du canal Bravo demeure une incertitude, pas une confirmation de morts affichée pour renforcer artificiellement le drame.

**État livré et cible.** Silhouettes procédurales, repli déterministe de Bravo et réception nommée au toit. Il n’existe pas de simulation de combat d’équipe ni de pathfinding de secours. Les premières animations de production à créer sont tourner vers une alerte, désigner un accès, se baisser, porter une caisse et accueillir un transfert. Elles doivent respecter les volumes libres des routes jouables.

## 10 Réglage, difficulté et données à recueillir

La difficulté doit d’abord modifier la marge de ressources et la fréquence de certaines menaces, sans changer la vérité du récit. La première personne, le passage obligé, le matériel minimal et la sécurité des refuges restent garantis. Les options de confort ne diminuent pas les récompenses et ne conditionnent pas les fins.

Pour une séance de test, relever le temps avant compréhension de la corde, les erreurs de sortie, le temps entre contact et réception, les appels radio demandés, les retours sur un objectif déjà terminé et les ressources restantes au refuge. Ajouter des observations verbales : ce que le joueur croit savoir sur Bravo, à qui il attribue un appel et où il pense retrouver une personne sauvée. Une bonne moyenne de vitesse ne prouve pas cette compréhension.

Les objectifs initiaux de validation sont qualitatifs : trouver Ana sans aide extérieure, comprendre que le treuil confirme le sauvetage, reconnaître la nouvelle route après le choc et distinguer réception vérifiée d’écho ambigu. Les seuils chiffrés d’acceptation doivent être fixés après une première série représentative ; cette bible ne transforme pas une estimation en résultat d’essai.

## 11 Sources et responsabilités

Les paramètres jouables proviennent de [player_controller.gd](../prototype/scripts/player_controller.gd) et [main.gd](../prototype/scripts/main.gd). La génération est définie par [floor_generator.gd](../prototype/scripts/floor_generator.gd), la communication par [radio_director.gd](../prototype/scripts/radio_director.gd), la persistance par [save_store.gd](../prototype/scripts/save_store.gd) et les représentations par [world_builder.gd](../prototype/scripts/world_builder.gd). Les noms de scripts sont vérifiables dans le dépôt ; toute modification de valeur doit conduire à réviser cette annexe.

Le [catalogue des étages](CATALOGUE_ETAGES.md) détermine où les boucles se combinent. Les [props](PROPS_INTERACTIONS.md) décrivent les actions et états locaux. Le [bestiaire](ENNEMIS_STATISTIQUES.md) définit les contre-jeux et statistiques proposés. Les [scènes](SCENES_CINEMATIQUES.md) règlent la transition entre présentation et contrôle. Le rapport de livraison conserve les résultats d’essais effectivement obtenus.
