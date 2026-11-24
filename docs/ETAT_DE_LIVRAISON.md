# État de livraison — version 0.2

**Date : 24 novembre 2026.** Cette livraison fournit un prototype jouable et une proposition de campagne complète. Les documents de conception décrivent volontairement davantage de contenu que ce qui est codé.

## Ce qui est livré

| Élément | État réel |
| --- | --- |
| Bible et catalogue | Univers original, personnages, intrigue, quatre fins, trente étages, tour Hespérie, souterrains, bunker, niveau 666 et extension Mountain Hole décrits |
| Document Word | Bible, catalogue et spécifications techniques réunis ; fabrication reproductible avec `tools/build_bible.py` |
| Prototype | Godot 4.7.2, solo, vue subjective, toit et étages 30 à 25 |
| Arrivée | Approche de six secondes, passage avec E, deux tours droites, deux hélicoptères et équipes Alpha/Bravo visibles sur leurs toits |
| Effondrement | Déclenchement à la baie Est du 29 après Ana treuillée et départ des appareils ; regard continu de 0,8 s ou interaction explicite ; alerte 8 s, secousse 6 s, chute 7 s, impact 4 s |
| Conséquences | Inclinaison d’Hespérie contre Aube, vitres détruites, débris, éclairage d’urgence, détour au noyau du 28, silence de Bravo et signal d’Aube dégradé |
| Boucle de mission | Trois victimes à retrouver, transport abstrait au harnais, treuillage visible et confirmation, refuge final |
| Exploration | Trois indices, deux caisses, radio, journal, dangers et dispositions variant selon la graine |
| Rappel | Déplacement guidé dans le puits, balancement amorti, remontée, sortie aux paliers et ancrage secondaire consommable |
| Horreur | Silhouette au spa, dialogue radio ambigu, stress, lampe pour ralentir la silhouette et fusées pour la repousser |
| Persistance | Schéma JSON v2, migration stricte des sauvegardes v1, points sûrs avant/après l’incident, remplacement atomique et refus des données corrompues |
| Confort | Pause, sous-titres, mouvement de caméra réduit par défaut, éclairages intermittents facultatifs, son désactivable |
| Windows | Export 0.2 reconstruit, exécutable x64 avec ressources embarquées ; lancement sur Windows restant à vérifier |
| Web | Export 0.2 reconstruit sans threads, rendu Compatibility, distribution `dist/` actualisée ; rendu navigateur restant à vérifier |

Pendant l’incident, le joueur conserve le contrôle et aucune mort automatique n’est imposée. Les sauvetages déjà confirmés restent acquis. Le passage du 28 attend que le joueur quitte sa zone de chute avant d’activer son obstacle ; une fois posé, cet obstacle reste solide. Le noyau intérieur, le puits et le refuge demeurent accessibles.

Une interruption pendant une phase transitoire revient au checkpoint précédant la scène. Une reprise après stabilisation conserve les dégâts. Le fichier reste nommé `save_v1.json` pour permettre la migration : les parties v1 non terminées reprennent en état `intact`, les parties terminées en état `aftermath`.

## Vérifications exécutées

Les huit suites suivantes ont été exécutées avec succès sur les sources de cette livraison, sous Godot 4.7.2 : **1 452 contrôles au total**. Il s’agit de contrôles automatisés, pas de parties humaines.

| Suite | Contrôles | Ce qu’elle vérifie |
| --- | ---: | --- |
| Génération | 820 | 200 graines, déterminisme, indépendance des tirages, invariants, couverture des variantes et rejet de définitions invalides |
| Sauvegarde | 107 | Aller-retour v2, migration stricte v1, conservation des fichiers lors des erreurs, état stable de l’incident, bornes, doublons et corruption |
| Mission | 83 | Rappel, trois indices, trois sauvetages confirmés, caisses utilisables une fois, pause, checkpoints et condition de fin |
| Trajets physiques | 205 | 150 segments avec `move_and_slide`, 27 approches d’objectifs et retours, trois graines couvrant les trois dispositions de chaque étage |
| Directeur d’effondrement | 27 | Déclenchement unique, durées, transition lors des grandes frames, conservation du temps restant et restaurations stables |
| Intégration de l’incident | 63 | Deux appareils, arrivée, conditions de progression et de regard, protection des transports, pause, reprise, géométrie persistante et fin de mission |
| Trajets de l’incident | 130 | 81 segments physiques, baie 29 avant/après, détour 28 avec retour en portant, six blocages attendus et trois sorties depuis une zone de chute occupée |
| Effets après impact | 17 | Dissipation de la poussière, pause/reprise sur de vraies frames, chargement d’un décor stabilisé et retrait de l’enseigne au contact |

Les deux suites physiques représentent **231 segments au total** : 150 sur les parcours existants et 81 ciblant les changements. Les six blocages attendus font partie des essais du détour ; ils ne constituent pas six segments supplémentaires à ajouter. Les graines 3, 47 et 69 couvrent les trois dispositions des étages 28 et 29.

Les tests de mission et d’intégration déplacent directement le joueur pour isoler les règles. Les tests de trajets utilisent la capsule et les collisions, avec placement direct uniquement au début de chaque scénario. Ils ne démontrent pas toutes les trajectoires libres possibles ni l’équilibre du jeu.

## Contrôles de livraison

| Contrôle | État de la version 0.2 |
| --- | --- |
| Vue native | Menu, début d’intervention, toit et pause inspectés dans Godot. Sept vues supplémentaires de la vraie scène et de son HUD ont été capturées avec des états préparés : arrivée, baie intacte, réplique, basculement, impact, après-choc et détour. Ce contrôle ne constitue pas une partie humaine complète. |
| Export Windows | Export Godot terminé avec succès ; exécutable PE32+ x86-64 et ressources embarquées. Exécution sur Windows non testée. |
| Export Web | Export sans threads terminé avec succès ; fichiers recopiés dans `dist/`. Rendu 3D navigateur de cette version non testé. |
| Archives | ZIP Windows et sources 0.2 reconstruits, intégrité ZIP et contenu vérifiés ; sommes SHA256 enregistrées dans `releases/SHA256SUMS.txt`. |
| Documents | Word et PDF v0.2 générés ; les 65 pages A4 ont toutes été inspectées visuellement. |

Les [captures natives de la séquence](CAPTURES_V0.2.md) sont conservées avec leur protocole. Les vues préparées utilisent une sauvegarde de contrôle isolée et n’écrasent pas la partie du joueur.

L’environnement de fabrication est Linux. L’exécutable Windows 0.2 n’y a pas été lancé sous Windows. Les archives 0.1 sont conservées comme historique ; la distribution recommandée est la 0.2. Les détails de construction figurent dans [EXPORTS.md](EXPORTS.md).

## Limites connues

- La campagne complète, Alma, la chute dans la piscine, l’exploration intérieure d’Hespérie, les cavernes, le bunker et les fins sont conçus, mais non jouables dans cette version.
- Aucun multijoueur ni portage Unreal Engine 5 n’est inclus. Le document de portage est une proposition d’architecture.
- Le rappel est un contrôleur guidé ; il ne simule pas une corde articulée, les frottements ou une chaîne d’assurage réaliste.
- Les victimes utilisent des silhouettes géométriques. Le portage est abstrait ; l’animation complète et l’IA d’escorte restent à développer.
- S’accroupir réduit la caméra et la vitesse, sans raccourcir la capsule de collision.
- L’effondrement est animé en temps réel à partir de géométries et d’états préparés. Il ne simule pas intégralement la résistance structurelle, les débris ou les fluides.
- Les mouvements de l’entité sont locaux au spa ; le jeu ne possède pas encore le directeur d’horreur complet décrit dans la bible.
- Les interfaces sont françaises. Il n’y a pas de doublage, de manette configurée ni de remappage complet des commandes.
- Les durées proposées dans la bible sont des objectifs de conception. Aucun test joueur ne confirme encore la durée, la difficulté ou la performance sur une configuration minimale.

## Prochain jalon recommandé

Faire essayer cette intervention de six étages, vérifier que la baie attire naturellement le regard et que le détour reste lisible après l’impact, puis renforcer la tranche avec les assets, animations et sons définitifs. Le document UE5 décrit une proposition de portage ; aucun portage n’est livré ici.

Les commandes de vérification se trouvent dans le README. Les détails de distribution et de provenance des modèles d’export se trouvent dans `EXPORTS.md`.
