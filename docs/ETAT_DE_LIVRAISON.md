# État de livraison — version 0.4

**24 novembre 2026 — version 0.4.0.** Cette livraison poursuit le prototype jouable avec une direction cinématique pour le démarrage, un accueil lié à la progression et une bible de production développée. Le jeu livré fonctionne sous Godot ; les assets restent des volumes de prototype. La campagne complète et le portage Unreal Engine 5 sont documentés comme travail à produire.

## Contenu effectivement livré

| Élément | État réel de la version 0.4 |
| --- | --- |
| Signature du studio | Séquence de 15 s : couronne, « Darknigthmare Kingdoms Games Productions », « présente », « un jeu de Darknigthmare », puis titre. Les références sont relevées dans quatre autres dépôts de l’auteur. |
| Accueil | Décor 3D reconstruit à partir du dernier checkpoint validé : approche, toit, étages 30–25 ou refuge terminé. Les dégâts correspondent à l’état déjà enregistré. Aucun temps de mission ni nouvelle sauvegarde n’est consommé par l’attente au menu. |
| Navigation | Reprendre, nouvelle intervention avec préparation de la graine, dossier de mission adapté, commandes, options, revoir l’introduction et quitter sur ordinateur. Souris, focus clavier et fermeture des modales avec Échap. |
| Introduction en jeu | 28 s, quatre plans de 7 s : Nacre, les tours, les équipes et le poste d’Aube ; quatre transmissions sous-titrées. Passage par E, Entrée ou bouton ; pause et reprise sans avancer les événements. La caméra donne ensuite le contrôle au joueur. |
| Cohérence du décor | Deux tours droites et façades fermées avant l’incident. Les aides flottantes de gameplay sont absentes des vues du menu et de la cinématique ; elles restent disponibles dans la caméra du joueur. |
| Confort | Audio, caméra réduite, éclairs et intro au lancement mémorisés dans un fichier de préférences distinct. Plans fixes avec caméra réduite, éclairs désactivés par défaut, sous-titres permanents. |
| Audio | Onze sons procéduraux originaux, dont thème du menu, rotors et ponctuation de signature. Gestion de l’arrêt, de la pause et des changements de volume ; aucun doublage enregistré. |
| Tranche jouable | Solo, vue subjective, toit et six étages 30–25. Trois victimes, trois archives, deux réserves, rappel guidé, balises, treuillage et refuge final. |
| Incident | Déclenchement à la baie Est du 29 après Ana treuillée et départ des appareils ; regard continu de 0,8 s ou interaction. Alerte 8 s, secousse 6 s, basculement 7 s et impact 4 s. Le joueur conserve son contrôle. |
| Conséquences | Hespérie inclinée contre Aube, vitres détruites au contact, poussière dissipée, éclairage d’urgence et détour au 28. L’obstacle attend que sa zone soit libre avant d’activer sa collision. |
| Équipes et sauvetages | Retrait visuel de Bravo durant la crise ; Ana, Samuel et Nora apparaissent nominativement à la réception médicale du toit après confirmation de leur treuillage. |
| Communications | File radio avec priorités, historique, dédoublonnage, écho au 27 et vérifications de liaison. Journal des transmissions et bilan des sauvetages accessibles pendant l’intervention et après sa fin. |
| Persistance | Schéma JSON 3, migrations des versions 1 et 2, validation stricte et remplacement atomique. Les étapes transitoires reviennent au point sûr précédent ; un impact stabilisé reste acquis. |
| Bible | 119 pages A4 réunissant dix sources Markdown et près de 59 000 mots. Univers, intrigue, personnages et motivations, trente étages, régions annexes, gameplay détaillé, scènes, communications, 52 props, E00 et dix archétypes de campagne, statistiques, états, contre-jeux et critères de validation. Markdown modifiable, Word et PDF. |
| Distribution | Exports Windows x64 et Web reconstruits ; ZIP Windows et sources ; scripts de fabrication, captures et preuves de vérification conservés dans le dépôt. |

La reprise 0.3 avait perdu ses fichiers temporaires avant publication. Ses fonctions ont été reconstruites depuis la base 0.2 et les preuves conservées, puis testées à nouveau. La 0.4 ne prétend pas restituer les octets de cet ancien travail ; [REPRISE_V0.3.md](REPRISE_V0.3.md) reste le relevé historique.

La sauvegarde garde le nom `save_v1.json` pour retrouver les anciennes installations, mais son contenu utilise le schéma 3. Revoir la signature du studio conserve la partie et restaure son contexte à la sortie. Une nouvelle partie ne remplace le point sûr qu’après le déploiement confirmé.

## Vérification automatisée des sources

**2 037 contrôles réussis dans quatorze suites**, exécutées sur l’arbre figé avec Godot 4.7.2. Le [rapport VERIFICATION.json](validation/v0.4/VERIFICATION.json) contient les empreintes des sources, le résultat de chaque suite et les journaux associés. Les contrôles des paquets exportés sont rapportés séparément pour ne pas gonfler ce total.

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

Les deux suites de déplacement représentent 231 segments physiques : 150 sur les parcours initiaux et 81 sur l’incident. Les six blocages attendus font partie des essais de détour, sans être ajoutés au nombre de segments. Les autres tests de mission peuvent téléporter le personnage pour isoler une règle. Ces essais ne constituent ni une partie humaine complète ni une mesure de difficulté.

## Vérification des livrables

- **Captures natives** : treize vues du rendu Godot Compatibility, produites dans GitHub Actions via Xvfb/Mesa à 1440 × 900, avec sauvegarde et préférences d’essai isolées. Les cadrages et interfaces sont revus visuellement ; le protocole et les limites sont dans [CAPTURES_V0.4.md](CAPTURES_V0.4.md).
- **Paquets** : le script externe charge les ressources embarquées dans l’exécutable Windows et le paquet Web depuis un répertoire vide. Les deux paquets passent chacun 18 contrôles, soit **36 contrôles séparés**. Ils vérifient la version, les séquences, les ressources nécessaires et le cycle de sauvegarde, avec Godot sous Linux. Le [rapport des paquets](validation/v0.4/EXPORTED_PACK_VERIFICATION.json) enregistre leurs empreintes et les journaux.
- **Archives** : intégrité ZIP, absence de doublons et de chemins dangereux, correspondance de chaque fichier source, en-tête PE x64, tailles Web et SHA256. La commande reproductible est `python tools/verify_release.py`.
- **Documents** : Word et PDF de 119 pages produits depuis les dix mêmes sources de conception. Toutes les pages ont été inspectées dans le rendu initial ; après corrections, les 108 corps identiques ont été comparés pixel par pixel et les onze pages modifiées ont été relues. Le [rapport documentaire](validation/v0.4/DOCUMENT_REVIEW.json) conserve la couverture, les corrections et les empreintes des formats finaux.

Les exports et leur provenance sont détaillés dans [EXPORTS.md](EXPORTS.md). L’exécutable Windows n’a pas été exécuté sous Windows dans cet environnement ; le rendu de l’export Web dans un navigateur n’a pas été vérifié. Les captures montrent le moteur natif Linux, avec des états préparés.

## Limites de production et suites prévues

La présentation pose une direction cinématique, avec interfaces, rythmes et transitions implémentés. Les personnages, bâtiments et hélicoptères restent géométriques ; aucune qualité visuelle finale AAA, performance minimale ou durée commerciale n’est certifiée. Les appareils sont montrés sur leurs toits pendant l’approche, puis décollent dans la mission ; il n’existe pas encore de scène complète d’atterrissage avec animations de débarquement.

La campagne des trente étages, Alma, la piscine, l’exploration intérieure d’Hespérie, les cavernes, le bunker, le niveau 666, les fins et Mountain Hole sont conçus mais ne sont pas jouables dans la tranche actuelle. Les dix archétypes E01–E10 ont des fiches de production ; seule l’entité locale du spa E00 possède une logique implémentée. Les valeurs proposées doivent être équilibrées par des tests joueurs.

Le rappel est guidé, sans simulation complète de corde ; le transport des victimes est abstrait, sans IA d’escorte ni animation de portage finalisée. L’accroupissement réduit la caméra et la vitesse mais pas la capsule. L’effondrement est une séquence de géométries préparées, pas un calcul de résistance structurelle. Aucun multijoueur, doublage, remappage complet ou portage UE5 n’est inclus.

Le prochain jalon de production consiste à faire essayer cette intervention, vérifier la lecture de la baie et du détour, puis remplacer les volumes de référence par des assets et animations définitifs. Les fiches de props, d’ennemis, de scènes et d’étages définissent le travail et ses critères d’acceptation.
