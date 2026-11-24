# Scènes, cinématiques et accueil

**The Tower Descent — version 0.5.0.** Cette annexe fournit le découpage de l’ouverture livrée, les contrats de transition avec le jeu et les scènes à produire pour la campagne. La direction recherche la précision d’une présentation cinématographique : composition, rythme, lisibilité des équipes et continuité du son. Le résultat actuel reste une maquette en temps réel dans Godot, avec personnages et décors procéduraux. Il ne constitue pas une livraison de personnages, d’animations faciales ou d’assets « AAA » définitifs.

## 1 Intentions et langage visuel

Le premier plan doit faire comprendre une mission de secours. La catastrophe existe à l’échelle de la ville, mais le regard découvre ensuite deux équipes et trois personnes identifiables. Le titre s’efface devant la question pratique : comment descendre, retrouver quelqu’un et le remettre à une équipe qui l’attend ? L’horreur apparaît dans un espace que le joueur a d’abord appris à lire.

La palette associe mer froide, béton désaturé, éclairage médical plus chaud et balises visibles. L’or du studio appartient à l’identité de présentation. Le vert ou le jaune d’un équipement doit ensuite annoncer une fonction précise. Les volumes restent lisibles lorsque l’orage, la transparence du verre ou les effets de grain sont désactivés. Le ciel ne doit pas brûler les silhouettes des équipes ; les contre-jours doivent conserver un liseré de vêtement ou de casque.

Trois échelles alternent : l’île pour la situation, les deux tours pour la géographie et les personnes pour la mission. Une caméra de présentation peut montrer un danger déjà confirmé par la sauvegarde. Elle ne révèle ni les profondeurs ni un effondrement qui n’a pas eu lieu dans cette partie. Les plans ne présentent pas une absence de réponse radio comme une preuve de décès.

Les références d’identité proviennent de quatre dépôts vérifiés à des commits fixes. L’orthographe **Darknigthmare Kingdoms Games Productions** et le crédit **un jeu de Darknigthmare** sont conservés. La couronne au trait de Jurassic Arsenal est adaptée à une identité maritime comprenant les deux tours. Les références, leur statut et leurs limites sont documentés dans [Références de l’introduction](REFERENCES_INTRO.md).

## 2 SC00 Cartons de lancement — livré

### Durée et ordre

La séquence dure **15 secondes**. Elle peut être passée dès son début par le bouton affiché, E ou Entrée. Elle conduit à l’accueil ; elle ne crée pas de partie. Le réglage « Afficher l’introduction au lancement » permet de la désactiver aux démarrages suivants. « Revoir l’introduction » la relance volontairement depuis le menu, sans réinitialiser la mission.

| Intervalle | Carton et fonction | Traitement actuel |
| --- | --- | --- |
| 0 à 3,6 s | Darknigthmare Kingdoms Games Productions | Emblème, nom du studio et mention Productions ; apparition et extinction progressives |
| 3,6 à 5,6 s | présente | Respiration typographique, sans information de mission |
| 5,6 à 8 s | un jeu de Darknigthmare | Attribution de l’œuvre, nom propre inchangé |
| 8 à 15 s | THE TOWER DESCENT | Titre, « Chaque vie compte. Chaque étage vous éloigne du ciel. », révélation plus claire du décor |

Les fondus de carton utilisent une fenêtre de 0,65 seconde. La scène 3D reste derrière une surimpression sombre, des bandes de cinéma et un voile graphique. L’interface utilise les fontes Open Sans embarquées, avec contraste clair sur fond sombre. L’emblème est un SVG ; il n’exige pas de texture générée à chaque lancement.

### Caméra, son et interaction

Le plan d’ensemble observe la mer et les tours avec un champ de vision de 53 degrés. En mode caméra animée, il avance lentement vers le site. Avec les mouvements réduits, activés par défaut, il conserve un point de vue fixe. Les textes et le fondu portent alors le rythme. Aucun balancement de la caméra de joueur n’est ajouté pour compenser l’immobilité.

Un motif original synthétique de 3,6 secondes fournit la signature de lancement. L’ambiance de menu prend ensuite le relais. Ce matériau est une composition procédurale reproductible, pas un enregistrement orchestral ni une musique licenciée présentée comme originale. La coupure de l’audio reste effective pendant l’introduction et après son passage.

Le contrôle de passage doit rester visible indépendamment de la phase du carton. Une longue image ou plusieurs pressions rapprochées ne doivent pas créer plusieurs menus ni lancer une intervention. Le directeur calcule le plan à partir du temps de séquence, ce qui permet une arrivée directe à l’état final. La sauvegarde de mission reste inchangée pendant ce parcours.

## 3 SC01 Accueil contextuel — livré

### Source de vérité

Le décor de l’accueil est reconstruit à partir d’une **sauvegarde validée**, en utilisant son dernier point sûr. Le menu ne récupère pas une position brute issue d’une partie interrompue en rappel ou pendant l’effondrement. Une sauvegarde rejetée ne doit pas produire un décor de progression plausible : l’accueil revient au contexte initial et la reprise n’est pas proposée.

| Point sûr validé | Cadrage de l’accueil | Informations autorisées |
| --- | --- | --- |
| Aucune partie | Mer et deux tours debout | Opération Orphée, première rotation, Alpha et Bravo |
| Toit, étage logique 31 | Poste médical d’Aube | Personnes réellement confirmées au treuil et état enregistré des tours |
| 30 | Restaurant | Dernier point sûr, personnes sauvées et état structurel sauvegardé |
| 29 | Suites et perspective vers Hespérie | Tour intacte avant l’incident ; conséquences seulement après leur confirmation |
| 28 | Archives et noyau | Passage condamné si l’impact a été sauvegardé ; détour déjà connu |
| 27 | Jardin des enfants | Dernier point sûr et bilan humain enregistré |
| 26 | Spa | État connu du secteur, sans révélation des souterrains |
| 25 ou intervention terminée | Refuge | Bilan et consultation d’une intervention achevée |

Le décor affiche le nombre de vies sauvées et le temps de mission du point sûr. La réception médicale utilise les mêmes identifiants qu’en jeu ; elle n’invente pas une personne supplémentaire pour enrichir le plan. Une fin de prototype demeure consultable et n’est pas présentée comme le début d’un nouvel étage.

Les façades extérieures des six étages sont opaques vues de dehors, tandis que leur face intérieure n’obstrue pas les cadrages intérieurs. Elles suivent les parents visuels endommagés lors de l’impact. Cette enveloppe ne crée aucune collision. Les étiquettes 3D propres au gameplay sont exclues des caméras d’accueil et de cinéma ; l’interface de présentation porte les informations nécessaires. Ces choix corrigent la lecture de tours artificiellement ouvertes en coupe depuis la mer.

### Actions et protection de la partie

La colonne principale propose **Reprendre l’intervention**, **Nouvelle intervention**, **Dossier de mission**, **Options**, **Revoir l’introduction** et **Quitter** sur ordinateur. Sans sauvegarde valide, le bouton principal devient **Commencer l’intervention** et la reprise disparaît. Une intervention terminée propose **Consulter l’intervention terminée**. Quitter n’apparaît pas dans l’export Web.

Nouvelle intervention ouvre un panneau consacré au déploiement. Le joueur y choisit la disposition, exprimée par un nombre de 1 à 999 999 ; la valeur initiale est 271104. Si une partie existe, le panneau annonce qu’elle sera remplacée et que les réglages de confort seront conservés. L’action **Déployer Alpha** confirme ce remplacement. Retour referme le panneau sans toucher à la mission.

Le dossier présente la situation et le parcours des six étages. Avant l’effondrement, les deux tours sont décrites comme debout. Après un point sûr enregistrant l’impact, il indique la liaison coupée, le noyau praticable et l’absence de réponse de Bravo. Cette information doit toujours correspondre à la sauvegarde utilisée pour le décor.

Les options sont accessibles avant une nouvelle partie. Elles comportent ambiance sonore, réduction des mouvements de caméra, activation des éclairs lumineux et introduction au lancement. Les valeurs par défaut sont audio actif, mouvements réduits actifs, éclairs désactivés et introduction active. Les sous-titres sont toujours affichés. Ces préférences sont enregistrées séparément de la mission et chargées avant le choix d’afficher le prologue.

### Composition et comportement

Le titre et les actions occupent le côté gauche sur un dégradé sombre. Le point sûr et le bilan occupent le bas droit, sans concurrencer la vue principale. Le focus clavier est visible ; Reprendre reçoit le focus quand il existe, sinon Commencer. Le retour d’un panneau replace le focus sur l’action principale.

Les mouvements réduits donnent un plan fixe. Le mode animé ajoute un déplacement de faible amplitude, sans rotation complète autour des tours ni exposition à une zone non atteinte. L’horloge du menu peut faire vivre le fond, la pluie et les rotors. Elle ne consomme ni oxygène, ni endurance, ni temps de mission. Le départ des hélicoptères ne progresse pas parce que le joueur lit les options.

## 4 SC02 Arrivée sur Aube — livré

### Déclenchement et durée

Une nouvelle intervention commence par **28 secondes**, divisées en quatre plans de sept secondes. La reprise d’un point sûr ne rejoue pas cette arrivée. Le passage volontaire conduit au joueur sur le toit avec une mission prête à commencer ; il ne saute aucun sauvetage et ne déclenche pas l’incident. La pause suspend le directeur et les communications de cette séquence.

La caméra accompagne désormais une arrivée animée des deux appareils. Leurs trajectoires, inclinaisons, portes coulissantes et déplacements des équipes sont calculés à partir du temps de la séquence. La cabine possède des volumes intérieurs, une ouverture latérale et des sièges de maquette. Les membres existants des équipes sortent et gagnent leurs postes ; les jambes et les bras prennent des poses de marche. Ce dispositif n’utilise ni capture de mouvement, ni animation faciale, ni personnage équipé d’un squelette de production. Les appareils, équipes et tours restent des représentations procédurales.

| Plan | Image, objectif et champ de vision | Carton |
| --- | --- | --- |
| 1, 0–7 s | Vue large sur la mer, la ville et les appareils en approche ; faire comprendre l’isolement, 56° | ÎLE DE NACRE ; 04:17 / PREMIÈRE ROTATION DE SECOURS |
| 2, 7–14 s | Rapprochement sur les deux toits pendant les posés successifs ; nommer la géographie, 53° | LES TOURS ORPHÉE ; AUBE / HESPÉRIE |
| 3, 14–21 s | Vue des cabines ouvertes et du déploiement des équipes ; rendre leur relation spatiale concrète, 64° | DEUX ÉQUIPES ; ALPHA SUR AUBE / BRAVO SUR HESPÉRIE |
| 4, 21–28 s | Arrivée vers le poste d’Aube et le point de prise en main ; cadrage dégagé de l’antenne, 62° vers 76° en mode animé | VOTRE LIGNE TIENT ; AUBE / POSTE DE COMMANDEMENT |

En caméra animée, chaque plan interpole une position et un regard avec accélération et décélération progressives. Les mouvements réduits conservent des cadrages fixes ; le dernier plan reste une vue stable du poste avant la remise du contrôle. Les bandes et sous-titres sont identiques dans les deux modes. Le champ de vision de la caméra jouable, 77 degrés, reprend à l’issue de la transition.

### Dépose et déplacements de la version 0.5

Le premier plan établit une distance à parcourir : Alpha commence à 28 m au-dessus de son point de stationnement et Bravo à 36 m. Chaque appareil rejoint une approche à faible altitude puis son repère au toit. L’altitude des modèles reste supérieure ou égale à leur stationnement final ; ils ne traversent pas une dalle pour rejoindre une position imposée. Ces trajectoires de mise en scène ne représentent pas un modèle de vol pilotable.

| Événement | Temps de séquence | Résultat visible |
| --- | --- | --- |
| Fin d’approche de Bravo | 6,5 s | Transition vers la descente finale au-dessus d’Hespérie |
| Fin d’approche d’Alpha | 8,0 s | Transition vers la descente finale au-dessus d’Aube |
| Toucher de Bravo | 10,8 s | Appareil posé et inclinaison annulée |
| Ouverture de Bravo | 11,2 à 13,4 s | Portes latérales coulissantes |
| Toucher d’Alpha | 13,4 s | Appareil posé sur l’hélisurface d’Aube |
| Ouverture d’Alpha | 13,8 à 16,0 s | Cabine accessible visuellement avant le déploiement |
| Déploiement des équipes | 16 à 23 s | Sortie échelonnée et marche vers les postes préparés |
| Fermeture des cabines | 24 à 26 s | Appareils prêts pour leur futur départ |
| Remise de la caméra au joueur | 28 s | Équipes en place et début de l’horloge de mission |

La poussière et les embruns du rotor sont des effets de présentation proches des toits. Leur intensité augmente pendant l’approche basse et diminue avant la remise du contrôle. Ils n’exercent aucune force sur le personnage et ne constituent pas un danger. Les pales principales et de queue tournent selon l’horloge de présentation ; la pause les fige avec le son. Les mouvements réduits stabilisent les caméras tout en conservant les déplacements des appareils et des équipes nécessaires à la compréhension de la scène.

La fin naturelle, le passage à n’importe quel instant et la reprise du point sûr initial doivent donner les mêmes portes fermées, appareils posés et membres en poste. Ces poses sont absolues et peuvent être appliquées plusieurs fois sans déplacement supplémentaire. L’état d’arrivée n’est pas enregistré. Le point sûr du toit contient une intervention prête à jouer ; il ne stocke ni une caméra intermédiaire ni un équipier à mi-chemin de la cabine. Les quatre transmissions continuent à respecter leurs repères : passer la séquence ne crée pas celles qui n’ont pas encore été entendues.

Le départ opérationnel conserve une autre horloge. Il commence après dix secondes de mission pour Alpha et treize pour Bravo ; chacun suit un éloignement de vingt-trois secondes. La durée passée dans l’introduction ne réduit donc pas la présence des appareils après la prise en main. Un menu construit depuis un point sûr à un temps plus avancé replace directement les appareils selon ce temps, sans rejouer la dépose.

L’équipe Bravo possède ensuite ses propres poses de repli lors de l’incident. Restaurer ou réappliquer la fin de l’arrivée après cet incident ne doit pas faire réapparaître ses membres sur le toit. La séparation entre arrivée et repli protège la continuité du récit et évite de transformer une opération visuelle en réinitialisation des conséquences.

### Texte exact des quatre communications

À **0,6 s**, HÉLIX 2 / APPROCHE NACRE : « Nacre en vue. La ville est sous les eaux. Les deux tours sont toujours debout. » Le message reste prévu pour 6,4 secondes. Il décrit seulement ce que l’approche confirme.

À **7,2 s**, VARGA / OPÉRATION ORPHÉE : « Alpha sur Aube, Bravo sur Hespérie. On vérifie chaque signal. Aucun étage n’est déclaré sûr. » La durée prévue est 6,4 secondes. Cette phrase donne la méthode : la radio guide mais ne certifie pas à elle seule un espace.

À **14,2 s**, BRAVO / ÉQUIPE HESPÉRIE : « Bravo posé. Nous voyons votre équipe de l’autre côté. On reste en contact. » La durée prévue est de six secondes. Le lien entre les toits est posé avant que la situation se dégrade.

À **21 s**, VARGA / POSTE D’AUBE : « Alex, rejoignez la ligne de rappel. Ana Rios vous attend au restaurant du 30. On tient votre corde. » La durée prévue est de sept secondes. Le premier objectif et la destination de retour sont explicites à la prise en main.

Ces répliques sont actuellement des sous-titres. Aucun doublage enregistré n’est fourni. Les messages empruntent le système de communication du jeu et son journal, mais les indices d’émission de la cinématique sont protégés contre les doubles appels. Passer la séquence termine ses indices ; les lignes non encore émises ne sont pas artificiellement rejouées derrière le premier objectif.

### Son et remise du contrôle

Une boucle originale de rotor de huit secondes soutient l’arrivée. Le motif de menu, d’une durée de seize secondes, et la signature de lancement sont produits par le script audio du dépôt. Leur mixage reste un premier équilibre, à vérifier sur plusieurs sorties audio pendant la production. La lecture des sous-titres ne dépend pas de la présence du son.

L’horloge de mission demeure suspendue pendant l’arrivée. La caméra de cinéma est courante, le déplacement est désactivé et les dangers, départs d’appareils et treuillages n’avancent pas. À la fin, le masque se retire, le HUD revient, la caméra du joueur devient courante et le contrôle est activé si le jeu n’est pas en pause. L’objectif d’Ana est rappelé. Une pause au dernier instant ne doit pas rendre la souris captive derrière un écran encore ouvert.

## 5 SC03 Le premier sauvetage et sa réception

Cette scène est jouée. L’ouverture s’achève au poste, le joueur apprend la corde puis atteint le restaurant du 30. Les accessoires P01, P02, P04 et P11 forment une chaîne visuelle : ligne, balise, treuil et réception médicale. Aucun plan forcé ne doit cacher la commande au moment de sortir de la corde.

Le prototype permet de sécuriser Ana avec E, de la transporter jusqu’à la balise et d’observer une montée de cinq secondes. La confirmation au treuil inscrit `survivor_30` parmi les personnes sauvées. La silhouette d’Ana apparaît ensuite au poste médical du toit. Le dispositif fonctionne aussi avec Samuel et Nora, chacun avec un nom, une pose ou une couverture distincte.

La cible de production ajoute un regard d’Alex vers la ligne tendue, un geste d’accueil de l’équipier et une réponse courte de la personne recueillie. Ces inserts doivent pouvoir être désactivés et ne jamais masquer une sortie. Ils ne demandent pas une caméra externe obligatoire : le mouvement de la corde et l’équipe au-dessus peuvent suffire. La priorité demeure la certitude qu’une personne a été prise en charge.

## 6 SC04 Effondrement d’Hespérie — livré et cible d’habillage

Le déclenchement se fait depuis l’observation du 29 après le sauvetage d’Ana et le départ des appareils. Depuis la baie Est, l’incident démarre après un regard maintenu vers Bravo ou une confirmation explicite avec E. Il n’est pas lancé pendant le transport d’une personne, un treuillage ou la traversée de la corde. Les conditions et la machine d’état sont détaillées dans [Effondrement en direct](EFFONDREMENT_EN_DIRECT.md).

Le découpage livré suit avertissement de huit secondes, réplique de six secondes, bascule de sept secondes et impact de quatre secondes. Les ordres de Bravo et Varga se succèdent avec priorité opérationnelle. Les membres visibles de Bravo se tournent puis gagnent l’intérieur ; leur disparition derrière les volumes est un repli, pas une animation de mort. Hespérie bascule suivant une animation déterministe, puis un état stable endommagé remplace le passage Est du 28 par le détour du noyau.

La caméra reste liée au joueur : elle encourage à regarder mais ne téléporte pas Alex sous les débris pour obtenir une meilleure image. L’avertissement doit être perceptible hors champ par la radio, le grondement et les premières vibrations. Une personne qui détourne le regard conserve une compréhension de l’ordre d’événements grâce aux messages et au journal.

Pour l’habillage final, le plan sonore commence par une oscillation du verre et des attaches, laisse une courte suspension avant la rupture principale, puis distingue contact, chute de débris et retour des appels. La cible évite une compression uniforme qui couvrirait Varga. La poussière révèle progressivement la géographie transformée ; elle ne doit pas conserver un écran opaque plus longtemps que nécessaire à la lecture du nouveau passage.

Les tests doivent séparer la puissance de la scène et sa justesse mécanique : trajet survivant toujours praticable, sortie de corde libre, restauration directe de l’état final, absence de dégâts issus d’une collision de décor non prévue. Le caractère spectaculaire ne valide pas ces contrats à lui seul.

## 7 SC05 L’écho de Bravo au 27 — livré

Après l’impact et le sauvetage confirmé de Samuel, le joueur peut entendre au 27 un fragment déjà prononcé par Bravo. Le jardin reste un lieu de baisse de pression. L’appel n’ajoute pas de créature et ne transforme pas ce point de respiration en piège. La scène demande six secondes calmes, sans communication active ni action de corde ou de transfert.

La vérification de Varga suit après deux nouvelles secondes calmes dans un lieu autorisé : 27, 25 ou toit. Ce déplacement possible permet au dialogue de respecter l’activité du joueur. L’événement est mémorisé : recharger ne rejoue pas éternellement la même incertitude. Les règles exactes sont décrites dans [Communications et équipes](COMMUNICATIONS_ET_EQUIPES.md).

La cible d’habillage utilise une différence discrète de couleur sonore et une absence de réponse directe. Le texte demeure lisible sans filtre sonore. Le scénario ne tranche pas ici entre répétition technique, présence et survivant. Le joueur doit pouvoir formuler une hypothèse sans qu’une interface ne lui impose une conclusion.

## 8 SC06 Refuge et compte rendu — livré

Le relais du 25 termine le périmètre de démonstration. L’écran récapitule les sauvetages et expose le journal des communications conservées. La présentation distingue personnes confirmées au treuil, informations recueillies et incertitude sur Bravo. La dernière image jouée reste un lieu sûr, sans attaque déclenchée par l’ouverture du bilan.

Le menu peut ensuite proposer de consulter cette intervention terminée. Son décor correspond au refuge et son texte à la partie achevée. Le résultat n’autorise pas la présentation d’un bunker, d’Alma retrouvée ou d’une fin de campagne : ces chapitres sont conçus mais ne sont pas jouables dans la version 0.5.0.

## 9 Storyboards de campagne à produire

### SC07 Retrouver Alma au socle

**Contexte et fonction.** Au A01, le joueur atteint une zone d’évacuation après avoir retrouvé les marques de l’enfant. La scène répond à une recherche concrète, avant d’ouvrir la seconde descente. Alma doit être reconnue par son nom et une interaction vérifiable ; aucune substitution par une apparition n’annule ce progrès.

**Découpage cible, 20 à 35 secondes intégrées au jeu.** Premier temps : plan à hauteur d’Alex à travers une séparation légère, silhouette immobile et bruit identifiable d’un objet. Deuxième temps : Alma répond à une question simple et désigne le groupe à rejoindre. Troisième temps : la caméra suit le geste vers un trajet court ; contrôle complet avant le premier déplacement. Les regards, le cadre de porte et l’éclairage guident sans flèche couvrant le personnage.

**Audio, état et sortie.** Le bruit extérieur baisse pendant la réponse sans disparition magique du monde. La conversation crée un état « Alma identifiée », pas « évacuée ». La sauvegarde sûre précède la transition suivante. Toute réplique passée est résumée par un objectif court. Les accessoires P31, P33 et P34 rappellent les indices rencontrés au jardin.

### SC08 Rupture de la terrasse A00

**Contexte et fonction.** La ligne protège d’abord Alex et Alma, puis la rupture d’un appui préparé provoque la chute vers les anciens bains. Cette transition est écrite et ne doit pas être attribuée à un échec de commande. Le joueur voit avant la rupture une structure qui travaille et entend un ordre de mise à couvert.

**Découpage cible, 12 à 18 secondes.** Montrer l’appui instable dans le regard du joueur, couper le mouvement pendant l’accrochage, suivre une courte traction de la ligne puis traverser la poussière. Éviter une caméra en chute libre tournant sur tous les axes. Le mode mouvements réduits emploie un fondu court entre la rupture et la reprise, avec les mêmes informations radio. Le retour de la lampe sur un repère proche donne l’orientation.

**États et reprise.** Conserver les personnes déjà mises à l’abri. Sauvegarder avant rupture puis au premier état souterrain jouable. Un crash au milieu reprend l’un de ces deux états certifiés, jamais un personnage suspendu sans issue. La réserve minimale nécessaire à la reprise est garantie ; le scénario n’exige pas une fusée conservée depuis le 30.

### SC09 Le bassin et le Porteur

**Contexte et fonction.** Au S01, une présence entraîne Alma vers une galerie. Le cadrage confirme une direction et un objectif sans violence graphique. Le Porteur, E04, est un acteur de trajet préparé ; sa scène ne dépend pas d’une poursuite physique aléatoire susceptible de coincer l’enfant.

**Découpage cible, 10 à 16 secondes.** Vision basse depuis le bassin, prise de la lampe, silhouette large franchissant un seuil, marque d’Alma sur un élément visible. Reprendre le contrôle avant la première bifurcation. Une trace matérielle et un appel sous-titré persistent si le joueur passe l’insert. Le passage n’ajoute pas un délai réel caché de survie de l’enfant.

**Contrechamp et son.** Le Porteur ne reçoit pas de gros plan explicatif. Sa masse coupe une source lumineuse puis sort du champ. L’écho du bassin diminue pour laisser entendre la galerie utile. Le premier espace jouable offre outils essentiels et point d’orientation stable.

### SC10 Le premier contrôle SILLAGE

**Contexte et fonction.** Au S07 puis B01, l’architecture industrielle change la lecture de la catastrophe. Une porte et un tableau montrent que l’isolement précède le tsunami. Les informations essentielles sont réparties entre un registre, un état de porte et un témoin, pas dissimulées dans un seul long enregistrement.

**Découpage cible, 15 à 25 secondes facultatives.** Regard vers le logo de contrôle, vers la porte fermée du côté intérieur, puis vers une date et un ordre d’isolement. Le joueur peut interrompre la lecture et utiliser le sas. Sorel peut répondre à la radio depuis un lieu identifié ; son objectif est de conserver les données, ce qui crée un conflit concret sans exposé complet sur le seuil.

**Production.** P45, P47 et P48 portent les informations. E05 peut imposer une discipline d’émission dans le secteur suivant, après explication de la règle. Ne pas cumuler une transmission indispensable, un verrouillage de porte et une attaque pendant ce premier apprentissage.

### SC11 Le seuil et le retour

**Contexte et fonction.** B06 et P666 reprennent des lieux déjà traversés. La scène exploite la mémoire du joueur : table, casier, balise et voix sont reconnaissables, mais leur relation change. La fermeture s’appuie sur des règles enseignées et sur un réseau de retour, pas sur un choix opaque dans un dialogue final.

**Découpage cible.** Trois objectifs courts, séparés par des points d’orientation, remplacent une longue cinématique. Chaque action produit une conséquence visible sur une liaison. Les plans ne quittent le contrôle que pour un changement spatial impossible à communiquer autrement, pendant deux à quatre secondes au maximum par insert. E09 et E10 agissent sur perception et réponse, sans barre de vie de boss arbitraire.

**Conclusion cible, 35 à 60 secondes passables.** Une galerie étroite s’ouvre vers le jour. Le son sépare de nouveau mer, vent et radio. Une réponse liée aux personnes et relais préservés confirme la continuité humaine. La vue basse des tours mesure la descente. Le bilan fournit les personnes sauvées et les preuves, sans transformer une exposition maximale au danger en score obligatoire.

## 10 Contrats de réalisation et validation

Chaque séquence doit déclarer son état d’entrée, son point de sortie, les événements qu’elle peut écrire et sa stratégie de passage. Le lancement et le menu n’écrivent pas de progression. L’arrivée initialise une mission puis rend le contrôle. L’effondrement produit un changement structurel persistant. Les transitions de campagne futures doivent disposer d’une sauvegarde avant et après leur portion non jouable.

Un événement narratif n’utilise pas le temps passé dans un menu comme délai caché. La pause suspend images narratives, communications et dangers. Une longue image traverse correctement les repères temporels ; un message n’est ni doublé ni sauté par erreur d’index. Une reprise applique l’état du monde sans répéter tous les sous-titres de l’intervention précédente.

Les contrôles de présentation couvrent au minimum menu initial, tous les contextes de reprise, cartons de lancement, quatre plans d’arrivée, modes de mouvement, son coupé, passage immédiat et pause près de la dernière image. La revue visuelle doit aussi vérifier silhouettes sur le ciel, façades intactes avant impact, absence d’antenne devant l’objectif du dernier plan et absence d’étiquettes de gameplay dans les caméras de cinéma.

Les essais automatiques valident les durées, états, préférences, événements et garde-fous d’intégration. Une capture ne prouve pas la qualité d’une transition sonore ; un test sans fenêtre ne prouve pas la lisibilité d’une image. Les résultats de livraison et les vérifications effectivement réalisées sont consignés dans [État de livraison](ETAT_DE_LIVRAISON.md).

## 11 Sources de vérité et prochaines passes

Le découpage livré est défini par [cinematic_director.gd](../prototype/scripts/cinematic_director.gd), l’accueil par [frontend_menu.gd](../prototype/scripts/frontend_menu.gd), les cartons par [cinematic_overlay.gd](../prototype/scripts/cinematic_overlay.gd) et les options par [preferences_store.gd](../prototype/scripts/preferences_store.gd). [main.gd](../prototype/scripts/main.gd) assure le changement de caméra, les horloges et la remise du contrôle. Le décor et la réception médicale viennent de [world_builder.gd](../prototype/scripts/world_builder.gd).

La prochaine passe de production doit d’abord valider la compréhension du parcours sans commentaire extérieur, puis remplacer les silhouettes par des rigs, travailler gestes et regards, enregistrer les voix et mixer l’ambiance. Les nouvelles ressources doivent respecter les durées et les contrats de sauvegarde. Un meilleur rendu ne justifie pas l’allongement automatique de l’ouverture ni la suppression de son passage immédiat.
