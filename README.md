# The Tower Descent

**Version 0.7 — dossier de mission, bilan au refuge et épilogue en jeu.**

Deux tours encore debout, une ville noyée, deux équipes de secours. Alex descend dans Aube pour ramener trois personnes au toit. Après le premier sauvetage, Hespérie bascule contre la façade : les lieux changent et Bravo ne répond plus.

Le dépôt contient une tranche jouable sous **Godot 4.7.2**, du toit au refuge du 25, et une bible détaillée de la campagne. Les personnages et décors restent procéduraux. Les assets et animations définitifs, la campagne complète et UE5 restent à produire.

## État de la version et accès au projet

La branche prépare la **0.7**. Son contrat de livraison exige **24 suites**, les ressources des deux exports testées en isolation, **30 captures natives** et une bible complète issue de **14 sources**, avec revue de chaque page. Les résultats et archives v0.7 restent à renseigner après exécution et revue ; les nombres de contrôles réussis et de pages ne sont pas anticipés. Voir [le suivi de livraison](docs/ETAT_DE_LIVRAISON.md) et [la procédure v0.7](docs/VALIDATION_V0.7.md).

Les liens suivants donnent accès à la **dernière livraison validée, la v0.6**, conservée pendant cette préparation. Le projet source courant se lance depuis `prototype/project.godot`.

- [Windows x64 — version 0.6](releases/The-Tower-Descent-v0.6-Windows-x64.zip)
- [Sources complètes — version 0.6](releases/The-Tower-Descent-v0.6-Sources.zip)
- [Démarrage Windows et commandes](docs/DEMARRAGE_WINDOWS.md)
- [État de livraison et limites vérifiées](docs/ETAT_DE_LIVRAISON.md)
- [Exports, moteur et licences](docs/EXPORTS.md)
- [Empreintes des archives](releases/SHA256SUMS.txt)

La source v0.6 a passé **21 suites et 4 500 contrôles**, avec **60 contrôles supplémentaires** sur les ressources des deux exports. Les **22 captures natives** et les **139 pages de bible** sont couvertes par les revues de leurs fichiers exacts. Le [rapport final des archives](releases/VERIFICATION_V0.6.json) vérifie l’intégrité et la cohérence des livrables. Les versions précédentes restent disponibles dans releases.

![Accueil contextuel conservé de la livraison v0.6](docs/captures/v0.6/01_menu_arrivee.png)

[Revoir les vingt-deux captures validées de la v0.6](docs/CAPTURES_V0.6.md), ou [consulter le contrat des trente captures v0.7](docs/CAPTURES_V0.7.md). L’image ci-dessus appartient à la livraison v0.6.

## Ouverture et accueil

La signature de quinze secondes présente la couronne adaptée au littoral et aux deux tours, **Darknigthmare Kingdoms Games Productions**, l’auteur puis le titre. Elle peut être passée, revue ou désactivée aux prochains lancements. Les [références consultées dans les autres projets](docs/REFERENCES_INTRO.md) sont documentées.

L’accueil montre le monde 3D au dernier point sûr : approche, toit, restaurant, suites, archives, jardin, spa ou refuge. La disposition, l’incident et les réceptions médicales correspondent à la sauvegarde. Attendre dans ce menu ne consomme ni ressources ni temps d’intervention.

L’arrivée en quatre plans dure vingt-huit secondes. Deux hélicoptères approchent, se posent, ouvrent leurs portes et déposent leurs équipes. Les six membres de toit gagnent leurs postes. Pause, passage et reprise du point initial convergent vers le même état de mission.

## Ce que la 0.7 apporte

### Un dossier qui suit la mission

**J** ouvre quatre rubriques : **Situation**, **Rescapés**, **Indices** et **Transmissions**. Le dossier affiche le lieu, le point sûr, le temps, les ressources, les personnes à secourir ou en cours de transfert et les réceptions confirmées. Les preuves non collectées restent fermées ; les textes recueillis et les trente-deux derniers échanges se relisent dans leur ordre. Consulter ces pages suspend l’intervention et ne remplace pas le point sûr.

### Une clôture dans les lieux du jeu

Après les trois personnes reçues et l’incident stabilisé, le relais du refuge 25 termine l’intervention. La clôture réussit son enregistrement puis présente **quinze secondes en trois plans** : poste médical d’Aube, terminal du refuge, Hespérie après impact. La séquence conserve l’incertitude sur le signal de Bravo. E, Entrée ou le bouton affiché permettent de rejoindre le bilan ; Échap suspend la présentation. Les mouvements réduits gardent les cadrages fixes.

### Un bilan consultable et une relecture volontaire

Le bilan reprend les noms, les preuves, la durée et les ressources de cette mission. Il permet de lire le dossier, revoir l’épilogue ou revenir à l’accueil. Charger une intervention achevée ouvre directement ce bilan. Revoir les trois plans ne réécrit ni la sauvegarde ni les transmissions et ne relance aucune simulation de secours. L’étage 24 reste hors du périmètre jouable.

Le [dossier de conception v0.7](docs/DOSSIER_ET_EPILOGUE_V0.7.md) décrit les scènes, les données, les commandes, les cas limites et les critères de revue.

## Sauvetages, ambiance et confort conservés

### Une chaîne de secours visible

Une personne sécurisée apparaît dans le harnais de première personne, avec sangles, poignée et mains d’Alex. Une seule personne est transportée et le centre de visée reste destiné à la route.

La balise engage cinq secondes de transfert : verrouillage, remontée et dépose. Le panier, le câble tendu et l’opérateur matérialisent le geste. L’objectif affiche phase et avancement. Seule la fin confirme le sauvetage et crée le point sûr.

Une prise en charge de 4,2 secondes accompagne ensuite la personne déjà reçue jusqu’à l’abri. Les équipiers existants retrouvent leurs postes. Le rechargement installe les personnes confirmées à leur place finale. Le [dossier de sauvetage](docs/SAUVETAGE_V0.6.md) décrit scène, props, durées et continuité.

### Un extérieur maritime cohérent

Un plafond nuageux à plusieurs couches, une bande de brume, huit voiles éloignés et deux nappes de pluie encadrent les tours. Le ciel sous l’horizon rejoint le brouillard de la mer pour améliorer le raccord des plans larges.

La pluie extérieure évite les enveloppes des tours. Mer et pluie suivent une horloge suspendue avec le monde. Les mouvements réduits conservent une ambiance fixe et masquent les traînées mobiles. Aucun collider ni tirage aléatoire de niveau n’est ajouté. Voir [Ambiance maritime](docs/AMBIANCE_V0.6.md).

### Des réglages avant et pendant la partie

| Réglage | Défaut | Plage |
| --- | --- | --- |
| Volume général | 100 % | 0–100 % |
| Sensibilité de souris | ×1 | ×0,25–×2,5 |
| Champ de vision jouable | 77° | 65–100° |
| Regard vertical inversé | Désactivé | Souris et flèches |
| Mouvements réduits | Activés | Caméra et présentation |
| Éclairs lumineux | Désactivés | Optionnels |
| Son | Activé | Coupure indépendante du volume |
| Introduction au lancement | Activée | Toujours passable |

Le panneau complet est accessible depuis l’accueil et **Pause → Options et confort**. Les valeurs sont appliquées immédiatement, enregistrées séparément de la mission et migrées depuis l’ancien fichier. Tab, flèches et molette parcourent le panneau. Sa fermeture en partie retourne à la pause. Voir [Confort](docs/CONFORT_V0.6.md).

## Intervention jouable

Le toit et les étages 30–25 proposent trois rescapés nommés, trois preuves, deux réserves, rappel guidé, ancrages, fusées, lampe, journal et refuge. Douze objets examinables donnent un constat adapté aux lieux et au bilan humain.

Ana Rios attend au restaurant du 30, Samuel Breton aux archives du 28 et Nora Haddad au spa du 26. Leurs réceptions restent visibles et nominatives au médical.

Après Ana reçue et le départ des appareils, l’observation de Bravo à la baie Est du 29 peut déclencher l’incident : alerte 8 s, secousse 6 s, basculement 7 s et impact 4 s. Le joueur garde le contrôle. Un détour intérieur remplace le passage Est du 28.

La radio gère priorités, file et trente-deux dernières transmissions. Le silence de Bravo ne confirme pas son décès. Les sauvegardes du schéma 3 restaurent les états stables et migrent les versions 1 et 2.

## Bible complète et dossiers de production

La bible v0.7 doit réunir intégralement les **14 sources** ci-dessous, avec une nouvelle annexe consacrée au dossier et à l’épilogue. Les Word et PDF v0.7 sont soumis à construction et revue ; les liens suivants désignent les documents validés de la v0.6.

- [Bible Word v0.6](docs/The-Tower-Descent-Bible-v0.6.docx)
- [Bible PDF v0.6](docs/The-Tower-Descent-Bible-v0.6.pdf)

| Source | Contenu |
| --- | --- |
| [Bible du jeu](docs/BIBLE_DU_JEU.md) | Vision, univers, histoire, personnages, progression, horreur, fins |
| [Catalogue des étages](docs/CATALOGUE_ETAGES.md) | Trente fiches de lieux, scènes, routes, indices et dangers |
| [Systèmes procéduraux](docs/SYSTEMES_PROCEDURAUX.md) | Génération, invariants, données et sauvegardes |
| [Architecture et UE5](docs/ARCHITECTURE_ET_PORTAGE_UE5.md) | Architecture réelle et proposition de portage |
| [Effondrement](docs/EFFONDREMENT_EN_DIRECT.md) | Déclencheurs, chronologie, conséquences et reprise |
| [Communications et équipes](docs/COMMUNICATIONS_ET_EQUIPES.md) | Radio, secours, sauvetages et journal |
| [Props et interactions](docs/PROPS_INTERACTIONS.md) | 52 fiches et douze observations livrées |
| [Ennemis et statistiques](docs/ENNEMIS_STATISTIQUES.md) | Figure E00 et dix archétypes de campagne |
| [Scènes et cinématiques](docs/SCENES_CINEMATIQUES.md) | Ouverture, accueil, arrivée, sauvetage, clôture et scènes futures |
| [Gameplay détaillé](docs/GAMEPLAY_DETAILLE.md) | Règles, ressources, progression, envies, motivations et peurs |
| [Sauvetage v0.6](docs/SAUVETAGE_V0.6.md) | Portage, harnais, câble, réception et recette |
| [Ambiance v0.6](docs/AMBIANCE_V0.6.md) | Nuages, horizon, pluie et rendu |
| [Confort v0.6](docs/CONFORT_V0.6.md) | Réglages, migration, pause, focus et valeurs |
| [Dossier et épilogue v0.7](docs/DOSSIER_ET_EPILOGUE_V0.7.md) | Quatre onglets, faits de mission, bilan, trois plans, reprise et relecture |

Les fonctions programmées et les cibles de campagne sont distinguées. Alma, la piscine, l’intérieur d’Hespérie, les cavernes, le bunker, le seuil 666, les fins et Mountain Hole ne sont pas jouables dans cette tranche.

## Développer et vérifier

Ouvrir prototype/project.godot avec Godot 4.7.2, puis lancer la scène principale. Les scripts de validation utilisent Python 3 et l’exécutable Godot.

Commande : python3 tools/run_validation.py --godot /chemin/vers/godot

La [procédure v0.7](docs/VALIDATION_V0.7.md) décrit construction figée, exports, contrôles des ressources embarquées, captures natives et revue des documents. Une erreur moteur reste bloquante même si le processus renvoie zéro.

Les captures sont des vues du moteur natif Linux à partir d’états préparés. Elles ne constituent pas une partie humaine sous Windows ou dans un navigateur, ni une mesure de performances. La PR reste en brouillon ; main conserve son état précédent.
