# Architecture du prototype et portage vers Unreal Engine 5

Version de conception 0.6.0 — Présentation cinématique et continuité de mission — 24 novembre 2026

Ce document décrit le prototype Godot 0.5.0 et propose une trajectoire vers Unreal Engine 5. La tranche solo en vue subjective comprend un toit, six étages de 30 à 25, trois sauvetages, trois indices et un refuge. Les deux tours commencent intactes, deux hélicoptères et des groupes de secours sont visibles en maquette, puis un effondrement partiel se déroule pendant l’observation depuis le 29. La campagne complète et le portage UE5 restent à produire.

Le projet déclare une base de fonctionnalités Godot 4.7. Les exécutables, versions de moteur effectivement utilisées et résultats de vérification sont décrits dans le rapport de livraison du dépôt. Ce document ne constitue pas un rapport d’exécution d’Unreal Engine. La coopération en réseau n’est pas implémentée.

## Architecture actuellement présente

La scène d'entrée `prototype/scenes/main.tscn` instancie le contrôleur principal. Celui-ci construit le monde à partir d'une graine, ajoute le personnage, puis relie l'interface et les interactions. La géométrie est créée par code, sans dépendance à des modèles achetés ou à un service distant.

| Fichier dans prototype/scripts | Responsabilité réelle |
| --- | --- |
| `main.gd` | Cycle menu et partie, objectifs, interactions, ressources, événements, treuillage, points de reprise et coordination des autres scripts |
| `player_controller.gd` | `CharacterBody3D`, caméra, marche, course, saut, déplacement lent accroupi, rappel guidé, lampe et tracé de corde |
| `floor_generator.gd` | Production déterministe des six descriptions d'étage et validation des invariants de contenu |
| `world_builder.gd` | Géométrie et collisions, repli préparé de Bravo, réception nominative des sauvés, appareils, rupture, détour et points interactifs |
| `collapse_director.gd` | Phases et durées de l’incident, transitions et restauration de ses états stables |
| `radio_director.gd` | File de sous-titres ordinaires, priorité des alertes et historique borné des transmissions |
| `save_store.gd` | Schéma 3, migration stricte en lecture des schémas 1 et 2, progression et données radio, remplacement contrôlé du checkpoint |
| `cinematic_director.gd` | Échantillonnage du prologue de 15 s et de l’arrivée de 28 s, quatre plans, quatre repères de communication, contexte du menu |
| `frontend_menu.gd` | Accueil, reprise, nouveau déploiement confirmé, dossier et réglages de confort |
| `cinematic_overlay.gd` | Cartons, bandes, sous-titres et commande de passage des séquences |
| `preferences_store.gd` | Préférences booléennes validées, indépendantes de la mission et chargées avant le prologue |
| `hud.gd` | Jauges, objectifs, commandes contextuelles, radio, journal, pause et bilan |
| `presentation_geometry.gd` | Géométrie native des hélicoptères, sauveteurs, équipement du toit et repères littoraux, sans modifier les collisions de mission |
| `field_props.gd` | Catalogue de douze observations, construction des accessoires et projection de leur texte depuis le contexte de mission |
| `inspection_panel.gd` | Fiche de lecture défilante et fermeture, dont la pause et la reprise sont coordonnées par la mission |

Le personnage utilise `move_and_slide()` pour la marche. Godot décrit `CharacterBody3D` comme un corps contrôlé par script disposant notamment de détection des murs et des pentes ; la gravité et les règles de déplacement restent ici écrites dans le contrôleur. [Documentation Godot CharacterBody3D](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html)

`main.gd` est volontairement central pour cette tranche courte. Avant d'étendre la campagne, séparer ses responsabilités en gestion de mission, ressources, interactions, événements et sauvegarde évitera que chaque nouveau niveau ajoute des conditions dans une boucle unique.

## Présentation, horloges et vérité de la progression

Le prologue et l’arrivée possèdent leur temps de séquence ; le menu dispose d’un temps d’animation distinct. Le temps de mission ne progresse ni pendant l’accueil ni pendant les 28 secondes d’arrivée. Les départs d’hélicoptères, dangers et treuillages restent ainsi liés à l’intervention jouée. La pause suspend les séquences. Passer l’arrivée applique une sortie unique : fin du directeur, caméra du joueur courante, HUD visible et contrôle rendu seulement si l’état de pause le permet.

Depuis la 0.5, `Cinematics.staging_sample(time)` fournit les décalages des deux appareils, leurs rotations, l’ouverture des portes, l’intensité des embruns et la progression des équipes. `world.apply_arrival_staging(sample)` applique ces valeurs absolues. `restore_arrival_staging()` remet les poses finales sans supprimer un repli déjà appliqué pendant l’incident. Aucun Tween ne détient la progression, aucun état de cabine ou de vol transitoire n’est sérialisé. La fin naturelle, le passage et le chargement du point sûr du toit font l’objet d’une comparaison dans une scène réelle.

Le constructeur d’observations retourne douze nœuds `kind = inspect` ajoutés au tableau des interactions. Leur identifiant stable sert au catalogue, pas au calcul de fin de mission. La sélection exige proximité, même étage, orientation et rayon physique libre. Les commandes de mission conservent leur priorité à moins de 1,5 m. L’ouverture de la fiche réutilise la pause de mission ; le signal de fermeture reprend le jeu. Le panneau reçoit des données textuelles et ne peut ni consommer un objet ni écrire une sauvegarde.

L’accueil reçoit uniquement le résultat validé de `save_store.gd`. Le contexte utilise le dernier étage sûr, le registre des sauvés, l’état stable d’incident et le temps enregistré. Il restaure un décor de présentation sans lancer de nouvelle mission. Sans sauvegarde valide, les tours sont intactes et le bouton Reprendre n’apparaît pas. Après une intervention terminée, le menu propose sa consultation au refuge. Les contrôles et textes sont détaillés dans [Scènes cinématiques](SCENES_CINEMATIQUES.md).

Les façades extérieures ajoutées en 0.4.0 sont des surfaces visuelles sans collision. Leur face arrière n’est pas rendue pour conserver la lecture depuis l’intérieur ; les panneaux endommagés suivent les groupes de façade du 29 et du 28. Les étiquettes 3D de gameplay utilisent une couche de visibilité exclue des caméras de présentation. Ce masque ne modifie ni les objets interactifs ni la caméra jouable.

Les préférences `audio`, `reduced_motion`, `flashes` et `startup_intro` sont des booléens du fichier `user://preferences.cfg`. Le chargeur conserve des valeurs par défaut sûres en cas de champ incorrect. Leur écriture utilise un fichier temporaire puis un remplacement. Elles ne dépendent pas de la création d’une sauvegarde de mission. Les mouvements réduits et l’absence d’éclairs sont les réglages initiaux.

Le son de présentation provient de boucles synthétiques originales générées par un outil du dépôt : thème de menu de 16 s, signature de 3,6 s et rotor de 8 s. Les textes de l’approche ne sont pas doublés par des voix enregistrées. Les ressources doivent être embarquées dans les exports et le basculement du son doit s’appliquer aux effets déjà actifs.

## Espace et limites de la simulation

Le monde utilise le mètre. Une dalle jouable se trouve à `y = (numéro − 24) × 6` ; le toit est à 42 m dans le repère local. La mer est à −132 m. Cette origine permet de travailler sur les niveaux supérieurs tout en conservant une façade de gratte-ciel jusqu'au niveau de l'eau.

Chaque plateau mesure 24 m de côté et laisse un puits central de 5,4 m. Les points d'entrée de corde, de secours et de collecte occupent des emplacements protégés. Les variantes déplacent une portion de mobilier et la décoration sans déplacer les éléments nécessaires à l'objectif. Il existe donc une variation procédurale contrainte, pas encore une génération complète de plans architecturaux.

Le rappel actuel guide directement la position dans le puits, ajoute une oscillation latérale et affiche une ligne. L'ancrage secondaire amortit le balancement pendant une durée limitée. Ce dispositif n'est pas une simulation de corde segmentée ni un calcul d'efforts d'un système de sauvetage.

Le sauvetage reste simplifié : sécuriser le rescapé ralentit le joueur ; rejoindre la balise déclenche une remontée animée. Après confirmation, `world.set_rescued_people(rescued)` projette le registre au poste médical du toit. Les figures, noms, couvertures et la civière sont préconstruits, sans collision ni nouvel interactable. La méthode peut être rappelée après chargement et reçoit une liste vide à chaque nouvelle partie. Elle ne constitue ni une IA de blessé ni une animation complète de transfert. L’accroupissement abaisse la caméra et réduit la vitesse, sans réduire la capsule.

## Génération déterministe et persistance

Le générateur conserve les fonctions architecturales et les objectifs : restaurant 30, suites 29, archives 28, accueil enfants 27, spa 26, refuge 25. Les canaux de hasard séparés sélectionnent variante, décoration, danger et anomalie. Le refuge, l'accueil initial et la respiration narrative du niveau 27 restent protégés des événements hostiles.

La graine permet de retrouver une partie avec le même code et le même environnement moteur. Elle ne constitue pas une garantie de reproduction entre toutes les versions : Godot indique que l'algorithme interne du générateur aléatoire est un détail d'implémentation. [Documentation Godot RandomNumberGenerator](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html)

La sauvegarde de schéma 3 contient la graine, le niveau sûr, les ressources, le temps, les étages visités, les personnes sauvées, les indices, les caisses utilisées, `incident_state`, `transmissions` et `radio_events`. Elle conserve au plus 32 transmissions et deux événements facultatifs. Le chargeur refuse les types incorrects, nombres non finis, champs manquants ou supplémentaires, incohérences radio et tailles excessives. L’écriture passe par un temporaire voisin avant remplacement. Le contrat exact figure dans [Systèmes procéduraux](SYSTEMES_PROCEDURAUX.md).

L'identité courante `type_étage`, par exemple `survivor_28`, convient à un objet de chaque type par étage. La campagne devra adopter des identifiants indépendants de l'ordre de création, tels que `aube/28/archive/samuel`. Ajouter `generation_version`, `content_revision` et le manifeste des étages générés au format de sauvegarde permettra de migrer les données et de charger la même disposition après un portage. Ne pas sauvegarder les adresses des acteurs ou leurs indices dans un tableau.

Le chemin historique `user://save_v1.json` permet de retrouver les parties existantes. Les schémas 1 et 2 sont validés avant migration en lecture. Le premier déduit l’incident du seul état de fin ; le second conserve son état explicite. Tous deux commencent avec journal et événements radio vides. Une reprise ne rejoue pas un ancien sous-titre. Le prochain checkpoint réussi écrit le schéma 3. Un arrêt pendant l’effondrement reprend le point stable préalable ; `aftermath` restaure directement les dégâts et les prises en charge.

## Incident du 29 et séparation des états

L’observation se débloque après le treuillage confirmé d’Ana et le départ des deux hélicoptères. L’objectif mène à la baie Est du 29. Approche et regard vers Hespérie arment la scène ; aucun minuteur global ne déclenche la rupture pendant l’apprentissage. Le directeur déroule quatre phases de session : `warning` (8 s), `quake` (6 s), `collapse` (7 s), `impact` (4 s), puis `aftermath`. Ses valeurs `phase` et `phase_elapsed` restent distinctes de l’état de sauvegarde.

Le contrôleur de mission décide quand avancer le directeur, quand afficher la radio et quand sauvegarder. La pause ne lui transmet aucun temps de progression. Le constructeur du monde applique la présentation de la phase et l’état final ; le contrôleur du joueur garde l’autorité sur ses commandes et son mouvement. Le point sûr est enregistré avant l’avertissement, puis après la stabilisation. Aucune phase intermédiaire n’est chargée comme une position arbitraire parmi des débris en mouvement.

La rupture affecte surtout la façade haute et un itinéraire latéral. La tour voisine reste partiellement debout contre Aube. Le puits, le noyau intérieur, les objectifs de sauvetage et le refuge conservent leurs accès. Cette approche représente une destruction scénarisée avec une conséquence persistante ; elle ne simule pas la tenue structurelle d’un gratte-ciel. Le [dossier de séquence](EFFONDREMENT_EN_DIRECT.md) fixe les contrats de progression et la proposition d’acting.

## Air respirable et perception

La variable actuelle appelée `oxygen` représente une **réserve abstraite d'air respiratoire**, normalisée de 0 à 100. Elle diminue dans les étages marqués fumée ; une caisse la remplace. À épuisement dans la fumée, la santé diminue. Le jeu ne mesure pas actuellement la teneur ambiante en oxygène, la pression d'une bouteille ou une consommation respiratoire physiologique.

Pour la version complète, distinguer trois éléments dans les données et l'interface : mesure d'atmosphère du capteur, autonomie du dispositif respiratoire et exposition à un danger. Une atmosphère signalée dangereuse ne doit pas vider instantanément une bouteille ; une bouteille pleine ne doit pas afficher un air ambiant sain. Les seuils et durées seront des paramètres d'équilibrage clairement présentés au joueur.

Le stress est aujourd'hui un indicateur de tension modulé par les événements, la radio et les espaces sûrs. Il ne doit pas devenir un pourcentage arbitraire autorisant n'importe quelle hallucination. Le système futur distinguera événements objectifs, perceptions individuelles et preuves persistantes, chacun avec des conditions et un contre-jeu définis dans la bible.

## Répartition proposée sous Unreal Engine 5

La structure suivante est une recommandation de portage, pas une liste de classes déjà créées. Conserver les règles testables en C++ et exposer aux Blueprints les paramètres, présentations et assemblages de niveaux.

| Élément proposé | Responsabilité |
| --- | --- |
| `ADescentCharacter` | Avatar, caméra, posture et équipement visible |
| `UDescentMovementComponent` | Marche et mode de rappel contrôlé |
| `URescueInteractionComponent` | Recherche de cible, portée, visibilité et actions |
| `URescueMissionSubsystem` | Objectifs, personnes secourues et états de progression |
| `UDescentIncidentController` | Proposition : prérequis, phases de catastrophe, pause, points de reprise et état persistant |
| `UFloorGenerationSubsystem` | Manifeste déterministe et validation des étages |
| `UFloorStreamingSubsystem` | Chargement des niveaux nécessaires et restauration de leurs états |
| `UAtmosphereComponent` | Danger local, exposition et consommation des réserves |
| `UDescentSaveGame` | Données persistantes versionnées |
| Blueprints de modules | Pièces, portes, points d'ancrage, accessoires et mise en scène |
| Widgets UMG | Interface, radio, journal et réglages |

Créer des actions Enhanced Input pour marcher, regarder, s'attacher, monter, descendre, poser un ancrage, utiliser le matériel et ouvrir le journal. Des contextes distincts « marche », « rappel » et « interface » clarifieront les commandes. Epic documente précisément les actions, contextes et changements de contexte à l'exécution. [Documentation Epic Enhanced Input](https://dev.epicgames.com/documentation/en-us/unreal-engine/enhanced-input-in-unreal-engine)

## Portage du rappel

La première étape UE doit reproduire le rappel guidé actuel avant d'ajouter une physique plus libre. Utiliser un mode de mouvement personnalisé associé au personnage, avec une longueur de corde, un point d'ancrage, une vitesse de descente et une limite latérale explicites. Le mouvement de la capsule doit vérifier les collisions ; quitter la corde nécessite une surface d'appui et un volume libre.

Le Character Movement Component fournit les modes standards et le cadre des mouvements personnalisés. Son intégration réseau ne rend cependant pas automatiquement répliquée une nouvelle mécanique de corde : les états et commandes supplémentaires devront être traités lors d'une phase dédiée. [Documentation Epic Character Movement](https://dev.epicgames.com/documentation/en-us/unreal-engine/understanding-networked-movement-in-the-character-movement-component-for-unreal-engine)

Un Cable Component pourra afficher la ligne et ses oscillations. Epic décrit une simulation par particules contraintes ; le choix proposé est de l'utiliser pour la présentation, tandis que le contrôleur conserve l'autorité sur le déplacement jouable. Cela évite de faire dépendre le passage d'une porte d'une instabilité de câble décoratif. [Documentation Epic Cable Components](https://dev.epicgames.com/documentation/en-us/unreal-engine/cable-components-in-unreal-engine)

Les ancrages futurs seront des points autorisés avec identifiant, support et état. La pose ne coupera jamais silencieusement la ligne principale. Tester la reprise de corde, le retour sur dalle, la pause et la restauration après sauvegarde avant d'introduire le secours simultané de plusieurs personnes.

## Chargement des étages et état des acteurs

Le prototype construit actuellement les six niveaux et l'extérieur ensemble. Pour la campagne, conserver un niveau persistant léger contenant le ciel, la mer, les silhouettes des tours et la structure du puits. Charger les intérieurs proches du joueur, puis anticiper l'étage suivant pendant la descente. Garder chargés les éléments nécessaires à une victime en cours de treuillage.

Un choix initial raisonnable est l'étage courant, celui du dessus et celui du dessous, avec marge supplémentaire près d'une transition. Ce budget reste à mesurer sur la machine cible. Le Level Streaming d'Unreal permet de charger, décharger et masquer des niveaux par volumes, Blueprints ou C++. [Documentation Epic Level Streaming](https://dev.epicgames.com/documentation/en-us/unreal-engine/level-streaming-overview-in-unreal-engine)

Avant déchargement, transférer les états utiles dans un registre indépendant des acteurs : victime évacuée, indice lu, porte ouverte, ancrage posé. Au retour, reconstruire le module puis appliquer ce registre. Une silhouette extérieure simplifiée peut rester visible sans maintenir tout son intérieur. World Partition pourra être évalué pour l'île élargie ; il n'est pas un préalable au premier bâtiment vertical.

## Procédural et développement de l’effondrement sous UE5

Le générateur de campagne doit d'abord assembler un graphe praticable : entrée, sortie, secours, ravitaillement et chemin de retour. Il doit ensuite vérifier les largeurs, ressources nécessaires et respirations narratives. Les variantes décoratives viennent après cette validation.

Le framework PCG d'Unreal constitue une option pour distribuer végétation, gravats et accessoires à partir de règles. Il ne doit pas remplacer les invariants de sauvetage ou décider seul de la progression narrative. Cette utilisation est une proposition adaptée au rôle de génération procédurale décrit par Epic. [Documentation Epic PCG](https://dev.epicgames.com/documentation/en-us/unreal-engine/procedural-content-generation-framework-in-unreal-engine)

Dans le prototype 0.5.0, Hespérie passe d’un état vertical intact à un état partiellement effondré pendant le jeu. Son état final, le détour et les communications sont persistants. Le portage UE5 proposé doit d’abord reproduire ce contrat, avec trajectoires préparées, zone d’observation, commandes libres, pause réelle et reprises avant/après. Des débris et effets plus détaillés pourront ensuite enrichir la scène sans décider de la praticabilité du trajet de secours.

Pour la production UE5, prévoir des groupes distincts : structure intacte, volume mobile de rupture, façade haute endommagée, débris décoratifs et collisions finales. Le contrôleur narratif resterait responsable du passage d’état ; une éventuelle simulation de débris ne serait pas la source de vérité des routes. L’approche en hélicoptère et le jeu d’acteurs de l’équipe opposée constituent des séquences supplémentaires à produire. Ces choix sont des propositions d’architecture, pas du code UE5 livré.

La liaison basse du 6 donnera plus tard accès à Hespérie à travers des dégâts secondaires ; elle ne rejouera pas le premier impact des étages hauts. La chute d’Alex et Alma vers le bassin reste une transition distincte de l’acte trois. Une simulation structurelle complète des deux tours n’est pas prévue : la scène doit conserver des résultats reproductibles et un sauvetage praticable.

## Sauvegarde UE et coopération ultérieure

Transposer les données persistantes vers une classe `USaveGame`, en conservant les identifiants du contenu et les versions du manifeste. Epic prévoit les écritures synchrones et asynchrones et recommande la voie asynchrone pour éviter une interruption perceptible pendant le jeu. Tester explicitement le comportement en cas de fichier absent, version ancienne et écriture interrompue. [Documentation Epic Saving and Loading](https://dev.epicgames.com/documentation/en-us/unreal-engine/saving-and-loading-your-game-in-unreal-engine)

La coopération constitue un chantier distinct. Définir d'abord l'autorité sur les victimes, le treuil et les ressources partagées. Une hallucination individuelle doit rester une perception locale ; la mort d'un PNJ ou l'ouverture d'un passage doit être un état commun. Tester ensuite déconnexion, retour d'un joueur et chargement d'étages avec deux équipiers éloignés. Aucune de ces fonctions n'est présente dans cette livraison.

## Phases et critères de passage

### Contrats de contenu avant extension

Les fiches P01 à P52 doivent devenir des données séparant représentation, interaction et état persistant. Chaque instance porte un identifiant stable, un volume d’usage, des états autorisés et des points de pose. Un modèle artistique ne doit pas créer sa propre collision de route par défaut ; le niveau décide quelles surfaces bloquent réellement le joueur et les personnes transportées.

Les archétypes E01 à E10 décrivent des règles de campagne, tandis qu’E00 documente la silhouette actuelle. La future interface d’une présence doit recevoir des faits observables : cible, distance, ligne de vue, bruit ou émission. Elle ne doit pas lire arbitrairement le contenu caché d’une sauvegarde pour deviner le joueur. Les limites de territoires, refuges et transferts restent des contraintes imposées par la mission.

La première extraction technique prioritaire est un registre d’entités indépendantes des nœuds. Les noms actuels `survivor_30`, `evidence_29` ou `supply_25` conviennent à la tranche mais ne distinguent pas plusieurs objets de même type au même étage. La campagne doit utiliser des identifiants de contenu, un manifeste de génération et un état sérialisable versionné. Les animations d’accueil et les groupes visibles doivent pouvoir être reconstruits depuis ce registre.

Le portage UE5 doit conserver ces contrats avant de remplacer les images : montage de présentation annulable, horloge de mission séparée, reprise sûre et résultat humain persistant. Les références d’API externes de ce document décrivent une trajectoire d’architecture ; aucun projet Unreal compilé ni comparaison de performances avec Godot n’est livré.

### Jalons proposés

Les objectifs suivants sont des critères proposés, pas des mesures de performance déjà obtenues.

| Phase | Livrable et critère vérifiable |
| --- | --- |
| Consolider la tranche Godot | Trois sauvetages, incident unique du 29, pause des phases, migration des schémas 1 et 2, journal et réception restaurés, reprise avant/après et trajets accessibles dans les deux états sur un lot de graines |
| Extraire les systèmes | Modules mission et interaction séparés ; tests inchangés ; identifiants uniques et manifeste versionné |
| Reproduire sous UE5 | Même boucle sur un toit et deux étages ; marche et rappel sûrs ; commandes clavier et manette ; aucune progression perdue après recharge |
| Étendre à six étages UE | Parité des objectifs, deux tours intactes puis effondrement, dangers, indices, refuge, sauvegarde et confort ; comparaison avec une grille de validation commune |
| Charger la campagne | Au moins trente variantes assemblées ; ressources bornées ; transitions sans vide visible ; mesure mémoire et temps de chargement sur matériel nommé |
| Produire le chapitre souterrain | Chute préparée, reprise cohérente, Alma et première créature intégrées à une séquence terminable |
| Évaluer la coopération | Prototype réseau séparé ; attribution exclusive des secours, retour après déconnexion et scénarios à deux joueurs vérifiés |

Les risques immédiats sont le couplage du contrôleur principal, l'absence de navigation de PNJ, la capsule d'accroupissement inchangée, les interactions de mission encore fondées sur proximité et les limites des identifiants actuels. Les traiter avant de multiplier les étages évitera de transporter ces simplifications dans toute la campagne.

Le portage doit préserver une intervention compréhensible, terminable et reprenable. Les personnages, animations et effets seront ensuite enrichis selon un budget graphique mesuré.
