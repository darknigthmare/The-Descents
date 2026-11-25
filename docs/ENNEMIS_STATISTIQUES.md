# Présences ennemis et statistiques de rencontre

**Version 0.7.0 — Une figure jouable et dix archétypes de campagne — 25 novembre 2026**

Le joueur affronte des situations qu’il peut lire, vérifier et modifier. Le bestiaire sert la mission de sauvetage : il ne transforme pas chaque étage en arène à nettoyer. Une routine ancienne, une voix imitée et un animal territorial n’utilisent pas les mêmes règles, même si tous peuvent créer de la tension.

Une seule menace mobile simplifiée est actuellement intégrée à la tranche : la figure du spa au 26. Les dix archétypes de campagne ci-dessous sont des spécifications, avec des valeurs initiales à tester. Aucun chiffre proposé n’est présenté comme une mesure issue d’une partie de campagne ou d’un équilibrage déjà validé.

La 0.7 conserve ce périmètre. Le dossier et l’épilogue du refuge n’ajoutent ni adversaire ni combat final. Le fragment de relais laisse l’origine du signal ouverte ; il ne confirme pas la présence d’un archétype de campagne dans le secteur jouable. La simulation hostile reste suspendue pendant la lecture du journal et après la clôture de mission.

## Convention des statistiques

Les distances sont en mètres, les vitesses en mètres par seconde, les durées en secondes et les dommages en points sur une santé de référence de 100. Les valeurs correspondent au mode de campagne « Référence » proposé. La marche actuelle d’Alex est de 3,7 m/s, sa vitesse avec une victime de 2,4 m/s, et sa course de 6 m/s ; ces repères motivent les vitesses de poursuite et les fenêtres de repli.

Un temps d’annonce commence lorsque le joueur peut percevoir une intention hostile, pas lorsque le script décide intérieurement de l’attaque. Une détection requiert une visibilité ou un événement conforme à la fiche. Une porte opaque bloque une vision ; une simple distance ne doit pas faire traverser un mur. La maquette actuelle du spa n’implémente pas encore toutes ces règles : ses limites sont décrites séparément.

Les points de vie de combat ne sont pas un champ obligatoire pour une présence sans corps. La Rémanence et le Répondant ne deviennent pas « tuables » pour remplir une colonne. Lorsqu’une créature corporelle possède une vitalité interne proposée, sa résolution pacifique et la protection des personnes restent possibles ; l’interface ne demande pas de vider une jauge pour poursuivre.

| Code | Famille | Rôle principal | Statut |
| --- | --- | --- | --- |
| E00 | Figure du spa | Première menace lisible, lampe et fusée | Jouable en maquette |
| E01 | Rémanence | Observer une routine et lire une route | Campagne |
| E02 | Répondant | Vérifier une voix et son contexte | Campagne ; échos radio préparatoires présents |
| E03 | Noyé sec | Retirer un bruit qui masque l’approche | Campagne |
| E04 | Porteur | Protéger une personne et préparer un détour | Campagne |
| E05 | Veilleur | Gérer une émission et un cône d’observation | Campagne |
| E06 | Creuseur | Traverser un territoire sans l’agresser | Campagne |
| E07 | Délié | Reconnaître une personne dans une crise | Campagne |
| E08 | Contremaître | Comprendre puis modifier une ronde | Campagne |
| E09 | Chambre qui écoute | Maintenir des repères dans un espace réactif | Campagne |
| E10 | Chœur bas | Rompre les liaisons du seuil | Campagne |

## E00 Figure actuellement jouable au spa

**Silhouette et rôle.** Figure humaine sombre étirée en hauteur, deux petits repères ambrés au visage, construite avec les volumes existants. Elle se trouve au 26, autour du bassin et de Nora. Son rôle est d’enseigner la différence entre une lumière ordinaire qui ralentit et une fusée qui donne un temps de repli. Elle n’est pas encore un rig animé ni une IA générale de campagne.

| Paramètre actuel | Valeur et comportement |
| --- | --- |
| Activation | Plus de 4 s cumulées dans le traitement actif du niveau 26 |
| Vitesse avec lampe allumée | 0,72 m/s |
| Vitesse avec lampe éteinte | 1,1 m/s |
| Cible | Position horizontale du joueur, hauteur fixe du niveau 26 |
| Portée de contact | Distance inférieure à 2 m |
| Dommage | 12 points |
| Délai entre dommages | 3 s |
| Pression de stress | +0,9 point/s lorsque la figure est visible |
| Fusée | Figure cachée et replacée au fond tant que le temps de fusée est positif ; effet de 20 s |
| Après contact | Repositionnement de la figure loin du joueur |
| Exclusions | Figure cachée hors du 26, sur la corde et pendant l’incident |
| Vitalité | Aucun système de dégâts infligés à la figure |

**Contrejeu actuel et limites.** Allumer la lampe, garder une distance, employer une fusée ou rejoindre la corde. L’effet de la lampe dépend actuellement de son état allumé, pas d’un test du faisceau sur la silhouette. La fusée utilise une durée globale, pas une exposition spatiale. Le déplacement se fait par rapprochement direct et ne fournit pas encore une navigation de contournement ; il ne faut pas attribuer au personnage une compréhension des portes ou du mobilier. Le rayon de contact est une simplification à revoir avec des animations finales.

**Recette.** Sauver Nora avec et sans fusée, revenir chercher le relevé, quitter puis retrouver l’étage, ouvrir la pause, passer sur la corde et reprendre un checkpoint. Vérifier que la figure ne s’expose pas au 27 ou au refuge, qu’une menace masquée ne produit pas de dégâts invisibles et que son repositionnement reste compréhensible. Les résultats réels de la révision appartiennent au rapport de livraison.

## E01 La Rémanence

**Rôle et apparence.** Employé ou visiteur reproduisant une action banale dans un lieu endommagé : porter un plateau, fermer une porte inexistante, compter une rangée de chaises. La tenue et la trajectoire appartiennent à une époque reconnaissable. Introduire cette présence avant la première menace corporelle pour enseigner que toute silhouette n’est pas un adversaire à repousser.

**Valeurs proposées.** Taille 1,6 à 1,9 m ; vitesse de routine 0,6 à 1 m/s ; boucle de 12 à 18 s ; distance de première lecture 8 à 14 m ; fondu d’entrée et de sortie de 0,8 s. Dommages 0, portée d’attaque inexistante, poursuite 0. Pas de points de vie. Une seule routine active dans une pièce, deux occurrences principales maximum dans un même secteur narratif.

**États et règle.** Dormante, routine visible, répétition attendue, observation consignée, retirée. La séquence reste identique pour une même occurrence. Une variation après observation doit être écrite comme une autre étape et posséder un indice, pas résulter du hasard d’animation. La Rémanence ne tourne pas soudainement vers le joueur pour le frapper.

**Contrejeu et usage.** Attendre depuis un appui sûr, suivre à distance, comparer le trajet à un plan. La routine peut révéler une porte de service cachée par une cloison récente. La sortie principale ne dépend pas de toucher la figure. Une source lumineuse ne la détruit pas ; une mesure ou un témoin enrichit la preuve.

**Son, placement et reprise.** Pas, vaisselle ou fragment de phrase répétés à l’identique, sous-titrés comme reprise. Première scène proposée à A23, développement dans H-SALON. Reprendre la partie repart du début d’une boucle lisible si la preuve n’est pas acquise ; le journal empêche de la compter plusieurs fois. Recette : voir deux cycles, couper le son, quitter avant la fin, revenir avec preuve déjà consignée.

## E02 Le Répondant

**Rôle et apparence.** Présence vocale sans silhouette obligatoire. Elle imite le phrasé d’un secouriste ou d’un proche à partir de fragments disponibles. Elle connaît ce qui a été enregistré, mais échoue sur un détail récent vérifié. L’écho facultatif de Bravo est une préparation à cette règle ; il ne prouve pas à lui seul que le Répondant en est l’auteur.

**Valeurs proposées.** Fenêtre d’appel de 6 à 10 s ; délai minimal de 90 s après une communication importante ; au plus un appel trompeur dans une fenêtre de 4 min ; deux indices de vérification accessibles ; réponse contextuelle donnée en 2 à 4 s. Dommages directs 0, points de vie sans objet. Une erreur ajoute au plus 8 points de stress et un détour borné de 20 à 40 s, sans détruire un sauvetage.

**États et règle.** Fragment disponible, canal libre, imitation, question de contrôle, incohérence observable, retrait ou réponse différée. Un appel prioritaire réel interrompt sa présentation. L’entité ne peut annoncer comme système que le toit n’est plus sûr ou que le registre a été effacé. Les paroles fausses restent des paroles attribuées à une source, pas une modification de l’objectif certifié.

**Contrejeu.** Demander un détail du dernier transfert, comparer au journal, couper le canal, rejoindre un relais authentifié. Ignorer l’appel ne bloque pas la campagne. Les questions utilisent des données déjà connues et consultables ; aucun test de mémoire rapide n’est requis. Un témoignage indépendant permet de résoudre la contradiction sans reconnaître une voix d’acteur.

**Son, placement et reprise.** Même traitement de base que les vrais secours ; l’erreur vient du contexte ou du timing. A22 introduit le faux appel, A17 permet sa vérification. Les événements sont persistés et ne redémarrent pas après chaque chargement. Recette : priorité de transport, journal plein, sous-titres longs, source inconnue sans stéréo et choix de ne pas répondre.

## E03 Le Noyé sec

**Rôle et silhouette.** Forme humaine couverte de dépôts secs dans une pièce où l’eau ne justifie pas sa présence. Elle avance lorsque le bruit d’une machine masque ses pas. Le joueur apprend à transformer le paysage sonore en moyen de surveillance.

**Valeurs proposées.** Taille 1,85 m, enveloppe 0,65 m ; marche masquée 1,25 m/s ; déplacement à découvert 0,35 m/s ; perception visuelle à 12 m dans un cône de 100° avec visibilité réelle ; télégraphe d’approche finale 1,4 s ; portée d’attaque 1,5 m ; dommage 15 ; récupération 4 s ; poursuite limitée à 12 m de sa zone d’origine. Pas de mort par points de vie : la rencontre se résout en retirant son couvert sonore ou en fermant sa route.

**États et règle.** En attente, bruit couvrant présent, approche, entendu, hésitation, attaque annoncée, repli. L’arrêt de la machine gèle l’approche rapide et expose les pas ; une lampe maintenue sur la forme pendant 1,5 s impose une hésitation de 3 s. Une fusée crée une fenêtre de passage de 10 s, avec retour annoncé après l’extinction. Ces valeurs doivent être évaluées face au portage à 2,4 m/s.

**Contrejeu et échec.** Couper la pompe, déplacer une source de bruit pour lire le passage, éclairer, refermer une porte. La première erreur coûte une atteinte et un recul vers un appui, sans enchaînement de coups. Le joueur peut toujours quitter le secteur par le chemin protégé ; aucune apparition derrière lui ne bouche la seule issue.

**Son, placement et reprise.** Les pas deviennent nets lorsque le moteur s’arrête ; sous-titre directionnel optionnel et poussière au sol donnent une information visuelle. Première scène complète proposée en H-CHAMBRES ou A09, pas au restaurant. Maximum un Noyé actif. Un checkpoint restaure la forme dans sa poche de départ, loin du joueur, et conserve les machines déjà arrêtées.

## E04 Le Porteur

**Rôle et silhouette.** Grande forme ramassée, épaules chargées, membres visibles avant le corps entier. Elle déplace des objets et, dans une scène de campagne, emporte Alma vers une galerie. Cette séparation est un événement écrit ; une prise en charge déjà certifiée au réseau supérieur n’est jamais annulée par un spawn aléatoire.

**Valeurs proposées.** Taille au repos 2,3 m, largeur 1,1 m ; marche 1,1 m/s ; engagement bref 2,5 m/s pendant 3 s maximum ; perception à 10 m dans 90° ; préparation visible 2,2 s ; portée 1,8 m ; dommage 24 ; récupération 6 s ; poursuite de 8 m avant réorientation. Pas de victoire par dégâts. Deux sources de lumière convergentes pendant 2 s le font reculer de 3 m et ouvrent une fenêtre de 7 s.

**États et règle.** Garde un seuil, détecte, protège une charge, avance, se couvre de la lumière, recule, retourne à son objectif. Il poursuit une fonction concrète ; il n’apparaît pas au hasard pour augmenter la difficulté. Ses trajets ne peuvent traverser une porte plus étroite que sa silhouette.

**Contrejeu.** Préparer une deuxième lumière fixe, attirer l’attention vers un objet, fermer une porte lourde ou emprunter une ouverture latérale. Le joueur observe d’abord la réaction au faisceau avant de devoir l’exécuter avec une personne. Une hache ne suffit pas à arrêter l’élan ; un geste de défense éventuel donne seulement le temps d’atteindre un appui.

**Son, placement et reprise.** Frottement d’objet, souffle bas et appuis lourds, sans cri permanent. Séquence principale après la chute dans S01 ; une reprise ultérieure maximum avant le bunker. Au chargement, Alma est soit encore dans l’état d’avant la séparation, soit dans l’état narratif suivant, jamais attachée à un acteur suspendu au milieu d’une animation.

## E05 Les Veilleurs

**Rôle et silhouette.** Présences liées aux postes d’observation SILLAGE : corps minces, tête orientée vers une source d’émission, gestes économes. Elles réagissent à une radio ou à un équipement actif, ce qui donne une raison de connaître la source de chaque signal.

**Valeurs proposées.** Taille 2 m ; ronde 0,8 m/s ; investigation 1,8 m/s ; rayon d’audition d’une émission 14 m, réduit par les cloisons du niveau ; vision 11 m, cône 70° ; acquisition de 1 s ; annonce d’attaque 1,2 s ; portée 1,4 m ; dommage 18 ; récupération 4,5 s. Mémoire d’une dernière émission 6 s. Un leurre attire au moins 5 s ; une émission continue ne verrouille pas éternellement le joueur.

**États et règle.** Surveillance, émission détectée, investigation au dernier point, recherche, attaque annoncée, retour. Une radio coupée ne rend pas Alex invisible si celui-ci est déjà devant la figure ; elle supprime le nouvel indice sonore. La lampe ne l’efface pas automatiquement. Pas de points de vie affichés ; deux frappes défensives espacées peuvent interrompre une poursuite, sans nettoyer la zone.

**Contrejeu.** Couper un poste, poser un leurre sonore, traverser derrière un obstacle, attendre la fin d’une rotation de caméra. Un appel obligatoire de mission attend une position sûre ou suspend cette rencontre pour éviter un piège imposé par le scénario.

**Son, placement et reprise.** Servos du poste, parasites et pas espacés ; les émissions actives ont un signe visuel. A17 enseigne le réseau sans Veilleur agressif ; H-OBSERVATION ou S07 porte la première épreuve. Maximum deux Veilleurs avec cônes non superposés sur toute l’issue. Reprise aux postes, jamais en contact immédiat avec Alex.

## E06 Les Creuseurs

**Rôle et silhouette.** Faune cavernicole altérée, basse, aux membres adaptés au relief. Les nids, débris et traces précèdent la créature. Son comportement territorial permet d’éviter le combat et fait lire la hauteur du sol comme une ressource.

**Valeurs proposées.** Corps de 0,9 m de long sur 0,45 m de haut ; déplacement prudent 1 m/s ; approche 2,8 m/s ; bond court de 4,2 m/s pendant 0,5 s après une annonce de 1 s ; détection de vibrations à 8 m pour la marche et 13 m pour la course ; hors sol, détection divisée par deux selon les surfaces prévues. Portée de morsure 0,9 m ; dommage 10 ; récupération 3 s ; vitalité interne initiale 40, repli automatique à 20 pour éviter une mise à mort obligatoire.

**États et règle.** Nid, écoute, inspection d’une vibration, avertissement, défense, repli. Le joueur qui recule de 6 m hors du territoire et cesse de produire des chocs pendant 4 s rompt l’engagement. L’animal ne suit pas Alex sur une échelle ni dans un refuge.

**Contrejeu.** Marcher lentement, traverser une voie haute, lancer un objet de leurre à un point préparé, détourner une machine vibrante. La lampe montre les traces mais n’est pas une arme universelle. Une défense à l’outil repousse ; l’équilibrage doit favoriser le détour plutôt que l’acharnement.

**Son, placement et reprise.** Grattements, clics et déplacement de cailloux avec alternatives visuelles. S05 introduit un nid ; maximum trois individus, un seul attaquant à la fois, délai minimal de 2 s entre engagements de membres différents. Aucun nid ne couvre simultanément les deux trajets de sortie. La reprise remet les animaux dans leur territoire avec une grâce d’observation.

## E07 Les Déliés

**Rôle et silhouette.** Personnes transformées ou désorientées qui conservent des réactions à un nom, un objet ou une routine. Les signes humains doivent rester reconnaissables. Le joueur peut préserver une distance, établir un contact et ouvrir un passage sans devoir exécuter la personne.

**Valeurs proposées.** Taille humaine ; déambulation 0,5 m/s ; agitation 1,7 m/s ; approche de reconnaissance 0,6 m/s ; portée de voix 6 m ; fenêtre de réponse 4 s sans compte à rebours punitif ; annonce d’agitation 1,5 s ; portée de saisie 1,2 m ; dommage de bousculade 8 ; récupération 5 s. Vitalité de combat non utilisée dans la boucle de sauvetage. Une reconnaissance correcte stabilise pendant au moins 20 s.

**États et règle.** Repli, stimulus, agitation, repère reconnu, interaction courte, route protégée. Le nom n’est efficace que si le joueur a obtenu une preuve ; répéter au hasard une liste de noms n’est pas un puzzle. Après un échec, un autre indice permet de comprendre la réaction.

**Contrejeu et résultat.** Réduire le bruit, montrer l’objet personnel depuis une distance sûre, appeler la personne identifiée, ouvrir une séparation physique. Le journal distingue contact établi, aide en cours et prise en charge confirmée. Une personne confiée à un refuge ne redevient pas un ennemi pour remplir un quota de rencontre.

**Son, placement et reprise.** Respiration et mots fragmentaires, sous-titres respectueux qui ne diagnostiquent pas la personne. Présence proposée à A09 ou B02 ; une seule interaction de ce type active avec un rescapé en cours. La reprise conserve les indices et la relation acquise, puis replace les acteurs dans une configuration non collée.

## E08 Le Contremaître

**Rôle et silhouette.** Ancien responsable technique pris dans une répétition. Il vérifie des circuits, compte des gestes et corrige ce qui lui paraît hors séquence. Sa menace vient d’une ronde qui entre en conflit avec la route d’Alex, puis d’une règle que le joueur peut lui rendre inoffensive.

**Valeurs proposées.** Taille 1,95 m ; ronde 0,85 m/s ; déplacement de correction 2 m/s ; cycle de 42 s comprenant trois postes ; attente de 6 s à chaque poste ; vision 10 m dans 100° ; annonce d’intervention 2 s ; portée 1,6 m ; dommage 20 ; récupération 5 s. Recherche limitée à 9 s. Aucune jauge de vie : trois postes mis dans un ordre cohérent résolvent la scène.

**États et règle.** Inspection, constat, annonce, correction, recherche, reprise de ronde. Les arrêts et le sens de marche sont observables depuis une niche sûre. Une action du joueur peut rediriger l’étape suivante ; elle ne téléporte pas le personnage vers un poste hors champ.

**Contrejeu.** Observer un cycle, lire le schéma simplifié, intervenir sur un circuit lorsque le poste est libre, fermer une porte de service pour gagner du temps. Une erreur rétablit seulement la tâche locale incomplète ; elle ne réinitialise pas toute l’enquête du bunker.

**Son, placement et reprise.** Liste murmurée, outils et relais ; transcription des mots utiles. Une seule séquence majeure en B04. La sauvegarde se fait dans une alcôve et conserve les postes réglés ; la ronde reprend dans une phase d’observation d’au moins 8 s avant tout contact hostile. Recette : ordres alternatifs, pause entre deux postes et déplacement avec un témoin.

## E09 La Chambre qui écoute

**Rôle et apparence.** Menace spatiale sans corps unique. Elle reproduit une pièce connue et modifie une connexion lorsque personne ne l’observe. Les balises, les mesures et les témoins donnent une prise concrète sur l’espace ; le jeu ne dépend pas d’un couloir aléatoire infini.

**Valeurs proposées.** Salle d’épreuve de 12 à 20 m de côté, trois sorties apparentes et une route de secours fixe ; changement après 3 s hors observation ; transition d’au moins 1 s ; maximum trois reconfigurations avant qu’un indice de résolution soit renforcé. Dommages directs 0 dans l’apprentissage, 8 points au plus pour une collision narrative annoncée dans une reprise avancée. Pas de points de vie. Deux repères persistants suffisent à établir la contradiction.

**États et règle.** Forme stable, observation perdue, transition, nouvelle connexion, comparaison, route ancrée. Aucune géométrie solide ne se déplace dans la capsule ou une victime. Le changement se limite aux connexions préparées ; le noyau, le point sûr et les objets déjà acquis restent valides.

**Contrejeu.** Mesurer deux distances, marquer un mur, garder un témoin à une ouverture, poser une balise et revenir par une autre porte. Le joueur peut réussir sans mouvement rapide de caméra. Le mode confort remplace tout effet d’inclinaison par un fondu ou une modification hors champ, sans simplifier la preuve.

**Son, placement et reprise.** Réponse acoustique légèrement retardée, texte descriptif si elle porte un indice. A14 prépare la comparaison, A13 montre une contradiction courte, P666 emploie la forme complète. Sauvegarder la configuration logique, pas seulement la position d’Alex. Une reprise dans une version de salle supprimée doit être migrée vers un appui sûr.

## E10 Le Chœur bas

**Rôle et apparence.** Présence finale constituée de fragments de lieux et d’appels superposés. Les voix ne forment pas une foule visuelle coûteuse à combattre ; elles entretiennent trois liaisons identifiables. Le joueur résout un système qu’il a appris à lire, tout en protégeant Alma et le réseau de retour.

**Valeurs proposées.** Trois objectifs de liaison ; fenêtres d’action de 8 à 12 s après un contre-signal ; interruption annoncée 2,5 s ; dommage éventuel de pression 12, jamais plus d’une fois par fenêtre de 5 s ; zone d’appui sûre entre objectifs ; durée cible de la scène complète 6 à 9 min à tester. Aucun point de vie et aucune phase exigeant une précision de tir. Au plus trois couches vocales intelligibles, une parole opérationnelle prioritaire.

**États et règle.** Réponse globale, liaison ciblée, préparation, interruption, liaison isolée ou détournée, accalmie, prochaine étape. Les choix portent sur énergie, motif et réponse humaine. Le système conserve les résultats des objectifs accomplis et n’annule pas un sauvetage antérieur lorsque le joueur échoue à une autre liaison.

**Contrejeu et fins.** Couper ou détourner les réseaux selon les preuves, obtenir une confirmation d’un témoin, cesser une réponse qui alimente la présence. Les options de résolution sont annoncées par leurs conséquences locales. La fin dépend de plusieurs états persistants ; aucune option de confort ou de difficulté ne donne automatiquement la mauvaise fin.

**Son, placement et reprise.** Les voix reprennent des motifs entendus plus haut, avec mots compréhensibles et silences de décision. Aucun volume extrême n’est nécessaire à l’intensité. Rencontre unique P666, routes et stations préparées. Le checkpoint reprend à une accalmie entre objectifs avec le même état d’Alma, du seuil et des preuves.

## Contraintes communes de rencontre

Une rencontre physique ne commence pas pendant un transfert obligatoire de tutoriel, une cinématique d’approche, la consultation d’un refuge ou un effondrement déjà chargé. Le directeur de campagne doit réserver au moins 30 s de respiration après une rencontre longue et un appui sûr avant d’introduire une nouvelle règle. Ce délai est une cible d’équilibrage ; le prototype ne possède pas encore ce directeur général.

Les ennemis corporels ont un volume de navigation, une visibilité et une distance de désengagement cohérents avec leur silhouette. Une erreur technique de pathfinding suspend le danger ou replace l’acteur hors champ dans une poche valide ; elle ne tue pas un survivant coincé. Aucun spawn ne se fait à moins de 6 m du joueur ou à l’intérieur de son champ immédiat, sauf apparition visuelle sans attaque expressément écrite. Les refuges certifiés sont exclus par données et par validation.

Les attaques ne s’empilent pas. Un seul attaquant au contact est autorisé dans les premiers secteurs ; les autres investiguent ou avertissent. Après un coup, la fenêtre de récupération est perceptible. La remise à distance ne s’accompagne pas d’une nouvelle apparition derrière Alex. Les dégâts d’environnement et ceux d’ennemis doivent être testés ensemble, notamment le portage ralenti dans l’eau.

## Profils de difficulté proposés

| Paramètre de campagne | Accompagné | Référence | Pression |
| --- | --- | --- | --- |
| Dommages des attaques | 0,65 fois la fiche | Valeur de fiche | 1,2 fois la fiche |
| Temps d’annonce | 1,4 fois la fiche | Valeur de fiche | 0,9 fois la fiche, minimum 1 s |
| Recherche après perte du joueur | 0,7 fois la durée | Valeur de fiche | 1,2 fois la durée |
| Ressources du chemin critique | Même minimum garanti | Même minimum garanti | Même minimum garanti |
| Vérification des indices | Aide explicite après échec | Aide contextuelle | Même preuves, aide plus tardive |
| Refuge, pause et confirmations | Garanties identiques | Garanties identiques | Garanties identiques |

Ces profils ne sont pas des réglages déjà disponibles. Les changements de difficulté ne modifient ni la chronologie, ni les noms, ni la vérité du registre, ni l’accès aux fins. Les options de mouvements réduits, de sous-titres et de flashes sont séparées de la difficulté.

## Données de production et recette

Une fiche livrée au moteur comprendra l’identifiant d’archétype, la version des valeurs, les états autorisés, les perceptions, les conditions de dégâts, les destinations de repli, les exclusions de spawn et les signaux de chaque transition. Les rencontres scénarisées ajoutent un identifiant d’événement et leurs prérequis. Les statistiques ne doivent pas rester cachées dans plusieurs animations contradictoires.

Pour chaque rencontre, mesurer le temps de première compréhension, les dégâts avant compréhension, les dépenses indispensables, le temps de repli et les échecs de navigation. Enregistrer aussi si le joueur a compris le résultat humain de l’action. Réussir un test de distance ne prouve pas que le signal d’attaque a été vu. La recette comprend son coupé, mouvements réduits, lecture prolongée, pause à chaque transition, reprise avant et après résolution, retour avec charge et absence totale de consommable optionnel.

Références locales : [menace actuelle et ressources](../prototype/scripts/main.gd), [construction de la figure](../prototype/scripts/world_builder.gd), [mouvement du joueur](../prototype/scripts/player_controller.gd), [règles de la campagne](BIBLE_DU_JEU.md) et [objets de contrejeu](PROPS_INTERACTIONS.md).
