# Traversée entre étages et rappel contrôlé

**The Tower Descent — version 0.9.0 — 25 novembre 2026.**

Cette annexe développe la précision apportée à la descente : certains escaliers restent praticables seulement entre deux niveaux voisins ; d’autres passages exigent de descendre en rappel par une ouverture du bâtiment. Le joueur doit lire un lieu, choisir le bon accès et conserver une route de retour. Le moyen de déplacement change au cours de la descente sans changer les faits de la mission.

Le périmètre actuel comprend le toit d’Aube et les étages 30 à 25. La version 0.9 ajoute six liaisons locales à ce secteur, un modèle de rappel contrôlé, des escaliers physiques, des stations distinctes et une présentation du descendeur. Elle ne rend pas jouables les étages inférieurs, les laboratoires profonds ou l’Enfer. Le canon reste celui de la 0.8 : perceptions discrètes, phénomènes persistants, rencontres humaines dangereuses, expériences avec une dimension infernale réelle, puis franchissement physique dans la campagne future.

Les valeurs de ce document décrivent les scripts du prototype. Les résultats d’exécution, les exports et les captures effectivement examinées appartiennent aux rapports de livraison. Les cibles de campagne sont annoncées comme telles ; une description de relais, de blessé accompagné ou de corde oblique ne signifie pas que ce système est livré.

## 1 Intention de jeu

Une descente réussie doit conserver une petite décision à chaque étage. Alex ne se laisse plus glisser sur une ligne globale jusqu’au refuge. Il rejoint un palier, observe le prochain passage et retrouve les personnes ou les preuves du niveau. La circulation alterne le mouvement suspendu, la marche dans une cage et le parcours horizontal. Ce rythme donne une utilité à l’architecture et préserve les scènes situées sur les plateaux.

Un escalier praticable ne certifie pas toute sa cage. Son repère nomme précisément les deux étages accessibles. Après la paire, le chemin quitte les volées et rejoint une autre station. Le joueur peut revenir par le même passage ; il ne découvre pas une fermeture arbitraire uniquement parce qu’il marche dans l’autre sens. Les limites de la tranche sont visibles dans la géométrie et dans les destinations proposées.

Le rappel offre une liberté contrôlée : monter, descendre, accélérer la descente, approcher lentement, freiner, verrouiller et se recentrer. L’endurance donne un coût à la remontée ou à la vitesse, mais n’impose pas de lâcher la corde lorsque la jauge est vide. Le contrôle fiable permet de regarder une pièce ou d’écouter un message sans devoir lutter contre un système imprévisible.

Le métier de secours reste lisible. La ligne personnelle d’Alex et le treuil des personnes sont deux systèmes distincts. Une station bleue dessert une courte liaison ; une balise orange confirme une extraction vers le poste médical. Le joueur ne compte pas une personne comme sauvée parce qu’il l’a portée sur un escalier ou près d’un ancrage.

Les tours commencent avec leurs façades intactes. Les ouvertures initiales sont des accès de service repérables et les cages représentées sont des tronçons locaux. La mise en scène ne doit pas montrer une brèche d’effondrement déjà présente au toit pour justifier le premier rappel. L’événement du 29 conserve son rôle : une transformation nouvelle, vécue pendant l’intervention.

## 2 Graphe livré et retour

Le catalogue de routes ne tire aucun hasard. Les six identifiants, leurs extrémités et leurs types sont fixes pour cette tranche. Les variantes de mobilier ne peuvent déplacer ni une station, ni une volée, ni une surface d’arrêt.

| Liaison | Type | Descente | Retour | Ce que le passage prépare |
| --- | --- | --- | --- | --- |
| R31_30 | Rappel personnel | Toit vers restaurant 30 | Remontée au toit | Apprentissage calme, contact avec Ana |
| S30_29 | Escalier local | Restaurant vers suites 29 | Marche vers le 30 | Observation de Bravo et effondrement |
| R29_28 | Rappel personnel | Suites vers archives 28 | Remontée au 29 | Lecture du changement structurel et secours de Samuel |
| S28_27 | Escalier local | Archives vers jardin 27 | Marche vers le 28 | Respiration, dessin d’Alma et écho facultatif |
| R27_26 | Rappel personnel | Jardin vers spa 26 | Remontée au 27 | Secours de Nora et rémanence perceptive |
| S26_25 | Escalier local | Spa vers refuge 25 | Marche vers le 26 | Bilan humain, relais et fin de tranche |

Chaque liaison relie exactement deux étages adjacents. Les rappels s’arrêtent aux deux terminaux définis ; les escaliers ne possèdent pas de volée supplémentaire vers une troisième dalle. Le retour du 25 au toit reste donc possible par la succession inverse des six liens, sous les règles ordinaires de mission. Il ne nécessite aucun ancrage consommable.

Les objectifs restent au même étage : Ana au 30, Samuel au 28, Nora au 26, indices au 29, au 27 et au 26, ravitaillement au 29 et au 25. Le refuge reste la fin jouable. Atteindre sa dalle avant l’incident ou avant les trois confirmations ne termine pas l’intervention ; le chemin de retour permet de résoudre ce qui manque.

Les routes sont identiques avant et après l’impact. Le détour latéral des archives change, mais les accès aux stations, à l’escalier, aux personnes et à leur balise demeurent. Un effet de poussière ou une silhouette ne possède pas l’autorité de modifier ce graphe. Les contraintes mécaniques restent séparées du doute narratif.

## 3 Implantation et volumes réservés

Le repère du prototype place une dalle à `y = (étage − 24) × 6`. Le toit logique 31 est à 42 m, le restaurant 30 à 36 m et le refuge 25 à 6 m. Les six mètres décrivent le dénivelé entre deux niveaux de cette tranche ; la campagne pourra utiliser d’autres hauteurs en produisant les liaisons correspondantes.

Le rappel personnel occupe la moitié ouest du puits. Son axe est à x = −1,3 m, z = 0. Les pieds suspendus atteignent les terminaux à la hauteur de dalle augmentée de 0,04 m. Les points d’entrée sur le plateau sont à x = −3,8 m, z = 0, à la dalle augmentée de 0,06 m. L’ancrage fixe se trouve 2,6 m au-dessus de la dalle supérieure. Le décalage latéral agit sur Z dans une limite de ±0,65 m ; il ne transforme pas le rappel en déplacement libre dans tout le puits.

Les surfaces d’arrêt occidentales mesurent 3,4 × 5,4 m, avec une épaisseur de 0,6 m. Leur centre x = −1 m donne des limites x = −2,7 à +0,7 m. Elles bornent les arrivées au 30, au 28, au 26 et au 25. Elles constituent des éléments de collision fixes. Le personnage ne les traverse pas pour continuer vers un étage qui ne fait pas partie du segment.

Le treuil des personnes reste à l’est, autour de x = 1,8 m, z = 0. Son trajet monte jusqu’au toit et conserve la dépose préparée vers x = 3,3 m, z = −2 m. Un garde-corps sépare la circulation des piétons de ce corridor, avec l’ouverture nécessaire à la dépose sur le toit. Le panier, les personnes et le câble ne doivent pas rencontrer les nouvelles surfaces d’arrêt.

La capsule d’Alex conserve un rayon de 0,34 m et une hauteur de 1,72 m. Le volume libre se vérifie avec ce corps et son décalage réel, pas seulement avec le point de caméra. La position basse abaisse encore la caméra sans réduire la capsule. Une entrée apparemment franchissable à l’image peut donc rester impropre au corps ; elle doit être corrigée dans la géométrie plutôt que validée par une animation qui ignore les collisions.

## 4 Escaliers limités à une paire

Les escaliers S30_29, S28_27 et S26_25 occupent le sud du noyau. L’emprise de l’ouverture est de 5 × 5,6 m, entre x = −2,5 et +2,5 m et z = 5,8 à 11,4 m. Les points de départ et d’arrivée sur la dalle sont placés à z = 5 m : le terminal haut à x = −1,3 m et le terminal bas à x = +1,3 m.

Chaque volée franchit trois mètres de hauteur sur 4,4 m de course horizontale, soit une pente de maquette d’environ 34,3 degrés. Vingt marches visibles par volée donnent quarante marches par liaison : hauteur visuelle de 0,15 m et course de 0,22 m. La capsule marche sur une rampe de collision continue dont les bornes correspondent à ces marches. Ce choix évite de demander un saut ou un dispositif d’escalade à chaque arête.

Le palier intermédiaire mesure 5 × 1,2 m et se trouve à mi-hauteur. Il permet de ralentir, tourner et reprendre dans l’autre sens. Les garde-corps possèdent deux barres, à 0,55 et 1,12 m, d’épaisseur 0,075 m ; les montants sont espacés d’au plus 1,5 m. Ces dimensions décrivent la maquette du jeu, avec ses collisions et ses enveloppes, et non une validation technique d’un bâtiment réel.

Le déplacement utilise les règles ordinaires de marche : vitesse normale, réduction lors du portage, position basse et effets applicables du sol. Aucune interaction d’escalier ne place automatiquement Alex sur l’étage suivant. Les mêmes entrées de déplacement servent à avancer et à revenir. Les volées et le palier restent des surfaces physiques pendant la pause, la reprise et l’état après impact.

Le milieu de l’escalier n’est pas un étage visité. Le contrôleur exige une hauteur à ±0,35 m de la dalle, une position hors du volume de l’escalier, un support physique sous les pieds et une vitesse verticale absolue d’au plus 0,15 m/s avant de confirmer une arrivée de mission. Le joueur doit retrouver le plateau à l’extrémité : être près du haut ou du bas d’une volée mais encore dans la cage ne suffit pas. Le numéro le plus proche ne doit pas suffire à déclencher un objectif, une manifestation, un checkpoint ou le contenu complet d’un dossier.

La direction artistique doit rendre l’arrêt local de la cage compréhensible. Montrer la sortie vers le plateau, la paire desservie et le prochain accès. Ne pas dessiner une volée praticable qui mène à une collision invisible. Une future variante peut comporter une porte condamnée ou un tronçon structurellement inutilisable, mais sa fermeture et sa voie de contournement devront être produites ensemble.

## 5 Cycle d’un rappel personnel

### Lire et engager

Alex rejoint la station du terminal supérieur ou inférieur. Le repère nomme la destination et le HUD annonce le raccordement. La personne doit être seule : une prise en charge en portage refuse le rappel. Le segment est déterminé par la station et ne peut pas être remplacé par une hauteur arbitraire ou une route d’escalier.

E demande l’engagement. Le contrôleur vérifie le palier et le dégagement vers l’axe. Le transfert dure 0,85 s et utilise la capsule physique. La caméra reste celle du joueur ; le regard n’est pas remplacé par un cadrage imposé. Le descendeur et les mains deviennent la représentation du mouvement. L’engagement ne consomme pas d’ancrage facultatif.

Une obstruction refuse ou suspend le passage sans effacer l’attache. Le temps de transfert n’avance pas pour traverser l’obstacle. Le message doit expliquer le problème matériel. Une succession d’appuis ne valide pas plusieurs engagements et ne remplace pas une sortie inachevée par une nouvelle descente.

### Se déplacer et attendre

Une fois attaché, Alex peut descendre, remonter et se décaler dans les limites du segment. Le modèle produit une position demandée ; le contrôleur confronte cette demande aux collisions. Une collision ne devient pas une permission de traverser le décor. La position effectivement acceptée revient au modèle pour éviter une divergence entre ce qu’affiche le HUD et l’emplacement du personnage.

Relâcher la direction verticale provoque un freinage progressif. Espace verrouille immédiatement la hauteur et conserve cet état jusqu’à un nouvel appui. Le verrou retire les commandes de déplacement ; le vent et l’amortissement du balancement restent une présentation de suspension bornée lorsque la mission est active. La pause, elle, fige toute l’horloge du système.

Une remontée complète d’un segment constitue une action réelle, avec son coût d’endurance. Le joueur peut s’arrêter et récupérer avant de continuer. Le modèle ne suppose pas qu’un trajet de retour est impossible parce que la jauge n’est pas pleine au moment de l’engagement.

### Rejoindre la dalle et sortir

Le segment bloque la hauteur à ses deux terminaux. Pour quitter la corde, il faut être à moins de 0,45 m de l’un d’eux, avec une vitesse verticale d’au plus 0,05 m/s et un décalage latéral d’au plus 0,25 m. Il faut aussi que le passage de la capsule vers la station soit libre. Espace peut aider à stabiliser l’approche ; Ctrl fournit une vitesse précise.

E engage alors une sortie contrôlée de 0,85 s vers la dalle. La corde reste attachée pendant le mouvement. Le personnage ne passe à la marche qu’après la fin du transfert. Une obstruction ne le détache pas à mi-chemin. Une demande en plein segment produit un refus lisible et conserve la situation suspendue.

Une chute à pied de plus de 3,5 m sous le dernier appui, ou sous la limite basse du monde, reprend le dernier point sûr. Elle ne valide pas une arrivée dans un étage sauté. Il faut engager la longe au repère personnel avant d’entrer dans une ouverture.

Le retour utilise le même cycle depuis le terminal opposé. Changer de liaison impose de sortir, traverser le plateau ou l’escalier, puis engager la station suivante. Il n’existe pas de raccourci qui remplace cette circulation par une sélection de numéro d’étage.

## 6 Commandes, vitesse et endurance

| Commande | Résultat en suspension | Coût ou limite |
| --- | --- | --- |
| S | Descente normale, cible 2,8 m/s | Aucun coût d’endurance propre à ce mode |
| Z ou W | Remontée, cible 1,6 m/s | 10 points d’endurance/s au régime de déplacement |
| Ctrl avec direction | Précision, cible 0,75 m/s | Montée précise : 5 points/s ; descente précise : aucun coût |
| Maj avec S | Descente rapide, cible 4,2 m/s | 8 points d’endurance/s |
| A ou Q, D | Action latérale | Déplacement sur Z borné à ±0,65 m |
| Relâcher la direction | Frein automatique | Décélération de 16 m/s² jusqu’à l’arrêt |
| Espace | Basculer le verrou | Arrêt vertical immédiat ; état conservé sans maintien |
| X | Stabiliser seize secondes | Un ancrage uniquement si l’usage est accepté |
| E près d’un terminal | Demander la sortie | Hauteur, vitesse, recentrage et capsule vérifiés |

L’accélération vers une vitesse cible vaut 7,5 m/s². Une inversion de direction freine d’abord vers zéro avant d’accélérer dans l’autre sens. La précision a priorité sur la descente rapide ; maintenir Ctrl et Maj ensemble ne cumule pas leurs vitesses. La priorité du verrou puis de l’épuisement empêche une commande contradictoire de relancer immédiatement le déplacement.

L’endurance reste la même ressource que celle du personnage à pied. La montée et la descente rapide dépensent selon le mouvement du modèle ; atteindre une butée ne prolonge pas le segment. La descente normale et la descente précise ne régénèrent pas la jauge pendant leur déplacement. La récupération sur corde exige un arrêt et atteint 12 points/s, avec plafond à 100.

Lorsque la jauge atteint zéro, le système entre en repos et arrête le mouvement. Il reprend sa disponibilité à 20 points. Si une direction est encore maintenue, elle peut alors redevenir active ; le joueur peut la relâcher ou conserver le verrou s’il souhaite attendre davantage. Aucune chute, aucun dégât et aucune rupture de corde ne sont attachés à ce seuil.

Ces règles créent trois usages différents. La vitesse normale sert au déplacement courant. La précision facilite une approche ou un recentrage. La vitesse rapide échange de l’endurance contre une descente plus brève, avec un freinage qui reste contrôlable. Le prototype ne prétend pas reproduire l’effort physiologique ou les charges d’un équipement réel.

## 7 Stabilisation, longueur et lecture du HUD

X est une aide facultative, avec quatre unités au départ et un plafond de huit après ravitaillement. Une activation acceptée remet le décalage et sa vitesse à zéro puis réduit l’excitation du balancement pendant seize secondes. Le modèle garde le même segment et les mêmes terminaux. L’action ne crée ni ancrage persistant dans le monde ni nouvelle voie de déplacement.

Un stock nul refuse la commande. Une stabilisation déjà active refuse aussi un second usage, sans dépenser une unité et sans réinitialiser silencieusement la durée. La pause fige ce temps. À son expiration, le mouvement redevient celui du modèle ordinaire ; le passage ne se rompt pas et Alex ne reçoit aucun dommage. Le joueur doit pouvoir réaliser toute la route principale sans ce consommable.

Le HUD doit distinguer les mesures de corde des distances de parcours. `segment_length` vaut six mètres ; `travelled` mesure la descente depuis le terminal haut et `distance_remaining` la hauteur restante jusqu’au terminal bas. Ces deux dernières mesures partitionnent le segment. Elles ne décrivent pas le nombre de mètres de câble au-dessus du harnais.

`rope_length` représente l’enveloppe géométrique disponible entre l’ancrage et le harnais au terminal bas, avec marge latérale. `deployed` mesure la distance actuelle de l’ancrage au harnais. `remaining` est la différence non négative entre ces deux longueurs. Leur lecture doit éviter de faire croire qu’une corde manque lorsque le joueur est simplement décalé ou proche d’un palier.

L’état affiché doit répondre à une question pratique : suis-je engagé, en déplacement, verrouillé, en repos, en transfert ou empêché par un obstacle ? Les étages reliés, la vitesse, l’endurance et la commande utile accompagnent cet état. L’onglet Situation du journal liste les six passages et distingue la liaison en cours de l’étage déjà atteint. Le chiffre seul ne suffit pas : une sortie refusée doit expliquer ce qu’il faut faire. La couleur peut soutenir le message, mais la paire d’étages et le verbe restent lisibles sans elle.

## 8 Présentation subjective et confort

La corde visible relie l’appui au harnais. Une présentation distincte place un descendeur, un mousqueton, un brin et des mains gantées dans la caméra subjective. Le levier et l’indicateur reflètent la vitesse ou le verrou ; le joueur peut associer son action à un objet présent dans l’image. Cette représentation ne possède aucune collision de personnage et ne décide pas du mouvement.

Le mode de mouvements réduits retire le léger mouvement cosmétique des mains et le roulis associé au balancement. Il conserve les informations utiles : déplacement réel, destination, état de freinage et position par rapport au palier. La caméra ne doit pas prendre le contrôle du regard pour forcer la contemplation du vide.

Le matériel doit rester en dehors de la zone de lecture de l’arrivée. Il ne masque ni le bord de dalle ni les commandes. Les mains restent des volumes procéduraux : elles ne constituent pas un jeu d’acteurs achevé, un système de prise digitale ou une animation de corde libre. Le son final de manipulation et le mixage constituent un travail distinct ; leur qualité ne se déduit pas d’un modèle présent dans le pack.

Le modèle utilise une horloge locale pour le vent. L’ouverture d’un menu ou la consultation du journal ne doit pas avancer ce temps en arrière-plan et rendre la reprise différente selon la durée de lecture. Les hautes cadences et les grandes images sont traitées par pas bornés dans le modèle ; la capsule et les transitions doivent malgré cela être éprouvées à leurs cadences réelles d’exécution.

## 9 Portage, treuil et priorités de mission

Sécuriser une personne conserve les états déjà établis : présente, portée, au treuil, reçue. Le portage réduit la vitesse et interdit le rappel personnel. Les escaliers restent utilisables, ce qui donne une circulation physique cohérente sans transformer cette personne en partenaire équipé pour la corde.

La balise de transfert autorisée reste celle de l’étage d’origine. Si Alex porte Ana vers les suites, la balise du 29 ne la téléporte pas dans le panier : le jeu demande le retour au 30. La même règle vaut pour Samuel et Nora. Le joueur peut remonter l’escalier avec la personne et retrouver la balise correcte. La sauvegarde ne confirme rien avant la fin du treuillage.

Le treuil conserve ses cinq secondes de transfert puis la réception médicale de présentation. Son couloir monte directement au toit, à l’est. Une surface d’arrêt destinée à la corde personnelle ne doit jamais y être insérée. Les trois personnes continuent d’apparaître au poste médical à partir du registre confirmé, indépendamment de la présence d’Alex sur un segment ou un escalier.

Les appels opérationnels conservent leur priorité. L’écho facultatif de Bravo et sa vérification exigent un palier admissible, avec support, vitesse verticale absolue d’au plus 0,15 m/s et position hors escalier. Leur temps de calme ne progresse pas pendant un rappel, dans une volée ou pendant un saut. Les manifestations des suites, des archives et du spa attendent un contexte compatible ; elles ne surgissent pas comme une punition pendant le rappel. La géométrie des sorties et la vérité des personnes sauvées restent fiables même lorsque le récit devient incertain. Une perception ne reconfigure pas le graphe dans cette tranche.

L’incident du 29 attend encore Ana confirmée, les appareils partis et l’observation à la baie Est. Le nouveau déplacement ne remplace pas ces prérequis par un déclenchement au milieu d’une volée. Pendant la catastrophe, le noyau reste une route utile. Après impact, les six liaisons sont les mêmes, avec le détour de plateau déjà prévu aux archives.

## 10 Pause, checkpoint et reprise

La pause suspend le déplacement, l’inertie, la stabilisation, le vent local et les transferts. Le journal, les options et les autres lectures qui suspendent la mission gardent le même contrat. Fermer un panneau ne réécrit pas une sauvegarde et ne valide pas un palier que le joueur n’a pas atteint.

La reprise de session continue l’état suspendu. La reprise depuis le disque reconstruit le dernier checkpoint stable, avec la graine, les faits de mission et l’état stable de l’incident. Ces deux opérations sont différentes. Un joueur qui quitte complètement l’intervention pendant un rappel revient au point sûr enregistré, pas à une position libre dans le vide.

Le schéma de sauvegarde reste la version 3. Aucun champ de verrou, de vitesse, de demi-volée, de longueur déployée ou d’animation d’entrée n’est ajouté. L’endurance du déplacement reste un état de session déjà géré par le personnage ; les ressources sauvegardées conservent leur contrat existant. Les anciennes sauvegardes validées se chargent sur une dalle et retrouvent le nouveau réseau de circulation fixe.

Le contrôleur refuse l’écriture immédiate d’un checkpoint pendant la suspension, un transfert ou une position dans l’escalier. La demande est différée jusqu’à la prochaine dalle admissible ; elle ne remplace pas le point sûr précédent pendant l’attente. Une confirmation de secours, un événement radio ou un changement d’incident ne doit pas contourner cette règle par une autre entrée de sauvegarde. Une arrivée d’étage doit attendre une hauteur de dalle stable et la sortie du volume d’escalier ; le point de reprise ne dépend pas du milieu géométrique d’une liaison.

En cas d’échec d’écriture, la dernière sauvegarde réussie reste la référence. L’interface ne doit pas afficher une validation nouvelle uniquement parce qu’une transition a fini. La clôture au refuge conserve son exigence de sauvegarde réussie avant l’épilogue ; les nouvelles routes ne changent pas le bilan des personnes ou des preuves.

## 11 Props et apprentissage dans les scènes existantes

Les fiches P01 à P04 ont été réconciliées avec la séparation des usages. P01 désigne la balise de treuil des personnes ; P02 son support ; P03 la stabilisation facultative ; P04 les segments personnels. Quatre nouvelles fiches complètent le catalogue, désormais composé de 64 références.

| Prop | Rôle actuel | Point de vigilance |
| --- | --- | --- |
| P61 Escalier local à deux volées | Passage physique entre une paire d’étages | Collision continue, sorties et absence de troisième liaison |
| P62 Station de rappel personnel | Engagement local depuis l’une des deux dalles | Destination explicite et refus pendant le portage |
| P63 Dalle d’arrêt et ouverture de service | Limite de segment et séparation du treuil | Aucun obstacle dans le corridor oriental du panier |
| P64 Descendeur et mains gantées | Retour visuel de la vitesse, du frein et du verrou | Présentation sans autorité de mission et compatible avec les mouvements réduits |

SC03 reste la scène d’apprentissage jouée. Le premier rappel donne le temps de descendre, relâcher, verrouiller puis approcher le restaurant. Le sauvetage d’Ana explique ensuite la différence entre station personnelle et balise de transfert. L’escalier vers les suites introduit une seconde manière de descendre, sur une paire seulement. Aucun nouvel identifiant de scène ne remplace ce parcours.

SC04 conserve l’effondrement. SC05 attend ses conditions de calme au jardin. SC06 clôt la tranche au refuge. La nouvelle circulation relie ces scènes sans changer leur ordre de connaissance ni convertir une manifestation discrète en attaque. Les storyboards des humains dangereux, des expériences et de l’Enfer restent des scènes de campagne future.

## 12 Critères de validation

| Domaine | Cas à éprouver | Résultat attendu |
| --- | --- | --- |
| Catalogue | Routes manquantes, type changé, étage sauté, coordonnées non finies | Rejet explicite sans remplacer un état valide |
| Escaliers | Trois paires, aller et retour, palier et extrémités | Marche physique complète, sans saut ni téléportation |
| Portage | Chaque escalier avec une personne ; rappel demandé | Escalier utilisable, rappel refusé, retour à la balise d’origine possible |
| Rappel | Engagement depuis le haut et depuis le bas | Bonne route, capsule conservée, terminal atteint |
| Commandes | Précision et rapide simultanés, inversion, absence d’entrée | Priorités déterministes, freinage et limites respectés |
| Endurance | Montée prolongée, descente rapide, jauge nulle | Coûts distincts, arrêt attaché, récupération puis disponibilité |
| Stabilisation | Stock nul, double usage, expiration et pause | Aucune dépense refusée, durée cohérente, aucun dommage d’expiration |
| Sortie | Milieu du segment, vitesse élevée, décalage, obstruction | Refus motivé ; aucune séparation dans le vide ou dans une paroi |
| Transition | Obstacle ajouté, pause, reprise, appuis répétés | Attache conservée, progression cohérente, pas de double transfert |
| Incident | Parcours avant et après impact | Six liens disponibles et détour des archives préservé |
| Sauvegarde | Requête sur corde, demi-escalier, sans support ou en mouvement vertical, ancien schéma 3 | Aucun checkpoint transitoire ; reprise sur dalle stable |
| Présentation | HUD, descendeur, commandes, mouvements réduits | Informations lisibles et cohérentes avec l’état du modèle |
| Treuil | Volume du panier et trois personnes jusqu’au toit | Aucune nouvelle dalle ou rambarde sur la trajectoire requise |

Un test du catalogue ne suffit pas à valider les collisions. Une traversée physique ne suffit pas à prouver la compréhension d’un joueur. Les suites de logique, les scènes d’intégration, les images natives et les séances humaines répondent à des questions différentes. Les rapports doivent conserver cette portée et ne pas transformer un total de contrôles en promesse de qualité finale.

Les variantes de mobilier doivent être exercées sur les mêmes trajets obligatoires. Les essais de retour comptent autant que la descente, en particulier avec une personne portée dans l’escalier. Les preuves préparées doivent montrer les entrées, les sorties et les limites de cage ; une belle vue du vide ne prouve pas que le pied d’une volée est franchissable.

## 13 Extensions de campagne à produire

La prochaine extension peut ajouter des obliques courtes et des relais séparés, à condition d’exposer la destination avant engagement. Leur intérêt serait de contourner un volume effondré, atteindre une terrasse ou préserver un chemin de retour. Chaque variante devra conserver le contrôle d’arrêt et une issue connue ; un câble libre spectaculaire ne remplace pas une route jouable.

Un relais persistant demande un identifiant, un état du support, une action de confirmation et une migration de sauvegarde. Le consommable X actuel ne constitue pas ce système. Une station posée par le joueur devra rester reconnaissable après déchargement et chargement du lieu, sans copier une position arbitraire d’acteur. La rupture scénarisée d’une ligne demandera une annonce, une sauvegarde préalable et une nouvelle route produite.

L’accompagnement sur corde est également une capacité future. Elle exige un harnais adapté à la personne, une enveloppe de collision plus large, des animations de raccordement, des commandes de rythme et une confirmation de transfert. Les humains hostiles ne doivent pas interrompre un apprentissage obligatoire en rendant le seul équipement inutilisable. Un partenaire retardé doit conduire à une réponse claire, pas à sa disparition silencieuse.

Dans les profondeurs, les mêmes gestes peuvent vérifier la réalité : comparer une hauteur, retrouver une ligne numérotée, constater qu’un repère reste présent. Les expériences SILLAGE introduiront des appuis et matériels dont la provenance est documentée. Après P666, les lignes de retour P57–P60 donneront une continuité physique à la traversée infernale, avec des règles apprises dans les tours.

La réalité de l’Enfer n’autorise pas à effacer les acquis du secours. Une hallucination ne consomme pas rétroactivement un ancrage en prétendant qu’il n’a jamais existé ; une brèche ne transforme pas une personne déjà reçue au toit en simple illusion. Les règles du retour peuvent devenir plus exigeantes, mais elles doivent rester observables et produire des conséquences persistantes.

## 14 Sources de référence

Le [catalogue de routes](../prototype/scripts/route_catalog.gd) fixe les six connexions. Le [modèle de rappel](../prototype/scripts/rope_traversal.gd) définit les valeurs, les états et leurs sorties. Le [contrôleur du personnage](../prototype/scripts/player_controller.gd) applique les collisions et les transferts. La [présentation du descendeur](../prototype/scripts/rope_presentation.gd) échantillonne les poses sans modifier la progression.

Les dossiers [Gameplay détaillé](GAMEPLAY_DETAILLE.md), [Catalogue des étages](CATALOGUE_ETAGES.md), [Props et interactions](PROPS_INTERACTIONS.md), [Systèmes procéduraux](SYSTEMES_PROCEDURAUX.md), [Scènes cinématiques](SCENES_CINEMATIQUES.md) et [Architecture et portage UE5](ARCHITECTURE_ET_PORTAGE_UE5.md) reprennent ce contrat à leur niveau. La [Progression de l’horreur](PROGRESSION_HORREUR_V0.8.md) conserve les paliers de récit et distingue le premier secteur des contenus de campagne à produire.
