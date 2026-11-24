# Systèmes procéduraux de The Tower Descent

**Version 0.6.0 — 24 novembre 2026**

## Objet et périmètre

Le prototype assemble une descente de six étages, du restaurant panoramique 30 au refuge technique 25. Sa génération varie la disposition des accessoires, certaines conditions de danger et les manifestations secondaires. Elle conserve les fonctions architecturales, les trois victimes à sauver, les trois indices et les ressources nécessaires. Le résultat est un parcours de sauvetage lisible dont certains détails changent à chaque graine.

La révision 0.2 conserve ce générateur et ajoute un événement de mission indépendant : les tours commencent intactes, puis Hespérie s’effondre partiellement vers Aube pendant l’observation depuis la baie Est du 29. Le choix de graine ne décide ni de sa présence ni du destin d’une personne déjà sauvée.

Ce document distingue ce mécanisme livré de la génération plus ambitieuse de la campagne, décrite dans la bible. Il ne faut pas interpréter les trente étages de la bible comme trente niveaux déjà jouables. La géométrie du prototype est construite par `world_builder.gd`; `floor_generator.gd` ne prétend pas, à lui seul, prouver la traversabilité des collisions produites.

La 0.4.0 rétablit le repli de Bravo, la réception nominative au toit et les communications persistantes conçus pendant la continuation 0.3. Elle ajoute une présentation cinématique et un menu contextualisé. Ces systèmes utilisent la progression de mission et des horloges de présentation, sans modifier le tirage des six étages. La 0.5 ajoute des poses d’arrivée échantillonnées et douze observations fixes. Leur construction ne consomme pas le générateur aléatoire ; leurs textes sont projetés depuis l’incident stable et les réceptions confirmées, sans nouvel état persistant.

## Contrat d’extension du contenu

Les trente fiches d’assemblage du [catalogue](CATALOGUE_ETAGES.md), les 52 [props](PROPS_INTERACTIONS.md) et les archétypes du [bestiaire](ENNEMIS_STATISTIQUES.md) sont des spécifications de campagne. Ils ne sont pas tous inscrits dans le générateur actuel. Leur intégration doit commencer par des variantes préparées d’un petit nombre de niveaux, avec validation du chemin avant ajout de décoration.

Une future description d’étage doit séparer quatre couches : graphe de circulation, états narratifs autorisés, interactions requises et habillage. Le graphe indique entrée, sortie, palier sûr et voie de transfert. Les états narratifs déterminent ce que le joueur peut déjà savoir. Les interactions déclarent outils, durée proposée et conséquence persistante. L’habillage peut choisir des tables ou des gravats compatibles sans déplacer les points nécessaires à la mission.

Une instance de prop doit recevoir un identifiant stable, une orientation, un volume d’interaction et des volumes réservés. Les petits objets décoratifs peuvent varier librement à l’intérieur d’un emplacement validé ; un meuble de collision doit être soumis au contrôle de circulation. Une civière, un accompagnant ou un équipier au travail demande une enveloppe plus large que la capsule seule. Le générateur doit conserver le chemin de retour après l’action, pas seulement un accès aller à la personne.

Une présence de campagne doit déclarer son territoire, les signaux d’annonce, le contre-jeu accessible et les exclusions. Les refuges, le premier transfert, les sorties de corde et les apprentissages de mouvement ne sont pas des emplacements aléatoires de menace. Deux événements facultatifs peuvent se remplacer selon le contexte ; ils ne doivent pas s’empiler jusqu’à rendre les appels opérationnels illisibles. Les délais d’événement n’incluent ni pause ni menu ni arrivée cinématique.

Le contexte du menu est une projection du dernier checkpoint validé. Il n’effectue aucun nouveau tirage de progression et n’invente pas un état d’incident en fonction du temps de présentation. Les personnages médicaux et dégâts sont reconstruits depuis les mêmes registres que la reprise jouable. Les préférences restent dans un fichier séparé ; changer la graine de la mission ne réactive pas les éclairs ni les mouvements de caméra.

Pour un portage, conserver le manifeste des modules retenus en plus de la graine. Une graine seule ne garantit pas les mêmes choix si le code, le moteur ou l’ordre de tirage change. Les clés de personnes, props, preuves et événements doivent survivre au changement d’asset ou au déchargement d’un étage. Le schéma 3 actuel reste inchangé tant que cette extension de données n’est pas effectivement développée et migrée.

## Contrat des données livrées

`FloorGenerator.generate(seed_value: int) -> Array` renvoie six dictionnaires, toujours dans l’ordre 30, 29, 28, 27, 26, 25. L’appel ne modifie ni le monde ni une sauvegarde. `FloorGenerator.validate(floors: Array) -> Array[String]` renvoie une liste vide si les invariants de contenu sont respectés et des erreurs lisibles dans le cas contraire.

| Champ | Type | Usage |
|---|---|---|
| `number` | entier | Identité et ordre de l’étage |
| `theme` | chaîne | Famille de modules architecturaux |
| `name` | chaîne | Nom français présenté au joueur |
| `safe` | booléen | Refuge dont la sécurité est garantie |
| `hazard` | chaîne | `none`, `smoke`, `water` ou `unstable` |
| `survivor` | booléen | Présence d’une victime du scénario |
| `evidence` | booléen | Présence d’un indice du scénario |
| `supplies` | booléen | Présence de matériel récupérable |
| `anomaly` | chaîne | `none`, `footsteps`, `radio` ou `figure` |
| `layout_variant` | entier de 0 à 2 | Variante du placement prévu par le constructeur |
| `prop_seed` | entier positif ou nul | Sous-graine réservée aux accessoires |
| `survivor_name` | chaîne | Identité stable du rescapé, sinon chaîne vide |
| `evidence_title` | chaîne | Titre de l’indice, sinon chaîne vide |
| `evidence_text` | chaîne | Texte complet de l’indice, sinon chaîne vide |

## Invariants de la descente

| Niveau | Fonction fixe | Sauvetage | Indice | Ressources | Variation autorisée |
|---|---|---|---|---|---|
| Toit | Deux tours intactes, dépose et commandement | Groupes visibles sur les deux toits | Briefing | Équipement initial | Deux appareils et déploiement fixes ; accessoires hors générateur |
| 30 | Restaurant panoramique | Ana Rios | Aucun | Aucune cache | Accessoires et disposition; aucun danger ni apparition |
| 29 | Suites et baie Est d’observation | Aucun | Chambre 2908 | Stock accessible | Événement majeur fixe ; dangers secondaires compatibles, accessoires hors des trajets protégés |
| 28 | Bureaux et archives après impact | Samuel Breton | Aucun | Aucune cache | Fumée ou instabilité possibles ; réplique de Samuel adaptée à l’état de l’incident |
| 27 | Jardin d’enfants évacué | Aucun | Le dessin des deux tours | Aucune cache | Accessoires; pause mécanique garantie |
| 26 | Spa et piscine | Nora Haddad | Relevé SILLAGE 06 | Aucune cache | Eau possible; apparition visuelle garantie |
| 25 | Refuge de maintenance | Point de regroupement | Bilan | Réapprovisionnement | Accessoires; sécurité garantie |

Les trois sauvés ne sont pas tirés au sort. Un joueur ne perd donc pas un objectif obligatoire parce que la graine l’a omis. Les indices qui établissent l’existence d’événements avant la catastrophe ne disparaissent pas non plus. Les étages 30, 27 et 25 sont mécaniquement calmes. L’étage 27 donne une respiration après le choc du 29 et le sauvetage du 28, avant la première apparition lisible au 26 ; cela garantit qu’il n’existe jamais trois étages hostiles consécutifs dans les spécifications.

Le statut `safe` du générateur est réservé au refuge 25. Le 27 reste sans danger mécanique ni apparition hostile ; un échange radio facultatif y est piloté par la mission. Traverser le niveau n’ajoute ni stock ni checkpoint implicite. Recevoir l’écho de Bravo ou sa vérification demande en revanche un checkpoint explicite en zone calme.

## Événement majeur indépendant de la graine

La baie Est du 29, sa vue sur Hespérie, le passage intérieur et les emplacements de reprise sont des éléments fixes. L’événement requiert Ana treuillée et confirmée au toit, le départ des hélicoptères, puis l’approche de la baie et un regard maintenu vers la tour voisine ou une confirmation explicite avec E. Un délai minimal de mission permet le départ des appareils, mais il ne déclenche pas seul la scène. Un joueur qui explore ou apprend les commandes ne rate pas l’effondrement au profit d’un minuteur invisible.

Le directeur de scène déroule `warning` pendant 8 s, `quake` pendant 6 s, `collapse` pendant 7 s et `impact` pendant 4 s, puis atteint `aftermath`. Les paramètres `phase` et `phase_elapsed` décrivent la session en cours. La pause arrête la progression de cette horloge ; le regard et le déplacement restent libres lorsque le jeu est actif. Le contrôleur attend un état compatible avec la scène : aucune victime portée ou en cours de transfert ne doit être perdue par un changement de phase.

L’état initial et l’état après impact doivent chacun posséder un chemin praticable vers les balises, les survivants, les indices, les réserves et le refuge. Un passage latéral change ; le puits intérieur et sa ligne restent utilisables. Les débris de présentation ne peuvent devenir des obstacles aléatoires sur le trajet nécessaire. Les dangers secondaires générés au 29 doivent respecter la zone et le temps d’observation protégés. La validation des seuls dictionnaires d’étage ne suffit pas à établir ces propriétés de scène.

Le [dossier de séquence](EFFONDREMENT_EN_DIRECT.md) définit la mise en scène, les informations radio et les comportements attendus lors d’une reprise.

## Reproductibilité et séparation des tirages

Chaque étage possède quatre générateurs locaux indépendants : `layout`, `props`, `hazard` et `anomaly`. Leur graine est le hachage d’un identifiant comprenant le titre du projet, la graine de partie, le numéro d’étage, le nom du canal et la version de génération. Ajouter un tirage d’accessoire n’avance donc pas le générateur d’événements. Le générateur global de Godot n’est jamais utilisé pour déterminer les spécifications.

Godot documente qu’une graine donnée de `RandomNumberGenerator` reproduit une séquence, tout en précisant que l’algorithme sous-jacent reste un détail d’implémentation. La garantie de cette livraison s’applique donc à la même version du générateur et du moteur. Une migration de moteur doit conserver le manifeste déjà généré dans la sauvegarde ou fournir une migration explicite; conserver uniquement le nombre de la graine ne constitue pas une promesse de compatibilité éternelle. [Documentation officielle de RandomNumberGenerator](https://docs.godotengine.org/en/stable/classes/class_randomnumbergenerator.html)

Dans le prototype, `GENERATION_VERSION` vaut 1 ; cette version du générateur est distincte du schéma de sauvegarde 3. Le choix de graine ne dépend ni de l’heure ni de la vitesse du processeur. La fonction pure accepte aussi des entiers négatifs pour les essais, tandis que l’entrée de partie et la sauvegarde utilisent une graine de 1 à 999999. Le moteur décide ensuite comment exploiter la valeur `prop_seed`; il ne doit pas introduire de nouveaux tirages globaux qui rendraient les accessoires sensibles à l’ordre de chargement.

## Ce que les tests vérifient

Exécuter depuis la racine du dépôt :

```sh
godot --headless --path prototype --script tests/test_generation.gd
```

Le test parcourt 200 graines. Il exige l’égalité de deux générations successives, l’indépendance vis-à-vis de tirages globaux intercalés, l’absence d’état mutable partagé et la validation de chaque résultat. Il vérifie que ce corpus exerce les trois variantes de disposition, les quatre états de danger et les quatre états d’anomalie. Il couvre aussi des entiers limites et des entrées invalides : liste vide, mauvais type, champ absent, refuge rendu dangereux, survivant obligatoire supprimé et succession de trois niveaux hostiles. Une anomalie entraîne un code de sortie non nul et un message explicite.

Ces vérifications portent sur le contrat des données. La collision d’une table avec un chemin, le rayon d’interaction d’un PNJ, la lisibilité d’une sortie, la bonne dépense d’oxygène et la persistance des victimes évacuées exigent des tests de scène et de progression distincts. Un succès du test de génération ne doit jamais être présenté comme la validation complète d’une partie.

## Vérification des trajets physiques du prototype

Le test complémentaire `tests/test_routes.gd` construit le monde et utilise la véritable capsule du personnage avec `move_and_slide`, la gravité et les collisions du décor. Il place seulement le personnage au départ de chaque étage; ensuite, chaque aller vers un objectif et chaque retour à la balise est parcouru par le moteur physique. Aucun passage n’utilise de téléportation, de désactivation des collisions ou de modification du décor.

```sh
godot --headless --fixed-fps 60 --path prototype --script tests/test_routes.gd
```

Les graines 3, 47 et 69 forment un ensemble couvrant les variantes de modules 0, 1 et 2 sur chacun des six étages. Le test suit les voies prévues autour du puits vers les trois survivants, les trois indices, les deux réserves et le refuge. Il s’arrête à portée d’interaction des objets, dont certains comportent leur propre collision, puis revient au treuil. La vitesse est de 3,7 mètres par seconde à l’aller et de 2,4 pendant le retour avec une victime.

Ces trajets forment un corpus de vérification, pas une couverture de toutes les positions, des sauts, de toutes les graines ou de la campagne. La validation courante comprend également une traversée après impact et une vérification de la baie Est. La logique de mission, les pauses et les reprises relèvent de `tests/test_mission.gd` et des tests de l’incident ; l’interface et la visibilité des chemins exigent une inspection visuelle. Les résultats d’exécution appartiennent au rapport de validation du dépôt ; aucun total de la version précédente ne vaut validation de cette révision.

## Extension prévue pour la campagne

La campagne doit conserver un squelette conçu à la main : déploiement sur deux toits intacts, premier sauvetage, choc vécu au 29, refuges, liaison basse du 6, sauvetage d’Alma, chute dans le bassin, sous-sols, cavernes, bunker et seuil 666. La génération peut choisir les pièces secondaires et l’état des connexions, mais ne doit pas effacer ces événements ou les placer hors de leur ordre narratif.

La proposition de génération complète comporte cinq passes :

1. **Plan d’étage.** Choisir une grammaire compatible avec la fonction du lieu : hôtel à couloirs et chambres, bureaux à plateaux, piscine à volume central, laboratoire à sas. Préserver les noyaux porteurs et les gaines verticales entre les étages.
2. **Dommages.** Associer les dégâts à un état narratif avant de poser l’eau, les ruptures de dalles et les coupures électriques. Les façades des deux tours restent intactes au départ ; les bris du choc ne sont activés qu’après la rupture. Un étage inondé ne doit pas être posé au-dessus d’un trou ouvert sans mécanisme d’écoulement lisible.
3. **Objectifs.** Placer le rescapé, son état, le point de stabilisation et le trajet vers la ligne d’extraction. Vérifier le chemin avant de poser les accessoires secondaires.
4. **Ressources et tension.** Garantir un budget de traversée et une marge de retour avant tout événement facultatif. Poser un temps calme après un événement majeur; préserver la fiabilité des refuges annoncés.
5. **Validation et réparation.** Vérifier la connexion entrée–objectif–sortie, les capacités requises, la portée des points d’ancrage, le dégagement de la civière et la visibilité des signaux essentiels. Remplacer un module invalide par une variante de secours au lieu de relancer indéfiniment la génération.

Ces passes de campagne sont des objectifs d’implémentation, pas des fonctionnalités présentes dans le générateur de six étages.

## Contraintes de progression à conserver

Un itinéraire obligatoire ne dépend jamais d’un consommable tiré aléatoirement. Si une porte nécessite un outil particulier, cet outil est garanti en amont et ne peut pas être dépensé définitivement avant la porte. Un objet facultatif peut réduire un danger ou ouvrir un raccourci, mais son absence n’efface pas le chemin principal.

Les ancres imposées par le parcours sont stables. Les points facultatifs peuvent réduire le balancement et raccourcir une extraction. Le choc du 29 conserve la circulation intérieure et le retour au toit dans la tranche jouable. La rupture du socle, prévue à l’acte trois de la campagne, ferme plus tard la route supérieure dans une transition distincte. Jusqu’à cette seconde rupture, une voie vers un refuge ou un point de repli doit rester disponible. Après la chute souterraine, le jeu annonce un nouvel objectif et une nouvelle réserve minimale ; il ne réutilise pas silencieusement une route devenue impossible.

Une hallucination peut troubler une voix, une silhouette ou la lecture momentanée d’un espace secondaire. Elle ne transforme pas sans signal un refuge en piège, ne supprime pas un rescapé déjà évacué et ne consomme pas un objet en prétendant ensuite que son utilisation n’a jamais eu lieu. La confiance dans les conséquences mécaniques rend l’incertitude narrative plus forte.

## Stockage des checkpoints du prototype

Le composant livré `DescentSave`, dans `prototype/scripts/save_store.gd`, expose deux fonctions statiques : `save_data(data, path)` renvoie un code `Error`; `load_data(path)` renvoie le checkpoint normalisé ou `{}` si aucun fichier exploitable n’est disponible. Le chemin par défaut reste `user://save_v1.json`, dans les données locales du jeu, pour retrouver les fichiers existants ; le nom historique du fichier ne fixe pas la version de son contenu. Les erreurs d’écriture doivent être affichées par l’interface; un retour non nul ne signifie pas que le checkpoint est enregistré.

La version 3 exige exactement les champs `version`, `seed`, `floor`, `health`, `oxygen`, `stress`, `anchors`, `flares`, `rescued`, `clues`, `supplies_used`, `elapsed`, `seen_floors`, `completed`, `incident_state`, `transmissions` et `radio_events`. `incident_state` est une chaîne égale à `intact` ou `aftermath`. Les écritures de parties terminées exigent `aftermath`. Les champs supplémentaires, les états transitoires et les versions inconnues sont refusés. Les jauges sont des nombres finis entre 0 et 100, les ancres entre 0 et 8, les fusées entre 0 et 6, la graine entre 1 et 999999 et le numéro de reprise entre 25 et 31. Les identifiants collectés sont des chaînes non vides, uniques dans chaque liste, limitées à 80 caractères et 64 éléments. Les étages vus sont des entiers distincts entre 25 et 31. Le temps écoulé est fini et positif ou nul.

`transmissions` contient au plus 32 dictionnaires exacts `speaker`, `message`, `elapsed`. Les textes sont non vides et limités à 120 caractères pour l’indicatif et 1200 pour le message. Les temps sont finis, positifs ou nuls, chronologiques et ne dépassent pas le temps de mission sauvegardé. La reprise restaure le journal sans rejouer le sous-titre ou la file d’attente.

`radio_events` contient au plus deux identifiants uniques : `bravo_echo` et `bravo_verification`. La vérification exige l’écho ; les deux exigent `aftermath` et `survivor_28` dans le registre. Les compteurs de silence repartent de zéro au chargement. Le détail de la priorité radio figure dans [Communications et équipes](COMMUNICATIONS_ET_EQUIPES.md).

Le stockage n’interprète pas la géométrie : `floor = 29` désigne une reprise à l’emplacement choisi par le contrôleur, pas la preuve que tout l’étage est sans danger. Le contrôleur crée le checkpoint au point autorisé et restaure un emplacement stable. Le magasin ne sauvegarde pas une position arbitraire au milieu d’une corde ou d’un effondrement.

| Moment | Valeur persistante | Comportement de reprise |
| --- | --- | --- |
| Avant l’avertissement | `intact` | Reprise au point sûr avant la scène ; premier sauvetage conservé |
| `warning`, `quake`, `collapse`, `impact` | Le checkpoint antérieur reste `intact` | Toute interruption reprend avant la scène, même pendant les quatre secondes d’impact |
| Stabilisation accomplie | `aftermath` | Application directe de la géométrie, du détour et de la radio après impact |
| Ancienne version 1 non terminée | Migration en lecture vers `intact` | Ressources et objectifs préservés ; nouvelle scène disponible |
| Ancienne version 1 terminée | Migration en lecture vers `aftermath` | Bilan conservé et nouvelle géométrie cohérente avec une mission terminée |
| Ancienne version 2 valide | État d’incident conservé | Migration vers 3 avec historique et événements vides |
| Écho ou vérification reçu en zone calme | `aftermath` et événement identifié | Checkpoint courant ; aucune répétition de l’étape après écriture réussie |

La migration valide d’abord le schéma exact d’origine. Les schémas 1 et 2 reçoivent des listes `transmissions` et `radio_events` vides ; aucun ancien dialogue n’est inventé. Le schéma 1 utilise l’état de fin pour choisir `intact` ou `aftermath`, tandis que le schéma 2 conserve `incident_state`. La lecture ne réécrit pas le fichier : le prochain checkpoint réussi utilise le schéma 3. La durée de jeu et les étages visités ne servent pas à deviner l’incident. La pause fige l’horloge transitoire ; la reprise restaure un état stable.

Avant toute écriture, le dictionnaire est validé et copié sans modification de l’entrée. Les données sont écrites dans un fichier temporaire voisin, vidées vers le système de fichiers, puis renommées sur le checkpoint. Le fichier précédent n’est jamais supprimé avant cette substitution. Cela évite qu’une sauvegarde normalement interrompue pendant l’écriture du temporaire remplace un fichier valide. Cette séquence ne constitue pas une garantie matérielle contre toute panne de disque ou coupure électrique.

À la lecture, la taille est limitée à 64 Kio avant le décodage JSON. Les données invalides, tronquées ou d’une version inconnue sont rejetées sans lancer d’exception dans le jeu. Le décodage JSON ne préserve pas le type entier de GDScript : les champs entiers sont donc restaurés uniquement si leur valeur est mathématiquement entière et dans les bornes prévues. Les booléens et chaînes numériques ne sont jamais traités comme des nombres. [Documentation officielle de JSON](https://docs.godotengine.org/en/stable/classes/class_json.html) · [FileAccess](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html) · [DirAccess](https://docs.godotengine.org/en/stable/classes/class_diraccess.html)

Le test dédié se lance avec `godot --headless --path prototype --script tests/test_save.gd`. Il vérifie l’aller-retour des valeurs, le remplacement d’un checkpoint existant, l’absence de mutation, les types et bornes invalides, le refus des versions inconnues, les fichiers corrompus ou trop grands, les erreurs d’écriture et l’ignorance d’un temporaire interrompu.

## Sauvegarde de campagne et futurs outils de production

Pour une version ultérieure, enregistrer ensemble la graine, la version de génération, le manifeste complet, les objectifs résolus, les ressources ramassées, les ancres posées et les événements déjà joués. Un rechargement doit restaurer un monde, pas rerouler les dangers. Les identifiants des objets doivent dériver de l’étage et de leur rôle, et rester indépendants de leur position exacte.

Un outil d’édition utile afficherait la pile des trente niveaux, les connexions verticales, le budget d’oxygène requis, les espaces de retournement des civières et la dernière validation. Son export JSON pourrait être consommé aussi bien par Godot que par une future implémentation Unreal Engine 5. Cette séparation entre manifeste, construction et état de partie constitue la partie à préserver lors d’un changement de moteur.
