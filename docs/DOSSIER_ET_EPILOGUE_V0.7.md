# Dossier d’intervention, bilan et signal du relais — v0.7

## 1. Intention et périmètre livré

La version 0.7 donne une forme consultable à ce que le joueur a réellement accompli. Le journal possède quatre onglets, un axe de descente et des compteurs communs. Le bilan nomme les trois personnes de la mission et rappelle les moyens encore disponibles. Une courte séquence dans le monde du jeu relie leur réception au poste médical, le relais du refuge et la silhouette d’Hespérie après l’impact.

Le refuge marque **la fin de la tranche jouable actuelle**. Il ne devient pas la fin de la campagne. Le sort de Bravo, l’origine du signal et la descente sous le 25 restent ouverts. Aucun nouvel étage jouable, ennemi, objet à collecter ou objectif obligatoire n’est ajouté par ces écrans. Les développements de campagne décrits dans la bible gardent leur statut de conception.

Cette annexe complète [les communications et les équipes](COMMUNICATIONS_ET_EQUIPES.md), [les scènes cinématiques](SCENES_CINEMATIQUES.md), [le sauvetage v0.6](SAUVETAGE_V0.6.md) et [le confort v0.6](CONFORT_V0.6.md).

## 2. Le journal pendant une intervention

La touche **J** ouvre le journal depuis l’intervention. La mission est suspendue par son contrôleur : déplacement, monde, consommation de ressources, horloge de mission et progression des communications ne continuent pas pendant la lecture. Le dossier est une photographie de cet état. Son ouverture n’établit pas un nouveau point de reprise et ne change pas les registres de mission.

Chaque ouverture commence sur **Situation**. La ligne supérieure indique le numéro du dossier, le lieu actuel et le temps de mission. Quatre compteurs restent visibles au-dessus de la lecture : personnes réellement à l’abri, indices récupérés, temps écoulé, étage actuel. Le point sûr est indiqué séparément dans Situation, car il peut précéder l’endroit où se trouve le joueur.

| Onglet | Ce que le joueur consulte | Règle de vérité |
|---|---|---|
| Situation | Priorité de secours, état structurel, noms et états des trois personnes, ressources, point sûr et trois derniers échanges | Ne confond pas étage actuel et point de reprise ; ne considère pas le portage comme une réception |
| Rescapés | Ana Rios, Samuel Breton et Nora Haddad ; étage d’origine, statut et détail de leur prise en charge | Seul le registre des réceptions confirme « À l’abri » |
| Indices | Trois emplacements de documents, contenu des seules pièces déjà récupérées | Aucun titre narratif ni texte d’un document non collecté n’entre dans le modèle affiché |
| Transmissions | Historique conservé, avec indicatif, message et horodatage de mission | Lit les échanges reçus ; ne transforme pas les sous-titres de l’épilogue en nouveaux appels radio |

### 2.1. Situation et progression spatiale

Le panneau latéral reprend les sept niveaux déjà établis par la mission : poste du toit au 31, restaurant au 30, suites au 29, archives au 28, jardin au 27, spa au 26 et refuge au 25. Le niveau actuel est distingué en or. Les étages visités prennent une teinte plus claire. Une mention « ÉVAC. » apparaît sur l’étage d’origine d’une personne réceptionnée ; cette mention ne déplace pas la personne sauvée, qui demeure au poste médical du toit.

Avant la réplique, Situation explique la coordination Alpha/Aube et Bravo/Hespérie et le contact visuel prévu depuis la baie Est du 29 après la réception d’Ana. Pendant les phases d’alerte, de secousse, de basculement et d’impact, la consigne insiste sur le noyau et le point sûr précédent. Après stabilisation, elle précise qu’Hespérie reste appuyée contre Aube, que le passage Est du 28 est condamné et que le détour intérieur reste utilisable. Elle maintient l’incertitude sur Bravo.

Le texte initial contient toujours **les trois noms et leurs états**. Son extrait radio porte l’en-tête **« TRANSMISSIONS REÇUES · DERNIERS ÉCHANGES »**. Les trois dernières entrées y figurent dans leur ordre de réception ; l’onglet dédié permet de consulter l’historique conservé. Sans message dans l’instantané, l’écran annonce simplement l’absence de transmission enregistrée.

### 2.2. États des personnes

| Personne | Lieu d’origine | Identifiant conservé |
|---|---|---|
| Ana Rios | Restaurant panoramique, 30 | `survivor_30` |
| Samuel Breton | Archives Pelagos, 28 | `survivor_28` |
| Nora Haddad | Spa de Nacre, 26 | `survivor_26` |

Les états ont un sens opérationnel précis :

- **À secourir** : aucune prise en charge active ni réception confirmée dans l’instantané.
- **Au harnais** : le joueur porte la personne ; elle doit encore rejoindre la balise de son étage.
- **Au treuil** : la remontée est en cours ; la réception du toit n’est pas encore acquise.
- **À l’abri** : l’identifiant figure dans le registre des réceptions confirmées au poste d’Aube.

Une réception confirmée prévaut sur un identifiant temporaire de portage ou de treuil resté dans l’entrée. À défaut, le treuil prévaut sur le portage. Ni l’ouverture du journal, ni un drapeau de fin isolé ne fabriquent une personne sauvée. La réapparition au poste médical et la reprise après chargement restent gouvernées par les systèmes de sauvetage et de sauvegarde existants.

### 2.3. Indices et protection des découvertes

Les trois identifiants connus sont `evidence_29`, `evidence_27` et `evidence_26`. Le contrôleur fournit au dossier les fiches réelles de génération correspondant aux pièces récupérées. Le modèle applique une seconde vérification : une fiche n’est admise que si son identifiant appartient aussi au registre des indices collectés.

Un emplacement non récupéré affiche **« DOCUMENT NON RÉCUPÉRÉ »** et une indication générale sur la lueur bleue des documents. Son titre et son récit ne sont pas chargés dans la projection, même si un appelant transmet par erreur toutes les fiches d’étage. Le filtrage porte donc sur les données du modèle, et pas uniquement sur la visibilité d’un contrôle.

Une fiche récupérée présente son véritable titre et son texte. Si le registre indique une collecte mais que le texte manque à l’instantané, le dossier conserve le compte et annonce que le texte n’est pas disponible. Il n’invente pas un récit pour combler ce manque. Les doublons ne multiplient pas les découvertes et une fiche répétée ne remplace pas la première fiche valide.

### 2.4. Historique de réception

Le journal conserve au maximum les **32 derniers échanges valides** reçus, conformément au budget existant de la radio. Chaque entrée indique `[minutes:secondes]` ou `[heures:minutes:secondes]`, l’indicatif et le message. L’ordre original est conservé ; le dossier n’effectue aucun tri qui pourrait changer la relation entre deux réponses.

Le lecteur utilise du texte simple : des crochets présents dans un message restent des caractères visibles et ne deviennent pas des balises de mise en forme. Les entrées sans indicatif, sans texte ou sans horodatage valide sont écartées. La lecture produit des copies des entrées retenues, afin qu’une sélection, une consultation ou un traitement d’affichage ne puisse modifier l’historique actif.

## 3. Le bilan au refuge

Après la séquence de fin, **LE REFUGE 25** remplace l’ancien bloc de texte unique. La mention « Tranche jouable terminée » situe clairement la portée de cette conclusion. Les quatre compteurs donnent les valeurs finales de cette intervention ; trois cartes nomment les personnes et leur réception. Une grande carte de lecture réunit le signal du relais, l’état d’Hespérie et les ressources restantes.

| Élément du bilan | Valeur affichée |
|---|---|
| Personnes à l’abri | Compte des identifiants de réception uniques et connus, sur trois |
| Indices | Compte des identifiants collectés uniques et connus, sur trois |
| Temps | Temps de mission figé, sans durée ajoutée par l’épilogue ou sa relecture |
| Position | Étage courant du snapshot de fin, normalement le refuge 25 |
| État physique, air, tension | Valeurs réelles, présentées en pourcentages entiers |
| Ancrages et fusées | Quantités restantes ; aucun réapprovisionnement de présentation |
| Réserves ouvertes | Caisses réellement utilisées parmi `supply_29` et `supply_25` |
| Structure | Phase réelle de l’incident ; après impact, rappel du détour intérieur au 28 |
| Relais | Fragment attribué à Bravo, avec origine et heure non confirmées |

La carte du relais rappelle : **« Nous sommes au 24. Il y a de la lumière dessous. »** Elle précise qu’un tel fragment ne confirme ni un contact en direct ni le sort de l’équipe. L’évocation écrite d’une voix d’enfant prolonge le texte de fin déjà présent dans la version précédente ; elle ne constitue pas un nouveau personnage jouable, une personne sauvée supplémentaire ou une piste sonore enregistrée.

Trois actions restent disponibles :

1. **Compte rendu** ouvre le même journal structuré, sur Situation, avec le snapshot final. Fermer revient au bilan et ne réactive pas le personnage.
2. **Revoir la séquence** relit les quinze secondes du signal. Cette action n’est disponible que pour une fin comportant les trois réceptions confirmées.
3. **Revenir à l’accueil** restaure le menu contextuel de la mission, dont l’état de refuge provient du point de reprise conservé.

Une sauvegarde de fin valide exige les trois identifiants de réception, un point sûr à l’étage 25 et l’état structurel stabilisé après l’impact. Le validateur vérifie ce contrat pour les schémas 1, 2 et 3 ; le contrôleur vérifie aussi la position réelle du joueur avant la clôture. Le modèle demeure prudent : il affiche les véritables états et désactive la relecture si les trois reçus ne sont pas présents, même dans un instantané fabriqué directement pour l’interface.

## 4. Épilogue du relais

### 4.1. Trois plans dans le monde existant

La séquence **« Signal du relais »** dure **15 secondes**. Elle utilise le monde déjà construit et figé. Les personnes, le terminal et les deux tours appartiennent à la scène de mission ; les plans ne sont pas des illustrations de substitution.

| Temps | Carton | Sujet et intention |
|---|---|---|
| 0 à 5 s | TROIS VIES À L’ABRI | Poste médical d’Aube : Ana sur civière, Samuel sous couverture jaune, Nora sur siège bas. Le registre réel commande leur présence. Le premier plan rend visible le résultat humain du sauvetage. |
| 5 à 10 s | LE RELAIS RÉPOND | Terminal physique du refuge 25, écran frontal lumineux et salle sûre. Le plan recentre l’attention sur la source matérielle de l’extrait présenté. |
| 10 à 15 s | SOUS NOS PIEDS | Vue extérieure d’Aube et d’Hespérie après impact. Aucune visite du 24 n’est montrée. L’image conserve la question posée par le signal. |

Les sous-titres sont directement échantillonnés dans la présentation de la séquence :

| Fenêtre | Attribution visible | Texte |
|---|---|---|
| 0,45 à 4,70 s | VARGA | « Ana, Samuel et Nora sont au poste médical. Votre ligne tient. » |
| 5,40 à 9,70 s | RELAIS 25 / FRAGMENT BRAVO | « Bravo à Aube. On vous voit à la baie Est… » |
| 10,40 à 14,70 s | RELAIS 25 / ORIGINE NON CONFIRMÉE | « Nous sommes au 24. Il y a de la lumière dessous. » |

L’attribution incertaine est inscrite à l’écran. Aucun décès, nouveau rescapé ou contact direct n’est confirmé par la mise en scène. Les échanges de mission déjà reçus restent consultables séparément dans l’onglet Transmissions.

### 4.2. Caméras, transitions et confort

Chaque plan possède un déplacement lent. L’option de réduction des mouvements remplace chaque déplacement par son point médian fixe, sans supprimer le plan, le texte ni sa durée. Des fondus noirs de **0,35 seconde** accompagnent chaque côté des coupes. Aucun flash n’est ajouté.

| Plan | Position de départ | Position d’arrivée | Cible | Champ de vision |
|---|---|---|---|---|
| Poste médical | `(7.6, 44.1, -5)` | `(7.9, 44.05, -5.4)` | `(8.15, 43, -9.15)` | 62° |
| Relais | `(10.25, 8.25, 9.6)` | `(9.65, 8.05, 9)` | `(7, 7.15, 6.1)` | 51° |
| Extérieur | `(75, 42, 91)` | `(72, 40, 87)` | `(16, 17, -5)` | 56° |

Le contrôle **« Voir le bilan · E / Entrée »** permet de terminer la lecture. La pause et les options conservent la position de lecture. Après la fin ou le passage, une caméra fixe au refuge sert de fond au bilan.

### 4.3. Temps, reprise et absence d’effets de mission

L’horloge de l’épilogue est indépendante du temps de mission. Son directeur est un échantillonneur pur : à un instant donné, il fournit le plan, la caméra, les fondus et le sous-titre valide. Il ne maintient pas une file de nouveaux appels. Un saut de temps ou une relecture ne provoque donc pas l’émission successive des phrases manquées.

La sauvegarde de fin est acquise avant la première lecture. Charger une sauvegarde déjà terminée ouvre directement le bilan. Le bouton de relecture permet ensuite de revoir la séquence. Ni cette lecture ni sa fermeture ne consomment d’air, ne modifient l’inventaire, ne rejouent une réception, ne font progresser un incident et ne réécrivent l’historique des transmissions.

Si l’écriture du point de reprise final échoue, le contrôleur rétablit `completed` à `false`. Le personnage et le HUD restent disponibles, un message signale l’erreur et le relais peut être réessayé. La séquence ne démarre pas sur une fin non enregistrée ; l’échec ne remplace pas le précédent fichier valide.

## 5. Direction visuelle et accessibilité pratique

Le dossier reprend les familles Open Sans déjà intégrées : titres condensés, texte courant lisible, blanc légèrement chaud, or de repérage et bleu grisé pour les informations secondaires. Un filet supérieur et les règles verticales des boutons structurent l’ensemble. Le journal utilise un voile sombre à 88 % d’opacité ; le bilan, un voile à 80 %, laisse percevoir le refuge derrière les cartes opaques. Le HUD de terrain est masqué pendant la consultation, puis restauré à la fermeture d’un journal ouvert en jeu.

Le focus est visible au clavier. Entrée active les boutons. Les flèches changent l’onglet et son focus. Tab parcourt les onglets, le texte et la fermeture ; le bilan possède sa boucle de navigation entre ses trois actions et sa carte de lecture. Dans le lecteur, Page précédente/suivante, Début et Fin complètent la molette. Le passage à un autre onglet remet son défilement au début.

Le conteneur remplit le viewport ; les titres, marges et corps de texte se resserrent sous 1100 pixels de largeur ou 720 pixels de hauteur. Le rail secondaire des étages disparaît sous 740 pixels de hauteur, et l’aide de raccourcis en pied de journal sous 1100 pixels de largeur. Les quatre onglets et l’action de fermeture restent accessibles. Les textes longs défilent dans leur lecteur ; les boutons de fermeture et de bilan gardent leur propre rangée.

Les tests géométriques et de navigation couvrent le viewport de référence **1440 × 900** et un viewport virtuel réduit **960 × 600**. Ils ne constituent pas une certification universelle de toutes les tailles, de tous les lecteurs d’écran ou de toutes les configurations de manette.

## 6. Contrat de données et responsabilités

`mission_dossier.gd` reçoit un dictionnaire et retourne une projection indépendante. Il ne lit aucun fichier, ne consulte aucune horloge et ne tire aucune valeur aléatoire. `mission_dossier_panel.gd` construit et affiche les contrôles. `hud.gd` conserve les points d’entrée et transmet les intentions au contrôleur de mission.

| Entrée du snapshot | Utilisation |
|---|---|
| `seed`, `floor`, `checkpoint_floor`, `seen_floors` | Identité de dossier, position actuelle, point sûr et axe de descente |
| `rescued`, `carried_id`, `hoisting_id` | Registre confirmé et états transitoires des trois personnes |
| `clues`, `clue_records` | Registre de collecte et fiches réelles autorisées, chacune `{id, floor, title, text}` |
| `transmissions` | Entrées reçues `{speaker, message, elapsed}`, jamais la file des messages futurs |
| `elapsed`, `health`, `oxygen`, `stress` | Temps de mission et état du personnage à l’ouverture |
| `anchors`, `flares`, `supplies_used` | Moyens restants et caisses ouvertes |
| `completed`, `incident_state` | Conclusion de tranche et état réel des tours |

L’API publique du modèle est `build(snapshot)`. Sa sortie contient les quatre pages `situation`, `survivors`, `clues`, `transmissions`, les fiches structurées des personnes et des indices, la route, les compteurs, le texte structurel, la carte du relais et la disponibilité de la relecture. Les tableaux et dictionnaires rendus n’exposent pas les registres actifs par référence.

Le panneau fournit `present(snapshot)` et `select_tab(tab_id, focus_tab)`. Les identifiants restent en anglais dans le code, tandis que leurs libellés sont en français. Le HUD expose `show_journal(snapshot)` et `show_debrief(snapshot)`. Les handles `journal_panel`, `journal_text`, `end_panel`, `completion_text` et `end_journal_button` restent utilisables ; les deux lecteurs sont de véritables `RichTextLabel` sans BBCode.

La fermeture du journal émet l’intention de reprise existante. Le bilan émet les intentions de compte rendu, de retour à l’accueil et `epilogue_replay_requested`. Le contrôleur décide alors de la suspension, de la caméra et des transitions. Le journal et le bilan n’ajoutent aucun champ au format de sauvegarde.

## 7. Vérification et limites de la preuve

La suite `test_mission_dossier.gd` vérifie la fidélité des comptes, la distinction portage/treuil/réception, l’absence de mutation des entrées, la protection contre les révélations d’indices, les données manquantes ou malformées, l’ordre et la rétention radio, les durées longues et les phases structurelles. Elle instancie les vrais panneaux, active leurs boutons avec Entrée, change les onglets au clavier, fait défiler un historique long et contrôle les limites géométriques aux deux tailles annoncées. Elle vérifie aussi les handles et la transmission des actions du HUD.

La suite `test_epilogue.gd` couvre l’horloge, les frontières de plans, les deltas invalides, le passage, la relecture, les sous-titres directement échantillonnés, les caméras fixes en mouvement réduit et la compatibilité de l’overlay avec l’ouverture et l’arrivée existantes. Ses contrôles de scène portent sur la projection des véritables sujets et sur l’absence de géométrie opaque entre les caméras, les personnes et l’écran du terminal.

La suite `test_epilogue_integration.gd` exerce la véritable fin de mission, les onglets et les actions du bilan, la pause et les options imbriquées, l’échec d’une sauvegarde finale, la relecture, le passage et la reprise d’une fin déjà enregistrée sans nouvelle écriture. Elle contrôle aussi le retour à une nouvelle partie pour détecter une caméra, une horloge ou un état de fin conservé par erreur.

Les captures natives du pipeline complètent ces contrôles par une inspection du rendu. Les captures utilisent des états préparés : elles ne prouvent pas une partie humaine complète, la durée réelle d’un parcours, la qualité d’une voix enregistrée ou la disponibilité de la campagne sous le 25. Les résultats exacts, versions d’outils et archives livrées appartiennent au [rapport de validation v0.7](VALIDATION_V0.7.md).
