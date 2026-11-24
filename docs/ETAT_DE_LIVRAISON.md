# État de livraison — version 0.5

**24 novembre 2026 — version 0.5.0.** Cette livraison poursuit l’ouverture cinématique avec une arrivée animée des deux hélicoptères, le déploiement des équipes, une présentation 3D plus détaillée et douze observations contextuelles dans le parcours. L’accueil reste lié à la progression. Le jeu livré fonctionne sous Godot avec des géométries procédurales de prototype ; la campagne complète, les assets définitifs et le portage Unreal Engine 5 sont documentés comme travail à produire.

## Contenu effectivement livré

| Élément | État réel de la version 0.5 |
| --- | --- |
| Signature du studio | Séquence de 15 s : couronne, « Darknigthmare Kingdoms Games Productions », « présente », « un jeu de Darknigthmare », puis titre. Les références sont relevées dans quatre autres dépôts de l’auteur. |
| Accueil | Décor 3D reconstruit à partir du dernier checkpoint validé : approche, toit, étages 30–25 ou refuge terminé. Les dégâts correspondent à l’état déjà enregistré. Aucun temps de mission ni nouvelle sauvegarde n’est consommé par l’attente au menu. |
| Navigation | Reprendre, nouvelle intervention avec préparation de la graine, dossier de mission adapté, commandes, options, revoir l’introduction et quitter sur ordinateur. Souris, focus clavier et fermeture des modales avec Échap. |
| Introduction en jeu | 28 s, quatre plans de 7 s : Nacre, les tours, les équipes et le poste d’Aube ; quatre transmissions sous-titrées. Les deux appareils approchent, se posent, ouvrent leurs portes et déposent les équipes. Les membres gagnent leur poste avec des poses de marche. Passage par E, Entrée ou bouton ; pause et reprise sans avancer les événements. La caméra donne ensuite le contrôle au joueur. |
| Continuité de l’arrivée | Poses calculées depuis le temps absolu de la séquence, rotors et souffle au toit, cabines fermées avant la prise en main. La fin naturelle, le passage immédiat et la reprise du point sûr initial donnent le même état. Le temps d’introduction ne fait pas avancer le départ opérationnel des appareils. Une restauration après l’incident ne remonte pas Bravo sur son toit. |
| Présentation du monde | Hélicoptères avec cabines, portes coulissantes, patins et rotors de queue ; secouristes articulés avec casques, visières, sacs et radios ; poste médical, bouteilles, treuil, console et balisage du toit. Phare, dôme et marina renforcent la lecture de la côte. Ces détails ne créent ni collision supplémentaire ni tirage aléatoire dans la génération. |
| Observations de terrain | Douze objets examinables du toit au 25 : rôle, constat contextuel, consigne et note d’équipe. Même étage, portée de 2,4 m, visée et rayon de visibilité libre. Une action de secours à moins de 1,5 m garde la priorité. Lecture en pause, défilement au clavier, fermeture par bouton ou Échap et consultation répétable. Les constats suivent l’impact et les sauvetages confirmés, sans ajout de collecte ou de condition de victoire. |
| Cohérence du décor | Deux tours droites et façades fermées avant l’incident. Les aides flottantes de gameplay sont absentes des vues du menu et de la cinématique ; elles restent disponibles dans la caméra du joueur. |
| Confort | Audio, caméra réduite, éclairs et intro au lancement mémorisés dans un fichier de préférences distinct. Plans fixes avec caméra réduite, éclairs désactivés par défaut, sous-titres permanents. |
| Audio | Onze sons procéduraux originaux, dont thème du menu, rotors et ponctuation de signature. Gestion de l’arrêt, de la pause et des changements de volume ; aucun doublage enregistré. |
| Tranche jouable | Solo, vue subjective, toit et six étages 30–25. Trois victimes, trois archives, deux réserves, rappel guidé, balises, treuillage et refuge final. |
| Incident | Déclenchement à la baie Est du 29 après Ana treuillée et départ des appareils ; regard continu de 0,8 s ou interaction. Alerte 8 s, secousse 6 s, basculement 7 s et impact 4 s. Le joueur conserve son contrôle. |
| Conséquences | Hespérie inclinée contre Aube, vitres détruites au contact, poussière dissipée, éclairage d’urgence et détour au 28. L’obstacle attend que sa zone soit libre avant d’activer sa collision. |
| Équipes et sauvetages | Retrait visuel de Bravo durant la crise ; Ana, Samuel et Nora apparaissent nominativement à la réception médicale du toit après confirmation de leur treuillage. |
| Communications | File radio avec priorités, historique, dédoublonnage, écho au 27 et vérifications de liaison. Journal des transmissions et bilan des sauvetages accessibles pendant l’intervention et après sa fin. |
| Persistance | Schéma JSON 3, migrations des versions 1 et 2, validation stricte et remplacement atomique. Les étapes transitoires reviennent au point sûr précédent ; un impact stabilisé reste acquis. |
| Bible | 127 pages A4 réunissant dix sources Markdown et 61 731 mots sources. Univers, intrigue, personnages et motivations, trente étages, régions annexes, gameplay détaillé, scènes, communications, 52 props, E00 et dix archétypes de campagne, statistiques, états, contre-jeux et critères de validation. La 0.5 ajoute le découpage précis de la dépose, les modèles et les douze observations avec leurs règles. Markdown modifiable, Word et PDF. |
| Distribution | Exports Windows x64 et Web reconstruits ; ZIP Windows et sources ; scripts de fabrication, captures et preuves de vérification conservés dans le dépôt. |

La 0.5 prolonge la livraison 0.4 dans la même branche de travail. Les archives 0.1, 0.2 et 0.4 sont conservées. La reprise 0.3 avait perdu ses fichiers temporaires avant publication ; la reconstruction réalisée en 0.4 et ses limites restent consignées dans [REPRISE_V0.3.md](REPRISE_V0.3.md).

La sauvegarde garde le nom `save_v1.json` pour retrouver les anciennes installations, mais son contenu utilise le schéma 3. Revoir la signature du studio conserve la partie et restaure son contexte à la sortie. Une nouvelle partie ne remplace le point sûr qu’après le déploiement confirmé.

## Vérification automatisée des sources

**3 299 contrôles réussis dans dix-huit suites**, exécutées sur les sources figées avec Godot 4.7.2. Le [rapport VERIFICATION.json](validation/v0.5/VERIFICATION.json) contient les empreintes des sources, le résultat de chaque suite et les journaux associés. Les contrôles des paquets exportés sont rapportés séparément pour ne pas gonfler ce total.

| Suite | Contrôles | Portée |
| --- | ---: | --- |
| Génération | 820 | 200 graines, déterminisme, invariants et couverture des dispositions. |
| Sauvegarde | 269 | Schéma 3, migrations strictes depuis 1 et 2, historique radio, atomicité et refus des données corrompues. |
| Mission | 83 | Rappel, archives, trois sauvetages confirmés, caisses, checkpoints et condition de fin. |
| Trajets physiques | 205 | 150 segments au contrôleur réel et 27 approches d’objectifs sur trois graines. |
| Directeur de l’incident | 27 | Déclenchement unique, durées, grandes frames et restauration stable. |
| Intégration de l’incident | 63 | Conditions d’observation, appareils, transports, pause, reprise et géométrie persistante. |
| Trajets après incident | 130 | 81 segments, baie du 29, détour du 28, retour en portant, blocages attendus et zone de chute occupée. |
| Effets et façade | 29 | Poussière, pause, enseigne, vitrage extérieur intact, orientation et retrait au contact. |
| Réactions des équipes | 27 | Retrait déterministe de Bravo, réception nominative des victimes et absence de nouvelles collisions. |
| Directeur radio | 33 | Priorités, file bornée, dédoublonnage et historique. |
| Intégration radio | 59 | Silences, écho au 27, confirmations, pause, journal et persistance. |
| Directeur des cinématiques | 109 | Durées de 15 et 28 secondes, cartons, quatre plans, quatre transmissions, caméra et contexte des points sûrs. |
| Préférences | 80 | Types stricts, valeurs de confort par défaut, écriture atomique et restauration. |
| Accueil et introduction | 103 | Boutons réels, clavier, modales, reprise, options, passage, pause, temps de mission et transfert au joueur. |
| Dépose et déploiement | 126 | Échantillonnage absolu des trajectoires, chronologie des portes et des équipes, pose finale, pause, passage et protection du retrait de Bravo. |
| Intégration des observations | 125 | Interaction réelle, règles de priorité et de visibilité, pause du monde et de l’audio, fermeture, reprise et absence d’écriture de sauvegarde. |
| Catalogue des observations | 477 | Douze identifiants, constats avant et après impact, personnes réellement reçues, portée, visée, occlusion et accès physique aux points de lecture. |
| Présentation du monde | 534 | Modèles détaillés, matériaux, hélicoptères, membres articulés, déploiement et conservation des contraintes de collision et de génération. |

Les deux suites de déplacement représentent 231 segments physiques : 150 sur les parcours initiaux et 81 sur l’incident. Les six blocages attendus font partie des essais de détour, sans être ajoutés au nombre de segments. Les autres tests de mission peuvent téléporter le personnage pour isoler une règle. Ces essais ne constituent ni une partie humaine complète ni une mesure de difficulté.

## Vérification des livrables

- **Captures natives** : dix-sept vues du rendu Godot Compatibility, produites dans GitHub Actions via Xvfb/Mesa à 1440 × 900, avec sauvegarde et préférences d’essai isolées. Les cadrages, modèles, sous-titres et fiches de lecture sont revus visuellement ; le protocole et les limites sont dans [CAPTURES_V0.5.md](CAPTURES_V0.5.md).
- **Paquets** : le script externe charge les ressources embarquées dans l’exécutable Windows et le paquet Web depuis un répertoire vide. Les deux paquets passent chacun **28 contrôles**, soit **56 contrôles distincts**. Ils vérifient la version, les séquences, la nouvelle dépose, les observations, les ressources nécessaires et le cycle de sauvegarde, avec Godot sous Linux. Le [rapport des paquets](validation/v0.5/EXPORTED_PACK_VERIFICATION.json) enregistre les résultats, les empreintes et les journaux.
- **Archives** : intégrité ZIP, absence de doublons et de chemins dangereux, correspondance de chaque fichier source, en-tête PE x64, tailles Web et SHA256. La commande reproductible est `python tools/verify_release.py`.
- **Documents** : Word et PDF de 127 pages produits depuis les dix mêmes sources de conception, avec 1 492 paragraphes et 44 tableaux. Chaque page a été inspectée visuellement ; après ajustement des tableaux et clarification des règles d’interaction, les pages identiques ont été vérifiées par leur empreinte PNG complète et les pages modifiées relues. Le [rapport documentaire](validation/v0.5/DOCUMENT_REVIEW.json) conserve cette couverture, les corrections et les empreintes des formats finaux.

Les exports et leur provenance sont détaillés dans [EXPORTS.md](EXPORTS.md). L’exécutable Windows n’a pas été exécuté sous Windows dans cet environnement ; le rendu de l’export Web dans un navigateur n’a pas été vérifié. Les captures montrent le moteur natif Linux, avec des états préparés.

## Limites de production et suites prévues

La présentation pose une direction cinématique, avec interfaces, rythmes et transitions implémentés. L’arrivée montre maintenant l’approche, le posé, les portes et le déploiement des équipes. Les modèles sont toutefois procéduraux : aucune capture de mouvement, animation faciale, qualité visuelle finale AAA, performance minimale ou durée commerciale n’est certifiée. Les poses des membres sont animées par le code ; elles ne remplacent pas un rig et un jeu d’animations de production.

Les douze observations rendent le décor consultable, sans ajouter douze nouveaux mécanismes. Le manomètre ne pilote pas encore une pompe, le poste incendie ne donne pas un extincteur utilisable et le boîtier radio ne répare pas la liaison. Leurs fiches précisent ce qui est observable et ce qui reste inconnu. La sélection des interactions de mission historiques reste fondée sur la proximité ; le rayon de visibilité introduit en 0.5 s’applique aux observations.

La campagne des trente étages, Alma, la piscine, l’exploration intérieure d’Hespérie, les cavernes, le bunker, le niveau 666, les fins et Mountain Hole sont conçus mais ne sont pas jouables dans la tranche actuelle. Les dix archétypes E01–E10 ont des fiches de production ; seule l’entité locale du spa E00 possède une logique implémentée. Les valeurs proposées doivent être équilibrées par des tests joueurs.

Le rappel est guidé, sans simulation complète de corde ; le transport des victimes est abstrait, sans IA d’escorte ni animation de portage finalisée. L’accroupissement réduit la caméra et la vitesse mais pas la capsule. L’effondrement est une séquence de géométries préparées, pas un calcul de résistance structurelle. Aucun multijoueur, doublage, remappage complet ou portage UE5 n’est inclus.

Le prochain jalon de production consiste à faire essayer cette intervention, vérifier la lecture de la baie et du détour, puis remplacer les volumes de référence par des assets et animations définitifs. Les fiches de props, d’ennemis, de scènes et d’étages définissent le travail et ses critères d’acceptation.
