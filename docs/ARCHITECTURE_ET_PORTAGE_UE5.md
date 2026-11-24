# Architecture du prototype et portage vers Unreal Engine 5

Version de conception 0.2 — Effondrement en temps réel — 24 novembre 2026

Ce document décrit le prototype Godot 0.2 et propose une trajectoire vers Unreal Engine 5. La tranche solo en vue subjective comprend un toit, six étages de 30 à 25, trois sauvetages, trois indices et un refuge. Les deux tours commencent intactes, deux hélicoptères et des groupes de secours sont visibles en maquette, puis un effondrement partiel se déroule pendant l’observation depuis le 29. La campagne complète et le portage UE5 restent à produire.

Le projet déclare une base de fonctionnalités Godot 4.7. Les exécutables, versions de moteur effectivement utilisées et résultats de vérification sont décrits dans le rapport de livraison du dépôt. Ce document ne constitue pas un rapport d’exécution d’Unreal Engine. La coopération en réseau n’est pas implémentée.

## Architecture actuellement présente

La scène d'entrée `prototype/scenes/main.tscn` instancie le contrôleur principal. Celui-ci construit le monde à partir d'une graine, ajoute le personnage, puis relie l'interface et les interactions. La géométrie est créée par code, sans dépendance à des modèles achetés ou à un service distant.

| Fichier dans prototype/scripts | Responsabilité réelle |
| --- | --- |
| `main.gd` | Cycle menu et partie, objectifs, interactions, ressources, événements, treuillage, points de reprise et coordination des autres scripts |
| `player_controller.gd` | `CharacterBody3D`, caméra, marche, course, saut, déplacement lent accroupi, rappel guidé, lampe et tracé de corde |
| `floor_generator.gd` | Production déterministe des six descriptions d'étage et validation des invariants de contenu |
| `world_builder.gd` | Géométrie et collisions, deux états des tours, deux appareils, groupes de secours, effets de rupture, détour après impact et points interactifs |
| `save_store.gd` | Schéma 2, migration des sauvegardes 1, état persistant de l’incident, validation et écriture temporaire avant remplacement |
| `hud.gd` | Menu, jauges, objectifs, commandes contextuelles, radio, journal, pause et bilan |

Le personnage utilise `move_and_slide()` pour la marche. Godot décrit `CharacterBody3D` comme un corps contrôlé par script disposant notamment de détection des murs et des pentes ; la gravité et les règles de déplacement restent ici écrites dans le contrôleur. [Documentation Godot CharacterBody3D](https://docs.godotengine.org/en/stable/classes/class_characterbody3d.html)

`main.gd` est volontairement central pour cette tranche courte. Avant d'étendre la campagne, séparer ses responsabilités en gestion de mission, ressources, interactions, événements et sauvegarde évitera que chaque nouveau niveau ajoute des conditions dans une boucle unique.

## Espace et limites de la simulation

Le monde utilise le mètre. Une dalle jouable se trouve à `y = (numéro − 24) × 6` ; le toit est à 42 m dans le repère local. La mer est à −132 m. Cette origine permet de travailler sur les niveaux supérieurs tout en conservant une façade de gratte-ciel jusqu'au niveau de l'eau.

Chaque plateau mesure 24 m de côté et laisse un puits central de 5,4 m. Les points d'entrée de corde, de secours et de collecte occupent des emplacements protégés. Les variantes déplacent une portion de mobilier et la décoration sans déplacer les éléments nécessaires à l'objectif. Il existe donc une variation procédurale contrainte, pas encore une génération complète de plans architecturaux.

Le rappel actuel guide directement la position dans le puits, ajoute une oscillation latérale et affiche une ligne. L'ancrage secondaire amortit le balancement pendant une durée limitée. Ce dispositif n'est pas une simulation de corde segmentée ni un calcul d'efforts d'un système de sauvetage.

Le sauvetage est également simplifié : sécuriser le rescapé ralentit le joueur ; rejoindre la balise déclenche sa remontée animée. Il n'existe pas encore de navigation autonome de blessés, d'animation de portage complète ou de partage de charge entre deux équipiers. L'accroupissement abaisse la caméra et réduit la vitesse, mais ne réduit pas actuellement la capsule de collision.

## Génération déterministe et persistance

Le générateur conserve les fonctions architecturales et les objectifs : restaurant 30, suites 29, archives 28, accueil enfants 27, spa 26, refuge 25. Les canaux de hasard séparés sélectionnent variante, décoration, danger et anomalie. Le refuge, l'accueil initial et la respiration narrative du niveau 27 restent protégés des événements hostiles.

La graine permet de retrouver une partie avec le même code et le même environnement moteur. Elle ne constitue pas une garantie de reproduction entre toutes les versions : Godot indique que l'algorithme interne du générateur aléatoire est un détail d'implémentation. [Documentation Godot RandomNumberGenerator](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html)

La sauvegarde de schéma 2 contient la graine, le niveau de reprise, les ressources, le temps, les étages visités, les listes de personnes sauvées, indices et caisses utilisées, ainsi que `incident_state` (`intact` ou `aftermath`). Le chargeur refuse les types incorrects, nombres non finis, champs manquants et tailles excessives. L'écriture passe par un fichier temporaire voisin avant remplacement. Le principe de sérialiser explicitement les informations persistantes correspond au fonctionnement présenté par Godot. [Documentation Godot Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html)

L'identité courante `type_étage`, par exemple `survivor_28`, convient à un objet de chaque type par étage. La campagne devra adopter des identifiants indépendants de l'ordre de création, tels que `aube/28/archive/samuel`. Ajouter `generation_version`, `content_revision` et le manifeste des étages générés au format de sauvegarde permettra de migrer les données et de charger la même disposition après un portage. Ne pas sauvegarder les adresses des acteurs ou leurs indices dans un tableau.

Le chemin `user://save_v1.json` est conservé pour retrouver les parties existantes. Une ancienne sauvegarde valide non terminée migre en lecture vers `intact`, une ancienne partie terminée vers `aftermath` ; l’écriture au schéma 2 intervient au checkpoint suivant. La durée écoulée ne permet pas de reconstruire l’incident. Un arrêt pendant une phase transitoire reprend le checkpoint préalable, tandis qu’un état `aftermath` restaure directement les dégâts et la progression radio.

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

Dans le prototype 0.2, Hespérie passe d’un état vertical intact à un état partiellement effondré pendant le jeu. Son état final, le détour et les communications sont persistants. Le portage UE5 proposé doit d’abord reproduire ce contrat, avec trajectoires préparées, zone d’observation, commandes libres, pause réelle et reprises avant/après. Des débris et effets plus détaillés pourront ensuite enrichir la scène sans décider de la praticabilité du trajet de secours.

Pour la production UE5, prévoir des groupes distincts : structure intacte, volume mobile de rupture, façade haute endommagée, débris décoratifs et collisions finales. Le contrôleur narratif resterait responsable du passage d’état ; une éventuelle simulation de débris ne serait pas la source de vérité des routes. L’approche en hélicoptère et le jeu d’acteurs de l’équipe opposée constituent des séquences supplémentaires à produire. Ces choix sont des propositions d’architecture, pas du code UE5 livré.

La liaison basse du 6 donnera plus tard accès à Hespérie à travers des dégâts secondaires ; elle ne rejouera pas le premier impact des étages hauts. La chute d’Alex et Alma vers le bassin reste une transition distincte de l’acte trois. Une simulation structurelle complète des deux tours n’est pas prévue : la scène doit conserver des résultats reproductibles et un sauvetage praticable.

## Sauvegarde UE et coopération ultérieure

Transposer les données persistantes vers une classe `USaveGame`, en conservant les identifiants du contenu et les versions du manifeste. Epic prévoit les écritures synchrones et asynchrones et recommande la voie asynchrone pour éviter une interruption perceptible pendant le jeu. Tester explicitement le comportement en cas de fichier absent, version ancienne et écriture interrompue. [Documentation Epic Saving and Loading](https://dev.epicgames.com/documentation/en-us/unreal-engine/saving-and-loading-your-game-in-unreal-engine)

La coopération constitue un chantier distinct. Définir d'abord l'autorité sur les victimes, le treuil et les ressources partagées. Une hallucination individuelle doit rester une perception locale ; la mort d'un PNJ ou l'ouverture d'un passage doit être un état commun. Tester ensuite déconnexion, retour d'un joueur et chargement d'étages avec deux équipiers éloignés. Aucune de ces fonctions n'est présente dans cette livraison.

## Phases et critères de passage

Les objectifs suivants sont des critères proposés, pas des mesures de performance déjà obtenues.

| Phase | Livrable et critère vérifiable |
| --- | --- |
| Consolider la tranche Godot | Trois sauvetages, incident unique du 29, pause des phases, migration v1, reprise avant/après et trajets accessibles dans les deux états sur un lot de graines |
| Extraire les systèmes | Modules mission et interaction séparés ; tests inchangés ; identifiants uniques et manifeste versionné |
| Reproduire sous UE5 | Même boucle sur un toit et deux étages ; marche et rappel sûrs ; commandes clavier et manette ; aucune progression perdue après recharge |
| Étendre à six étages UE | Parité des objectifs, deux tours intactes puis effondrement, dangers, indices, refuge, sauvegarde et confort ; comparaison avec une grille de validation commune |
| Charger la campagne | Au moins trente variantes assemblées ; ressources bornées ; transitions sans vide visible ; mesure mémoire et temps de chargement sur matériel nommé |
| Produire le chapitre souterrain | Chute préparée, reprise cohérente, Alma et première créature intégrées à une séquence terminable |
| Évaluer la coopération | Prototype réseau séparé ; attribution exclusive des secours, retour après déconnexion et scénarios à deux joueurs vérifiés |

Les risques immédiats sont le couplage du contrôleur principal, l'absence de navigation de PNJ, la capsule d'accroupissement inchangée, les interactions encore fondées sur proximité et les limites des identifiants actuels. Les traiter avant de multiplier les étages évitera de transporter ces simplifications dans toute la campagne.

La fidélité du portage se jugera d'abord sur une intervention que l'on peut commencer, comprendre, terminer et reprendre. La qualité des personnages, animations, effets, ambiances et effondrements viendra ensuite enrichir cette base, avec un budget graphique établi à partir de mesures réelles.
