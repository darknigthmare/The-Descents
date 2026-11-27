# The Tower Descent — prototype 0.13.0

Ce guide décrit la candidature v0.13.0, du toit 31 au relais du 17. Les cibles de distribution sont [Windows x86_64](https://github.com/darknigthmare/The-Descents/raw/refs/heads/feat/live-tower-collapse/releases/v0.13/TheTowerDescent-v0.13-Windows-x86_64.zip), [les sources Godot et documents](https://github.com/darknigthmare/The-Descents/raw/refs/heads/feat/live-tower-collapse/releases/v0.13/TheTowerDescent-v0.13-Godot-Source.zip) et [l’export Web](https://github.com/darknigthmare/The-Descents/raw/refs/heads/feat/live-tower-collapse/releases/v0.13/TheTowerDescent-v0.13-Web.zip). Leur vérification et leur publication finales restent en cours au statut candidat. Consultez [l’état de livraison](https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/ETAT_DE_LIVRAISON.md) pour connaître les fichiers effectivement disponibles et leur portée de vérification.

## Lancer l’intervention

1. Extraire tout le ZIP **TheTowerDescent-v0.13-Windows-x86_64.zip** dans un dossier.
2. Ouvrir **JOUER_CINEMATIQUE.cmd** pour le rendu Forward+ (Vulkan), ou **JOUER_COMPATIBILITE.cmd** pour le rendu OpenGL plus léger. **TheTowerDescent.exe** demande aussi Forward+ par défaut. Aucune installation de Godot n’est nécessaire.
3. Passer ou regarder la signature du studio, ouvrir **Commencer l’intervention**, puis confirmer **Déployer Alpha**. La disposition proposée convient pour une première partie.

La signature de 15 secondes précède un accueil lié à votre dernier point sûr. L’approche en jeu de 28 secondes montre la ville, les deux tours encore droites et les équipes de secours en quatre plans. Les deux hélicoptères approchent et se posent ; les portes s’ouvrent pendant le déploiement des équipes, puis se referment avant la prise de contrôle. **E**, **Entrée** ou le bouton **Passer** permettent de passer la séquence. **Échap** met l’approche en pause. Le chronomètre de mission démarre après le raccord au joueur. Vous prenez ensuite le contrôle sur le toit d’Aube ; Bravo se déploie sur Hespérie.

Sur le toit, rejoignez le **repère bleu du rappel personnel**, puis appuyez sur **E**. Laissez se terminer le raccordement de la longe avant de descendre avec **S**. Le premier segment mène seulement au restaurant du 30. Les **balises orange** servent à l’évacuation des rescapés vers le toit.

## Trouver le passage vers l’étage voisin

Le parcours alterne rappels dans les ouvertures et escaliers locaux. Chaque passage permet le retour entre les deux niveaux indiqués.

| Liaison | Descente | Retour |
| --- | --- | --- |
| R31_30 — rappel | Toit → restaurant 30 | Remontée au toit |
| S30_29 — escalier | Restaurant 30 → suites 29 | Marche vers le 30 |
| R29_28 — rappel | Suites 29 → archives 28 | Remontée au 29 |
| S28_27 — escalier | Archives 28 → jardin 27 | Marche vers le 28 |
| R27_26 — rappel | Jardin 27 → spa 26 | Remontée au 27 |
| S26_25 — escalier | Spa 26 → refuge 25 | Marche vers le 26 |
| S25_24 — escalier, après le bilan | Refuge 25 → congrès 24 | Marche et escorte vers le refuge |
| R24_23 — rappel | Congrès 24 → exposition 23 | Remontée au congrès |
| S23_22 — escalier, après le bilan | Exposition 23 → galerie 22 | Retour au 23 |
| S22_21 — escalier nord | Galerie 22 → cuisines 21 | Retour au 22 |
| R22_21 — rappel facultatif | Galerie 22 → cuisines 21 | Remontée au 22 |
| S21_20 — escalier sud | Cuisines 21 → refuge 20 | Retour au 21 |
| S20_19 — escalier nord, après le bilan | Refuge 20 → résidences 19 | Retour et escorte vers le refuge 20 |
| R19_18 — rappel du duplex | Résidences 19 → duplex 18 | Remontée personnelle au 19 |
| S19_18 — escalier sud de service | Résidences 19 → duplex 18 | Retour et escorte après dégagement au Halligan depuis le 18 |
| S18_17 — escalier nord | Duplex 18 → télécommunications 17 | Retour et escorte vers le 18 |

Dans les escaliers, marchez avec **ZQSD / WASD**. Descendez la première volée, tournez sur le palier intermédiaire puis continuez sur la seconde. Aucun appui sur E n’est nécessaire. L’autre extrémité rejoint le plateau ; la cage ne mène pas automatiquement à un troisième étage. Le HUD indique la paire parcourue et le journal situe votre liaison.

Une arrivée d’étage n’est confirmée que lorsque vous retrouvez un plateau stable. Le palier à mi-hauteur ne devient pas un nouveau point sûr. Les repères de station permettent de retrouver le prochain passage et de revenir au toit si un objectif a été oublié.

## Maîtriser le rappel

Le rappel personnel exige les mains libres. Si vous portez une personne, ramenez-la d’abord à la balise orange de son étage et lancez le treuil. Le raccordement à une station bleue ne consomme aucun ancrage facultatif.

| Geste | Commande | Effet |
| --- | --- | --- |
| Engager la longe | E près du repère bleu | Raccordement de 0,85 s, si l’accès est libre |
| Descendre | S | Vitesse cible 2,8 m/s |
| Remonter | Z ou W | Vitesse cible 1,6 m/s ; consomme de l’endurance |
| Approcher précisément | Ctrl et une direction | Vitesse cible 0,75 m/s ; prioritaire sur Maj |
| Descendre rapidement | Maj + S | Vitesse cible 4,2 m/s ; consomme de l’endurance |
| Corriger le balancement | Q/A ou D | Recentre la suspension dans l’ouverture |
| Freiner | Relâcher la direction | Freinage automatique jusqu’à l’arrêt |
| Garder la hauteur | Espace | Verrouille le descendeur ; un nouvel appui le libère |
| Stabiliser | X | Seize secondes, contre un ancrage si l’usage est accepté |
| Quitter la corde | E près d’un terminal | Demande une vitesse presque nulle, un recentrage et un passage dégagé |

Relâchez la direction ou verrouillez pour récupérer de l’endurance. La remontée et la descente rapide en dépensent ; les descentes normale et précise n’en dépensent pas mais ne la régénèrent pas en mouvement. À zéro, Alex reste assuré, se repose et retrouve la disponibilité de mouvement à 20 points. Si vous maintenez encore la direction, il pourra alors repartir : gardez le verrou si vous souhaitez continuer à attendre.

Le HUD précise le mode, la vitesse, l’endurance, le câble déployé et les mètres jusqu’au terminal bas. Une stabilisation déjà active refuse un nouvel usage de X, sans consommer une autre unité. Vous pouvez effectuer l’itinéraire sans ce consommable.

Pour sortir, rejoignez le niveau de la dalle, relâchez la direction, corrigez le balancement si nécessaire puis utilisez **E**. **Ctrl** aide à approcher et **Espace** à garder la hauteur. La sortie conserve la longe pendant un transfert de 0,85 s. Si l’accès est encombré, le message explique le refus et Alex reste assuré. Si un transfert engagé se bloque, **E** permet de revenir au point de départ lorsque ce retour est dégagé. La longe reste attachée jusqu’au retour sur un appui réel. Une sortie ne permet pas de choisir un autre étage que les deux extrémités du segment.

La pause, le journal et les panneaux de lecture suspendent la mission et le rappel. Le regard reste sous votre contrôle ; les mouvements réduits atténuent les mouvements cosmétiques du matériel et de la caméra.

## Objectif

Retrouvez les trois personnes aux étages **30, 28 et 26**. Appuyez sur **E** à proximité pour les prendre en charge, puis revenez à la balise orange du même étage et utilisez **E** pour lancer le treuil. Attendez la confirmation du toit.

Après le sauvetage d’**Ana au 30** et le départ des hélicoptères, rejoignez la **baie Est du 29**. Regardez Bravo dans Hespérie pendant **0,8 seconde**, ou appuyez sur **E** près de la balise d’observation. L’alerte, la réplique, l’effondrement et l’impact se déroulent en 25 secondes ; vous gardez le contrôle. Éloignez-vous des vitres et gardez le noyau intérieur à portée.

Après l’impact, le couloir Est du **28** est condamné : contournez-le par le noyau pour atteindre Samuel, puis ramenez-le à la balise orange du 28. Les rescapés déjà arrivés au toit restent en sécurité. Une fois les trois sauvetages confirmés et la scène terminée, activez le relais du refuge **25**.

Les documents de preuve restent sur les plateaux ; les caisses fournissent du matériel. Les stations bleues de traversée se reconnaissent à la paire d’étages indiquée. Les apparitions du premier secteur restent des manifestations perceptives : elles ne poursuivent pas Alex et ne lui infligent pas de dégâts. Gardez les secours et la lecture des lieux comme priorité ; lampe et fusées restent à votre disposition.

## Utiliser le matériel d’intervention

Les touches physiques **1, 2, 3 et 4** de la rangée supérieure (ou du pavé numérique) sélectionnent la hache, l’extincteur, le Halligan et le coupe-boulon. L’outil choisi apparaît en main. Visez un point d’intervention proche et **maintenez E** jusqu’à la fin de la progression. Relâcher E, changer d’outil, s’éloigner ou ouvrir la pause interrompt le travail sans consommer de réserve.

| Outil | Point de travail après l’impact | Résultat |
| --- | --- | --- |
| 1 · Hache | Réserve de balisage dans la pièce ouest des suites 29 | Une fusée récupérée, dans la limite de six |
| 2 · Extincteur | Corbeille en feu dans les archives 28, près du passage intérieur | Foyer local éteint ; une charge consommée sur trois |
| 3 · Halligan | Armoire médicale dans la partie ouest du refuge 25 | Jusqu’à vingt points d’état physique récupérés |
| 4 · Coupe-boulon | Projecteur enchaîné dans le foyer du congrès 24 | Projecteur de secours activé |

Ces travaux sont facultatifs et chaque résultat n’est attribué qu’une fois. Un point sûr conserve les travaux achevés et les charges utilisées. Une reprise remet les outils au repos, sans rétablir un foyer déjà éteint. L’extincteur agit sur ce foyer identifié ; les fumées structurelles et les autres dangers du plateau conservent leur comportement. Le matériel se range pendant un portage, un treuillage, un rappel ou une secousse. Le dossier **J → Situation** récapitule les travaux et la réserve.

## Examiner les lieux

Douze objets peuvent être examinés du toit au refuge : registre médical, treuil, table du restaurant, passe de service, bagage, vitrage, dossier des archives, relais, casier, filtration, contrôle d’air et extincteur. Approchez-vous et regardez l’objet pour afficher son interaction, puis appuyez sur **E**.

La fiche présente sa fonction, le constat sur place, une consigne et une note de l’équipe. Son contenu tient compte de l’incident et des personnes déjà reçues au toit. La lecture met l’intervention et la radio en pause. Utilisez la molette ou **Page ↑ / Page ↓** pour défiler ; **Fermer et reprendre** ou **Échap** rend les commandes.

Ces observations restent facultatives. Les lire ne consomme aucun matériel et ne remplace pas le point de reprise. Terminez d’abord un portage, un treuillage ou une manœuvre de rappel avant d’ouvrir une fiche ; les consignes d’urgence gardent la priorité pendant la secousse.

## Lire le dossier et terminer au refuge

**J** ouvre le journal et suspend l’intervention. Les quatre onglets sont **Situation**, **Rescapés**, **Indices** et **Transmissions**. Situation indique le point sûr, les ressources, l’état des tours et les derniers échanges. Rescapés distingue une personne portée ou au treuil d’une personne effectivement reçue. Indices ne révèle que les documents déjà collectés ; Transmissions conserve les mots reçus, dans leur ordre.

Tab parcourt les contrôles ; les flèches changent d’onglet lorsqu’un onglet est sélectionné. La molette et **Page ↑ / Page ↓** permettent de lire les textes longs. Fermer le dossier ou utiliser **Échap** retourne à la partie. Cette consultation ne remplace pas votre point sûr et n’ajoute rien aux ressources ou à l’historique.

Après les trois réceptions et l’incident achevé, le relais du refuge 25 enregistre la fin de l’intervention. En cas d’erreur d’écriture, le message reste visible et vous pouvez réessayer le relais ; la séquence de fin attend un enregistrement réussi.

L’épilogue dure **quinze secondes** : poste médical du toit, relais du refuge puis Hespérie après impact. **E**, **Entrée** ou **Voir le bilan** permettent de passer la séquence. **Échap** la met en pause ; les options restent accessibles, puis **Reprendre** continue le film. Avec les mouvements réduits, chacun des trois plans garde un cadrage fixe.

Le bilan reprend les personnes sauvées, les documents recueillis, le temps et les ressources. **Compte rendu** ouvre le dossier ; sa fermeture revient au bilan. **Revoir la séquence** relit l’épilogue, sans rejouer les secours ni modifier la sauvegarde. **Revenir à l’accueil** retrouve le menu du refuge. Charger une intervention terminée ouvre directement le bilan. Le bouton **Poursuivre au congrès** ouvre maintenant la suite après enregistrement. Les anciens points sûrs terminés permettent ce choix sans rejouer les secours.

## Poursuivre vers le congrès et l’exposition

Depuis le bilan du refuge 25, choisissez **Poursuivre au congrès**. Rejoignez l’escalier de service **au nord** : il relie uniquement le 25 au 24. L’ancien escalier vers le spa reste au sud. Au congrès, cherchez la cabine d’interprétation et placez-vous face à **Léa Mercier et Idris Kaci**.

**E** donne un signe visible pour les faire suivre ; **E sur le groupe** leur demande d’attendre ou de reprendre. Restez à moins de cinq mètres et remontez à leur rythme jusqu’aux deux repères verts du refuge. Ils parcourent physiquement le foyer et l’escalier. Le rappel personnel reste indisponible tant que le groupe pris en charge n’est pas reçu. Le compteur ne passe à deux personnes au refuge qu’après leur arrivée réelle.

Une fois le groupe accueilli, redescendez au 24 puis engagez le **rappel 24–23**, dans le noyau ouest. Au 23, relevez séparément la maquette et la photographie des anciens bains. Les objets restent en place après lecture ; **J → Indices** permet de relire les constats. Le relais d’exposition transmet le compte rendu lorsque les deux pièces sont relevées et le groupe reçu.

L’accueil et le dossier indiquent votre dernier point sûr et la phase de mission. Une reprise remet une escorte interrompue en attente dans la cabine du 24 ; les personnes déjà reçues restent au refuge. Les réceptions initiales au toit, les ressources et l’état effondré d’Hespérie sont conservés. Le bouton **Poursuivre vers les commerces** du bilan du 23 ouvre maintenant les étages 22 à 20, après enregistrement du choix.

## Accompagner les personnes des commerces jusqu’au refuge 20

Depuis le bilan du 23, choisissez **Poursuivre vers les commerces**, puis empruntez l’escalier sud. Au 22, rejoignez le volet de la réserve, sélectionnez le **Halligan (3)** et **maintenez E** en regardant le point d’intervention. Le volet dégagé permet de contacter **Mina Bensaïd**. **E** la fait suivre ; utiliser E sur elle lui demande d’attendre.

Les accompagnements à pied passent par l’escalier nord **22–21**, puis l’escalier sud **21–20**. Gardez moins de cinq mètres d’écart et laissez le temps de franchir chaque volée. Le rappel 22–21 est facultatif et personnel ; les civils utilisent les escaliers et attendent pendant votre manœuvre de rappel.

Dans l’office du 21, **maintenez E au coffret de coupure** pour isoler le réchauffeur, puis **maintenez E à l’armoire de couverture**. La couverture contient le foyer local et libère le déplacement de **Théo Lenoir**. **Sofia Renard** attend au 20. Donnez à chacun le signal de suivi et conduisez-le jusqu’aux trois repères de réception. Le compteur change après l’arrivée physique de la personne, pas au premier contact.

Le **Retranché**, dans une alcôve de la galerie, peut être évité. Pour lui parler, reculez à environ 2 à 3 mètres, abaissez la lampe avec **F** et maintenez **E** en le regardant. Cette rencontre ne demande ni attaque ni soin forcé. Le maintien s’interrompt si vous relevez la lampe, perdez la visée ou réduisez trop la distance.

Relevez le **registre des livraisons au 22** et la **consigne de maintenance au 21**. Au refuge 20, rétablissez le relais en maintenant E au panneau puis utilisez son terminal. Le bilan demande trois nouvelles réceptions, le relais et les deux documents. Les cinq personnes déjà reçues au toit et au refuge 25 restent inscrites au dossier.

Une reprise replace une escorte inachevée à son contact initial, en attente ; les réceptions confirmées restent acquises. Vous pouvez remonter au relais du 25 pour enregistrer. Le bilan du 20 propose ensuite **Poursuivre vers les résidences**. Ce choix enregistre l’ouverture de la nouvelle tranche avant de donner accès aux étages 19 à 17.

## Retrouver Jeanne, Marc et Inès

Depuis le bilan du refuge 20, choisissez **Poursuivre vers les résidences**. L’escalier **nord 20–19** mène à l’appartement de **Jeanne Morel**, au nord-est du 19. Visez le point près du fauteuil et **maintenez E** pour préparer son départ. Vous pouvez ensuite lui donner la consigne de suivi. Jeanne marche lentement : restez à moins de cinq mètres et laissez-lui le temps de tourner et de franchir chaque volée.

Pour rejoindre **Marc Morel** au 18, repérez l’ouverture du duplex et son appui inférieur, puis utilisez le **rappel personnel bleu 19–18**. Les personnes accompagnées attendent pendant votre manœuvre ; aucune ne prend la corde. Depuis le plateau du 18, rejoignez la grille de service au sud, sélectionnez le **Halligan (3)** et **maintenez E au loquet**. Une fois la grille ouverte, le service offre un retour à pied vers le 19 puis le refuge 20. Marc attend dans la partie sud-est du duplex.

L’escalier **nord 18–17** rejoint les télécommunications. **Inès Vidal** se trouve dans le local protégé au sud-ouest. Donnez à chaque personne la consigne de suivi, puis accompagnez-la par les escaliers jusqu’aux **trois repères ouest du refuge 20**. Ils sont distincts des places de Mina, Théo et Sofia. Le compteur confirme chaque personne après son arrivée physique, avec un appui stable. **E** permet aussi de demander à une personne d’attendre sur le plateau.

Les trois constats se trouvent au **19** dans le message des visites, au **18** près de la fissure et au **17** auprès des enregistrements. Regardez chaque support et utilisez **E** pour le consigner. Le dossier **J → Indices** conserve uniquement les textes déjà relevés. Une apparition distante peut être observée au 17 ; elle n’est pas un objectif obligatoire.

## Vérifier le relais et transmettre le bilan au 17

Au 17, **maintenez E** sur l’alimentation secourue, puis sur la plaque du local de commande pour relever les données de routage. La destination et la référence restent consultables dans le dossier après ce relevé. Approchez la console et appuyez sur **E** : le formulaire suspend la mission, la radio et les escortes pendant votre lecture.

Recopiez la **destination** et la **référence** indiquées sur la plaque dans les deux champs, puis choisissez **Vérifier le routage**. Une erreur laisse le formulaire ouvert et permet de corriger les champs. **Revenir à la plaque** ou **Échap** rend les commandes sans valider la liaison. Après une bonne vérification, **maintenez E face à la console** pour établir l’émission. Relâcher l’action après l’avoir commencée, perdre la visée, changer d’outil ou ouvrir la pause interrompt le maintien ; une interruption vous permet de recommencer.

Lorsque Jeanne, Marc et Inès sont tous reçus au **refuge 20**, revenez au **17**. Le terminal **Bilan du secteur 19–17** exige aussi le relais vérifié et les trois constats. **E** transmet le compte rendu ; la clôture attend un enregistrement réussi. Le dossier et le bilan gardent les **onze réceptions** de la mission. Le parcours de cette version s’arrête au 17.

## Commandes essentielles

| Action | Touche |
| --- | --- |
| Marcher et emprunter les escaliers | ZQSD ou WASD |
| Regarder | Souris ou flèches |
| Interagir, examiner, engager ou quitter un rappel | E |
| Descendre / remonter sur corde | S / Z ou W |
| Équilibrer le rappel | Q/A et D |
| Progression précise sur corde | Ctrl avec une direction |
| Descente rapide sur corde | Maj + S |
| Verrouiller / libérer le descendeur | Espace, sur corde |
| Stabiliser seize secondes | X, sur corde |
| Courir / s’accroupir / sauter à pied | Maj / Ctrl / Espace |
| Hache / extincteur / Halligan / coupe-boulon | 1 / 2 / 3 / 4 (touches physiques ou pavé numérique) |
| Utiliser le bon outil sur un point de travail visé | Maintenir E |
| Lampe / fusée | F / G |
| Radio / journal à quatre onglets | R / J |
| Changer d’onglet du journal | Flèches sur un onglet ; Tab pour parcourir les contrôles |
| Défiler dans une fiche ou le dossier | Molette / Page ↑ / Page ↓ |
| Fermer une fiche et reprendre | Échap ou bouton de fermeture |
| Passer l’approche ou l’épilogue | E, Entrée ou bouton affiché |
| Pause et options | Échap |

L’aide **Commandes et mission**, accessible depuis l’accueil et la pause, reprend l’itinéraire et les commandes contextuelles. Espace sert au saut à pied et au verrouillage sur la corde.

La pause fige l’effondrement et le temps de stabilisation. Les mouvements de caméra sont réduits par défaut ; les éclairs lumineux sont facultatifs. Les réglages sont accessibles avant la partie et conservés sur cet appareil. **Revoir l’introduction** relance la signature sans modifier la sauvegarde.

## Points sûrs et reprise

Un enregistrement local est demandé au départ, après les treuillages, au refuge et avant/après l’incident. Si une demande survient sur une corde, pendant un raccordement ou dans un escalier, elle attend le prochain plateau stable, avec un appui sous les pieds. Elle ne crée pas de reprise suspendue ou à mi-hauteur. Le point sûr précédent reste la référence tant que cette écriture n’a pas réussi.

Si vous quittez pendant l’effondrement, la reprise revient au point sûr qui le précède. Après stabilisation, les dégâts sont conservés. **Déployer Alpha** confirme une nouvelle intervention et crée un point sûr ; **Reprendre l’intervention** poursuit le précédent. Les anciennes sauvegardes valides de schémas 1 à 5 sont validées puis migrées en mémoire vers le schéma 6 ; leur lecture ne réécrit pas le fichier. Le journal conserve les 32 dernières transmissions et reste accessible dans le bilan final. Le temps et les sous-titres de l’épilogue ne sont pas ajoutés à cette sauvegarde ; sa relecture ne réécrit pas le fichier. Les données ne sont pas envoyées en ligne.

## Portée de cette version

Prototype solo sous **Godot 4.7.2**, du toit 31 au relais du 17, avec onze identités de secours et seize liaisons locales. Les extensions s’ouvrent depuis les bilans du 25, du 23 et du 20. Les hélicoptères, personnages et une partie des décors restent procéduraux. Les catalogues actifs réunissent quarante modèles importés et douze albedos originaux ; les douze modèles résidentiels et les deux matières du 17–19 complètent les lots précédents.

La campagne complète, les niveaux 16 à 1, les laboratoires profonds, l’Enfer, Alma, l’intérieur d’Hespérie et le futur portage UE5 restent à produire. Le Retranché et le Répondant n’ont pas de système de combat. La corde suit des segments locaux prédéfinis. La préparation de Jeanne reste une action de secours abstraite.

Les contrôles finaux de la candidature sont en cours. Le chargement des ressources d’un export dans Godot Linux ne constitue pas une partie sur un PC Windows ni une exécution WebAssembly dans un navigateur. [L’état de livraison](https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/ETAT_DE_LIVRAISON.md) conserve les résultats et leurs limites ; `EXPORTS.md` décrit les formats prévus.

[Projet, sources et Bible sur GitHub](https://github.com/darknigthmare/The-Descents/tree/feat/live-tower-collapse)

Le projet éditable contient les codes, actifs, tests, guides et documents. Les sources Blender accompagnent les catalogues de modèles ; la Bible intégrale v0.9 et les suppléments v0.10, v0.12 et v0.13 restent distincts. Les médias et résultats antérieurs gardent leur version d’origine. Les licences du moteur et de ses composants figurent dans `GODOT_LICENSES.txt` ; les notices Open Sans accompagnent le paquet Windows.

## Réglages et présentation conservés

Accueil → Options et confort, ou Échap → Options et confort pendant l’intervention. Volume 0–100 %, sensibilité ×0,25–×2,5, champ de vision 65–100° et regard vertical inversé sont appliqués immédiatement. Fermer ce panneau en partie retourne à la pause ; Reprendre rend le contrôle. Les réglages restent distincts du point sûr.

Le portage montre le harnais et les mains d’Alex. Le treuil conserve ses cinq secondes, puis l’équipe prend la personne en charge au toit. La pluie et la mer suivent la pause ; les mouvements réduits conservent une ambiance fixe. Le matériel de rappel possède sa propre présentation, liée à la vitesse, au verrou et à l’état d’attache.

## Rendu et performances

Le profil cinématique utilise le moteur **Forward+** de Godot : SDFGI pour les surfaces fixes opaques, SSIL, SSAO, réflexions en espace écran, brouillard volumétrique et glow modéré. Il vise des rebonds et une profondeur lumineuse proches de l’intention visuelle de Lumen ; il ne reproduit pas toutes ses capacités. Les personnages, outils, appareils et la tour mobile ne sont pas des occluders SDFGI.

Le lanceur **Compatibilité** garde les textures, modèles, lumières directes, ombres et brouillard classique, avec un coût réduit. Le Web choisit automatiquement ce moteur. Le changement de moteur se fait au lancement. Aucun minimum matériel ni nombre d’images par seconde sur carte graphique dédiée n’est certifié par les contrôles automatisés. Les captures natives décrites dans les rapports montrent le moteur réellement utilisé.
