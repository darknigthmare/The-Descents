# The Tower Descent — Effondrement en direct

**Version 0.6.0 — Incident, équipes et continuité cinématique — 24 novembre 2026**

## 1. Décision de direction

À l’arrivée des secours, les deux tours sont droites, séparées et visiblement intactes. Le typhon, le tsunami et le premier séisme ont dévasté la ville qui les entoure. Des équipes sont déposées sur les deux toits et commencent une opération commune. Le joueur descend dans Aube pour sauver des personnes ; c’est pendant cette intervention qu’une nouvelle réplique provoque l’effondrement partiel d’Hespérie vers sa tour.

L’événement doit transformer un lieu que le joueur vient de comprendre. Il a vu le toit voisin occupé, entendu ses équipiers et confirmé un premier sauvetage. Quand la masse d’Hespérie se déplace derrière les vitres, il comprend quels lieux et quelles personnes sont menacés. Après le choc, la mission continue dans la géométrie endommagée, avec moins de voix pour l’accompagner.

La scène est un événement réel du récit. Les incertitudes sur les hallucinations apparaissent dans ce qui suit ; elles n’effacent ni l’effondrement, ni les sauvetages confirmés.

## 2. Périmètre de la version 0.5.0

| Élément | Périmètre retenu |
| --- | --- |
| Moteur jouable | Prototype Godot ; toit d’Aube et étages 30 à 25 |
| État initial | Deux tours droites et intactes ; île submergée autour |
| Déploiement | Approche temps réel, deux hélicoptères et équipes en maquette ; repli préparé de Bravo pendant l’incident |
| Observation | Baie Est du 29, tournée vers Hespérie |
| Prérequis | Ana treuillée et confirmée au toit ; hélicoptères partis ; approche de la baie puis regard maintenu ou confirmation avec E |
| Événement | Quatre phases de session, puis état permanent après impact |
| Contrôle | Regard et déplacement libres ; aucun cadrage forcé ou QTE obligatoire |
| Conséquences | Hespérie partiellement effondrée contre Aube, dégâts hauts, détour latéral, radio modifiée |
| Sauvetage | Puits et noyau intérieur utilisables ; personnes confirmées visibles et nommées au poste médical |
| Communications | Sous-titres ordonnés, alertes prioritaires, 32 transmissions conservées et écho facultatif après Samuel |
| Sauvegarde | Schéma 3, états `intact` et `aftermath`, données radio et reprise avant ou après la scène |
| Production ultérieure | Approche aérienne complète, personnages détaillés et animés, doublage, effets finaux, campagne et portage UE5 |

Ce dossier décrit le contrat de la tranche et les propositions de mise en scène. Les scripts de voix et d’acting ci-dessous ne constituent pas des enregistrements ou animations livrés. Le [rapport d’état](ETAT_DE_LIVRAISON.md) porte les résultats de vérification ; aucun résultat de test n’est annoncé dans ce document.

## 3. Géographie et équipes

### Aube

Aube est la tour occupée. Son toit accueille Varga, le poste médical, le treuil principal et le regroupement des personnes remontées. Alex appartient au groupe Corde ; Médical assure la prise en charge au toit. Le puits de service constitue l’axe de circulation des six étages jouables. Il existe avant la catastrophe et reste identifiable comme un accès de travail.

### Hespérie

Hespérie est fermée au public, mais des personnels techniques s’y trouvent encore et des signaux demandent vérification. Le détachement Bravo, qui réunit Échelle et Relais, est donc déposé sur son toit. Sa mission est annoncée avant la séparation des hélicoptères : vérifier ces signaux et établir une liaison avec Aube. La fermeture administrative ne suffit pas à conclure que le bâtiment est vide.

Le groupe doit être repérable depuis Aube par plusieurs indices concordants : silhouettes, vêtements de secours, balise et échange radio. Une seule lumière dans le brouillard ne permettrait pas de comprendre l’enjeu humain du choc.

### Après le déplacement

La partie haute d’Hespérie rompt et se rapproche d’Aube. Le choc principal touche la façade haute autour des 29/28. Hespérie reste partiellement debout et appuyée contre Aube : elle ne disparaît pas entièrement dans la mer. Le noyau intérieur et le puits nécessaires au prototype conservent une route vers le toit et le refuge.

Le niveau 6 appartient à la campagne future. Il porte une liaison basse déformée et des débris secondaires, qui ouvriront un accès à Hespérie. Il ne devient pas rétrospectivement le lieu unique du premier choc vu au 29. La coupe précise de cette traversée reste à produire.

## 4. Parcours du joueur et déclenchement

1. **Voir les deux tours.** L’approche de 28 secondes présente la mer, les tours et les équipes, puis rend le contrôle sur le toit d’Aube. Un appareil et des équipiers sont proches ; le second appareil et le groupe opposé donnent une échelle à Hespérie.
2. **Entendre la répartition.** Varga annonce le rôle des deux détachements ; Bravo répond. Les pilotes expliquent que le retour dépendra de l’accalmie.
3. **Réussir un sauvetage.** Au 30, Alex rejoint Ana et la ramène à la balise. Le treuil la conduit au toit et Varga confirme sa prise en charge. L’effondrement ne peut pas annuler ce résultat.
4. **Recevoir un objectif lisible.** Après le départ des hélicoptères, l’objectif devient : « Rejoindre la baie Est du 29 et repérer Bravo sur Hespérie. » La baie et sa relation à la tour voisine doivent être évidentes dans l’espace.
5. **Approcher et confirmer.** À la baie, un regard maintenu vers Hespérie pendant 0,8 seconde déclenche automatiquement la scène lorsque les prérequis sont réunis. E sur l’observation permet une confirmation explicite sans condition d’orientation. Le jeu ne retourne pas la caméra et ne remplace pas le regard par un film.
6. **Vivre les quatre phases.** La séquence dispose de sa propre horloge ; elle ne dépend plus de l’orientation du joueur une fois commencée. Regarder l’abri ou faire demi-tour n’interrompt pas l’effondrement.
7. **Réorganiser l’intervention.** Une fois le choc stabilisé, Varga confirme que la route intérieure reste utilisable. Le joueur contourne le passage touché, rejoint Samuel au 28 puis le calme relatif du 27.

Il n’existe aucun compte à rebours depuis le lancement de la partie. Attendre au toit, examiner le restaurant, ouvrir le journal ou prendre du temps avec Ana ne déclenche pas une catastrophe hors champ. Un joueur qui a sauté la baie conserve un objectif explicite pour y revenir ; les conditions de fin doivent rester cohérentes avec un état `aftermath`.

Le départ de la scène se fait hors rappel et hors transfert de victime. Une personne portée ou un treuillage actif ne doit pas être perdu parce qu’un déclencheur vient de s’activer. Les cas de progression inhabituelle doivent être traités par des objectifs et des états, sans déclarer un personnage mort ou faire disparaître sa prise en charge.

## 5. Découpage de la scène jouable

Le temps ci-dessous est relatif au début de l’avertissement, après validation des prérequis.

| Temps relatif | Phase | Durée | Mise en scène et information | Liberté du joueur |
| --- | --- | --- | --- | --- |
| 0 à 8 s | `warning` | 8 s | Bravo interrompt une observation ; un grondement monte ; Varga désigne l’intérieur stable. La baie offre encore une lecture nette de l’autre tour. | Regarder, reculer, rejoindre l’abri ; aucune dépense obligatoire de consommable |
| 8 à 14 s | `quake` | 6 s | Mouvement de la structure et des éléments suspendus ; craquements ; activité des secours opposés ; la rupture se prépare. | Se déplacer et regarder librement ; effet caméra atténuable |
| 14 à 21 s | `collapse` | 7 s | Hespérie rompt partiellement et se rapproche ; éléments de façade se détachent ; la liaison haute cède ; Bravo appelle puis se coupe. | Garder la tour dans le regard ou se protéger ; aucune visée ni touche rythmée imposée |
| 21 à 25 s | `impact` | 4 s | Choc sur la façade des étages hauts, vitrage brisé et poussière ; extinction partielle puis éclairage de secours. | Garder les commandes ; conserver un sol jouable et une sortie compréhensible |
| À partir de 25 s | `aftermath` | Permanent | Nouvelle silhouette, dégâts visibles, détour installé, réponse de Varga et absence de réponse confirmée de Bravo. | Reprendre l’exploration et le sauvetage dans le monde transformé |

La pause fige la progression des quatre phases. Les durées ne se rattrapent pas en bloc au retour au jeu. Les événements sonores et les messages doivent rester associés à leur phase ; une baisse de fréquence d’images ne doit ni répéter un appel ni rejouer l’impact.

L’observation n’est pas un piège mortel. La route du puits, l’indice Chambre 2908 et la caisse restent accessibles. Les collisions après impact changent le passage latéral sans se refermer sur le personnage. Les débris de présentation n’ont pas à pousser la capsule du joueur ou à décider de la survie d’un rescapé.

## 6. Proposition de cinématique d’arrivée et d’acting

La 0.4.0 donne une première approche en quatre plans temps réel avec la mer, les tours, les appareils et les équipes géométriques. Son contrat d’horloge, de saut et de reprise figure dans [Scènes cinématiques](SCENES_CINEMATIQUES.md). Les gestes précis, la cabine habitée et le doublage proposés ci-dessous restent à produire ; ils ne changent pas les prérequis de l’incident.

| Séquence | Composition proposée | Jeu des personnages et intention |
| --- | --- | --- |
| Survol de la ville | Vue depuis la porte de l’hélicoptère : toits noyés, marina détruite, deux tours intactes à l’arrière-plan. Le joueur peut regarder. | Un secouriste vérifie une sangle ; un autre cherche des signaux en contrebas. Travail concentré, sans annonce prophétique. |
| Séparation des appareils | Le second hélicoptère passe dans le champ puis rejoint Hespérie. Les deux toits deviennent des destinations distinctes. | Bravo confirme son objectif. Le pilote reconnaît l’accalmie temporaire et donne une consigne d’approche. |
| Dépose sur Aube | Repères de secours, matériels, gestes de coordination et départ du joueur vers le puits. | Varga donne une tâche courte. Médical accueille une personne ; deux équipiers déplacent une caisse. |
| Contact visuel opposé | Un équipier d’Hespérie fait un signe depuis une balise ou une fenêtre repérable. | Le geste répond à un échange entendu. Le joueur peut plus tard reconnaître cette place derrière la baie du 29. |
| Départ des appareils | Les rotors s’éloignent, laissant le vent, la mer et le fonctionnement du treuil. | Les équipiers restent actifs. Le départ des hélicoptères ne signifie pas encore l’abandon du joueur. |
| Retour au travail | Premier rappel puis prise en charge d’Ana. | Ana parle à Alex ; le toit répond à la fin du treuillage. Le système de secours paraît fiable. |

Dans la maquette, les deux membres de la galerie et les trois du toit se tournent pendant l’alerte, traversent vers la porte ou le noyau de service pendant la secousse, puis disparaissent à couvert au début de la chute. Le déplacement est préparé et échantillonné depuis la phase ; aucune navigation ni collision nouvelle n’est ajoutée. La campagne pourra enrichir cette action avec les binômes et les gestes de protection. L’absence de réponse ne constitue pas un constat de décès.

## 7. Proposition de script radio et sous-titres

Ces répliques donnent une direction de doublage. Les formulations courtes présentes dans le prototype peuvent différer ; l’ordre des informations et les conditions restent les éléments à conserver. Aucune réplique ne demande une technique de secours réelle : les consignes renvoient aux repères du niveau.

| Repère | Déclencheur | Voix et direction | Proposition de texte |
| --- | --- | --- | --- |
| ARR-01 | Vue des deux tours, campagne | Pilote, factuel | « Deux toits dégagés. Aube pour Corde et Médical. Bravo, vous prenez Hespérie. » |
| ARR-02 | Avant séparation, campagne | Bravo, concentré | « Reçu. Signaux sur les niveaux hauts, présence technique à vérifier. On établit le relais. » |
| ARR-03 | Dépose et briefing | Varga, calme | « Alex, vous commencez par le restaurant. Nous tenons le treuil. Chaque personne remonte jusqu’ici. » |
| ARR-04 | Départ des appareils | Pilote, sans dramatiser | « Le front se referme. On décroche. Pas de retour avant l’accalmie. » |
| RES-01 | Ana reçue au toit | Varga, confirmation nette | « Ana prise en charge. Elle est avec Médical. Premier transfert confirmé. » |
| OBS-01 | Ana sauvée et appareils partis | Varga, objectif | « Descendez au 29. Baie Est. Je veux un visuel sur Bravo avant la suite. » |
| OBS-02 | Observation, avant l’alerte | Bravo, échange ordinaire | « On vous voit, Aube. Le relais est près de la baie. On vérifie le couloir. » |
| INC-01 | `warning` | Bravo, interruption brève | « Attendez… Ça vient du bâtiment. Vous le sentez aussi ? » |
| INC-02 | `warning`, consigne prioritaire | Varga, ferme et intelligible | « Alex, éloignez-vous de la vitre. L’intérieur, près du puits. » |
| INC-03 | `quake` | Bravo, coordination urgente | « On rentre ! Gardez votre binôme ! » |
| INC-04 | `collapse` | Bravo, phrase interrompue | « Aube, la façade part vers vous, on… » |
| INC-05 | `impact` | Varga, appel court | « Alex, répondez ! » |
| APR-01 | `aftermath`, poussière retombant | Varga, essoufflée mais précise | « Aube tient. Le puits est praticable. Les personnes remontées sont avec nous. » |
| APR-02 | Après première confirmation | Varga, doute explicite | « Bravo ne répond plus. Je n’ai pas de confirmation. Reprenez par l’intérieur. » |
| SAM-01 | Samuel rejoint après l’impact | Samuel, sidération contenue | « J’ai vu l’autre tour dans la fenêtre… Elle ne bouge plus ? Vous pouvez me remonter ? » |
| SAM-02 | Après réponse ou aide à Samuel | Samuel, revient à une information utile | « Les ordres de fermeture sont dans les dossiers. Ils datent d’avant le séisme. » |
| AMB-01 | Plus bas, après respiration, campagne | Indicatif Bravo, origine incertaine | « On vous voit, Aube. Le relais est près de la baie. » |
| AMB-02 | Réaction à l’appel ambigu, campagne | Varga ou Inès, pas de conclusion hâtive | « Je l’ai reçu. Gardez votre position, on vérifie l’horodatage. » |

Le fragment effectivement repris dans le prototype est « Bravo à Aube. On vous voit à la baie Est... ». L’écho exige Samuel reçu au toit, l’état `aftermath`, le niveau 27 et six secondes continues de radio libre. Varga attend ensuite deux secondes de calme au 27, au refuge 25 ou au toit. Rappel, portage, treuillage, pause et arrivée suspendent ces conditions ; la pause n’ajoute aucun temps. Les deux étapes sont facultatives et persistées chacune une seule fois après sauvegarde réussie. L’annexe [Communications et équipes](COMMUNICATIONS_ET_EQUIPES.md) fait autorité sur le texte livré ; les lignes de doublage du tableau restent des propositions.

Les alertes de la scène remplacent le sous-titre courant et retirent les instructions en attente devenues obsolètes. Les transmissions déjà reçues restent dans le journal, dans sa limite de 32 entrées. Un message ordinaire peut être archivé pendant l’incident sans masquer l’alerte. Les indicatifs et coupures sont lisibles dans les sous-titres, indépendamment de la couleur ou du son.

## 8. Conséquences à conserver

| Domaine | État après impact | Ce qui reste exploitable |
| --- | --- | --- |
| Silhouette | Hespérie déplacée et partiellement effondrée contre Aube | Orientation générale et lecture de la hauteur |
| Façade | Dégâts sur les étages hauts, vitrage et débris visibles | Accès aux objectifs et protection de la zone de reprise |
| Parcours | Passage latéral touché, détour indiqué | Puits, treuil, retour au toit et accès au refuge |
| Équipes | Bravo sans réponse confirmée, poste d’Aube toujours actif | Appels de Varga, suivi des transferts, objectifs clairs |
| Personnes sauvées | Prises en charge inchangées au registre | Ana et les autres restent comptés une seule fois |
| Samuel | Réaction adaptée à l’événement déjà vécu | Aide, transfert et informations antérieures au désastre |
| Preuves et matériel | Objets déjà collectés conservés, objets restants accessibles | Chambre 2908, réserves et progression ultérieure |
| Ambiance | Moins de voix, structure qui travaille, poussière et éclairage de secours | Sons et repères nécessaires à l’orientation |

Les refuges certifiés restent sûrs. La scène ne détourne pas rétroactivement le sens de « sauvé ». La ville demeure ravagée, mais les nouveaux dégâts sur les tours apparaissent au bon moment et restent visibles ensuite.

## 9. Sauvegarde, interruption et migration

Le schéma 2 avait ajouté `incident_state` ; le schéma courant 3 le conserve avec les transmissions et les événements radio. Ses seules valeurs persistantes sont `intact` et `aftermath`. Les phases transitoires sont suivies en session avec `phase` et `phase_elapsed` ; elles ne définissent pas une reprise au milieu d’un mouvement de bâtiment.

| Situation | Résultat attendu |
| --- | --- |
| Juste avant `warning` | Checkpoint stable avec `incident_state: intact`, Ana sauvée et état courant conservé |
| Pause pendant une phase | Horloge de scène figée ; reprise depuis la même phase et le même temps |
| Retour au menu ou arrêt avant la fin de `impact` | Chargement du checkpoint préalable ; la séquence peut être rejouée depuis son départ |
| Entrée dans `aftermath` | Géométrie finale appliquée et checkpoint après impact |
| Chargement de `aftermath` | Pas de nouvel effondrement ; silhouette, détour, objectifs et radio restaurés |
| Nouvelle partie | Retour explicite à deux tours intactes, nouvelles listes de mission |
| Sauvegarde 1 non terminée | Lecture puis migration vers `intact`, sans effacer les résultats déjà acquis |
| Sauvegarde 1 terminée | Lecture puis migration vers `aftermath`, bilan conservé |
| Échec d’écriture | Message d’erreur ; aucun succès de sauvegarde annoncé ; checkpoint précédent conservé si possible |

Le fichier reste à `user://save_v1.json` pour retrouver les parties existantes. Son nom historique n’impose pas son schéma : les nouvelles écritures portent `version: 3`. Une ancienne sauvegarde n’est réécrite qu’à la prochaine écriture réussie. `completed: true` exige `aftermath` dans le schéma 3.

La migration ne devine jamais l’incident à partir de la durée de partie ou des étages vus. Elle ne modifie pas le compteur des personnes sauvées pour fabriquer une transition. Les listes d’indices et de matériel consommé restent cohérentes avec l’état chargé.

## 10. Lisibilité et confort

La scène se comprend avec le son coupé : déplacement de la tour, signaux visuels, sous-titres et objectif indiquent l’évolution. Elle se comprend aussi avec les mouvements de caméra réduits et les éclairs désactivés. Ces réglages ne diminuent ni les chances de sauver une personne ni la quantité d’informations utiles.

La poussière sert le choc sans masquer durablement le sol, le puits ou l’issue. Le contraste des balises et l’éclairage de secours doivent porter la sortie ; un changement de couleur seul ne suffit pas. Le regard reste libre même si le joueur préfère observer l’intérieur pendant l’impact.

Le rythme réserve le 27 à une respiration. Les appels ambigus et l’apparition du spa ne se superposent pas à la catastrophe pour rendre chaque seconde hostile. L’isolement naît surtout de l’écart entre les deux groupes actifs du départ et les réponses plus rares de l’après.

## 11. Proposition de portage et de production UE5

Le portage doit conserver les prérequis, les durées, la liberté de caméra, les deux états persistants et la garantie du sauvetage. Le moteur final pourra enrichir la scène avec des façades détaillées, des personnages animés, du son spatial et des débris, après reproduction de la boucle jouable.

Une organisation proposée sépare cinq ensembles : tours intactes, volume de rupture animé, façade endommagée, débris de présentation et collisions finales. Un contrôleur d’incident conserverait l’autorité sur la progression. Une simulation de débris éventuelle ne déciderait ni de l’ouverture du chemin obligatoire ni de la survie d’une personne au registre.

Les séquences d’approche et de départ peuvent être mises en scène avec le même monde, afin que les points vus depuis l’hélicoptère soient reconnaissables depuis la baie. L’animation d’Hespérie doit montrer une rupture partielle et un contact, plutôt qu’une tour rigide qui pivote seule sans dégâts. Le détail des fractures, le budget de particules, la durée de visibilité et les distances de lecture seront déterminés sur le matériel cible.

Cette section est une proposition. Elle n’annonce aucun projet UE5 compilé, aucune animation finale ni aucune simulation de structure livrée. Le [document d’architecture](ARCHITECTURE_ET_PORTAGE_UE5.md) détaille la séparation entre état de mission, mouvement, construction et persistance.

## 12. Critères de revue

Les points suivants servent à évaluer la révision ; ils ne constituent pas des tests déclarés réussis.

- Une nouvelle partie présente deux tours intactes, deux appareils et des groupes identifiables sur les deux toits.
- Le joueur peut prendre son temps avant le sauvetage d’Ana sans déclencher l’incident.
- L’objectif conduit à la baie Est du 29 ; la scène requiert l’approche et un regard maintenu ou une confirmation avec E, puis continue si le joueur détourne les yeux.
- Les quatre phases suivent l’ordre et les durées définis ; la pause et une reprise ne doublent aucun événement.
- Les commandes restent disponibles et les options de confort préservent les informations nécessaires.
- Le passage latéral est modifié sans condamner les objets, les victimes ou le puits ; aucun changement de collision n’enferme le joueur.
- Un arrêt pendant la scène reprend avant l’avertissement ; un arrêt après stabilisation restaure directement les dégâts.
- Les sauvegardes 1 migrent selon l’état de fin ; les sauvegardes 2 conservent l’incident. L’historique et les événements absents commencent vides ; la lecture n’écrit pas le fichier.
- Ana, Samuel et Nora restent sauvables une seule fois ; les personnes confirmées restent au registre après le choc et la reprise.
- Le refuge reste sûr ; la fin reste cohérente avec trois personnes sauvées et un incident achevé.
- Le contraste entre organisation initiale, rupture et isolement est lisible à l’image et dans les communications.
