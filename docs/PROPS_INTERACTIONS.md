# Props et interactions de production

**Base v0.9.0 — 64 fiches de référence et 12 observations jouables ; annotations de périmètre v0.12.0 — 25 novembre 2026**

Ce catalogue donne aux équipes de niveau, d’art, de son et de gameplay des objets qui ont une fonction dans l’intervention. Il décrit les accessoires du prototype lorsqu’ils existent, puis les objets à produire pour la campagne. Une fiche de campagne n’est pas un inventaire d’assets déjà livrés. Les dimensions proposées servent au blocage et à la recette de circulation ; elles ne constituent ni des normes de construction ni des instructions de secours réels.

Dans la 0.7, le dossier à quatre onglets décrit les faits issus de ces interactions ; il ne crée aucun accessoire collectable supplémentaire. Les plans de clôture observent le poste médical, le relais du 25 et la tour endommagée déjà présents dans le monde. La 0.8 porte le catalogue à 60 fiches avec huit props de campagne liés aux expériences et à l’Enfer. La 0.9 ajoute P61 à P64 pour les escaliers locaux, les stations personnelles, les dalles d’arrêt et le descendeur, soit 64 fiches. Les douze observations jouables conservent leur portée ; le bilan n’exige pas la lecture de tous les props facultatifs.

## Ajouts intégrés à la candidature v0.12

Le [supplément A22–A20](CONTINUATION_A22_A20_V0.12.md) complète ces fiches historiques avec **douze modèles GLB statiques**, utilisés dans les commerces, les cuisines et le refuge 20. Ils s’ajoutent au [lot de secours v0.11](VISUELS_ET_SECOURS_V0.11.md). Leur catalogue et leurs dimensions réelles se trouvent dans [commerce_asset_catalog.gd](../prototype/scripts/commerce_asset_catalog.gd) et dans le [manifeste du lot](../prototype/assets/models/commerce_v012/manifest.json).

| Secteur principal | Modèles du nouveau catalogue | Périmètre d’usage |
| --- | --- | --- |
| Galerie 22 | Vitrine, caisse de comptoir, commande de volet | Mobilier commercial et repère de l’intervention au Halligan ; aucun système monétaire |
| Cuisines 21 | Chariot, évier industriel, appareil de cuisson, hotte, tableau d’isolement, armoire de couverture coupe-feu | Présentation du service et des deux étapes du foyer local ; le chariot et le tableau sont aussi réutilisés au refuge |
| Refuge 20 | Lit pliant, réserve d’eau, paravent | Organisation de l’accueil ; aucune nouvelle mécanique de déplacement des lits ou de consommation d’eau |

La mécanique appartient aux scripts et aux cibles de scène, pas au seul fichier GLB. Les cinq interventions sont l’ouverture du volet, l’isolement du réchauffeur, la couverture du foyer, l’apaisement facultatif du Retranché et la remise en service du relais. Les trois réceptions de Mina, Théo et Sofia demandent leur présence physique sur les marques du refuge 20. Les deux nouveaux objets de constat, `commerce_deliveries_22` et `commerce_maintenance_21`, sont collectés séparément ; ils ne remplacent pas les douze observations facultatives du secteur supérieur.

Le terrazzo ivoire et le carrelage gris vert ajoutent deux albedos natifs de 1254 × 1254 pixels. Les dimensions, usages, sources et limites du lot figurent dans le supplément. Le graphe ajoute S23_22, S22_21, S21_20 et le rappel personnel R22_21 ; les fiches P04 et P61–P64 décrivent toujours les principes locaux, avec un nombre de liaisons daté de leur version d’origine.

Les **64 fiches P01–P64 gardent leurs identifiants et leurs cibles de campagne**. La présence d’un tableau, d’un chariot ou d’une couverture dans le lot v0.12 ne valide pas les mécaniques plus générales proposées dans leurs fiches. Les matériels expérimentaux et infernaux non intégrés restent des spécifications. Les actions de cette tranche, les états consommés et les reprises sont définis par [commerce_director.gd](../prototype/scripts/commerce_director.gd), [commerce_presentation.gd](../prototype/scripts/commerce_presentation.gd) et [save_store.gd](../prototype/scripts/save_store.gd), au schéma 5. Les mentions de schéma 3 ci-dessous décrivent les observations et la traversée dans leur version historique, sans nouveau reçu « déjà lu » pour les douze observations.

## Convention des fiches

Les dimensions sont données en mètres, largeur × profondeur × hauteur, sauf indication contraire. Le pivot d’un objet posé se situe au centre de son appui ; celui d’une porte se situe à la charnière. Les dimensions de « maquette » proviennent du constructeur actuel. Les dimensions « cibles » sont des valeurs initiales de production, à confirmer avec le personnage, le champ de vision et le transfert d’un rescapé.

Le statut **présent** signifie qu’une représentation ou une interaction identifiable existe dans le prototype. Il ne certifie pas l’ensemble de la fiche : chaque fiche sépare le comportement actuel de son extension. Le statut **campagne** signifie que l’objet et sa mécanique restent à implémenter. Une caisse décorative et une caisse de ressources utilisent des identités différentes ; un simple aspect visuel ne rend pas un objet utilisable.

Le joueur reçoit un verbe, une conséquence et, pour une action longue, une progression annulable. Le coût est engagé au succès de l’action, sauf consommation continue annoncée explicitement. Le résultat est enregistré par identifiant stable. Reprendre une sauvegarde ne peut recréer le contenu d’un objet utilisé, faire pivoter une porte à travers un personnage ou replacer un chariot dans une sortie.

## Règles de placement et de fabrication

Le prototype protège les points fixes de rescapés, d’indices, de ressources, de balises et la croix centrale autour du puits. Les ajouts de présentation restent hors de ces volumes. Pour la campagne, la cible de passage principal est 1,4 m de largeur libre, portée à 1,8 m sur un trajet de transfert accompagné ; les aires de retournement des objets longs sont testées avec leur enveloppe réelle. Ces chiffres sont des choix de gameplay initiaux, pas une promesse de simulation professionnelle.

Chaque prefab de campagne doit fournir un volume visuel, une collision simplifiée, un point d’examen, un point d’usage, un volume de dégagement et des états de persistance. Une variante décorative hérite des mêmes sockets. Les petits objets sur une table n’ajoutent pas chacun un corps physique dans un passage étroit. Les fragments d’un effondrement scénarisé ne peuvent décider de l’accès au seul survivant restant.

Les sons de confirmation, de refus et de fonctionnement ont des rôles distincts. Un refus donne aussi un texte court ; un indice essentiel ne dépend jamais uniquement d’une fréquence ou d’un canal stéréo. Les boucles s’arrêtent en pause avec le monde, tandis qu’un menu peut conserver son propre fond sonore. Les budgets de voix et de particules sont à mesurer avant la production artistique finale.

## Secours et lecture de mission

### P01 Balise de treuil

**Présent. Fonction et gabarit.** Repère orange à chaque palier et sur le toit, au bord du puits. La base de maquette mesure 0,68 m de diamètre sur 0,36 m ; la tige et le feu atteignent environ 1,8 m. L’étiquette TREUIL reste lisible depuis la sortie de corde.

**Interaction et états.** Depuis la 0.9, cette balise sert uniquement au transfert des rescapés. E lance le treuil lorsque la personne portée appartient à cet étage et qu’aucun transfert n’est actif. À vide, la balise explique sa fonction ; elle n’engage plus Alex sur une corde globale. Après un déplacement par escalier avec une personne, une balise d’un autre étage demande de revenir à son étage d’origine. La cible de campagne ajoute les états libre, raccordement, transfert, réception et indisponibilité expliquée, sans remplacer une prise en charge confirmée par un état inconnu.

**Son et implantation.** Bipe bref au raccordement, moteur pendant le transfert, confirmation vocale à la réception. Un socket fixe par palier jouable, aucun tirage dans les variantes de mobilier. Recette : aller et retour avec charge, reprise au checkpoint, appuis répétés et départ du palier pendant le treuil.

### P02 Poutre de la ligne principale

**Présent. Fonction et gabarit.** Traverse de maquette de 7 × 0,22 × 0,22 m au-dessus du puits, portée par deux montants. Elle montre d’où vient la ligne et relie visuellement chaque sauvetage au poste du toit. Cible artistique : ferrures et marquage d’inspection lisibles, sans ajouter des réglages techniques au joueur.

**Interaction et états.** La traverse est fixe et non consommable. Le joueur agit à la balise pour le treuil des personnes. Le couloir oriental reste continu jusqu’au toit, distinct des trois segments occidentaux de rappel personnel. Elle reste en place avant et après l’impact ; une séquence de campagne qui condamne cette route exige un autre réseau, une annonce et un checkpoint propre.

**Son et implantation.** Travail métallique discret sous le vent, jamais un signal ambigu de rupture imminente sur la ligne garantie. Un seul exemplaire au toit d’Aube. La silhouette ne doit pas croiser le cadre des noms du poste médical ni masquer le puits depuis le plan final de l’introduction.

### P03 Ancrage secondaire

**Présent sous forme abstraite. Fonction et gabarit.** La commande X dépense un ancrage accepté sur le segment personnel actif et stabilise le balancement pendant 16 s. Elle ne crée ni nouveau trajet ni relais persistant et ne remplace pas l’ancrage fixe du segment. Cible d’objet visible : boîtier de 0,18 × 0,12 × 0,22 m sur un socket autorisé.

**Interaction et états.** Stock initial 4, plafond 8. Une stabilisation déjà active ou un stock nul refuse la commande sans consommation. La pause fige les seize secondes ; l’expiration rend le balancement ordinaire sans rupture. Un objet de campagne pourra passer de disponible à posé, connecté puis récupérable selon le scénario. Il ne pourra être posé sur n’importe quelle texture. La réussite consomme une unité ; un emplacement refusé ne la consomme pas.

**Son et implantation.** Clic mécanique suivi d’un son plus calme de la ligne, avec texte « ancrage établi ». Les sockets de campagne sont validés avant les dangers et ne suppriment jamais la route gratuite nécessaire. Recette : stock nul, pause, double commande et reprise d’un point déjà installé.

### P04 Ligne de rappel

**Présent. Fonction et gabarit.** Ligne visible entre l’ancrage local et le harnais. Trois segments de six mètres relient 31–30, 29–28 et 27–26, dans la moitié ouest du puits, autour de x = −1,3 m. Le décalage latéral est limité à ±0,65 m sur Z. La descente normale atteint 2,8 m/s, la remontée 1,6 m/s, l’approche précise 0,75 m/s et la descente rapide 4,2 m/s. Cible artistique : corde de diamètre apparent 0,015 m, assez contrastée pour être suivie sans contour lumineux permanent.

**Interaction et états.** Au sol, engagement contrôlé, suspension mobile, freinage, verrouillage, repos pour fatigue, stabilisation facultative et sortie contrôlée vers une dalle. Espace verrouille ou libère ; E ne détache qu’au terminal, avec faible vitesse, recentrage et dégagement physique. Le modèle distingue longueur, vitesse, endurance et état de sortie. Les segments sont locaux et réversibles ; les relais persistants et le contournement libre d’obstacles restent des cibles de campagne. Aucun nœud décoratif ne décide de la trajectoire de la capsule.

**Son et implantation.** Frottement mesuré, vent et tension signalée par un changement clair. Aucun son de rupture aléatoire sur un segment garanti. La corde reste visible avec les mouvements réduits ; sa couleur est doublée par les balises et la géométrie.

### P05 Lampe de secours

**Présent. Fonction et gabarit.** Petite lampe visible de 0,32 m de longueur, faisceau de maquette de portée 27 m et angle 32°. Elle aide à lire les indices, les obstacles et les appuis du trajet de secours. Elle ne vide pas une batterie dans la tranche actuelle.

**Interaction et états.** F alterne allumée et éteinte. Cible de campagne : faisceau orienté, réglage confort et panne scénarisée très courte avec remplacement immédiat de l’information utile. Aucune réserve obligatoire ne peut disparaître sans moyen de traverser l’étage.

**Son et implantation.** Clic local de commutateur, aucun bip d’ennemi révélant automatiquement la nature d’une silhouette. Objet permanent du joueur, pas un tirage de butin. Recette : faisceau sur vitre, proximité d’un mur, brouillard, sous-titres et lecture du relief sans variations brusques de luminosité.

### P06 Radio individuelle

**Présent comme système. Fonction et gabarit.** Appels R, transcription et journal. Cible de prop : poste de 0,07 × 0,04 × 0,16 m, porté sur le harnais avec antenne courte ; le modèle ne masque pas le bas de la caméra.

**Interaction et états.** Appel disponible, délai de 8 s, réception ordinaire ou canal prioritaire. Les états source vérifiée et source inconnue appartiennent au récit ; ils n’altèrent pas les confirmations de mission. Les trente-deux derniers textes sont archivés même lorsqu’une urgence retire leur affichage.

**Son et implantation.** Clic de prise de canal, souffle léger, voix intelligible. Le filtre varie selon le contexte, sans réserver un effet démoniaque à toutes les imitations. Un message visuel porte l’indicatif. Aucun tirage ne peut retirer le poste ni empêcher l’accès au journal.

### P07 Fusée rouge

**Présent sous forme abstraite. Fonction et gabarit.** G consomme une unité, crée une lumière rouge pendant 20 s et réduit le stress de dix points. En 0.8, les silhouettes perceptives sont masquées pendant cette durée ; aucune créature n’est projetée ou téléportée. Stock initial 3, plafond 6. Cible physique : bâton de 0,04 m de diamètre sur 0,28 m, support visuel au sol ou en main.

**Interaction et états.** Non utilisée, allumée, consumée. Le masquage perceptif dépend du temps actif de la fusée, sans calcul d’exposition locale. Ce résultat ne confirme ni une attaque réelle ni un pouvoir d’exorcisme. La campagne devra tester portée, occultation et durée avant de proposer un effet défensif spatial sur une entité corporelle.

**Son et implantation.** Amorçage bref, crépitement discret, sous-titre utile si le joueur ne voit pas le halo. Pas de clignotement rapide. Les réserves critiques sont accessibles avant la rencontre ; une variante sans fusée conserve un détour et la ligne de retour.

### P08 Caisse de secours

**Présent. Fonction et gabarit.** Caisse orange de maquette 1,5 × 1 × 0,76 m, couvercle légèrement plus large, croix blanche. Les exemplaires de ressources se trouvent aux 29 et 25 ; les caisses du toit sont décoratives et ne promettent pas une recharge infinie.

**Interaction et états.** E applique une seule fois air à 100, santé +30 plafonnée à 100, ancrages +2 plafonnés à 8 et fusées +2 plafonnées à 6. L’identifiant rejoint `supplies_used`. La cible artistique conserve une coque ouverte ou vide pour expliquer l’état consommé, à la place de la disparition actuelle.

**Son et implantation.** Verrou, ouverture et inventaire court, sans couvrir une alerte. Placer hors du couloir et à portée du sol. Recette : chargement d’une caisse déjà utilisée, stock au plafond, interaction répétée et caisse proche d’une cloison.

### P09 Civière du poste médical

**Présent comme présentation. Fonction et gabarit.** Plateau de 0,95 × 2,25 m, environ 0,65 m au-dessus du sol ; poignées jusqu’à 2,6 m. Ana est visible dessus après réception. Aucune collision n’est ajoutée au toit.

**Interaction et états.** Vide dans le registre, occupée après transfert confirmé, reconstruite au chargement. La civière de campagne sera un objet de transfert distinct, avec enveloppe de passage et points de portage ; elle ne doit pas être annoncée comme déjà transportable.

**Son et implantation.** Accueil de Médical et bruit de couverture, sans description de soin à reproduire. Un exemplaire fixe au secteur médical, à distance du puits. Recette : nom lisible, corps posé au bon niveau, retour après impact, aucune figure supplémentaire après plusieurs projections du registre.

### P10 Couverture de réception

**Présent comme présentation. Fonction et gabarit.** Volumes simples sur les figures reçues : jaune pour Samuel, claire pour Nora et Ana. Cible textile déployée de 1,4 × 2 m, épaisseur visuelle faible ; une silhouette et un visage restent reconnaissables.

**Interaction et états.** Elle suit l’état du rescapé confirmé, sans consommable ni soin supplémentaire. La campagne pourra animer l’ajustement par un secouriste, mais n’ajoutera pas une tâche obligatoire après chaque remontée.

**Son et implantation.** Froissement court pendant l’accueil, pas de boucle sur chaque mise à jour du registre. Un ensemble par personne au poste médical, jamais un tirage qui masque son nom. Recette : couleurs discernables en niveaux de gris grâce aux postures et étiquettes ; les couvertures ne servent pas de preuve unique d’identité.

### P11 Registre du poste médical

**Présent comme panneau et journal. Fonction et gabarit.** Panneau MÉDICAL et compte de personnes à l’abri, placé au-dessus des trois emplacements. Cible artistique : tableau de 1,2 × 0,08 × 0,7 m avec trois lignes nominatives, doublé d’une vue lisible dans le journal.

**Interaction et états.** Vide, une à trois confirmations, état restauré. Le panneau est une projection de `rescued`, jamais une seconde liste capable de diverger. Une transmission incertaine ne modifie pas ce registre.

**Son et implantation.** Confirmation unique à la fin du treuillage ; actualiser le panneau au chargement ne rejoue pas les annonces. Emplacement fixe au toit. Recette : vérifier le même nom sur le journal, la figure et le compte rendu ; aucun succès affiché avant la fin réelle du transfert.

### P12 Terminal du refuge

**Présent. Fonction et gabarit.** Meuble de maquette 1,7 × 0,9 × 1,7 m avec écran vert et étiquette REFUGE 25. Il est la destination de la tranche après les trois prises en charge et l’incident stabilisé.

**Interaction et états.** E demande un checkpoint puis, si les conditions sont remplies, ouvre le bilan. Sinon, le message indique les secours ou l’observation encore nécessaires. Cible de campagne : consulter, enregistrer, préparer le secteur suivant ; la zone reste sûre pendant la lecture.

**Son et implantation.** Confirmation brève distincte d’une erreur d’écriture. La certification est aussi textuelle. Un terminal fixe par refuge, avec passage de sortie visible. Recette : état incomplet, mission terminée rechargée, erreur de sauvegarde et journal ouvert depuis le bilan.

## Architecture et circulation

### P13 Porte coupe feu

**Campagne. Fonction et gabarit cible.** Porte simple de 1,1 × 0,12 × 2,2 m ou double de 1,8 m de largeur pour un transfert. Elle sépare un refuge authentifié d’un secteur non vérifié et fournit un repère de repli.

**Interaction et états.** Fermée, ouverture, ouverte, retenue. Action de 0,8 s, annulable avant le mouvement. La porte ne se ferme pas à travers un personnage ou une civière ; la zone de débattement est testée avant la transition. Les états de campagne se conservent par identifiant.

**Son et implantation.** Barre, gond et fermeture amortie ; un contact de verrou ne doit pas ressembler à une attaque. Un exemplaire à chaque limite de refuge, jamais randomisé sur son unique accès. Recette : deux acteurs de part et d’autre, passage lent, reprise porte entrouverte et retour au refuge poursuivi.

### P14 Porte de chambre coincée

**Campagne. Fonction et gabarit cible.** Vantail de 0,95 × 0,08 × 2,1 m avec cadre déformé et numéro stable. Le défaut est visible avant le geste : battant de travers, poignée libre ou obstacle derrière.

**Interaction et états.** Examiner, tenter, dégager depuis l’autre côté ou forcer sur un point autorisé. Forçage cible de 3 s, bruit annoncé, jamais un code arbitraire pour un sauvetage obligatoire. Le joueur peut interrompre et chercher l’accès de service ; le résultat ouvert persiste.

**Son et implantation.** Résistance mécanique graduée, voix du témoin si présent, texte expliquant le blocage. Une seule porte nécessitant un geste nouveau par première rencontre. La variante ne condamne pas les deux accès à la personne. Recette : outil absent, chemin secondaire, retour avec charge et état restauré.

### P15 Trappe de maintenance

**Campagne. Fonction et gabarit cible.** Panneau de 0,9 × 0,9 m au mur ou au plancher, ouverture utile choisie selon le passage réellement possible. La couleur technique et la poignée l’opposent aux panneaux décoratifs.

**Interaction et états.** Fermée, déverrouillée, ouverte, accès vérifié. L’examen annonce si le passage est réservé à Alex ou compatible avec un rescapé. Ouverture cible 1,2 s ; un panneau inférieur ne laisse pas tomber le joueur sans plateforme ou ligne prévue.

**Son et implantation.** Deux attaches puis pivot, avec sous-titre de choc si un danger est révélé. Placer dans les locaux de service, hors d’un refuge à surprise hostile. Recette : caméra accroupie, volume de capsule réel, sortie du conduit et transfert impossible clairement indiqué avant d’engager la personne.

### P16 Passerelle de service

**Campagne. Fonction et gabarit cible.** Module droit de 3 × 1,8 m, variantes de 1,5 et 4,5 m de longueur, garde-corps préparés. Elle rend un franchissement lisible avant le vide et crée une route escortable.

**Interaction et états.** En place, déplacée par scénario, immobilisée, franchissable. Le mouvement est désactivé en présence d’un occupant sauf scène protégée. Un verrouillage cible de 2 s ne demande pas de dosage physique au pixel.

**Son et implantation.** Résonance des pas et claquement de verrou ; le son change après sécurisation. Sockets d’appui validés avant génération, destination visible. Recette : traversée lente avec personne, arrêt au milieu, caméra réduite, collision des bordures et reprise à une extrémité stable.

### P17 Échelle fixe

**Campagne. Fonction et gabarit cible.** Largeur utile 0,55 m, barreaux espacés de 0,28 m, segments de 3 m. Ces choix servent à la lecture du mouvement de jeu ; les échelles sportives décoratives ne deviennent pas automatiquement utilisables.

**Interaction et états.** Approche, accroche, montée guidée, sortie validée. Vitesse cible 1,1 m/s, possibilité de redescendre. Une victime peu mobile exige un autre trajet ; le jeu l’annonce avant le départ.

**Son et implantation.** Prises régulières, métal et équipement, sans secousse de caméra obligatoire. Au plus une séquence de changement d’échelle dans le premier secteur d’apprentissage. Recette : sortie haute obstruée, inversion immédiate, pause, chargement à l’appui et retour sans téléportation dans un mur.

### P18 Signalétique de détour

**Présent. Fonction et gabarit.** Flèches lumineuses au sol et texte de contournement après l’impact au 28. Cible artistique : panneau mural 0,8 × 0,04 × 0,45 m, symboles répétés à hauteur et au sol.

**Interaction et états.** Cachée avant le choc, active après installation du détour. Le texte désigne le noyau, pas un itinéraire incertain. Aucun point ni ressource ne sont consommés en la consultant.

**Son et implantation.** Une instruction radio à la transition, sans répétition permanente. Les flèches doivent être vues depuis l’arrivée de la corde et depuis la barrière. Recette : faible éclairage, poussière active, retour en portant Samuel, vue inversée et rechargement après impact.

### P19 Vitrage de la baie Est

**Présent. Fonction et gabarit.** Panneaux transparents de maquette de 7,25 × 4,25 m environ, épaisseur 0,06 m, derrière un appui solide. Ils donnent un cadre naturel sur Bravo avant de se briser à l’impact.

**Interaction et états.** Intact, fissuré visuellement, brisé. La rupture suit l’incident et n’est pas commandée par les coups du joueur. Le garde-corps et les trajets utiles restent présents. La cible artistique pourra remplacer la disparition de surface par des restes fixes et éclats préparés.

**Son et implantation.** Contraintes, fissures, impact, pluie plus directe. Le mix laisse entendre la consigne de Varga. Aucun fragment de présentation ne pousse la capsule. Recette : regard depuis la baie et l’intérieur, état direct après chargement, distance de lecture et absence de collision invisible au milieu du chemin.

### P20 Poutre ou plafond tombé

**Présent. Fonction et gabarit.** Obstacle de maquette de 5,3 × 0,8 × 2,8 m sur le passage Est du 28. Il ferme un trajet latéral et donne une conséquence réelle au choc, sans condamner le noyau.

**Interaction et états.** Retenu en hauteur, chute préparée, posé. La collision finale s’active après la pose et seulement si le volume n’est pas occupé. Une fois active, elle ne disparaît pas parce que le joueur s’en approche. Le contournement reste suffisamment large.

**Son et implantation.** Craquement puis choc sourd, débris légers secondaires. Placement fixe, jamais un tirage sur le puits ou la victime. Recette : joueur dans l’enveloppe à l’impact, sortie volontaire, retour contre la barrière, reprise directe après choc et escortage par le détour.

### P21 Gravats de présentation

**Présent. Fonction et gabarit.** Fragments de maquette d’environ 0,3 à 0,9 m de large et 0,16 m d’épaisseur, distribués hors des traversées protégées. Ils racontent le dommage sans former un parcours de sauts.

**Interaction et états.** Absents avant impact, visibles ensuite. Pas de ramassage ni de collision pour ces fragments. Un futur gros bloc utilisable doit être un autre prefab avec enveloppe de navigation testée.

**Son et implantation.** Bruits groupés pendant l’événement, puis silence ; chaque morceau ne reçoit pas une boucle ou une simulation indépendante. Distribution à partir du canal d’accessoires, excluant la croix centrale et les sockets. Recette : toutes variantes, hauteur de caméra accroupie, contraste avec un objet interactif et absence de duplication après reprise.

### P22 Relais radio de palier

**Consultation présente depuis la 0.5.** Un boîtier au 28 expose une fiche sur le réseau et le contact des équipes. Il ne rétablit aucun canal, ne recharge pas la radio et ne possède pas de commande de réparation. Le comportement décrit ci-dessous reste une cible de campagne.

**Campagne. Fonction et gabarit cible.** Boîtier de 0,38 × 0,22 × 0,55 m, antenne et câble vers un réseau identifiable. Il matérialise l’amélioration du contact et sert au Répondant ou aux Veilleurs sans transformer tous les appels en pièges.

**Interaction et états.** Hors service, inspecté, alimenté, destination vérifiée, émission. L’activation cible dure 2 s après une vérification contextuelle. Une erreur se corrige depuis un appui sûr ; elle ne ferme pas définitivement l’unique liaison d’évacuation.

**Son et implantation.** Souffle, porteuse et confirmation d’un interlocuteur ; des libellés donnent le même résultat sans son. Sockets techniques aux 17 et 10, puis souterrains. Recette : données inconnues, retour en arrière, sauvegarde avant validation et émissions simultanées bornées.

## Mobilier et traces de vie

### P23 Table de restaurant

**Consultation présente depuis la 0.5.** Un couvert et un bon de préparation du restaurant peuvent être examinés. Leur fiche évolue avec le choc et la réception d’Ana ; les objets ne sont pas déplacés ni collectés.

**Présent. Fonction et gabarit.** Table de maquette de 2,8 m de diamètre, plateau à environ 1 m du sol. Le premier groupe encadre Ana sans couper le trajet depuis le puits. Cible artistique : nappes, couverts et préparation interrompue.

**Interaction et états.** Décor solide ; les couverts sont visuels. Une seule table de campagne devient examinable pour la scène « préparée trop récemment ». Son indice est textuel et daté, sans objet minuscule obligatoire à ramasser.

**Son et implantation.** Résonance du verre pendant une secousse, arrêt lisible ensuite. Trois groupes dans la maquette, variations compatibles avec les passages. Recette : trajet aller et portage retour, chaises proches, lecteur d’indice et visibilité d’Ana avant l’approche.

### P24 Chaise de salle

**Présent. Fonction et gabarit.** Siège de maquette de 0,75 × 0,8 m, dossier à environ 1,35 m. Assise et dossier ont des collisions simples ; les pieds sont de présentation. L’ensemble donne une échelle humaine au restaurant et aux bureaux.

**Interaction et états.** Dans la tranche, elle ne se déplace pas. La cible de campagne autorise pousser une chaise légère dans des poches préparées, sans empiler des meubles pour franchir toutes les barrières. L’état déplacé se conserve si le passage en dépend.

**Son et implantation.** Frottement court propre au sol. Les chaises décoratives d’un groupe peuvent partager un son lors du choc. Exclusion stricte devant balise, survivant et seuil de porte. Recette : angle de capsule, retour à vitesse réduite et présence de plusieurs dossiers à proximité.

### P25 Comptoir du Belvédère

**Présent. Fonction et gabarit.** Corps de maquette de 8 × 1,5 × 1,4 m, plateau plus large. Le bar crée une façade de service et une voie de contournement, tout en donnant une lumière chaude à la première scène humaine.

**Interaction et états.** Décor fixe ; aucun inventaire d’alcool ni recette de soins. Un tiroir de campagne peut contenir le registre des clients sous forme de preuve indépendante. L’examen ne retire pas le meuble de la scène.

**Son et implantation.** Bouteilles qui s’entrechoquent à l’incident et matériel de service immobile au calme. Un exemplaire au restaurant, hors du passage vers Ana. Recette : silhouette du bar depuis le puits, accès des deux côtés prévu, aucun indice obligatoire caché derrière une collision sans ouverture.

### P26 Chariot de service

**Campagne. Fonction et gabarit cible.** Chariot de 0,7 × 1 × 1,1 m, roues visibles et frein. Il sert de trace d’évacuation ou d’obstacle déplaçable court, sans devenir un véhicule improvisé au-dessus du vide.

**Interaction et états.** Freiné, déverrouillé, déplacé le long d’un rail de jeu, garé. Déplacement cible à 0,7 m/s ; le joueur peut relâcher et reprendre. La zone finale est validée avant l’action pour conserver une largeur suffisante.

**Son et implantation.** Roulettes, frein et vaisselle distincte des sons de menace. Deux positions authored dans un couloir de service ou une cuisine ; aucune physique libre dans le puits. Recette : relâcher au milieu, charger pendant un déplacement, contourner avec victime et pousser depuis le mauvais côté.

### P27 Lit de suite

**Présent. Fonction et gabarit.** Cadre de maquette 3,2 × 3,9 × 0,7 m, tête haute et matelas. Ce gabarit volontairement ample structure le blocage des suites ; l’art final pourra réduire le modèle en gardant les voies protégées.

**Interaction et états.** Décor solide. La campagne peut proposer examiner les traces de départ ou rechercher une personne dans une zone accessible, mais jamais imposer de passer sous le lit tant que la capsule accroupie ne le permet pas.

**Son et implantation.** Tissu, ressort occasionnel lié à un événement écrit, pas un faux saut sonore sur chaque visite. Deux ensembles dans la maquette ; lit et cloison sont validés ensemble. Recette : angle du pied de lit, accès à l’indice et détour après impact sans escalade obligatoire.

### P28 Valise ouverte

**Consultation présente depuis la 0.5.** Une étiquette de valise des suites peut être examinée. Elle donne un constat sur des affaires laissées sur place, sans créer une mission de recherche ni confirmer le sort de leur propriétaire.

**Présent comme volume. Fonction et gabarit.** Petite valise de maquette d’environ 1,1 × 0,8 × 0,7 m. Cible : modèle plus fin, vêtements et étiquette nominative qui racontent une personne, sans créer une collection de butin.

**Interaction et états.** Décor, ou examen de campagne avec une information courte. Les objets personnels ne prennent pas la place des outils dans un inventaire. Si une identité est utile, le journal conserve son texte même quand la valise n’est plus dans le champ.

**Son et implantation.** Fermeture ou tissu uniquement en examen ; silence sinon. Une à trois valises aux suites, aucune au centre de la route de transfert. Recette : ne pas confondre le contour avec une caisse de secours, garder le nom lisible et ne pas cacher un indice sous un effet de poussière.

### P29 Bureau et poste informatique

**Consultation présente depuis la 0.5.** Le dossier papier voisin du poste peut être examiné ; l’écran demeure décoratif. La fiche distingue le plan antérieur au choc et le détour intérieur actuellement praticable.

**Présent. Fonction et gabarit.** Plateau de maquette 2,3 × 1,5 m à environ 0,83 m ; écran de 1 × 0,08 × 0,65 m. Il organise les bureaux d’archives et la ligne de vue sur Samuel.

**Interaction et états.** Le poste actuel est décoratif. Cible de campagne : éteint, alimenté, session accessible et dossier consulté. Un document essentiel reste récupérable sur papier ou par témoignage si le courant manque. La connexion ne lance pas un piratage abstrait obligatoire.

**Son et implantation.** Ventilation faible, clavier seulement si l’usage est montré ; confirmation d’archive distincte de la radio. Quatre postes dans le blocage actuel, groupes variables futurs. Recette : chaise comprise dans le gabarit, angles de collision et lecture à proximité sans recouvrir l’objectif humain.

### P30 Armoire d’archives

**Présent. Fonction et gabarit.** Armoire de maquette de 1,15 × 0,8 × 2,6 m, poignées répétées. Elle raconte le stockage administratif et protège une poche de fouille à distance du noyau.

**Interaction et états.** Décor dans la tranche. Cible : tiroir identifié, fermé, ouvert, preuve consultée. Une seule action d’examen donne l’information utile ; ouvrir vingt tiroirs identiques ne constitue pas le gameplay de l’archive.

**Son et implantation.** Coulissement métallique, dossier et fermeture optionnelle. Les tiroirs ne repoussent pas la capsule vers le vide ; la collision ouverte respecte un débattement. Trois armoires au 28, familles dérivées aux 7 et B03. Recette : reprise ouverte, accès derrière Samuel et signalétique de dossier sans code couleur unique.

### P31 Document ou plaque de preuve

**Présent sous forme de station. Fonction et gabarit.** Dans la maquette, les preuves sont portées par un socle de 1,1 × 0,7 × 1 m et une plaque lumineuse. Cible artistique : document A4, registre, photo ou plaque de 0,3 à 0,6 m, selon la scène.

**Interaction et états.** Non lu, consulté, consigné. E ajoute l’identifiant une seule fois et rend le texte accessible au journal. Le support de campagne pourra rester visible après lecture. L’information narrative ne dépend pas d’un tirage susceptible de supprimer la seule preuve.

**Son et implantation.** Froissement ou clic d’enregistrement, texte complet sans voix obligatoire. Points fixes au 29, 27 et 26 dans la tranche. Recette : interaction répétée, lecture interrompue par alerte, reprise après collecte et version localisée longue.

### P32 Casier d’enfant

**Consultation présente depuis la 0.5.** Une étiquette de casier du jardin peut être examinée. Le texte distingue trace matérielle et présence confirmée, sans déclencher de nouvelle rencontre.

**Présent. Fonction et gabarit.** Bloc de maquette de 0,95 × 0,7 × 1,6 m ; série colorée au Jardin des Marées. La hauteur doit évoquer l’usage du lieu sans réduire toute la circulation à une échelle enfantine.

**Interaction et états.** Décor actuel. Cible de campagne : quelques portes ouvertes et étiquettes de prénoms examinables, avec une information d’évacuation fiable. Aucun enfant n’est tiré au sort à l’intérieur pour un effet de peur.

**Son et implantation.** Porte légère si action, ambiance calme sinon. Six casiers dans la maquette, séries modulaires le long d’un mur. Recette : prénoms non confondus avec rescapés actuels, chemin jusqu’au dessin, porte ouverte hors trajet et contraste accessible entre les modules.

### P33 Jouet arrêté

**Présent comme petits volumes ; interaction de campagne. Fonction et gabarit cible.** Jouet de 0,2 à 0,4 m, identifiable à distance par sa forme et sa place au sol. Une seule source sonore mécanique peut donner un geste simple : l’arrêter.

**Interaction et états.** En marche, arrêté, examinable. L’action cible dure 0,5 s et laisse un véritable temps de silence. Un éventuel son qui continue vient d’une autre source écrite ; il n’autorise pas une attaque au 27.

**Son et implantation.** Mélodie courte originale, sous-titre descriptif, volume modéré. Les petits blocs actuels n’ont aucune collision et restent dans une poche de jeu. Recette : source localisable sans stéréo, arrêt persistant, pas de répétition automatique après sauvegarde et coexistence avec l’écho facultatif.

### P34 Dessin des deux tours

**Présent. Fonction et gabarit.** Panneau de maquette d’environ 3,6 × 1,6 m avec deux formes de tours ; le texte d’indice est associé à la station du 27. Cible artistique : feuilles, traits et signature d’Alma lisibles sans reproduire une vraie identité d’enfant.

**Interaction et états.** Observer le dessin, consigner son contenu, le comparer plus tard. La preuve existe avant l’écho de Bravo et ne dépend pas de celui-ci. Elle établit la présence d’Alma et l’ancienneté du motif sous-marin.

**Son et implantation.** Aucun cri ni ponctuation de peur à la collecte ; laisser place à la lecture. Position murale visible depuis la voie sèche, hors de l’axe du puits. Recette : taille du texte dans le journal, distance d’examen et absence de message radio qui l’efface avant lecture.

### P35 Bassin du spa

**Présent. Fonction et gabarit.** Volume de maquette de 7 × 6,5 m, bord haut de 0,3 m et surface d’eau visuelle. Il structure le niveau 26 et donne un repère stable à la présence stationnaire.

**Interaction et états.** Le bassin actuel n’est pas une simulation de nage. La campagne distingue eau décorative, passage ralenti, circuit dangereux et bassin isolé ; chaque catégorie possède un retour clair. Une coupure électrique ne fait pas disparaître magiquement toute menace sans vérification.

**Son et implantation.** Eau, filtre et réverbération distincte des appels. La passerelle sèche reste visible et praticable pour Nora. Recette : lumière rouge, reflet trompeur optionnel, largeur du contournement, appui de capsule et lisibilité de la sortie lorsque la présence perceptive est visible.

### P36 Transat de soin

**Présent. Fonction et gabarit.** Base de maquette de 1,6 × 3,4 m, dossier incliné et assise basse. Il rappelle la fonction de détente du spa et guide la circulation autour du bassin.

**Interaction et états.** Décor fixe actuel. Cible de campagne : examiner une serviette ou un matériel abandonné, déplacer un seul exemplaire sur un trajet préparé si nécessaire. Il ne devient pas une civière certifiée par simple similitude de forme.

**Son et implantation.** Pieds sur sol humide, tissu ; silence lorsque personne n’agit. Trois emplacements dans la maquette, aucun sur le socket de Nora ou du relevé SILLAGE. Recette : dossier incliné non traversable visuellement, collision simplifiée, route de portage et position de la figure loin du point de secours.

## Réseaux et outils de campagne

### P37 Tableau électrique local

**Campagne. Fonction et gabarit cible.** Coffret de 0,8 × 0,25 × 1,2 m à hauteur accessible, schéma simplifié de trois circuits maximum. Il permet de sécuriser une traversée sans demander une compétence électrique extérieure au jeu.

**Interaction et états.** Alimenté, repéré, isolé, vérifié. Sélection en une action explicite de 1,5 s ; un schéma et une conséquence visible identifient le bon secteur. Le joueur ne manipule pas de câbles réalistes ni de protocole technique applicable hors fiction.

**Son et implantation.** Bourdonnement avant isolation, arrêt net et confirmation textuelle. Placer le coffret sur le côté sûr du danger ou fournir une voie d’accès alternative. Recette : source de secours secondaire, état rechargé, fausse déduction corrigible et aucune perte de l’éclairage essentiel du refuge.

### P38 Pompe de filtration

**Consultation présente depuis la 0.5.** Le manomètre et la plaque de filtration du spa peuvent être examinés. Leur fiche rappelle l’état du sol et la route de secours ; aucune pompe jouable ne change le niveau d’eau dans cette tranche.

**Campagne, décoration technique partielle présente. Fonction et gabarit cible.** Groupe de 1,2 × 1,8 × 1,1 m avec tuyaux et voyant de fonctionnement. Il peut déplacer un danger de niveau d’eau ou fournir un bruit continu exploité par le Noyé sec.

**Interaction et états.** Arrêtée, alimentée, amorcée dans l’abstraction de jeu, fonctionnement, défaut annoncé. Une action de 2 s lance une variation lente et visible, avec possibilité de couper. Une pompe ne vide pas instantanément un étage entier.

**Son et implantation.** Moteur régulier, vibration et changement de débit, sous-titre « pompe en marche ». Local technique du spa, sous-sol ou citerne ; volume d’attente stable. Recette : arrêter pendant une rencontre, quitter la zone, recharger en fonctionnement et conserver un trajet hors de l’eau.

### P39 Vanne de service

**Campagne. Fonction et gabarit cible.** Volant de 0,35 m de diamètre sur conduite identifiable. La couleur et un pictogramme indiquent le réseau ; le sens de fonctionnement est montré par un état lisible, sans dépendre d’une convention métier.

**Interaction et états.** Ouverte, fermeture en cours, fermée, pression stabilisée. Action cible de 2,5 s avec option maintien ou bascule. Le joueur peut annuler ; la reprise réutilise un état cohérent, pas un volant à moitié tourné avec effet déjà complet.

**Son et implantation.** Effort discret, chute de souffle et gouttes après fermeture. La vanne est accessible depuis une niche protégée avant le jet dangereux. Recette : texte lisible à la lampe, caméra confortable, effet visible depuis le poste et arrêt sonore au bon instant.

### P40 Ventilation et grille

**Campagne. Fonction et gabarit cible.** Module mural de 1,2 × 0,35 × 0,8 m, ventilateur inaccessible derrière grille. Le système peut réduire une fumée de gameplay et rendre audible une présence auparavant masquée.

**Interaction et états.** Inactif, alimentation disponible, extraction, arrêt. Un délai cible de 5 s annonce le dégagement progressif d’une poche ; l’interface distingue extraction active et air effectivement praticable. Aucun petit conduit n’est un passage implicite pour le joueur.

**Son et implantation.** Montée et descente progressives de moteur ; sous-titre de bruit couvrant les pas lorsqu’une rencontre utilise cette règle. Placer interrupteur, grille et espace concerné dans une relation visuelle compréhensible. Recette : priorité radio, pause, changement de zone et cohérence de la dépense d’air.

### P41 Bouteille respiratoire

**Présent comme ressource et décor. Fonction et gabarit cible.** Cylindre porté de 0,18 m de diamètre sur 0,6 m, fixé au harnais. La maquette utilise une réserve abstraite de 0 à 100 ; les cylindres décoratifs du refuge ne sont pas des recharges indépendantes.

**Interaction et états.** Réserve disponible, basse, épuisée, remplacée via caisse dans la tranche. La campagne peut ajouter une cartouche unique mais doit annoncer la durée utile avant un secteur. Le pourcentage affiché ne représente pas la composition chimique de l’atmosphère.

**Son et implantation.** Souffle réglable et alerte doublée par texte ; aucun acouphène obligatoire. Ressource minimale garantie avant les fumées du chemin principal. Recette : pause et menu sans consommation, retour au refuge, stock épuisé et récupération d’un checkpoint avec la même réserve.

### P42 Détecteur d’atmosphère

**Consultation présente depuis la 0.5.** Un indicateur fixe au refuge possède une fiche de lecture qui distingue atmosphère du lieu et réserve d’air. Il ne fournit pas un détecteur portable ni une nouvelle mesure simulée.

**Campagne. Fonction et gabarit cible.** Boîtier de 0,09 × 0,04 × 0,16 m, écran à trois états textuels : sûr, incertain, danger. Il informe sur le volume actuel, indépendamment de la réserve d’air du joueur.

**Interaction et états.** Mesure en cours pendant 1 s, lecture stable, changement de zone. Le détecteur n’identifie pas automatiquement un phénomène surnaturel. Les informations critiques sont consultables sans maintenir une animation de main devant le visage.

**Son et implantation.** Alerte réglable, mot et symbole persistants ; la fréquence seule ne porte pas l’information. Objet permanent de campagne, enseigné dans un local sans menace. Recette : frontière de volumes, mesure pendant portage, daltonisme, son désactivé et absence de confusion avec la jauge de bouteille.

### P43 Extincteur

**Consultation présente depuis la 0.5.** Un extincteur identifiable au refuge peut être examiné. Il ne se ramasse pas, ne consomme pas de charge et n’éteint pas de foyer dans le prototype.

**Campagne. Fonction et gabarit cible.** Cylindre de 0,18 m de diamètre sur 0,55 m, silhouette distincte d’une bouteille respiratoire. Il agit sur de petits foyers préparés et sur la visibilité, selon des abstractions de jeu.

**Interaction et états.** Pris, visée courte, émission, charge épuisée. Charge cible de 6 s d’usage total ; un foyer de tutoriel demande 2 s et laisse une marge. La dépense est continue et annoncée. Il ne neutralise pas tout incendie de décor.

**Son et implantation.** Souffle fort mais limité, toux et acouphènes optionnels ; danger restant visible dans l’interface. Un exemplaire garanti avant le premier besoin, route secondaire disponible ensuite. Recette : arrêt de jet, collision du nuage, radio intelligible, sortie non masquée et aucune ressource exigée après épuisement forcé.

### P44 Hache de dégagement

**Campagne. Fonction et gabarit cible.** Outil de 0,7 m de longueur, tête de 0,22 m, porté sur le harnais. Son verbe principal est dégager un panneau marqué, puis repousser une menace à portée si la rencontre l’autorise.

**Interaction et états.** Disponible, préparation, frappe, récupération. Un dégagement cible demande trois frappes en 3,6 s ; l’animation peut être interrompue entre frappes. Aucun démembrement ni destruction libre du bâtiment n’est nécessaire à cette fonction.

**Son et implantation.** Matériau frappé identifiable, bruit annoncé avant action, pas d’impact sur un survivant voisin. Objet permanent de campagne, cibles de dégagement sélectionnées. Recette : portée sans traverser un mur, dépenses éventuelles explicites, états de panneau conservés et contrejeu limité selon la fiche d’ennemi.

## Recherche et profondeur

### P45 Terminal SILLAGE

**Campagne. Fonction et gabarit cible.** Console de 1,4 × 0,8 × 1,2 m avec écran secondaire et boutons fonctionnels limités. Elle relie les expériences aux décisions humaines, sans devenir une page d’exposition interminable.

**Interaction et états.** Hors ligne, session locale, dossier accessible, commande demandée, effet confirmé. Chaque action annonce le réseau touché. Une preuve essentielle se lit avant une commande irréversible ; une sortie de consultation reste disponible.

**Son et implantation.** Ventilation sèche, relais et journal d’actions consultable. L’écran peut répéter un enregistrement, mais le HUD de mission ne falsifie pas un succès. Emplacements aux 9, 8 et bunker ; variantes de documents secondaires. Recette : ordre de lecture libre, texte long, perte d’alimentation et confirmation de commande à distance.

### P46 Caméra d’observation

**Campagne. Fonction et gabarit cible.** Boîtier de 0,2 × 0,35 × 0,2 m sur bras, moniteur associé. Elle permet de comparer le lieu actuel à une image captée, et sert de dispositif observable aux Veilleurs.

**Interaction et états.** Éteinte, acquisition, enregistrement, replay identifié. Le joueur peut couper une alimentation locale ou détourner l’angle via un panneau prévu. Le retour vidéo porte une heure et un statut qui peuvent être comparés à d’autres preuves.

**Son et implantation.** Petit servo et clic de relais ; le voyant possède un symbole lisible. Une à trois caméras dans un poste d’observation, cônes visibles par décor ou écran. Recette : image hors champ, pause, état coupé restauré et distinction entre reprise enregistrée et observation en direct.

### P47 Enregistreur de témoignage

**Campagne. Fonction et gabarit cible.** Appareil de 0,14 × 0,03 × 0,08 m, étiquette de date et indicateur de lecture. Il porte un fragment court plutôt qu’une longue bande obligatoire à écouter immobile.

**Interaction et états.** Trouvé, lecture, arrêté, consigné. Lancer, suspendre et reprendre sont explicites. Le texte complet rejoint le journal et une alerte urgente interrompt proprement le son sans perdre l’avancement de lecture.

**Son et implantation.** Début et fin de bande, voix compréhensible ; les défauts n’effacent pas les mots nécessaires. Un enregistrement principal par niveau d’enquête, variantes facultatives séparées. Recette : chevauchement avec radio, retour au menu, reprise de session et écoute sans sous-entendre que la voix est présente dans la pièce.

### P48 Sas de recherche

**Campagne. Fonction et gabarit cible.** Module de 2,4 × 3 × 2,6 m, deux portes de 1,4 m de largeur utile et baie de lecture. Il prépare un changement de règles sans bloquer le joueur dans une attente inexpliquée.

**Interaction et états.** Entrée ouverte, cycle annoncé, sortie autorisée, arrêt d’urgence. Cycle cible de 4 s, annulable avant verrouillage ; un moyen de retour reste disponible jusqu’à une transition narrative enregistrée. La présence d’un rescapé doit être prise en compte avant fermeture.

**Son et implantation.** Relais, ventilation et consigne courte avec compte à rebours lisible. Un module principal au S07, dérivés au bunker. Recette : corps dans le seuil, charge longue, panne de cycle, pause, reprise au côté sûr et absence de softlock après retour arrière.

### P49 Balise de comparaison

**Campagne. Fonction et gabarit cible.** Petit boîtier de 0,12 × 0,08 × 0,18 m, numéro et symbole visibles. Il conserve un point de mesure dans les espaces contradictoires et permet au joueur de vérifier une distance ou une réponse.

**Interaction et états.** En stock, posée sur socket, active, relevée. Pose cible 0,8 s, récupération libre si aucun transfert n’en dépend. L’identifiant ne se renumérote pas après chargement ; une copie perceptive ne reçoit pas le statut de balise authentifiée dans le journal.

**Son et implantation.** Bipe espacé désactivable, numéro lisible à la lampe. Deux balises garanties avant la première énigme qui les requiert. Recette : repères comparés depuis deux entrées, inventaire plein, faux reflet et route résoluble sans distinguer seulement les couleurs.

### P50 Module du seuil

**Campagne. Fonction et gabarit cible.** Trois stations différentes d’environ 1,2 × 1 × 1,4 m : énergie, motif enregistré et réponse humaine. Elles rendent la fin compréhensible par les fonctions apprises, sans une barre de vie géante.

**Interaction et états.** Actif, identifié, isolé ou détourné, résultat confirmé. Chaque choix exige une condition montrée dans la scène. La résolution peut être interrompue et reprise depuis un appui protégé ; elle ne réinitialise pas les personnes sauvées.

**Son et implantation.** Chaque liaison porte une signature stable et des sous-titres de source ; les couches se retirent avec les actions. Placement écrit en B06 puis dans I04, de l’autre côté de P666 ; aucune permutation du sens des stations. Recette : ordre alternatif autorisé, choix final explicite, retour de checkpoint et épilogue cohérent avec les faits enregistrés.

### P51 Télémètre

**Campagne. Fonction et gabarit cible.** Outil de 0,06 × 0,12 × 0,04 m, lecture superposée discrète. Il apprend au joueur à comparer une distance ordinaire avant de lui permettre d’identifier une contradiction spatiale.

**Interaction et états.** Visée, surface trouvée, mesure stable après 0,6 s, mesure enregistrée. Une surface invalide donne un refus clair. Le chiffre reste un outil de fiction ; la précision affichée ne doit pas excéder celle utilisée par l’énigme.

**Son et implantation.** Clic court et lecture en mètres, accessibles sans laser visible. Objet fourni avant A14, utilisé d’abord dans un couloir stable. Recette : verre, eau, absence de surface, même point mesuré depuis deux positions et texte lisible avec champ de vision large.

### P52 Hélicoptère de secours

**Présent comme maquette détaillée. Fonction et gabarit.** Deux appareils distincts servent à la dépose et à la lecture des deux opérations. La version 0.5 donne au fuselage un nez, une cabine ouverte latéralement, des sièges, des portes coulissantes, un train posé au toit, des attaches et deux ensembles de pales animées. Les marquages de secours et les hélisurfaces les relient à leur mission. Leur géométrie reste procédurale et ne correspond pas à la reproduction certifiée d’un appareil réel.

**Interaction et états.** Approche, descente finale, toucher, ouverture, sortie des équipes, fermeture, appareil au toit, départ opérationnel, éloigné. Le joueur ne le pilote pas. La cinématique d’arrivée possède son horloge ; la passer ne doit pas accélérer le départ de mission ni remettre un appareil au mauvais endroit. Aucun appareil n’est enfant de la tour qui bascule pendant son vol. Le souffle visible des rotors est un effet sans collision et sans coût de ressource.

**Son et implantation.** Couches de rotor, moteur et vent, atténuées sous les sous-titres. Points fixes de dépose sur Aube et Hespérie, pas de spawn aléatoire. Recette : caméra finale, pale sans collider, reprise au menu, mouvement réduit et cohérence du départ après une introduction passée.

## Accessoires des expériences et de la traversée infernale — campagne future

Les huit fiches suivantes complètent P01–P52. Elles fixent des verbes et des états avant la production des modèles. **Aucun de ces objets n’est livré comme interaction dans la tranche toit–25.** Les dimensions sont des gabarits de jeu à éprouver.

### P53 Caisson de comparaison matérielle

**Fonction et gabarit cible.** Deux cellules vitrées sur un bâti de 2,4 × 1,1 × 1,7 m. Un échantillon local et une matière ramenée de la brèche peuvent être observés sans exposer Alex. L’objet établit que les essais portent sur un transfert matériel ; il ne prétend pas expliquer toute la physique de l’Enfer.

**Interaction et états.** Scellé, témoin local lu, témoin étranger lu, comparaison consignée. Deux repères persistants et un registre daté rendent la conclusion indépendante d’un seul écran. Une vitre brisée reste un obstacle local annoncé, jamais une contamination mortelle invisible.

**Son, implantation et recette.** Compresseur à bas régime, verrous et signal d’état doublé par un mot. Implantation A08 puis B02 ; comparaison principale possible sans consommable. Vérifier lecture dans n’importe quel ordre, retour après panne, contraste des matières et séparation entre observation et certitude cosmologique.

### P54 Registre de franchissement

**Fonction et gabarit cible.** Pupitre de 0,8 × 0,5 × 1,1 m avec feuillets et écran d’archive. Il relie départ, retour, masse transportée, opérateurs et décisions d’autorisation. Le récit se construit par concordance avec les objets présents.

**Interaction et états.** Fermé, pièce lue, pièces rapprochées, copie emportée. Les noms d’opérateurs et les dates sont stables. Une pièce facultative peut préciser une victime ; aucune seule page cachée ne verrouille la compréhension du passage.

**Son, implantation et recette.** Papier, tiroir, lecteur sobre ; aucun « succès » sonore avant lecture effective. A07 expose la chaîne de responsabilité, B01 et B05 la complètent. Tester page longue, lecture interrompue, journal et preuve dupliquée : une copie d’un registre ne compte pas comme un second témoignage indépendant.

### P55 Collecteur de seuil

**Fonction et gabarit cible.** Assemblage industriel fictif de 3 × 2 × 2,8 m, raccords reconnaissables et chambre inaccessible. Il matérialise l’exploitation tentée par Pelagos et la dépendance énergétique de la brèche.

**Interaction et états.** Alimenté, dérivation disponible, isolé, état confirmé. Le joueur agit sur un panneau simplifié ; le modèle n’enseigne aucune procédure réelle de haute énergie. Couper une branche modifie un effet visible et ouvre une fenêtre de traversée définie.

**Son, implantation et recette.** Pulsation grave et rythme de relais, sans niveau sonore extrême. B03 puis installation transférée en I03. Recette : anticipation du changement, détour sans précision au pixel, panne au milieu d’une commande et conservation de l’état après reprise.

### P56 Porte de confinement déformée

**Fonction et gabarit cible.** Cadre de 2,8 × 1,2 × 3 m, double battant et joint marqué par une matière étrangère. Les efforts visibles indiquent de quel côté est venue la rupture. La porte sert aussi de séparation contre une menace humaine corporelle.

**Interaction et états.** Entrebâillée, retenue, passage autorisé, refermée ou condamnée avec détour. Une fermeture attend que le joueur et toute personne accompagnée aient quitté le volume. Le retour utile ne se condamne pas par un clic involontaire.

**Son, implantation et recette.** Frottement métallique, flexion progressive et verrou distinct. Première porte lisible à A09, variante profonde B04. Vérifier capsule, corps porté, course des battants, état du verrou et chemin secondaire avant toute mise en scène hostile.

### P57 Balise d’amarrage dimensionnel

**Fonction et gabarit cible.** Tripode de 0,7 × 0,7 × 1,1 m avec identifiant mécanique, lumière fixe et bobine visible. Il authentifie un appui de retour entre P666 et I01. Sa signature est un objet du monde que le joueur a préparé, pas un label apparu sur une copie inconnue.

**Interaction et états.** Transportée, posée sur socket sûr, raccordée, liaison vérifiée, protégée. La première balise est fournie avant le franchissement. L’équipement ne disparaît pas au chargement et une copie perceptive ne reçoit pas son identifiant.

**Son, implantation et recette.** Bip espacé désactivable, texte et symbole permanent. Un couple Nacre/Enfer au chemin critique, variantes secondaires limitées. Tester passage, retour, sauvegarde, partenaire absent et lecture sans distinguer seulement le rouge du vert.

### P58 Ligne de retour et treuil d’amarrage

**Fonction et gabarit cible.** Treuil de 1,6 × 1 × 1,3 m et ligne représentée entre points préparés. Il transpose le geste de rappel en moyen de continuité physique dans la dimension infernale, sans simuler une corde infinie libre.

**Interaction et états.** Ancrée, déployée par segment, tendue, segment isolé, route confirmée. Les segments portent des numéros et ont des appuis valides. Le jeu annonce une rupture narrative et fournit une solution de repli avant de retirer une ligne acquise.

**Son, implantation et recette.** Roulement, tension lente et cliquetis localisés. P666, I01 et I02 ; aucun câble traversant la capsule. Vérifier retour avec charge, bifurcation, pause sous tension, orientation et reprise au dernier appui plutôt qu’au milieu d’un segment.

### P59 Borne de contre-signal

**Fonction et gabarit cible.** Trois variantes d’un poste de 1,3 × 0,9 × 1,6 m, distinguées par forme, fonction et repère. Elles rendent accessibles les liaisons énergie, motif et réponse du Chœur bas.

**Interaction et états.** Liaison reconnue, contre-signal préparé, fenêtre ouverte, liaison isolée ou détournée. Chaque commande annonce son coût et son effet sur le retour. Le joueur peut observer un cycle depuis un appui avant d’agir ; aucune phrase cachée n’est une solution magique.

**Son, implantation et recette.** Couches différentes qui se retirent à l’action, sous-titres de source et indicateurs fixes. I04 uniquement pour la résolution complète, version d’enseignement B06. Vérifier ordre alternatif, interruption, preuve incomplète, personnes protégées et sauvegarde entre objectifs.

### P60 Sas de retour à Nacre

**Fonction et gabarit cible.** Volume de 4 × 4 × 3 m, rail de matériel, baie d’observation et double repère d’amarrage. Il rend le retour physique vérifiable avant la galerie de sortie.

**Interaction et états.** Appui établi, personnes regroupées, matériel compté, côté Nacre confirmé, fermeture autorisée. La validation conserve les identifiants des personnes et des objets qui franchissent. Elle ne transforme pas une personne déjà sauvée en copie douteuse pour fabriquer un retournement final.

**Son, implantation et recette.** La réverbération infernale s’efface devant la ventilation connue et un appel authentifié. Interface unique entre I04, P666 et la route SORTIE. Tester retour partiel, partenaire retardé, abandon volontaire d’un objet facultatif, échec d’écriture et reprise de chaque côté avec les mêmes résultats humains.

## Liaisons locales de la version 0.9

### P61 Escalier local à deux volées

**Présent. Fonction et gabarit.** Trois assemblages en U relient les paires 30–29, 28–27 et 26–25. Leur implantation se trouve au sud du noyau, entre x = −2,5 et +2,5 m et z = 5,8 à 11,4 m. Deux volées franchissent chacune trois mètres sur 4,4 m de course et rejoignent un palier intermédiaire de 5 × 1,2 m. Chaque volée comporte vingt marches visuelles de 0,15 m de hauteur et 0,22 m de course ; une liaison en comporte donc quarante. L’arrivée et le départ sont lisibles depuis la circulation du plateau.

**Interaction et états.** Alex les parcourt par la marche physique, dans les deux sens, sans touche de téléportation. Les marches sont visuelles ; la capsule suit des collisions inclinées continues pour éviter que chaque arête produise un blocage. Le portage reste possible à sa vitesse ordinaire. La cage n’ouvre pas une troisième liaison : après la sortie sur la dalle, le joueur rejoint une station de rappel distincte. Ces trois assemblages restent utilisables avant et après l’incident.

**Présentation, implantation et recette.** Les numéros des deux étages et le sens du chemin doivent accompagner la forme des volées. La main courante et les limites de palier servent à comprendre le passage ; une couleur seule ne certifie pas une ouverture. Vérifier l’aller et le retour avec la vraie capsule, sans saut, puis avec le portage ; tester le palier intermédiaire, la rotation, les extrémités et les collisions voisines sur les variantes de mobilier. Une marche visuellement présente sans sol physique constitue un défaut bloquant.

### P62 Station de rappel personnel

**Présent. Fonction et gabarit.** Chaque extrémité de R31_30, R29_28 et R27_26 possède un point d’engagement sur la dalle à l’ouest du puits. La station est bleue, avec une fonction et une destination écrites. Le point d’interaction se situe à x = −3,8 m, z = 0 ; l’axe suspendu est à x = −1,3 m. L’appui fixe est au-dessus du terminal supérieur. La station identifie la paire d’étages qu’elle relie, sans présenter la balise orange du treuil comme un moyen de déplacement personnel.

**Interaction et états.** Disponible, entrée contrôlée, segment occupé par Alex, retour au terminal et sortie contrôlée. E vérifie la proximité, l’absence de personne portée et le dégagement. Un refus conserve la position et les ressources. Le segment est accessible depuis son haut ou son bas ; aucun consommable n’est requis pour la route principale. Les transferts d’entrée et de sortie ne sont pas sérialisés dans le schéma 3.

**Présentation, implantation et recette.** Afficher destination, fonction et commande de façon concordante dans le monde et dans le HUD. Aucun raccordement ne déplace Alex de plusieurs étages. Tester les deux terminaux, l’usage répété, le mauvais côté, l’obstruction d’une capsule, une interruption pendant le transfert, le retour au menu et la reprise au dernier palier. L’arrêt d’une transition conserve un état cohérent ; il ne valide pas silencieusement une arrivée dans un mur.

### P63 Dalle d’arrêt et ouverture de service

**Présent. Fonction et gabarit.** Les ouvertures du rappel personnel occupent la moitié ouest du puits de service. Des surfaces d’arrêt locales bornent les arrivées au 30, au 28, au 26 et au refuge 25. Elles ne sont pas des trous créés artificiellement par un dommage antérieur à l’effondrement : le toit commence avec une ouverture de travail identifiable. La moitié orientale reste réservée au treuil continu des rescapés ; un garde-corps l’exclut du parcours piéton tout en laissant la dépose du toit libre.

**Interaction et états.** Géométrie fixe avec collision, sans commande d’ouverture ou de destruction. La surface empêche de prolonger une descente personnelle vers le segment suivant. Le terminal autorise une sortie vers la dalle ; l’escalier voisin assure la prochaine liaison. L’état après impact conserve ces appuis, les stations et le couloir oriental de transfert.

**Présentation, implantation et recette.** La lecture doit montrer où la ligne se termine, où Alex peut poser le pied et quel itinéraire reprend ensuite. Réserver le dégagement réel du corps au-dessus de chaque arrivée ; aucun bord décoratif ne peut traverser la capsule lors du transfert. Vérifier l’absence de passage direct multiétage à l’ouest, le libre passage du panier à x = 1,8 m, le contraste sans éclair et la cohérence des limites visibles avec les collisions.

### P64 Descendeur et mains gantées

**Présent sous forme procédurale. Fonction et gabarit.** Un descendeur, sa poignée, un mousqueton, un brin de corde et deux mains gantées apparaissent dans le cadrage de première personne pendant le rappel. Ces volumes donnent un geste identifiable au contrôle de vitesse. Leur échelle et leur placement sont des paramètres de présentation de caméra, distincts des collisions du personnage.

**Interaction et états.** La pose reçoit l’état du modèle : visibilité sur corde, position du levier liée à la vitesse, indicateur de verrouillage ou d’arrêt, léger mouvement lié au déplacement. Les mouvements réduits retirent l’oscillation cosmétique. Le prop ne consomme pas d’endurance, n’applique pas le frein et n’écrit pas de sauvegarde ; il montre les décisions déjà prises par le contrôleur. Il disparaît hors rappel et ne se superpose pas au harnais d’une personne portée.

**Présentation et recette.** La silhouette du matériel ne doit masquer ni le palier d’arrivée ni le texte de sortie. Les mains restent une représentation géométrique, sans capture de mouvement ni contact digital réaliste. Vérifier les poses à l’arrêt, en montée, en descente, en mode précis et verrouillé ; comparer les mouvements réduits, pause et reprise, puis le retour à la marche. Le son définitif de manipulation reste un travail de production distinct, à ne pas déduire de la présence du modèle 3D.

## Les douze observations de terrain de la version 0.5

Ces objets donnent une fonction de lecture au décor déjà parcouru. Le joueur s’approche, oriente son regard vers la surface utile puis appuie sur E. Une fiche présente le rôle de l’objet, un constat lié à l’état du monde, une consigne de déplacement ou de secours et une note de l’équipe. La fiche ne demande pas de collecter l’objet. Elle peut être relue et n’ajoute ni quête secondaire, ni ressource, ni condition de fin.

Le registre médical répond à une question précise : qui a réellement été reçu au toit ? Les objets des étages donnent des informations complémentaires : ce qu’un couvert abandonné permet de constater, pourquoi un plan d’avant l’impact doit être confronté à la route actuelle, ou pourquoi un indicateur de réseau ne confirme pas la survie d’une équipe. Cette écriture garde la distinction entre trace matérielle, hypothèse et confirmation de mission. Le silence de Bravo n’est jamais présenté comme la preuve de sa mort.

| Niveau | Objet examinable | Rôle dans la lecture du lieu | Référence |
| --- | --- | --- | --- |
| Toit | Registre du poste médical | Noms reçus et réceptions encore attendues | P11 |
| Toit | Carnet de la ligne principale | Distinguer le rappel personnel local du treuil continu des rescapés | P02, P04 et P62 |
| 30 | Couvert resté prêt | Service interrompu avant le choc observé | P23 |
| 30 | Registre de service | Séparer réservation, présence et évacuation | P25 |
| 29 | Valise des suites | Trace personnelle sans localisation inventée | P28 |
| 29 | Témoin de la baie Est | Constater le vitrage et garder la limite intérieure | P19 |
| 28 | Dossier de maintenance | Lire le plan puis le détour devenu nécessaire | P29 et P30 |
| 28 | Boîtier radio de palier | Identifier les équipes et la liaison dégradée | P22 |
| 27 | L’étiquette du jardin | Lire les traces d’un lieu de vie sans déduire une présence | P32 |
| 26 | Le manomètre de filtration | Comprendre le spa et le trajet vers Nora | P38 |
| 25 | Le contrôle du refuge | Distinguer état du lieu et réserve respiratoire | P42 |
| 25 | Le poste incendie | Reconnaître le matériel et la limite de son usage actuel | P43 |

### Conditions de lecture et priorité des secours

La portée est de **2,4 m dans le plan du sol**, sur le même étage. La caméra doit viser la zone d’examen avec un produit scalaire d’au moins **0,82**, soit un cône d’environ 35 degrés autour de la direction du regard. Un rayon physique entre la caméra et cette zone doit être libre. La capsule du joueur est exclue du rayon ; une cloison ou un meuble conservant une collision empêche la consultation à travers lui. Les points visés sont légèrement au-dessus de leur support pour que l’objet puisse être lu depuis le passage.

Une interaction de mission située à moins de **1,5 m** conserve la priorité. L’examen est disponible pendant l’intervention jouable, hors introduction et bilan final. Il ne peut pas prendre la place d’une commande pendant le rappel, le portage d’une personne, un treuillage ou l’incident structurel actif. Cela permet à la même touche E de rester prévisible dans l’urgence. En dehors de ces situations, le texte d’interaction annonce « Examiner » et le titre de l’objet ; une fiche sans conséquence de jeu ne se présente pas comme une activation de mécanisme.

L’ouverture suspend la mission, le monde et les canaux sonores. Le personnage reste immobile ; l’oxygène, les dangers, le temps de treuillage, l’historique radio et les conditions de progression ne changent pas pendant la lecture. Le bouton de fermeture reste accessible hors de la zone de défilement. Échap referme également la fiche et rend le contrôle. La lecture est disponible avec le son désactivé et les caméras réduites.

### Continuité des observations

Le texte est recalculé à chaque ouverture depuis l’état stable de l’incident et les identifiants de rescapés confirmés. Le registre ne confirme à l’abri que les personnes dont la réception est validée ; il affiche séparément les réceptions encore attendues parmi Ana, Samuel et Nora. Porter une personne ou la voir monter ne suffit pas à compléter sa ligne. Les observations au restaurant, aux archives et au spa changent leur consigne après la réception correspondante.

L’avant et l’après du choc possèdent des observations différentes. Le dossier de maintenance précise que le plan est antérieur aux dégâts ; il guide vers le détour intérieur sans réécrire le document lui-même. La fiche de la baie distingue les vitrages perdus des éléments de bord restés en place. Le poste du toit confirme que les personnes reçues demeurent à l’abri. Ces textes n’effacent aucun message historique et n’ajoutent pas un appel radio jamais entendu.

Les identifiants `inspect_roof_register` à `inspect_25_extinguisher` appartiennent au catalogue des observations. Ils n’entrent pas dans `clues`, `supplies_used` ou `rescued`. Le schéma de sauvegarde reste la version 3 ; aucun état « déjà lu » n’est ajouté. Une reprise reconstruit les douze objets puis recalcule leur fiche à la prochaine consultation. Le contenu peut donc rester cohérent sans écrire une sauvegarde à chaque lecture.

### Présentation et recette

Les accessoires ajoutés sont des modèles natifs : porte-documents, papiers, couvert, étiquette, plaquette, boîtier, tuyaux et extincteur. Les textes visibles dans le monde sont fixés à leur support. Les observations n’ajoutent pas de panneau flottant orienté en permanence vers la caméra. Leurs volumes ne possèdent pas de collision supplémentaire ; les routes de secours continuent à être définies par le niveau existant.

La recette vérifie une position debout libre près de chacune des douze fiches, la visée, la portée et l’occlusion. Elle ouvre le panneau depuis l’interaction réelle, ferme par son bouton et par Échap, puis compare temps, ressources et fichier de sauvegarde. Elle doit également confirmer qu’une balise proche reste prioritaire, qu’un objet peut être relu et qu’un changement d’incident ou de réception se reflète dans son texte. Les variantes de génération restent soumises aux vérifications de parcours ; un élément de présentation ne valide pas à lui seul l’accès à un rescapé.

## Priorité de production et recette commune

La première passe artistique traite P01, P02, P05, P08 à P12, P18 à P21 et P52, car ces objets portent les décisions déjà présentes dans la tranche. La deuxième passe habille le restaurant, les suites, les bureaux, le jardin et le spa sans modifier les passages. Les objets de campagne attendent leur verbes jouables et leurs scènes d’enseignement ; produire un modèle détaillé avant cette validation risque de figer une interaction encore mal comprise.

Un objet est accepté lorsque son rôle est reconnaissable, son gabarit laisse les routes prévues, son interaction ne se déclenche pas à travers un obstacle interdit, son coût correspond au résultat, sa pause est correcte et son état se restaure. Une variante de décor n’est pas acceptée sur sa seule apparence : elle doit passer les mêmes trajets avec et sans charge. Les sons, les sous-titres et les signes restent utiles quand les flashes et les mouvements de caméra sont réduits.

Références locales : [constructeur du monde](../prototype/scripts/world_builder.gd), [contrôleur du joueur](../prototype/scripts/player_controller.gd), [mission](../prototype/scripts/main.gd), [catalogue des niveaux](CATALOGUE_ETAGES.md) et [scènes](SCENES_CINEMATIQUES.md).
