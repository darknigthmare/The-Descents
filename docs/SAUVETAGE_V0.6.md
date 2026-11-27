# Sauvetage visible, portage et réception médicale

**The Tower Descent — version 0.8.0 — 25 novembre 2026**

Ce contrat de sauvetage, introduit en 0.6, est conservé dans la 0.8. Son nom de fichier historique reste inchangé. Le dossier et l’épilogue utilisent les mêmes identifiants de rescapés et les mêmes places de réception ; aucun plan de clôture ne déclenche un nouveau transfert.

## 1. Intention de la tranche

Le premier sauvetage doit montrer une chaîne compréhensible : Alex rejoint une personne, la sécurise dans un harnais, revient à la balise, suit la remontée et reçoit une confirmation du toit. Le corps transporté, la ligne tendue, l’opérateur et le poste médical donnent une présence matérielle à des états qui étaient déjà fonctionnels. Ana, Samuel et Nora gardent leurs noms, leurs lieux et leur place dans l’histoire.

Cette livraison enrichit la scène SC03 sans ajouter de plan imposé pendant une action dangereuse. Le joueur conserve sa vue, son déplacement et la possibilité de consulter la pause. La caméra ne part pas sur le toit pendant que son personnage reste au bord du puits. Les plans rapprochés du poste utilisés pour la revue visuelle sont des états préparés destinés à examiner la scène, pas une nouvelle caméra automatiquement déclenchée en partie.

Les volumes sont procéduraux : capsules, sphères, pièces de sangle et articulations simples. Le harnais et le mouvement de l’équipe renforcent la lecture du secours. Les mains, le visage, le contact physique, les vêtements et les animations faciales restent des éléments à produire avec des assets et des rigs définitifs.

## 2. Chaîne des états et autorité de mission

| État | Représentation visible | Conséquence de mission |
| --- | --- | --- |
| Présente | Personne à son emplacement, nom disponible | Identifiant absent du registre |
| Portée | Personne dans le harnais de première personne, mains d’Alex, sangles | Vitesse de portage ; aucun sauvetage confirmé |
| Au treuil | Personne assise dans le support, câble tendu, opérateur au toit | Horloge de cinq secondes ; identifiant encore absent |
| Reçue au toit | Personne déposée au débouché, départ de prise en charge | Identifiant inscrit une seule fois, stress diminué, point sûr |
| Installée au médical | Personne sous l’abri, pose et couverture propres | Même identifiant ; aucun second objectif |

La liste des sauvés appartient à la mission. Le module de présentation ne modifie ni cette liste, ni les ressources, ni le fichier de sauvegarde. Le registre médical, le journal et la condition de fin continuent à lire les confirmations de la mission. Une image de panier ou un bras tendu ne vaut pas confirmation.

La prise en charge médicale après la dépose dure 4,2 secondes et reste cosmétique. La personne a déjà été reçue sur le toit et mise à l’abri de la descente. Cette durée n’ajoute pas un verrou au joueur. Elle ne prolonge pas les cinq secondes nécessaires au sauvetage et ne crée pas une nouvelle occasion de perdre une personne confirmée.

## 3. Portage à la première personne

### Composition de l’image

Le support apparaît sous la ligne de visée, vers la droite. Les manches orange et les gants sombres d’Alex encadrent une poignée. Le buste de la personne, la toile orange, les deux sangles croisées et la boucle métallique expliquent ce qui est transporté. Le centre de l’écran reste destiné à la route et à la balise.

Les trois apparences utilisent le même contrat de placement. Samuel conserve le vêtement bleu ; Ana et Nora utilisent les tons clairs déjà présents dans le prototype. Un seul corps est visible dans le support à la fois. L’instance de la personne au sol est masquée pendant le transport et reste l’objet de mission utilisé pour la transition au treuil.

Le support suit la transformation de la caméra : tourner le regard, s’accroupir ou avancer ne le laisse pas derrière le personnage. Il utilise une couche de rendu de première personne, absente de la caméra d’accueil et des plans cinématiques. Les éléments de portage ne projettent pas d’ombre agrandie sur les murs. La représentation reste soumise à la profondeur du monde ; son éventuel contact avec une paroi très proche devra être affiné avec le modèle final.

### Mouvement et confort

Avec les mouvements réduits, aucun balancement supplémentaire du support n’est ajouté. En mode animé, une oscillation discrète, de quelques millimètres, donne une respiration au geste. Elle n’oriente pas la caméra et ne change pas la direction de marche.

Le portage conserve la vitesse de 2,4 m/s et les restrictions déjà appliquées au saut et à la course. Aucune fatigue supplémentaire, blessure cachée ou jauge de docilité n’est introduite. La personne ne peut pas être déposée librement dans cette tranche ; le retour prévu reste la balise de son étage.

La consultation des observations de terrain demeure indisponible pendant le transport. La pause générale, le journal et les options restent disponibles. L’ouverture des réglages ne détache pas le harnais et n’avance pas la mission.

## 4. Mise au treuil et trajectoire

### Géométrie

Le treuillage utilise un support orange, quatre sangles, deux suspentes et une attache supérieure. Un câble clair relie cette attache à la poutre du toit. Les jambes et les bras de la personne adoptent une pose soutenue, au lieu de conserver une station debout rigide pendant toute la remontée.

La trajectoire reste à l’intérieur du puits tant que la personne n’a pas atteint le toit. Le centre du panier se trouve à x = 1,8 m, z = 0. Le puits existant s’étend jusqu’à x = 2,7 m. La dépose se termine à x = 3,3 m, z = −2 m, sur la dalle du toit, avec les pieds à y = 42,08 m. Ce décalage évite le montant de la poutre et le mât de la balise. Le point d’attache supérieur reste fixé à x = 1,8 m, y = 45 m, z = 0 ; le câble s’incline pendant la dépose et garde ses deux extrémités reliées.

Les nouvelles géométries ne possèdent pas de collision. Elles ne réduisent pas l’ouverture, ne bloquent pas le joueur et ne transforment pas la corde guidée en simulation physique. La tension du câble est représentée par sa longueur calculée entre deux points connus.

### Chronologie livrée

| Temps du transfert | Action visible | État de mission |
| --- | --- | --- |
| 0 à 0,45 s | Support verrouillé au point bas | Personne au treuil |
| 0,45 à 4,2 s | Montée progressive dans le puits | Personne au treuil |
| 4,2 à 5 s | Déplacement latéral vers la dalle du toit | Personne au treuil |
| 5 s | Fin du transfert, disparition du support de remontée | Réception confirmée et point sûr |
| 0 à 4,2 s après réception | Prise en charge vers l’abri médical | Personne déjà sauvée |

Le temps de montée reste le même depuis les étages 30, 28 et 26. Il s’agit d’une durée de prototype compressée destinée à conserver le rythme de la boucle ; elle ne modélise pas la vitesse réglementaire d’un appareil réel. Une future production pourra choisir un temps fondé sur la longueur de câble, après essais sur le rythme et l’intérêt de l’attente.

La position est une fonction du temps absolu du transfert. Un grand pas de simulation rejoint le même point final qu’une succession de petits pas. Le temps négatif est limité au départ et le temps dépassant cinq secondes au point de dépose. La montée ne redescend pas, le câble ne s’inverse pas et le passage latéral ne commence qu’une fois la hauteur du toit atteinte.

### Retour d’information

L’objectif indique successivement verrouillage, remontée et dépose, avec le pourcentage du transfert. Le message de Varga conserve la priorité opérationnelle. Le son de confirmation existant intervient au terme du transfert. Les trois noms sont réutilisés dans la confirmation de réception.

La progression graphique ne constitue pas une nouvelle action à effectuer. Le joueur n’a pas à maintenir une touche pendant cinq secondes et ne doit pas cliquer une seconde fois pour que le sauveteur prenne la personne. La commande d’une balise déjà occupée rappelle d’attendre la réception.

## 5. Travail visible de l’équipe au toit

Le premier équipier d’Alpha rejoint une position de travail proche du débouché, les bras relevés pour matérialiser la conduite du treuil. Après la dépose, le second accompagne la personne vers le médical. Les membres déjà présents sont réutilisés : aucun sauveteur supplémentaire n’apparaît à chaque transfert.

Le trajet de réception passe par un point intermédiaire situé au nord-est du puits, puis rejoint la place de la personne sous l’abri. Le mouvement est interpolé sur 4,2 secondes. Les poses de jambes donnent une marche simple à l’accompagnant et aux personnes qui peuvent rester debout. L’opérateur regagne son poste pendant la prise en charge.

Ana reste sur sa civière, enrichie de supports et de roues. Samuel garde sa couverture jaune. Nora conserve sa posture basse et sa couverture claire. Les noms et le nombre de personnes reçues restent affichés au médical.

À la fin de la transition, les transformations des équipiers reviennent à leurs postes mémorisés. Il ne reste ni câble suspendu dans le vide ni deuxième personnage au point d’arrivée. Si une nouvelle remontée démarre après une succession accélérée d’actions, la réception précédente est d’abord fixée à sa pose finale.

Le transfert est une mise en scène préparée. Il n’utilise pas un système autonome de navigation, de recherche de chemin ou d’évitement des personnages. Les contacts des mains, le roulement réel d’une civière et l’assistance à deux personnes sont des objectifs de production ultérieurs. Cette distinction est essentielle pour ne pas présenter une animation de poste comme une IA d’équipe complète.

## 6. Sauvegarde, interruption et continuité

Le format de sauvegarde reste le schéma 3. Les nouveaux réglages de confort sont enregistrés séparément. Les coordonnées de la personne portée, la longueur du câble, la pose de l’opérateur et le temps de réception ne sont pas écrits dans le point sûr.

Une interruption pendant le portage ou la montée reprend le dernier état sûr antérieur. Une interruption après les cinq secondes reprend la personne déjà reçue, installée à son emplacement médical définitif. Le trajet cosmétique depuis le débouché n’est pas rejoué à chaque chargement.

La pause suspend le portage animé, la remontée et l’accompagnement médical. Elle suspend aussi les autres horloges de l’intervention. Aucun nœud de la présentation ne possède son propre traitement automatique capable de continuer derrière le menu.

Le retour à l’accueil reconstruit le monde depuis la sauvegarde validée. Une personne seulement portée n’y apparaît pas parmi les sauvés. Une nouvelle intervention efface les représentations de la précédente et masque tous les emplacements médicaux non confirmés.

La fin au refuge fixe toute réception encore transitoire à sa pose finale avant de suspendre le monde. L’effondrement continue à protéger les victimes déjà reçues ; il ne change pas une confirmation de Varga en perte de personne.

## 7. Contrat technique

| Élément | Propriétaire | Responsabilité |
| --- | --- | --- |
| Personne portée ou au treuil | main.gd | Interactions, exclusivité, horloge et confirmation |
| Registre et sauvegarde | main.gd et save_store.gd | Vérité de mission et reprise stable |
| Apparence du portage | rescue_presentation.gd | Corps unique, mains, sangles, transformation caméra |
| Support et câble | rescue_presentation.gd | Échantillonnage de la trajectoire et longueur visuelle |
| Personnes sous l’abri | world_builder.gd | Instances préconstruites et projection du registre |
| Mouvement des postes | rescue_presentation.gd | Transfert et restauration des poses |
| Texte et progression | main.gd et hud.gd | Objectif, indication de phase et confirmation |
| Réglages | preferences_store.gd | Valeurs persistées indépendamment de la mission |

Le module reçoit le monde et la caméra lors de la construction de chaque session. Il réutilise les matériaux et les figures de présentation existants. Il ne tire aucun nombre aléatoire, n’ajoute aucun objet interactif et ne consomme aucun matériel. Ses instances disparaissent avec le monde ; aucun corps de portage n’est conservé entre deux reconstructions.

La durée du treuil et les coordonnées finales sont des constantes explicites. Les calculs prennent des secondes et des mètres, les unités déjà utilisées par le prototype. Le temps est borné avant interpolation pour éviter les dépassements de trajectoire. Le câble reste strictement positif même lorsque le panier s’approche de la poutre.

## 8. Recette de validation

Les contrôles portent sur la continuité d’une personne et de ses identifiants, le passage d’une phase à l’autre, la pause, les bornes de trajectoire, l’absence de collision ajoutée et les reconstructions. Les trois rescapés doivent effectuer le cycle complet. Une seule apparence doit être visible pendant le portage ; aucun sauveteur ni patient ne doit être dupliqué après plusieurs appels.

Les essais de trajet physique existants gardent la responsabilité de vérifier que le joueur peut traverser les niveaux avec une personne. La nouvelle suite prépare des positions pour isoler les règles de présentation ; elle ne revendique pas une partie humaine ni une mesure de confort de manipulation.

Les captures de recette doivent montrer le portage depuis les yeux d’Alex, une remontée réellement en cours, une réception pendant le déplacement et la pose finale. L’examen doit vérifier le centre de l’image, la lecture du panier, la continuité apparente du câble, l’absence d’un second corps et la relation entre la position affichée et le texte de mission.

Les résultats exécutés, les empreintes des ressources, les images retenues et les limites matérielles figurent dans le dossier de validation de chaque livraison. Les preuves v0.6 restent historiques ; la 0.8 demande ses propres tests et captures du même contrat. La présence de ce chapitre ne remplace pas ces preuves.

## 9. Prochaine production de la scène SC03

La priorité graphique suivante est un corps de portage conçu pour la première personne : proportions, coupe du vêtement, déformation des sangles, articulation des poignets et transition entre prise et panier. Un rig final doit conserver une zone dégagée au centre, y compris aux limites du champ de vision réglable.

La seconde priorité est le contact de l’équipe : saisir la civière, orienter le chariot, poser les pieds et accompagner la personne sans glissement. Les transitions doivent rester reconstructibles depuis le registre, avec une pose finale simple à restaurer.

Une réponse de la personne recueillie peut apporter l’émotion : Ana reprend son souffle, Samuel demande de prévenir quelqu’un, Nora vérifie que le refuge tient. Ces lignes doivent respecter les envies et peurs des fiches de personnages et ne pas introduire de nouvelles preuves sur Bravo. Elles ne sont pas doublées ni livrées comme nouvelles communications dans cette tranche.

Une vraie simulation de câble ne doit être envisagée que si elle améliore un choix de jeu précis. La fiabilité du secours, la clarté du retour au point sûr et la maîtrise du joueur restent les critères de décision.

## Priorité du secours dans la 0.8

Les manifestations des suites, des archives et du spa ne déclenchent pas de poursuite ni de dommage. Leur présentation respecte les états de portage, treuillage et rappel ; elle ne remplace pas un message opérationnel. La prise en charge des trois personnes reste une réalité commune, même si Alex interprète mal une silhouette périphérique. Les humains dangereux et les créatures infernales appartiennent aux étapes futures du bestiaire : aucune rencontre de ce type n’est insérée rétroactivement dans le premier tutoriel.
