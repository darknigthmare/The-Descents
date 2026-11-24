# The Tower Descent

## Catalogue des étages et des espaces de campagne

**Version 0.6.0 — Assemblage des niveaux et dossier de production — 24 novembre 2026**

Ce catalogue développe les lieux de la [Bible du jeu](BIBLE_DU_JEU.md). Chaque étage possède une fonction fixe, une scène reconnaissable et un objectif de rythme. La génération fait varier des passages, des objets, des personnes secondaires et des détails compatibles ; elle ne déplace pas les révélations principales au hasard.

**Périmètre du prototype Godot 0.6.0 :** toit jouable d’Aube, Hespérie visible à distance, deux hélicoptères et équipes en maquette, étages 30 à 25, trois rescapés aux 30, 28 et 26, indices aux 29, 27 et 26, ravitaillement aux 29 et 25, anomalie au 26 et balise de fin au refuge 25. Les tours commencent intactes. La baie Est du 29 accueille l’effondrement en temps réel et les conséquences persistantes décrits dans [Effondrement en direct](EFFONDREMENT_EN_DIRECT.md). L’approche temps réel de la 0.5.0 anime les posés, les portes latérales et le déploiement des six membres de toit. Douze observations facultatives sont réparties sur les niveaux jouables. Le jeu d’acteurs et le doublage détaillés restent des cibles de campagne. Le README et le rapport de validation établissent l’état logiciel et les vérifications.

Les étages 24 à 1, la traversée d’Hespérie, les sous-sols, le seuil 666 et Mountain Hole sont conçus ici mais ne font pas partie de cette première tranche jouable. Les personnes et les incidents supplémentaires restent des propositions de contenu, pas des acteurs déjà intégrés au prototype.

## 1 Règles communes de variation

Chaque niveau est identifié par un code stable. Le nombre affiché au joueur peut parfois être incohérent dans une scène d’anomalie, mais l’identifiant interne ne change jamais. Les noms des preuves, les fonctions d’étage et les faits de récit restent constants pour une version donnée du catalogue.

Une variante décrit une combinaison préparée et validée, pas un tirage de décor sans logique. Le générateur vérifie l’accès à la sortie, la disponibilité des outils, les voies d’évacuation et la séparation des refuges. Une preuve indispensable peut changer de position dans une pièce compatible, jamais disparaître complètement.

Les thèmes « vide », « événement paranormal », « entité », « sauvetage » et « refuge » sont des rôles dominants. Ils ne sont pas des résultats mutuellement exclusifs qui rendraient un étage essentiel vide par hasard. Un niveau de sauvetage peut posséder une anomalie discrète ; un refuge certifié ne peut recevoir aucune attaque.

Les variantes présentées dans les entrées détaillées doivent être produites progressivement. La version de départ peut ne posséder qu’un plan par étage. L’objectif est d’obtenir quelques plans lisibles et robustes avant d’augmenter leur nombre.

## 2 Coupe générale de la tour Aube

| Code | Niveau | Fonction initiale | Rôle dominant | Statut dans la première tranche |
|---|---|---|---|---|
| A-TOIT | Toit | Hélisurface et maintenance | Arrivée, commandement, évacuation différée | Dans le périmètre |
| A30 | 30 | Restaurant panoramique | Premier sauvetage | Dans le périmètre |
| A29 | 29 | Suites de l’hôtel | Observation de Bravo, effondrement vécu, indice et détour | Dans le périmètre |
| A28 | 28 | Bureaux et archives | Sauvetage de Samuel après impact, chronologie | Dans le périmètre |
| A27 | 27 | Jardin d’enfants | Silence et trace d’Alma | Dans le périmètre |
| A26 | 26 | Spa et piscine technique | Sauvetage et anomalie | Dans le périmètre |
| A25 | 25 | Maintenance supérieure | Refuge certifié et relais | Dans le périmètre, fin de tranche |
| A24 | 24 | Centre de congrès | Traversée et groupe isolé | Campagne conçue |
| A23 | 23 | Exposition d’art et d’histoire | Enquête sur l’île | Campagne conçue |
| A22 | 22 | Galerie de boutiques | Itinéraires et premier faux appel | Campagne conçue |
| A21 | 21 | Cuisines et cantine | Danger matériel et entraide | Campagne conçue |
| A20 | 20 | Logistique hôtelière | Refuge certifié et regroupement | Campagne conçue |
| A19 | 19 | Résidences hautes | Sauvetage et liens familiaux | Campagne conçue |
| A18 | 18 | Résidences basses | Traversée verticale intérieure | Campagne conçue |
| A17 | 17 | Télécommunications | Réparation de relais et vérification | Campagne conçue |
| A16 | 16 | Sports et loisirs | Franchissement et paysage | Campagne conçue |
| A15 | 15 | Centre médical | Refuge certifié et choix d’itinéraire | Campagne conçue |
| A14 | 14 | Espaces de travail partagés | Désorientation vérifiable | Campagne conçue |
| A13 | 13 | Étage condamné | Première contradiction spatiale forte | Campagne conçue |
| A12 | 12 | Diagnostic et domotique | Comprendre les réseaux du bâtiment | Campagne conçue |
| A11 | 11 | Salons de réception privés | Témoignage et trace de Sorel | Campagne conçue |
| A10 | 10 | Poste technique de secours | Refuge certifié et distribution d’énergie | Campagne conçue |
| A09 | 9 | Clinique SILLAGE | Preuves humaines et menace | Campagne conçue |
| A08 | 8 | Laboratoires de géologie | Comprendre les empreintes | Campagne conçue |
| A07 | 7 | Direction et archives juridiques | Responsabilités et décisions | Campagne conçue |
| A06 | 6 | Liaison basse entre les tours | Débris secondaires et accès futur à Hespérie | Campagne conçue |
| A05 | 5 | Sécurité incendie | Refuge certifié et dernier réseau stable | Campagne conçue |
| A04 | 4 | Galerie et musée de marque | Submersion et passé effacé | Campagne conçue |
| A03 | 3 | Parking automatisé | Machines immobilisées et extraction | Campagne conçue |
| A02 | 2 | Jardin intérieur et grand hall | Vue de la ville au niveau de l’eau | Campagne conçue |
| A01 | 1 | Accueil bas et services | Retrouvailles avec Alma | Campagne conçue |
| A00 | Terrasse intermédiaire | Toit du socle et passerelle | Dernier transfert puis rupture | Campagne conçue |

Les numéros décrivent les espaces de la tour, pas une équidistance obligatoire. Les doubles hauteurs, locaux techniques et décalages entre tours doivent apparaître dans les plans de production. Le prototype utilise une hauteur régulière pour rendre la descente facile à tester ; cette simplification ne fixe pas définitivement l’architecture de la campagne.

## 3 Toit et premiers étages

### A TOIT Le poste qui attend le retour

**Fonction et image.** Hélisurface, groupes techniques et terrasse de maintenance. Deux appareils et des groupes de secours sont visibles dans la maquette 0.6.0, répartis sur les deux tours. Aube et Hespérie sont droites, séparées et visiblement intactes. Le poste de commandement et le treuil principal sont sur Aube ; Bravo est déposé sur Hespérie. La campagne enrichira les gestes des équipiers, la tente médicale et les transferts de matériel.

**Traversée et action.** Le joueur reçoit son objectif, consulte le repérage du bâtiment et rejoint l’ancrage marqué du puits de service. L’ouverture constitue un accès de travail identifié. Le passage enseigne l’observation et l’interaction sans présenter le toit comme déjà effondré.

**Danger et contrejeu.** Vent et débris restent principalement une mise en scène dans le tutoriel. Les limites de déplacement sont nettes. Aucun faux pas non enseigné ne supprime immédiatement la partie.

**Personnes et information.** Varga présente la mission ; Bravo confirme sa présence sur Hespérie, où des signaux et des personnels techniques doivent être localisés malgré la fermeture au public. Le départ des deux hélicoptères retire progressivement les rotors. Malik et Inès enrichiront cette installation dans la campagne.

**Variables.** Position des caisses, petites conversations, visibilité de la côte et angle de pluie. La présence initiale de deux appareils et de deux groupes identifiables reste fixe.

**Invariant.** Point d’arrivée sûr, premier ancrage visible, retour identifiable et annonce honnête de l’attente météo. La présentation d’approche peut être passée ; son horloge n’avance ni les départs opérationnels des appareils ni les ressources de mission.

Les retours confirmés sont visibles au poste médical : Ana sur une civière de maquette, Samuel sous une couverture jaune et Nora sous une couverture claire, avec noms et statut à l’abri. La présentation est reconstruite depuis le registre, sans duplication ni nouveaux obstacles. Sur Hespérie, trois silhouettes de toit rejoignent le noyau lors de l’incident.

### A30 Restaurant panoramique Le Belvédère

**Fonction et image.** Grande salle de restaurant panoramique, bar courbe, tables et verrière intacts au premier passage. Des couverts abandonnés, les lumières de secours et la mer autour de la ville racontent l’évacuation. Une cuisine de finition et un couloir de service donnent une structure simple au lieu. Les bris associés au choc entre les tours apparaissent seulement après l’événement du 29.

**Traversée et danger.** Une courte descente conduit sur un palier dégagé, à côté du puits de service. La première lecture du vide concerne cette ouverture architecturale et la ligne de rappel. Le trajet vers Ana reste calme et praticable. Des obstacles secondaires de campagne pourront être ajoutés sans détruire la façade avant l’effondrement.

**Personne et indice.** Ana Rios, maître d’hôtel, est la première rescapée. Elle sait où des clients ont été déplacés. Une table préparée trop récemment introduit un doute discret, sans interrompre le sauvetage.

**Variables.** Chemin à gauche ou à droite du bar, position de trois groupes de tables et accessoires de service. La façade intacte au départ et le trajet du premier sauvetage sont fixes.

**Invariant.** Ana est présente, joignable et enregistrée une seule fois. Son treuillage confirmé précède l’objectif d’observation du 29 et demeure acquis après le choc. Une route d’évacuation simple existe ; aucune entité hostile n’interrompt cet apprentissage.

### A29 Les Suites de Nacre

**Fonction et image.** Couloir feutré, chambres communicantes, valises ouvertes et baie Est intacte face à Hespérie. Avant le choc, la vue permet de repérer le détachement déposé sur l’autre tour. Après le choc, le vitrage, les débris et la silhouette inclinée d’Hespérie racontent une transformation vécue par le joueur.

**Traversée et danger.** Après le sauvetage d’Ana et le départ des hélicoptères, l’objectif dirige le joueur vers la baie Est pour repérer Bravo. L’approche et le regard vers Hespérie arment l’événement. Avertissement de 8 s, réplique de 6 s, effondrement de 7 s et impact de 4 s se succèdent avec déplacement et regard libres. Le passage latéral touché devient un détour intérieur lisible. Le puits et le retour vers le toit restent utilisables. Les accessoires ne peuvent obstruer ni la baie d’observation ni ce détour.

**Personne et indice.** La chambre 2908 contient le premier indice stable de la tranche : une trace datée qui ne correspond pas aux explications de fermeture. Les occupants ont quitté cette chambre ; leur absence n’est pas assimilée automatiquement à un décès.

**Ressource.** Un lot de ravitaillement accessible soutient la suite de la descente.

**Variables.** Chambre d’entrée, disposition des accessoires et objets personnels. La baie Est, le cadrage naturel d’Hespérie, l’abri intérieur et le détour après impact sont des invariants. La graine peut faire varier les dangers secondaires compatibles ; ils ne doivent pas imposer une dépense de survie pendant l’observation scénarisée.

**Invariant.** L’indice Chambre 2908 et le ravitaillement restent atteignables avant et après impact, sans dépense indispensable non fournie. Un point sûr précède l’avertissement et un autre suit la stabilisation. La pause fige la séquence ; une interruption pendant celle-ci reprend avant l’événement. Aucune porte ni collision nouvelle ne peut enfermer le joueur ou condamner son retour.

Les deux silhouettes de la galerie Bravo se tournent et rentrent à couvert. Les appels de structure sont prioritaires et restent consultables dans les trente-deux dernières transmissions. Leur disparition visuelle ne décide pas de leur sort.

### A28 Bureaux et archives de l’hôtel

**Fonction et image.** Espace de gestion, archives de maintenance, petite salle de réunion et postes informatiques inertes. Après le choc observé au 29, la poussière, les débris de façade et les papiers déplacés donnent une continuité visible entre les deux étages. L’intérieur utile au sauvetage demeure stable.

**Traversée et danger.** Des cloisons créent deux chemins courts vers le même noyau. Le trajet principal reste large pour un transfert. Le danger de campagne peut être un câble sous tension identifiable ; il faut un circuit isolable et une voie d’attente sûre.

**Personne et indice.** Samuel Breton, technicien des archives, est la deuxième personne à prendre en charge. Dans la progression normale, il réagit au choc qui vient d’avoir lieu puis signale que les ordres de fermeture sont antérieurs au typhon. S’il est rejoint avant le déclenchement, sa réplique doit rester compatible avec des tours encore intactes. Son sauvetage reste possible dans les deux états. La campagne pourra lui permettre d’aider Inès à interpréter les plans.

**Variables.** Cloisons ouvertes, bureaux déplacés, emplacement de Samuel dans la zone de travail accessible, piles de dossiers et portes vitrées.

**Invariant.** Samuel possède un trajet clair vers le relais. Le joueur ne doit pas deviner un code numérique pour effectuer ce sauvetage obligatoire. La chronologie antérieure est introduite sans révéler tout SILLAGE.

### A27 Le Jardin des Marées

**Fonction et image.** Espace d’activités, salle calme, sanitaires adaptés et petit jardin intérieur. Les meubles bas, les dessins et les manteaux montrent la vie du lieu. Il n’y a plus d’enfants sur cet étage.

**Traversée et danger.** Un passage entre les salles demande surtout de lire les traces d’évacuation. Une source sonore ordinaire peut être coupée. Le silence qui suit doit durer ; l’étage n’exige pas d’apparition agressive.

**Personne et indice.** Un dessin signé par Alma relie les deux tours sous la mer et évoque une voix dans les tuyaux. Le registre confirme que les enfants ont été déplacés vers des zones plus basses avant la mission. Cette preuve garantit l’existence d’Alma en dehors des perceptions d’Alex.

**Variables.** Disposition des tables, salle d’activités accessible, jouet sonore, objets de la dernière activité et position exacte du dessin dans un espace identifié.

**Invariant.** Aucun enfant n’est tiré au hasard comme victime d’une attaque. Le dessin et l’information d’évacuation demeurent accessibles. Le niveau offre une respiration après l’effondrement et le sauvetage de Samuel, avant l’anomalie du spa. Aucun second effondrement ne vient annuler ce temps calme.

Depuis la 0.5.0, le retour facultatif d’une phrase de Bravo peut suivre six secondes de calme radio au 27, après Samuel confirmé et l’incident stabilisé. Le message attend hors rappel, portage et treuillage. Sa réception demande un checkpoint ; quitter l’étage sans l’entendre ne bloque aucun objectif. Varga peut ensuite vérifier le signal en zone calme.

### A26 Spa et piscine technique

**Fonction et image.** Bassin suspendu, cabines de soin, vestiaires et locaux de filtration. L’eau du bassin reflète des lumières qui ne semblent pas toutes correspondre au plafond. Le volume permet de retrouver la tour voisine dans son état après impact ; elle reste partiellement debout contre Aube. Les reflets peuvent désormais introduire une contradiction avec cette géométrie connue.

**Traversée et danger.** Une passerelle sèche contourne le bassin. Dans la campagne, un circuit électrique ou une conduite doivent être isolés avant une traversée secondaire. Le trajet obligatoire du prototype reste réalisable avec les moyens disponibles.

**Personne et indice.** Nora Haddad, kinésithérapeute, constitue la troisième rescapée. Elle a entendu un appel dans un local condamné. Le Relevé SILLAGE 06 fournit une première mention explicite du programme.

**Anomalie.** Une apparition ou contradiction est garantie à cet étage. Elle arrive après que le joueur a pu reconnaître un objectif humain. Son déclenchement ne doit pas rendre Nora inaccessible.

**Variables.** Reflets, mobilier de soin, position de la voie sèche, contenu secondaire des vestiaires.

**Invariant.** Nora, le relevé et la sortie restent atteignables. Le refuge inférieur est une destination clairement lisible. Aucun tirage n’annule l’anomalie narrative de la tranche.

### A25 Refuge de maintenance supérieure

**Fonction et image.** Atelier, local de sécurité et palier protégé par une séparation coupe-feu. L’éclairage chaud tranche avec les étages ouverts. Du matériel de maintenance a été organisé en point de secours.

**Traversée et action.** Le joueur rejoint un espace stable, fait le bilan des trois personnes et active la balise vers le toit. La campagne permet ensuite de poursuivre ; la tranche du prototype se conclut ici lorsque ses conditions sont remplies.

**Danger.** Aucun ennemi, aucune attaque surprise, aucune dépense de survie pendant le repos. Des bruits peuvent venir du dehors, sans altérer ce contrat.

**Information et ressource.** Ravitaillement, reprise de contact et confirmation des prises en charge. Les indices peuvent être relus.

**Variables.** Petits objets de travail, messages de personnes déjà sauvées et contenu décoratif. Les ressources minimales sont fixes.

**Invariant.** La fin du prototype exige l’incident achevé, les trois rescapés et la balise. Si la baie du 29 a été sautée, un objectif doit indiquer le retour à effectuer. Arriver seul au 25 ne donne pas automatiquement la réussite. La certification du refuge est fiable.

Le bilan final permet de rouvrir le journal et ses transmissions sans relancer la simulation. Une vérification de l’écho de Bravo encore en attente peut arriver au 25 avant la clôture si ses conditions de calme sont remplies ; attendre cette réplique n’est pas obligatoire.

## 4 Les étages publics et résidentiels

### A24 Centre de congrès

**Fonction et image.** Auditorium, cabines de traduction et foyer de réception. Un écran suspendu est resté coincé au-dessus de rangées de sièges. Des projecteurs de secours dessinent plusieurs zones d’ombre.

**Traversée et danger.** Le trajet peut passer par le foyer ou par les coulisses. La grande salle est coupée par une structure suspendue instable, annoncée par des craquements et de la poussière. Un passage haut donne une alternative préparée.

**Personne et indice.** Une interprète s’est réfugiée dans une cabine avec un visiteur malentendant. Le sauvetage enseigne l’importance des signes visuels. Une présentation Pelagos annonce un programme de bien-être proche de SILLAGE sans le nommer.

**Variables.** Configuration des sièges, entrée latérale, cabine occupée, présentation affichée et état de l’éclairage.

**Invariant.** Les informations nécessaires à l’opération ne sont jamais uniquement sonores. L’itinéraire escortable évite le franchissement technique réservé à Alex.

### A23 Exposition Histoire de Nacre

**Fonction et image.** Art contemporain, maquettes du complexe et exposition permanente sur l’île. Une maquette révèle des volumes souterrains absents du plan touristique actuel.

**Traversée et danger.** Le niveau privilégie l’observation. Une baie détruite oblige à contourner une sculpture couchée ; des vitrines ne servent pas toutes de barrières infranchissables. Les espaces restent plus ouverts que l’étage précédent.

**Personne et indice.** Un gardien peut être présent dans une variante de sauvetage secondaire. Dans toutes les variantes, une photographie des anciens bains montre la même forme de porte que certains dessins récents. Le passé local devient concret.

**Variables.** Parcours de l’exposition, œuvres endommagées, présence du gardien, lumière naturelle et emplacement du document principal.

**Invariant.** Le lien entre la ville moderne et les bains enfouis demeure accessible. Aucune connaissance extérieure d’histoire ou de symboles religieux n’est nécessaire pour comprendre l’indice.

### A22 Galerie des boutiques

**Fonction et image.** Boutiques de luxe, café fermé, réserves et allée centrale. Les vitrines reflètent les lampes. Une enseigne tourne lentement au bout d’un câble.

**Traversée et danger.** Le joueur peut traverser les arrière-boutiques pour éviter une galerie exposée. Un premier faux appel tente de l’attirer vers une gaine. Le code radio appris permet de vérifier l’origine.

**Personne et indice.** Une employée réelle est cachée dans une réserve différente de la source du faux appel. Sa présence est confirmée par un signe matériel. Des bons de livraison indiquent des achats de matériel acoustique sans rapport avec les magasins.

**Variables.** Boutique accessible, rideaux métalliques, trajet de réserve, emplacement du témoin et source du son trompeur.

**Invariant.** La voix imitée ne peut annoncer mensongèrement qu’un sauvetage déjà confirmé est annulé. Il existe une méthode de vérification avant tout risque majeur.

### A21 Cuisines et cantine

**Fonction et image.** Cuisines centrales, plonge, chambre froide et cantine du personnel. Le contraste avec la galerie montre les coulisses du luxe. Des plateaux ont été utilisés pour caler une porte.

**Traversée et danger.** Fumée localisée, équipement chaud et écoulement d’eau créent une situation matérielle compréhensible. Le joueur coupe une alimentation et ouvre un passage de service. Le réseau critique possède des indications répétées.

**Personne et indice.** Un cuisinier et une agente d’entretien peuvent avoir organisé une petite zone d’attente. L’une d’elles connaît l’accès au refuge 20. Leur témoignage précise que certains bruits sous le sol existaient avant la catastrophe.

**Variables.** Source de fumée, porte de service coincée, réserves accessibles et composition du groupe dans une limite de navigation connue.

**Invariant.** Le matériel nécessaire au passage principal est fourni avant le danger. Les personnes prises en charge apportent un résultat visible au refuge suivant.

### A20 Refuge de logistique

**Fonction et image.** Lingerie, dépôt de chariots et salle du personnel transformés en point de regroupement. Des couvertures et du linge propre donnent au refuge une identité différente du 25.

**Traversée et action.** Les personnes sauvées dans le secteur sont confiées à une équipe. Le joueur peut ouvrir une route de retour vers un relais supérieur et recevoir deux pistes pour la suite.

**Danger.** Aucun à l’intérieur du périmètre certifié. Une porte vers un secteur non vérifié est clairement distinguée de la zone sûre.

**Personnes et information.** Le cuisinier peut préparer une boisson chaude. Une résidente demande des nouvelles d’un proche au 19. Inès donne une version annotée du plan.

**Variables.** Dialogues selon les personnes sauvées, décor de ravitaillement et messages radio disponibles.

**Invariant.** Sauvegarde, ressources minimales et sortie vers le palier garanties. La présence d’un personnage secondaire ne conditionne pas l’accès au ravitaillement indispensable.

### A19 Résidences hautes

**Fonction et image.** Appartements loués à long terme, bibliothèque commune et balcons. Certaines pièces semblent encore habitables, ce qui renforce le contraste avec la catastrophe extérieure.

**Traversée et danger.** Les cloisons déplacées obligent à traverser deux appartements avec accord des occupants ou à passer par un service. Un vide entre les niveaux 19 et 18 montre une première route verticale intérieure indépendante de la gaine principale.

**Personne et indice.** Une personne âgée attend son compagnon parti chercher un traitement. Le joueur peut d’abord établir sa sécurité puis choisir le détour vers une armoire de soins. Un message conservé évoque des visites nocturnes de techniciens dans Hespérie.

**Variables.** Appartement occupé, sens du passage, accès au balcon et objets racontant les habitants.

**Invariant.** Une personne peu mobile ne doit pas suivre un trajet exigeant le même franchissement qu’Alex. Le détour de secours reste explicitement séparé du trajet nécessaire pour poursuivre.

### A18 Résidences basses

**Fonction et image.** Partie inférieure des duplex, couloirs de service et local d’entretien. Un salon du 19 est visible au-dessus d’un plancher rompu.

**Traversée et danger.** Le joueur utilise une ligne courte et un relais pour contourner une cage d’escalier bloquée. Un appui est observé depuis le niveau supérieur avant d’être utilisé. La campagne peut proposer une remontée locale avec une personne équipée pour suivre.

**Personne et indice.** Le compagnon recherché au 19 peut être retrouvé, ou un signe fiable indique qu’une autre équipe l’a déjà pris en charge. Une feuille de maintenance confirme que la fissure principale avait été signalée des semaines plus tôt.

**Variables.** Emplacement de l’appui, couloir encombré, présence directe du témoin et petits obstacles de mobilier.

**Invariant.** Aucune branche ne rend insoluble la quête du 19. Le statut d’une personne est communiqué de façon fiable, même si son emplacement varie.

### A17 Télécommunications

**Fonction et image.** Baies réseau, local radio interne et ancien studio de présentation. Les ventilateurs s’arrêtent par zones. Une diode continue de clignoter sur un équipement sans alimentation visible.

**Traversée et danger.** Le joueur doit rétablir un relais de portée locale en suivant un circuit simple. La zone peut accueillir la première confrontation avec un Répondant qui utilise le réseau. L’enjeu consiste à vérifier la destination de l’émission avant de la relancer.

**Personne et indice.** Un technicien a enregistré deux messages identiques à des heures incompatibles. Il peut être vivant dans un local protégé. Les enregistrements restent récupérables quelle que soit cette variante.

**Variables.** Baie active, trajet de câbles, position du technicien et ordre de quelques tâches secondaires.

**Invariant.** Un code contextuel ou une donnée vérifiable permet la résolution. L’erreur ne coupe pas définitivement l’unique moyen d’évacuer la campagne.

### A16 Sports et loisirs

**Fonction et image.** Salle de sport, mur d’escalade intérieur, terrains et vestiaires. La façade détruite transforme une salle de course en balcon ouvert sur la ville noyée.

**Traversée et danger.** Une traversée latérale offre un moment de verticalité ample après le local réseau. Des câbles et supports conçus pour le bâtiment fournissent les points de jeu autorisés ; les prises sportives ne sont pas automatiquement des ancrages de secours.

**Personne et indice.** Une monitrice peut aider un client à surmonter sa peur du vide. Une caméra fixe a enregistré une silhouette dans Hespérie après sa fermeture.

**Variables.** Chemin par les vestiaires ou la salle, orientation d’une passerelle, objets sportifs déplacés et lumière extérieure.

**Invariant.** Le point d’arrivée reste visible avant le franchissement. La pression de temps ne commence pas pendant que le joueur découvre les commandes. Un détour accessible accompagne la personne à secourir.

### A15 Refuge médical

**Fonction et image.** Infirmerie et cabinet de consultation de l’hôtel. Une petite équipe a isolé des pièces stables pour accueillir les personnes remontées des niveaux bas.

**Traversée et action.** Le joueur remet les informations recueillies, recharge son matériel et choisit une priorité entre un accès direct au 14 et un court détour de service. Un bilan montre les conséquences des opérations précédentes.

**Danger.** Aucun dans le refuge. Les soins sont abstraits et ne deviennent pas une séquence de gestes médicaux précis à reproduire hors du jeu.

**Personnes et indice.** Une soignante reconnaît la terminologie utilisée dans les documents SILLAGE, sans avoir travaillé au bunker. Elle distingue les personnes en détresse des phénomènes qui les entourent.

**Variables.** Témoins présents, conversations, demandes secondaires et matériel décoratif.

**Invariant.** Sauvegarde et départ possibles sans accomplir toutes les quêtes secondaires. Le refuge n’est jamais un laboratoire hostile déguisé.

## 5 Les niveaux du secret

### A14 Espaces de travail partagés

**Fonction et image.** Grandes plateaux de bureaux, bulles de réunion et zones de repos. Des rangées de cloisons se ressemblent, mais des repères permanents permettent de les distinguer.

**Traversée et danger.** Une anomalie modifie un trajet secondaire lorsque le joueur ne l’observe plus. Le marquage, les fenêtres et le télémètre permettent d’établir un chemin stable. Le noyau de sortie ne se déplace pas arbitrairement.

**Personne et indice.** Une employée décrit une pièce plus longue à l’aller qu’au retour. Elle peut confirmer une mesure du joueur. Un relevé de réservation montre une réunion officiellement située sur un étage fermé.

**Variables.** Cloisons secondaires, séquence d’ouverture, positions de trois repères et présence de l’employée.

**Invariant.** Au moins deux repères fiables sont disponibles avant la contradiction. Le joueur ne doit pas errer indéfiniment pour déclencher la sortie.

### A13 Le niveau absent

**Fonction et image.** Sur les documents commerciaux, le niveau est nommé 12 bis. La porte technique porte encore 13. Derrière, un couloir condamné rejoint un ancien sas d’essai.

**Traversée et danger.** Le plan du joueur et le numéro du bâtiment divergent, mais la géométrie principale reste finie et vérifiable. Une Rémanence répète un trajet de service ; l’observer permet de repérer une ouverture masquée.

**Personne et indice.** Pas de sauvetage obligatoire ici. Une liste d’accès contient des noms d’employés déclarés partis ailleurs. Une voix enregistrée demande l’arrêt d’une expérience.

**Variables.** État des revêtements, porte secondaire, détails de la répétition et accessoires de condamnation.

**Invariant.** L’empreinte principale ne poursuit pas le joueur. Ce niveau enseigne à observer une répétition avant d’introduire une variante adaptative plus dangereuse.

### A12 Diagnostic du bâtiment

**Fonction et image.** Atelier de domotique, systèmes de façade et salle de supervision. Une vue schématique des deux tours donne enfin une lecture de leurs liaisons cachées.

**Traversée et danger.** Le joueur remet en service une section locale et ouvre une porte de secours. Une machine peut être arrêtée pour réduire le bruit et rendre audible un déplacement. L’action prépare la règle du Noyé sec.

**Personne et indice.** Un agent de maintenance a conservé les versions précédentes des plans. Les différences montrent une galerie effacée et une fermeture d’Hespérie antérieure au discours officiel.

**Variables.** Circuit actif, chemin dans l’atelier, emplacement des plans et quantité de bruit ambiant.

**Invariant.** Le puzzle reste compréhensible sans connaissance d’électricité. Les états des circuits sont explicitement montrés ; un choix ne tue pas hors champ un survivant sans information préalable.

### A11 Salons privés

**Fonction et image.** Salles de réception, bibliothèque de direction et petite salle de projection. Un repas interrompu suggère une réunion tenue peu avant la crise.

**Traversée et danger.** Le joueur traverse des espaces calmes, découvre une issue de service et entend une conversation répétée. Le danger vient d’une présence qui approche sous un fond sonore continu ; couper ce fond donne un répit.

**Personne et indice.** Un assistant de direction peut témoigner sur les ordres de Sorel. Une note distingue la fermeture structurelle d’Hespérie de la suspension des essais, prouvant que les deux sujets ont été volontairement mélangés.

**Variables.** Salon ouvert, appareils sonores, place du témoin et détails du repas.

**Invariant.** La règle du bruit a été introduite au 12. Le joueur peut fuir vers une issue claire sans devoir vaincre la présence.

### A10 Refuge technique

**Fonction et image.** Poste de secours électrique, pièces de repos et ancien local d’astreinte. Un tableau mural montre les circuits coupés et les relais encore capables de transmettre au toit.

**Traversée et action.** À l’intérieur de la zone certifiée, le joueur peut redistribuer des ressources de mission et préparer l’entrée dans les laboratoires. Une commande locale sécurise un sas extérieur ; le danger appartient au secteur suivant.

**Personnes et indice.** Malik peut rejoindre Alex brièvement selon sa route. Inès confirme que les documents recueillis décrivent des essais antérieurs. Une information fiable localise une équipe dans les niveaux bas.

**Variables.** Présence de Malik, dialogues, état visuel du réseau et objectifs secondaires proposés.

**Invariant.** Les réglages du refuge ne peuvent condamner le ravitaillement de base ni les survivants déjà confirmés. Aucun ennemi ne traverse sa limite.

### A09 Clinique SILLAGE

**Fonction et image.** Chambres d’observation, salle d’entretien et postes de mesure cachés derrière une façade de centre de bien-être. Des éléments familiers du spa apparaissent dans un contexte beaucoup plus inquiétant.

**Traversée et danger.** Les portes d’observation créent un circuit à deux accès. Une présence Veilleuse réagit aux émissions actives. Le joueur peut couper sa radio, déplacer un leurre ou attendre le retour d’un relais stable.

**Personne et indice.** Une ancienne participante aux essais possède une mémoire fragmentaire mais conserve une volonté et des choix. Ses documents confirment des procédures non consenties ou déformées par Pelagos. Le jeu évite de confondre son état avec la cause des entités.

**Variables.** Chambre occupée, route de service, dispositif émetteur et séquence de témoignage.

**Invariant.** Une méthode non violente de sauvetage existe. La personne ne devient pas automatiquement une ennemie à la fin du dialogue.

### A08 Laboratoires de géologie

**Fonction et image.** Échantillons de pierre de Nacre, chambres sourdes, cuves et postes d’enregistrement. Certains sons se déplacent d’une salle à l’autre sans chemin apparent.

**Traversée et danger.** Le joueur compare deux réponses acoustiques, isole une émission et ouvre un accès technique. Une salle permet d’observer une empreinte dans des conditions relativement contrôlées.

**Personne et indice.** Un chercheur ou un enregistrement complet établit que SILLAGE n’a pas créé le phénomène. Des échantillons plus anciens présentent la même signature. L’information précise la responsabilité humaine sans expliquer toute la cosmologie.

**Variables.** Salle d’essai utilisable, position des échantillons, présence du chercheur et bruit de machines.

**Invariant.** La preuve principale est obtenable même si le témoin est absent. Les étapes de l’expérience sont un puzzle fictionnel clairement guidé, pas un protocole scientifique réel.

### A07 Direction et archives juridiques

**Fonction et image.** Bureaux de direction, salle de contrats et coffre documentaire. Les parois épaisses ont mieux résisté que les espaces ouverts. Une fenêtre révèle les dégâts secondaires et la liaison basse entre les tours, longtemps après le choc principal vécu au 29.

**Traversée et danger.** Une porte sécurisée possède deux voies d’ouverture : coopération d’un témoin ou accès physique de maintenance. La salle n’est pas un simple code caché dans un post-it ; les informations obtenues ailleurs peuvent accélérer l’accès.

**Personne et indice.** Un responsable administratif sait que les risques ont été minimisés. Les preuves montrent qui a signé, qui a alerté et ce qui a été caché. Sorel intervient par radio ou en personne selon l’écriture finale.

**Variables.** Témoin disponible, entrée de maintenance, documents secondaires et ordre de lecture.

**Invariant.** La culpabilité de Pelagos repose sur des actes documentés. Le jeu ne fait pas du groupe la cause magique de tous les phénomènes naturels.

### A06 La liaison basse brisée

**Fonction et image.** Ancien étage de liaison et plateforme de service, touchés par les débris et déplacements secondaires du choc entre les tours. Le premier impact a déjà eu lieu aux étages hauts pendant le passage au 29. A06 donne accès à une liaison basse déformée, avec des couloirs et des passerelles qui ne s’alignent plus. Sa coupe précise reste à produire pour la campagne.

**Traversée et danger.** Le joueur doit rejoindre un point de circulation stable en observant les appuis et les mouvements. Une route secondaire ouvre la traversée d’Hespérie. Les grandes déformations sont préparées et annoncées ; elles ne dépendent pas d’un effondrement physique imprévisible.

**Personne et indice.** Une équipe de secours peut être retrouvée isolée de l’autre côté d’une passerelle, sans que la rupture du contact au 29 ait annoncé sa mort. Des marques anciennes prouvent qu’une intervention avait déjà eu lieu dans Hespérie ; elles ne constituent pas la preuve d’un précédent basculement de toute la tour.

**Variables.** Appui utilisable, voie de service, détail des débris et visibilité entre tours.

**Invariant.** Le joueur peut poursuivre la campagne sans explorer chaque pièce d’Hespérie. Le trajet critique et les objectifs de détour sont distincts.

### A05 Refuge de sécurité incendie

**Fonction et image.** Ancien poste central de sécurité et réserve d’intervention. Les cartes papier, les lampes et le matériel donnent l’impression d’un dernier lieu organisé au-dessus des parties inondées.

**Traversée et action.** Le joueur remet des survivants, enregistre les preuves et prépare la descente vers le socle. Une sauvegarde forte marque le début d’un secteur dont les retours seront plus longs.

**Personne et indice.** Une cheffe d’équipe confirme qu’Alma a été vue près du niveau 1 avec d’autres personnes. Les communications avec le toit sont réduites mais authentifiées.

**Variables.** Personnes présentes, matériel visuel, récits de la traversée d’Hespérie et informations secondaires.

**Invariant.** Refuge certifié sans attaque. Le minimum respiratoire et les moyens d’orientation nécessaires au socle sont disponibles. Le joueur sait qu’une descente plus difficile commence.

## 6 Le socle et la rupture

### A04 Musée de marque et galerie basse

**Fonction et image.** Boutique souvenir, galerie promotionnelle et musée de l’histoire récente d’Orphée. L’eau entre par intermittence dans les volumes les plus bas. Les slogans de luxe sont visibles au-dessus de meubles flottants.

**Traversée et danger.** Le joueur passe par des plateformes sèches et coupe un circuit exposé. Les courants locaux sont faibles et contrôlés pour le gameplay ; la campagne ne transforme pas cet étage en simulation maritime complète.

**Personne et indice.** Un salarié possède les clés d’une ancienne salle exclue du musée. Une photographie non retouchée révèle l’accès aux bains enfouis. Un sauvetage secondaire peut être proposé dans une réserve accessible.

**Variables.** Niveau d’eau dans une plage validée, position des meubles, réserve ouverte et côté du passage sec.

**Invariant.** Le trajet principal ne demande pas une longue plongée sans outil fourni. Le lien avec les anciens bains est obtenu avant la chute.

### A03 Parking automatisé

**Fonction et image.** Plateformes de véhicules, ascenseurs de stockage et poste de contrôle. Des voitures sont restées suspendues. Une cabine bloquée forme un passage inhabituel.

**Traversée et danger.** Le joueur immobilise un mécanisme local puis franchit son volume en sécurité. Les machines possèdent un cycle annoncé et une commande d’arrêt lisible. Une voiture ne tombe pas au hasard sur la seule sortie.

**Personne et indice.** Un chauffeur est coincé près d’une plateforme. Son véhicule de service transporte du matériel destiné à un site qui ne figure sur aucun panneau public. Le sauvetage utilise un accès mécanique simplifié.

**Variables.** Plateforme immobilisée, position des véhicules décoratifs, poste de commande et route de maintenance.

**Invariant.** La voie de transfert du chauffeur est validée. Le joueur ne doit pas sauter entre des véhicules en mouvement avec un blessé.

### A02 Jardin intérieur et grand hall

**Fonction et image.** Palmiers, bassins décoratifs, escaliers et verrière monumentale. La ville noyée se trouve presque à hauteur du regard. Des bâtiments qui semblaient minuscules depuis le toit deviennent des masses proches.

**Traversée et danger.** Le joueur suit une coursive surélevée, traverse un accès de service et peut ouvrir une voie pour un groupe. Une poussée d’eau scriptée exige d’attendre derrière un appui protégé, avec des signes préalables explicites.

**Personne et indice.** Des habitants réfugiés dans une mezzanine indiquent le trajet pris par Alma. Une femme reconnaît les sons du programme parce qu’elle travaillait à proximité des bains.

**Variables.** Coursive praticable, emplacement du groupe, plantes couchées et zones de vue sur l’extérieur.

**Invariant.** Les personnes ne sont pas emportées par un tirage aléatoire hors de la vue du joueur. Une solution d’évacuation existe une fois le passage sécurisé.

### A01 Accueil du socle

**Fonction et image.** Accueil secondaire, bureau du personnel, consignes et accès à la terrasse intermédiaire. Les panneaux récents recouvrent des directions plus anciennes.

**Traversée et danger.** Le joueur retrouve Alma derrière une séparation provisoire et établit un court trajet vers un groupe de secours. Le sol porte des signes visibles de déformation ; la scène donne le temps de comprendre que la structure est menacée.

**Personne et indice.** Alma confirme qu’elle a suivi sa mère et d’autres employés après l’évacuation du 27. Elle reconnaît une sonnerie entendue sous les bains. Elle n’a pas besoin de connaître le secret final pour être utile.

**Variables.** Objets de l’évacuation, trajet court jusqu’à Alma et présence de témoins secondaires.

**Invariant.** Alma est réelle, identifiée et retrouvée avant la chute. Son sauvetage n’est pas remplacé par une silhouette trompeuse. Une sauvegarde précède la transition irréversible.

### A00 Terrasse intermédiaire

**Fonction et image.** Toit bas du socle, espaces techniques et passerelle vers un ancien pavillon. La mer entoure des morceaux de ville. Au-dessus, la silhouette des deux tours permet de mesurer la descente accomplie.

**Traversée et danger.** Alex tente de transférer Alma vers un point stable. Un grondement profond précède une réplique. Un appui de service se détache, la ligne amortit puis la rupture entraîne les deux personnages dans un volume enfoui. Cette transition est écrite et testée ; elle n’est pas causée par une mauvaise saisie d’une commande.

**Conséquence.** La chute mène au bassin des anciens bains. Les personnes déjà prises en charge dans les refuges gardent leur statut. Le réseau supérieur tente de retrouver Alex.

**Variables.** Météo de mise en scène, messages récents et détails de décor. Le résultat narratif reste fixe.

**Invariant.** L’état d’avant rupture est conservé. Aucune ressource optionnelle manquée plus haut ne rend la suite impossible. Le joueur comprend pourquoi le chemin du toit est désormais fermé.

## 7 Traversée de la tour Hespérie

Hespérie est une ancienne tour condamnée, pas seulement un couloir ajouté à Aube. La campagne propose une traversée compacte de six espaces représentatifs, reliés par des décalages et des accès de service. Les numéros d’origine restent visibles pour montrer que le joueur traverse une structure partiellement déplacée. Leur relation exacte avec A06 doit être fixée par une coupe de niveau lors de la production ; le présent catalogue ne prétend pas fournir un plan d’ingénierie.

### H JONCTION La façade couchée

Une portion de façade et un ancien balcon forment l’entrée depuis la liaison basse du 6 et sa zone de débris secondaires. Le joueur doit lire l’orientation des cadres et les gravats avant de se déplacer. Une marque de secours vieille de plusieurs années apparaît sous un revêtement arraché. Les variantes changent la position d’une ouverture et les accessoires, jamais l’existence du point de retour. Un repère permanent indique la direction d’Aube.

### H SALON Le salon fermé depuis cinq ans

Un salon de réception conserve des verres, une horloge arrêtée et une partie de plafond propre, protégée de la poussière. Une Rémanence rejoue le début d’une évacuation. En suivant la scène à distance, le joueur repère une porte de service. Un document confirme la date du premier incident. L’empreinte ne devient pas hostile par un tirage aléatoire ; ce lieu est destiné à être observé.

### H CHAMBRES Les résidences murées

Une suite de chambres d’anciens employés a été condamnée sans être vidée. Les effets personnels donnent des noms aux absents. Un survivant récent, entré pour se protéger de la catastrophe, peut être présent et doit être distingué des silhouettes anciennes par un contact vérifiable. Les variantes choisissent les pièces secondaires et la place des preuves. Une personne réelle dispose toujours d’un trajet vers le relais d’Aube.

### H ESCALIER La cage inclinée

La cage d’escalier est devenue une succession de paliers décalés. Le joueur combine marche courte, appui et rappel. Des repères de hauteur montrent un déplacement de la structure, sans exiger une physique intégrale du bâtiment. Le danger vient de la lecture du trajet et d’un mouvement annoncé. La sortie est visible avant le dernier franchissement. Aucun ennemi ne surgit pendant l’apprentissage de ce nouveau mouvement.

### H OBSERVATION La pièce derrière le miroir

Un poste d’observation caché derrière un ancien espace hôtelier dévoile les moyens des premières expériences. Des écrans montrent des séquences répétées ; un changement dans l’une d’elles indique qu’un observateur a été observé en retour. Le joueur récupère une preuve et peut choisir d’interrompre l’émission. Les variantes changent l’ordre des écrans et les dossiers secondaires. Une solution sans exposition prolongée reste possible.

### H RETOUR Le relais des absents

Une petite zone technique permet de rétablir un contact avec Aube et de confirmer les personnes récupérées. Il s’agit d’un point de transfert protégé, pas nécessairement d’un refuge complet avec toutes les ressources. Malik peut y laisser un message ou y rejoindre le joueur. Le retour ne se ferme pas parce qu’un document optionnel n’a pas été lu. L’état de la traversée est enregistré avant de réintégrer Aube.

## 8 Les anciens bains et les souterrains

### S01 Le bassin sous la ville

**Image.** Alex reprend conscience dans un ancien bassin intérieur alimenté par des infiltrations. Des fragments du socle sont suspendus au-dessus. La lumière de la lampe révèle Alma emportée vers une galerie par le Porteur.

**Action.** Le joueur retrouve rapidement les commandes, récupère son matériel essentiel et identifie une trace concrète laissée par l’enfant. La ligne supérieure est inutilisable, visible et clairement expliquée.

**Danger et variation.** L’eau limite le mouvement et les bruits brouillent la distance. La position des éléments décoratifs peut varier ; le matériel de base et la sortie restent fixes. La scène de séparation évite la violence graphique.

**Invariant.** Aucun long passage sans outils ne suit la reprise. Le jeu sauvegarde un état jouable et conserve les réussites des tours.

### S02 Les vestiaires anciens

Des casiers, miroirs ternis et passages du personnel montrent une architecture antérieure à Pelagos. Les marquages d’Alma près du sol orientent le joueur. Une présence reflétée peut indiquer une sortie sans la bloquer. Le danger principal est la confusion de deux couloirs, résolue par des noms et des marques persistantes. Un registre ancien fournit une liste d’employés du premier établissement. Les variantes changent les casiers ouverts et le détour exploratoire ; la chaîne de repères ne peut être tirée de façon contradictoire.

### S03 Les galeries d’alimentation

Conduites, vannes et chemins étroits relient les bains aux cavernes. Un ouvrier de Pelagos a survécu dans une niche protégée et peut expliquer l’existence du bunker. La traversée demande d’attendre une variation de pression annoncée puis de rejoindre un sas. Les commandes sont fictionnelles et guidées par un schéma lisible. Les variantes portent sur la galerie secondaire et les fuites visuelles. Une solution stable existe sans chronométrage excessivement précis. Le joueur peut établir un nouveau relais de retour local.

### S04 Le refuge de la citerne

Une chambre de maintenance sèche, construite au-dessus d’une citerne, constitue le premier refuge certifié souterrain. Un contact intermittent avec Inès donne une preuve que le réseau supérieur existe encore. La réserve d’outils et la carte des galeries permettent de préparer le secteur naturel. Les personnes sauvées ici restent en sécurité, même si les communications se coupent. Des bruits profonds sont audibles à travers la roche ; aucune apparition n’envahit la zone. Les dialogues varient selon les preuves et les témoins, pas les garanties de repos.

### S05 Les cavernes des reprises

Le joueur entre dans une cavité où l’eau et la pierre produisent des réponses sonores répétées. Les Creuseurs défendent des zones identifiées par des traces. La route principale comporte des appuis réguliers et un passage haut ; des galeries latérales offrent des preuves facultatives. Le télémètre et les balises servent à reconstruire une carte. Les variantes choisissent un embranchement secondaire et l’emplacement des nids, mais jamais la seule issue. Le comportement territorial doit pouvoir être observé avant la première traversée risquée.

### S06 Le puits des équipes

Un grand puits porte plusieurs générations de lignes et de marques. Certaines sont récentes, d’autres appartiennent à l’incident d’Hespérie. Un secouriste isolé peut être retrouvé sur une terrasse et fournir un lien émotionnel avec l’opération du toit. Le joueur établit une chaîne courte de relais, puis rejoint un accès maçonné. Les voix qui montent du fond ne sont pas toutes adressées à lui. Les variantes changent le trajet secondaire et l’état visuel des anciennes lignes. Le matériel minimal pour la route principale est garanti.

### S07 Le sas Pelagos

Une porte industrielle coupe brutalement le paysage naturel. Les contrôles ont été conçus pour empêcher la sortie autant que l’entrée. Le joueur découvre un plan d’évacuation de l’installation et peut aider un employé bloqué dans un poste adjacent. Un Veilleur réagit aux émissions ; la règle déjà apprise plus haut redevient utile. Les variantes changent l’état initial des portes secondaires, pas la disponibilité d’un passage. Un indice montre que les ordres d’isolement ont été donnés avant le tsunami.

## 9 Le bunker SILLAGE

### B01 Réception et contrôle

Le bunker comporte une zone d’accueil impersonnelle, une salle de sécurité et un tableau d’accès aux chambres d’essai. Les noms retrouvés dans les tours réapparaissent sur des registres. Le joueur rétablit une circulation locale et découvre où Alma a été dirigée. Une conversation avec Sorel peut commencer ici, sous réserve des choix de scénario. Le danger vient d’un verrouillage annoncé, avec issue de secours lisible. Les preuves centrales restent accessibles par au moins deux chaînes d’actions.

### B02 Chambres de restitution

Plusieurs salles contiennent des fragments d’environnements reconstruits pour provoquer des empreintes. Une partie du restaurant ou du jardin d’enfants peut apparaître comme décor d’essai, ce qui explique certains motifs vus plus haut. Le joueur doit distinguer une répétition fixe d’une présence qui réagit. Une personne réelle est prisonnière d’une boucle de portes, mais une balise ou un témoin permet de maintenir la route ouverte. Les variantes portent sur les salles secondaires. Le mécanisme local reste apprenable et reproductible.

### B03 Archives des incidents

Les archives contiennent les avertissements, les rapports de fermeture et les décisions de reprise. Le joueur peut obtenir une preuve complète sans lire chaque page : quelques pièces essentielles établissent dates, auteurs et conséquences. Un détour donne davantage de noms et de contexte. La zone offre un moment de lecture à faible intensité, sans attaque déclenchée systématiquement à la prise d’un document. Les variantes concernent l’ordre d’accès et les preuves secondaires. Les responsabilités ne dépendent pas d’un seul témoin peu fiable.

### B04 La salle du Contremaître

Le réseau d’alimentation fonctionne encore selon une ronde entretenue par une empreinte complexe. Le Contremaître vérifie des circuits et ferme des accès si une séquence paraît incorrecte. Le joueur observe sa routine, modifie un circuit et crée une fenêtre de passage. Une méthode de repli existe si la première tentative échoue. Le combat ne constitue pas la solution principale. Les variantes peuvent inverser deux postes périphériques, mais le motif appris et les signaux restent cohérents.

### B05 Refuge de confinement

Une ancienne pièce de sécurité indépendante constitue le dernier refuge certifié. Alma peut y être retrouvée après une séquence de poursuite ou un détour dans les chambres, selon le scénario définitif. Ses marques ont participé à la progression et elle peut expliquer ce qu’elle a observé. Le joueur peut relire les preuves et préparer la fermeture du seuil. Aucune révélation ne transforme ce refuge authentifié en faux décor. Le point de sauvegarde protège l’accès au finale et conserve les personnes en sécurité.

### B06 Le dispositif du seuil

Trois liaisons maintiennent la relation entre le bunker et la profondeur. Le joueur doit comprendre ce que chacune transporte : énergie, motifs enregistrés et réponses humaines. Leur coupure ou leur détournement dépend des preuves et du réseau de secours établi. Sorel cherche à préserver certaines données, créant un conflit concret autour des commandes. Les actions sont signalées et leurs conséquences expliquées à l’échelle locale. La résolution ne demande pas de mémoriser une longue suite de symboles jamais enseignée.

## 10 Le seuil 666

### P666 La chambre qui écoute

Le code 666 correspond à **puits 6, boucle 6, seuil 6** dans l’ancienne classification SILLAGE. Le lieu est une profondeur impossible, pas le six cent soixante-sixième étage d’un immeuble. La signalétique et les distances deviennent contradictoires, tandis que certains objets laissés par le joueur demeurent fiables.

Des fragments du restaurant, des suites, du jardin d’enfants et de la tour abandonnée forment un espace composé. Chaque fragment possède une fonction de gameplay déjà apprise : maintenir une lumière, interrompre un appel, conserver un repère ou protéger un témoin. La pièce peut imiter un refuge, mais l’interface ne lui donne jamais une certification authentique.

Le Chœur bas maintient le passage à travers des réponses. Le joueur traverse plusieurs objectifs courts avec une possibilité de reprendre ses repères entre eux. Alma ou un autre survivant peut l’aider depuis un point protégé. La confrontation finale porte sur les liaisons et le retour, pas sur une immense barre de vie démoniaque.

**Variables autorisées.** Ordre de deux fragments secondaires, voix reprises selon les personnes rencontrées, objets issus de preuves optionnelles et réactions de Sorel.

**Invariants.** Les règles nécessaires ont été enseignées. La fermeture ne rend pas automatiquement nuls les sauvetages précédents. Les options d’accessibilité conservent les signaux. Les fins dépendent d’états documentés, pas d’un choix final opaque.

### SORTIE La galerie vers le jour

Une conduite de service ou une ancienne galerie d’entretien rejoint une ouverture éloignée du socle effondré. L’espace est étroit puis s’ouvre sur une vue de l’île. Les sons de vent, de mer et de radio redeviennent distincts. Les relais et les personnes sauvées influencent qui répond à l’appel.

Le joueur retrouve une météo améliorée, sans effacer les dégâts. Une arrivée aérienne ou maritime conclut l’évacuation selon l’état du monde retenu. La caméra donne enfin une vue des deux tours depuis un point bas extérieur. Le résultat humain et les preuves occupent l’épilogue ; les statistiques restent facultatives.

## 11 Extension Mountain Hole

Cette extension est une piste distincte. Elle ne fait partie ni du prototype ni du chemin critique de la campagne de Nacre.

| Zone | Scène et actions | Variations | Invariant |
|---|---|---|---|
| M01 Camp de montagne | Arrivée de secours, météo, cartes et première personne retrouvée | Position des équipements et conversations | Camp sûr et objectifs explicites |
| M02 Versant effondré | Traversée d’éboulis, lecture de parois et pose de relais autorisés | Deux chemins préparés et obstacles secondaires | Route principale sans tirage létal arbitraire |
| M03 Entrée de la cavité | Descente depuis la lumière naturelle, premiers appels sous la roche | Inclinaison du passage et détails de ruissellement | Matériel suffisant et point de retour connu |
| M04 Réseau naturel | Sauvetages, poches sèches, eau et faune cavernicole | Branches optionnelles et positions des repères | Personnes accessibles et navigation validée |
| M05 Station oubliée | Installation liée à une autre branche de SILLAGE | Dossiers, salle secondaire et témoin | Révélation propre à l’extension, fin de Nacre préservée |
| M06 Puits profond | Franchissement final, mécanisme local et retour vers le camp | Ordre des objectifs secondaires | Règles apprises, point sûr et conclusion complète |

## 12 Validation du catalogue

Avant l’intégration d’un étage, l’équipe doit pouvoir répondre à des questions concrètes : qu’aperçoit-on en arrivant, quel problème est compris en premier, quel geste est utilisé, où va la personne sauvée, quelle preuve est conservée et où peut-on reprendre son souffle ? Un étage qui ne fournit aucune réponse distincte doit être fusionné ou réécrit.

Les variantes se vérifient par graine et par graphe. Le catalogue exige un trajet d’arrivée à sortie, un chemin compatible avec chaque survivant, les ressources minimales avant la dépense et l’exclusion des menaces dans les refuges. Les tests de logique ne remplacent pas une traversée jouée : collisions, visibilité, compréhension et rythme doivent être examinés dans le moteur.

Une feuille de suivi de production pourra ajouter, pour chaque code, les statuts conception, blocage, jouable, art, son, narration et validation. Le statut « conçu » ne doit jamais être converti automatiquement en « terminé » parce qu’une entrée existe dans ce document.

## 13 Assemblage de production des trente étages

Les fiches suivantes traduisent les intentions précédentes en blocs à construire. **Toutes les dimensions, durées et interactions supplémentaires de cette section sont des cibles de production**, même pour les étages 30 à 25 déjà représentés. Le plateau actuel mesure 24 × 24 m, avec une hauteur d’étage régulière de 6 m ; les volumes proposés n’affirment pas qu’une nouvelle architecture a été intégrée. Les durées sont des budgets de rythme à tester, sans limite imposée au joueur.

Les identifiants P renvoient aux [52 props](PROPS_INTERACTIONS.md), les identifiants E aux [présences et adversaires](ENNEMIS_STATISTIQUES.md). Un objet inscrit dans une fiche peut exister seulement comme cible. Les zones de transfert exigent un volume libre de 1,8 m de largeur proposé ; les retours principaux visent au moins 1,4 m, avec essais sur les capsules et animations retenues. Ces mesures sont des critères de jeu à vérifier, pas des normes de bâtiment.

### A30 Assemblage du premier sauvetage

Sur la base actuelle, organiser une salle de 12 × 10 m, une bande de bar de 8 × 4 m et un service de 6 × 4 m. P23–P26 dessinent l’usage du restaurant ; P01 et P04 restent visibles depuis le retour d’Ana. Le premier cadrage doit montrer une personne réelle avant de demander de fouiller une pièce secondaire.

Prévoir trois temps : localiser Ana, lire le trajet, confirmer le treuil. Viser quatre à six minutes avec apprentissage, sans menace E. Une variante peut inverser deux ensembles de tables mais pas couper la diagonale utile. Après l’impact, les éclats de P19 changent l’image extérieure ; le trajet initial reste reconnaissable. Contrôler la visibilité de la balise depuis chaque position autorisée d’Ana.

### A29 Assemblage de l’observation

Prévoir deux suites de 6 × 5 m, un salon de 8 × 5 m et une baie d’observation de 4 × 3 m. P27, P28 et P31 construisent un séjour interrompu. P19 encadre Bravo sans barreau placé devant les silhouettes. La caisse P08 reste distincte du document afin que deux interactions ne se disputent pas la même position.

Le trajet enseigne d’abord la vue entre tours, puis l’abri intérieur. La scène du choc possède son propre temps, mais la préparation reste libre. La variante déplace les bagages et une porte secondaire, jamais la zone d’observation ni sa sortie. Tester l’état intact, l’avertissement, l’impact et le retour après sauvegarde avec les mêmes points de repère.

### A28 Assemblage du détour et de Samuel

Composer un espace de bureaux de 10 × 8 m, des archives de 7 × 5 m et un couloir de noyau de 2 m de large. P29–P31 portent les traces administratives. Le passage Est possède deux états préparés : ouvert avant impact, condamné par P20–P21 après impact. P18 matérialise le détour accessible.

Le joueur comprend le nouveau chemin avant de prendre Samuel. Viser quatre à sept minutes avec retour chargé. Aucun E ne doit apparaître dans le couloir de transfert ; la structure et la fumée éventuelle suffisent. Valider les deux sens du trajet, la visibilité de la personne derrière les archives et l’absence de meuble déplacé dans la sortie de corde.

### A27 Assemblage de la respiration

Une salle de 10 × 8 m, un espace de repos de 6 × 5 m et une circulation de 2 m permettent de lire l’évacuation. P32, P33 et P34 donnent trois échelles de trace : nom, objet personnel et dessin. La salle ne doit pas ressembler à un champ de bataille ou suggérer par défaut une catastrophe dirigée contre les enfants.

Conserver deux à quatre minutes de lecture possible sans attaque. L’écho de Bravo dépend de ses conditions radio, pas du ramassage d’un jouet. La sortie reste visible pendant l’appel. Les variantes choisissent les casiers ouverts et la place des dessins secondaires ; la chaîne d’Alma garde un sens. Aucun E et aucun danger mécanique dans cette respiration.

### A26 Assemblage de Nora et de la silhouette

Prévoir un bassin de 8 × 5 m, une plage sèche d’au moins 2 m et deux locaux de 5 × 4 m. P35, P36 et P39 indiquent l’usage du spa. Nora doit être atteignable par une route lisible sans saut sur l’eau ; la balise garde un axe direct de retour. E00 reste la menace réellement livrée.

La cible d’habillage donne une première vue de la silhouette à distance, puis une occasion de vérifier lampe et fusée. Viser cinq à huit minutes comprenant Nora et l’indice. Les variantes déplacent les transats hors du chemin de secours. Avant d’ajouter une menace navigante, corriger le mouvement direct d’E00 qui ne contourne pas les obstacles.

### A25 Assemblage du premier refuge

Sur une zone de 10 × 8 m, séparer consultation, réserve et arrivée de ligne par des volumes visuels bas. P08, P11, P12 et P22 forment un poste cohérent. L’entrée doit permettre de reconnaître la zone sûre avant de lire un texte. La lumière de travail doit différer des balises d’urgence sans dépendre d’une seule couleur.

Le bilan clôt la tranche actuelle. La campagne ouvrirait ensuite une nouvelle descente après choix explicite. Prévoir du temps libre pour les options et le journal ; aucune minuterie d’attaque. Vérifier qu’une personne sauvée demeure enregistrée et qu’un événement radio facultatif non encore entendu n’empêche pas la fin.

### A24 Assemblage du congrès

Cible : salle plénière de 14 × 10 m, deux salles de 6 × 5 m et couloir de service de 2 m. P23, P24 et P13 servent à établir une voie pour un petit groupe. Un écran éteint et des badges datent l’occupation ; ils ne doivent pas tous devenir des preuves interactives.

Séquence de quatre à sept minutes : repérer le groupe, ouvrir une circulation, confirmer son arrivée au relais supérieur. Une porte secondaire varie ; la sortie de secours demeure fixe. Pas de première attaque pendant l’enseignement du déplacement collectif. Persister la porte, les personnes transférées et le point de rassemblement ; tester un retour après déchargement du niveau.

### A23 Assemblage de l’histoire de Nacre

Cible : trois galeries de 6 × 8 m reliées par un vestibule de 5 × 5 m. Les socles et vitrines utilisent la logique P19 et P31, avec une paire de pièces essentielles lisibles hors des détours. L’ordre visuel passe d’une île antérieure au complexe à la construction des tours.

Une Rémanence E01 facultative rejoue un geste près d’un accès de service, sans attaque. Le joueur peut comprendre la chronologie par deux sources indépendantes. Les variantes déplacent les œuvres secondaires et une boucle exploratoire. Viser trois à cinq minutes, avec une zone calme pour la lecture et aucun verrou exigeant tous les cartels.

### A22 Assemblage des boutiques

Cible : galerie de 3 × 18 m avec quatre cellules de 5 × 5 m et une arrière-circulation. Les façades transparentes doivent laisser distinguer la vraie route d’une boutique sans issue. P28, P30 et P31 donnent objets personnels, rangement et liste de groupe.

E02 propose un premier faux appel situé hors de la route obligatoire. Une confirmation radio ou un indice matériel doit permettre de le vérifier sans subir automatiquement des dégâts. Le détour dure une à deux minutes et possède un retour visible. Une personne réelle éventuelle se distingue par contact et réponse, pas par une texture toujours différente des apparitions.

### A21 Assemblage des cuisines

Cible : production de 10 × 8 m, réserve de 6 × 5 m et cantine de 8 × 6 m. P26, P37, P39 et P40 organisent un problème matériel simple : couper un effet dangereux par une commande identifiée puis dégager un passage. Les tables fixes créent des couloirs suffisamment larges pour le portage.

Le danger enseigne ses signes avant toute consommation importante d’air. Une personne fournit une indication utile sans exiger une suite de recettes techniques réalistes. Viser cinq à sept minutes. La variante choisit le poste en panne parmi deux emplacements validés ; aucune vanne n’est cachée derrière le danger qu’elle seule permet d’arrêter.

### A20 Assemblage de la logistique

Cible : réserve de 12 × 8 m et poste de 8 × 6 m, séparés par un accès large. P08, P09, P10 et P22 servent au regroupement. Des noms et effets personnels relient les personnes arrivées depuis les secteurs précédents. La représentation n’est pas limitée à un compteur de population.

Ce refuge certifié offre reprise, plan et choix du prochain trajet. Les variantes sont décoratives et n’altèrent pas la quantité minimale de matériel de mission. Tester une arrivée avec plusieurs transferts déjà faits et une autre sans détours. Le passage reste praticable dans les deux cas ; les PNJ assis ne deviennent pas des collisions imprévues.

### A19 Assemblage des résidences hautes

Cible : trois logements de 6 × 6 m autour d’un palier de 5 × 5 m, avec une circulation de service. P27, P28 et P31 permettent de reconstituer les liens entre résidents. Un choix de détour aide un proche à rejoindre une personne déjà mise à l’abri.

La difficulté tient à l’information et au retour, pas à une course de décès cachée. Prévoir quatre à sept minutes pour le chemin principal. Les variantes peuvent modifier quel logement contient le témoin secondaire ; les relations et noms restent cohérents. Les états persistants distinguent personne retrouvée, proche informé et transfert confirmé.

### A18 Assemblage des résidences basses

Cible : deux appartements de 7 × 6 m et un volume de service vertical de 4 × 4 m. P15, P16 et P17 proposent un franchissement préparé. La vue doit montrer l’appui d’arrivée avant l’engagement ; une route de personne portée ne dépend pas d’une échelle que son animation ne sait pas utiliser.

Enseigner une seule nouvelle transition dans un espace sans menace active. Le passage peut ensuite être utilisé dans un retour court. Viser trois à six minutes. La sauvegarde se fait sur un palier, pas au milieu du franchissement. Tester caméra réduite, annulation avant engagement et reprise après l’ouverture de la trappe.

### A17 Assemblage des télécommunications

Cible : baie technique de 8 × 6 m, poste de contrôle de 6 × 5 m et toiture de service intérieure. P06, P22, P45 et P47 donnent une chaîne concrète de réception, comparaison et émission. L’interface locale montre ce qui a été enregistré sans prétendre authentifier une voix par sa seule sonorité.

Introduire E05 par une observation d’émission à distance, puis donner un itinéraire silencieux. L’objectif principal est de restaurer un relais ; l’écoute des archives reste facultative. Prévoir cinq à huit minutes. Le générateur ne doit jamais placer la commande de coupure dans l’unique zone constamment surveillée sans fenêtre de passage.

### A16 Assemblage des loisirs

Cible : salle de 12 × 9 m, vestiaires de 7 × 5 m et coursive vitrée de 2,5 m. Le mobilier permet un contraste entre activité quotidienne et façade ouverte vers la catastrophe. P16, P19 et P30 construisent le franchissement et une réserve secondaire.

La scène donne une vue nouvelle sur la hauteur restante, puis un retour rapide vers le noyau. Une anomalie E01 peut rester en fond ; pas de menace sur le premier appui. Viser trois à cinq minutes. La variante déplace les équipements décoratifs, pas la surface de réception ni le repère de retour.

### A15 Assemblage du refuge médical

Cible : espace de tri de 10 × 8 m, deux alcôves de 4 × 4 m et réserve de 5 × 4 m. P09–P11, P41 et P42 portent les soins abstraits et la lecture de situation. Les groupes visibles correspondent aux personnes effectivement arrivées dans ce secteur de campagne.

Le joueur compare deux itinéraires futurs et peut consulter les témoins. Les soins ne deviennent pas un mini-jeu punitif. Toute durée de discussion peut être interrompue puis reprise. Aucun E ni danger de ressources dans le refuge. Tester le registre lorsque certains survivants ont été transférés ailleurs, sans créer de doubles personnages.

### A14 Assemblage des bureaux partagés

Cible : deux plateaux presque symétriques de 8 × 8 m reliés par une zone de comparaison de 5 × 4 m. P29, P31 et P49 offrent des repères stables. La duplication apparente doit pouvoir être démontrée par une différence matérielle, pas seulement par la mémoire du joueur.

E01 ou E02, choisi par la variante, apporte une contradiction unique. Ne pas les superposer à une attaque. Le joueur peut marquer puis vérifier une porte en deux à quatre minutes. Les marques restent persistantes et ne sont pas déplacées silencieusement ; si l’espace change, la scène doit donner un indice observable de ce changement.

### A13 Assemblage du niveau absent

Cible : couloir de 2,5 × 16 m, deux pièces de 6 × 5 m et accès condamné lisible. Le numéro affiché peut être contradictoire, mais les identifiants internes et les repères P49 restent stables. P13 et P31 matérialisent la décision de fermeture antérieure au désastre.

La scène commence sans poursuite. Le joueur compare accès, plan et preuve, puis trouve une sortie de service. Prévoir quatre à six minutes et une ligne de vue sur le retour avant la contradiction forte. Une variante change une pièce secondaire ; elle ne crée pas une boucle infinie ni une issue dépendant d’une devinette non enseignée.

### A12 Assemblage du diagnostic

Cible : centre de contrôle de 9 × 7 m, deux locaux de 5 × 4 m et couloir de 2 m. P37, P39, P42 et P45 composent un réseau local simplifié. Le tableau doit distinguer mesure, commande et résultat, avec un retour visible dans le décor.

Le joueur rétablit un chemin d’énergie ou isole une fuite pour permettre un passage. Viser cinq à sept minutes. Les variantes permutent deux postes périphériques tout en conservant la logique apprise. La première action ne consomme pas un outil unique irréversible sans avertissement ; un état de repli permet de recommencer la séquence.

### A11 Assemblage des salons privés

Cible : salon de 10 × 7 m, bureau de 6 × 5 m et vestibule de 5 × 4 m. P23, P25, P29 et P31 donnent une réception interrompue et des traces de rendez-vous. La présence de Sorel dans l’histoire se déduit de dates et documents, sans gros portrait explicatif obligatoire.

Un témoin peut relier les décisions administratives à une scène vécue. Il conserve une route de transfert sûre. La tension vient d’un E02 facultatif après le dialogue, jamais d’un piège attaché automatiquement à la prise de preuve. Prévoir quatre à six minutes ; sauvegarder témoignage et objet lu séparément.

### A10 Assemblage du refuge technique

Cible : poste de 9 × 7 m, réserve de 6 × 5 m et zone de distribution protégée. P08, P12, P22 et P37 servent à réorganiser les chemins ouverts. Les connexions doivent être montrées sur un plan local lisible, avec confirmation de leur résultat dans le monde.

Le refuge permet de préparer la clinique et la liaison basse. La distribution de ressources ne doit pas rendre un sauvetage obligatoire impossible si le joueur a exploré auparavant. Les variantes choisissent une réserve facultative, jamais le minimum garanti. Tester sauvegarde et reprise avec chaque combinaison de relais ouverts.

### A09 Assemblage de la clinique SILLAGE

Cible : trois chambres de 5 × 4 m, observation de 6 × 5 m et corridor de 2,4 m. P09, P31, P46 et P48 exposent un usage du soin transformé en contrôle. Les données personnelles nécessaires au récit sont inventées pour le jeu et présentées avec retenue.

E07 peut occuper une route secondaire après démonstration de sa règle. Une personne réelle dispose d’un chemin compatible avec son accompagnement. Viser six à neuf minutes, avec première preuve accessible sans combat. Ne pas produire une confusion systématique entre patient et créature ; les silhouettes humaines doivent avoir une lecture narrative distincte.

### A08 Assemblage des laboratoires

Cible : laboratoire de 10 × 7 m, réserve minérale de 6 × 5 m et poste d’essai de 5 × 4 m. P45, P47 et P51 servent à comparer une mesure et une répétition. Une expérience locale enseigne une règle d’empreinte avec un résultat reproductible.

La découverte prépare le souterrain sans révéler toute la profondeur. Prévoir quatre à sept minutes. E01 peut rejouer un geste de travail ; le joueur distingue une répétition fixe d’une réaction nouvelle. La variante change l’échantillon secondaire, pas le résultat essentiel. Prévoir une sortie avant tout essai volontaire qui augmente la pression.

### A07 Assemblage des responsabilités

Cible : salle de réunion de 9 × 6 m, archives de 7 × 6 m et deux bureaux de 5 × 4 m. P29–P31 constituent un petit graphe de preuves : décision, date et conséquence. Le dossier essentiel est composé de quelques pièces lisibles, pas de dizaines de pages obligatoires.

Une réponse de Sorel peut apporter une aide conditionnelle tout en laissant ses omissions vérifiables. Le joueur doit pouvoir refuser un détour sans perdre la voie principale. Viser quatre à six minutes à faible intensité. Les preuves secondaires changent d’emplacement dans des zones compatibles ; aucune ne devient l’unique clé d’une porte finale.

### A06 Assemblage de la liaison basse

Cible : salle d’accès de 8 × 6 m, approche de 3 × 10 m et jonction de façade préparée vers Hespérie. P16, P18, P19 et P21 montrent les dégâts secondaires du choc. La coupe exacte entre tours doit être dessinée avant construction ; elle ne découle pas automatiquement des coordonnées simplifiées du prototype supérieur.

La traversée est un choix de campagne clairement annoncé. Placer un point sûr avant l’engagement et un repère d’Aube visible au retour. Une personne retrouvée de l’autre côté doit disposer d’une solution de transfert. Viser cinq à huit minutes pour la jonction seule ; la traversée d’Hespérie constitue un secteur séparé.

### A05 Assemblage du dernier refuge haut

Cible : poste incendie de 10 × 7 m, réserve de 6 × 5 m et sas sec de 4 × 4 m. P08, P12, P13, P22 et P43 donnent une équipe encore organisée près de la montée des eaux. Le plan indique clairement ce qui reste relié au toit.

Prévoir une préparation libre pour les niveaux bas, sans apparition hostile. Le bilan intermédiaire distingue personnes au toit, personnes au refuge et personnes en transfert. Les variantes ne changent pas l’étanchéité garantie de cette zone certifiée. Vérifier le retour après la traversée d’Hespérie et l’absence de perte d’état des témoins.

### A04 Assemblage du musée de marque

Cible : galerie de 12 × 7 m, réserve de 6 × 5 m et coursive sèche de 2 m. P19, P31 et P38 confrontent le récit public de Pelagos à un bâtiment partiellement noyé. Les panneaux officiels et les traces anciennes doivent pouvoir être comparés dans le même secteur.

E03, si retenu, est annoncé par son territoire et possède un contre-jeu enseigné. Il ne peut occuper sans pause l’unique route sèche. Viser cinq à sept minutes. La variante modifie un détour d’exposition, jamais la profondeur minimale permettant la traversée. Toute commande de pompe garde un accès de retour praticable.

### A03 Assemblage du parking automatisé

Cible : nef de 14 × 12 m, cabine de 5 × 4 m et voie de maintenance de 2 m. Les plateformes sont des blocs animés à états préparés ; P37, P44 et P48 donnent arrêt, libération et accès. Les véhicules ordinaires restent d’abord décoratifs, sans simulation physique coûteuse sur la route.

Le chauffeur est extrait après un arrêt confirmé. Viser cinq à huit minutes. Le mouvement possède avertissement, intervalle sûr et état bloqué reproductible. Une erreur ramène à un appui protégé plutôt qu’à une pluie aléatoire de véhicules. Tester le transfert avec chaque position finale autorisée de plateforme.

### A02 Assemblage du hall noyé

Cible : hall de 16 × 12 m, mezzanine de 8 × 5 m et passage de service de 2,2 m. P16, P19, P38 et P51 servent à lire la hauteur d’eau et la voie supérieure. Le cadrage fait enfin voir la ville à hauteur d’homme.

Le groupe attend sur un point protégé. Une poussée d’eau annoncée impose une courte attente, avec plusieurs indices accessibles ; elle ne déclenche pas la disparition automatique d’un PNJ hors champ. Viser cinq à huit minutes. La variante change une boucle secondaire et la végétation couchée, jamais la chaîne d’appuis ni le trajet vers A01.

### A01 Assemblage des retrouvailles

Cible : accueil de 10 × 8 m, bureau de 6 × 5 m et séparation provisoire de 4 × 4 m. P28, P31, P33 et P34 rappellent le parcours d’Alma. Le premier échange confirme son identité et son objectif avant d’annoncer la sortie vers le socle.

La scène SC07 rend rapidement le contrôle. Le trajet vers la terrasse reste court et lisible, sans nouvelle mécanique à apprendre. Une sauvegarde conserve les retrouvailles et les personnes déjà reçues. Les variantes ne changent que les accessoires et témoins secondaires. Tester une arrivée sans preuve optionnelle : Alma doit toujours être identifiable et la suite terminable.

## 14 Ordre de production du catalogue

Consolider d’abord les six étages actuels avec navigation de PNJ, interactions visibles et réception animée. Produire ensuite une paire de niveaux de campagne contrastés, par exemple A24 et A23, avant de remplir tout le bâtiment. Ajouter un refuge avec plusieurs groupes, puis un trajet vertical secondaire ; cela vérifie la persistance et les animations dont dépendront les étages inférieurs.

La liaison A06 et la rupture A00 nécessitent une coupe spatiale dédiée, des états de sauvegarde et des trajets de transfert testés. Les souterrains ne doivent être engagés en production lourde qu’après un prototype jouable de leur nouvelle route de retour. Les décors et menaces peuvent alors varier sans masquer des problèmes de circulation encore ouverts.
