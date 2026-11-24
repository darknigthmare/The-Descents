# The Tower Descent

**Version 0.6 — sauvetages visibles, atmosphère maritime et options de confort.**

Deux tours encore debout, une ville noyée, deux équipes de secours. Alex descend dans Aube pour ramener trois personnes au toit. Après le premier sauvetage, Hespérie bascule contre la façade : les lieux changent et Bravo ne répond plus.

Le dépôt contient une tranche jouable sous **Godot 4.7.2**, du toit au refuge du 25, et une bible détaillée de la campagne. Les personnages et décors restent procéduraux. Les assets et animations définitifs, la campagne complète et UE5 restent à produire.

## Jouer et examiner la livraison

- [Windows x64 — version 0.6](releases/The-Tower-Descent-v0.6-Windows-x64.zip)
- [Sources complètes — version 0.6](releases/The-Tower-Descent-v0.6-Sources.zip)
- [Démarrage Windows et commandes](docs/DEMARRAGE_WINDOWS.md)
- [État de livraison et limites vérifiées](docs/ETAT_DE_LIVRAISON.md)
- [Exports, moteur et licences](docs/EXPORTS.md)
- [Empreintes des archives](releases/SHA256SUMS.txt)

Le candidat v0.6 passe par une construction automatisée, une revue des captures et des pages de la bible, puis une vérification des archives. Les fichiers de preuve indiquent les étapes effectuées. Les versions précédentes restent disponibles dans releases.

## Ouverture et accueil

La signature de quinze secondes présente la couronne adaptée au littoral et aux deux tours, **Darknigthmare Kingdoms Games Productions**, l’auteur puis le titre. Elle peut être passée, revue ou désactivée aux prochains lancements. Les [références consultées dans les autres projets](docs/REFERENCES_INTRO.md) sont documentées.

L’accueil montre le monde 3D au dernier point sûr : approche, toit, restaurant, suites, archives, jardin, spa ou refuge. La disposition, l’incident et les réceptions médicales correspondent à la sauvegarde. Attendre dans ce menu ne consomme ni ressources ni temps d’intervention.

L’arrivée en quatre plans dure vingt-huit secondes. Deux hélicoptères approchent, se posent, ouvrent leurs portes et déposent leurs équipes. Les six membres de toit gagnent leurs postes. Pause, passage et reprise du point initial convergent vers le même état de mission.

## Ce que la 0.6 ajoute

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
| [Scènes et cinématiques](docs/SCENES_CINEMATIQUES.md) | Ouverture, accueil, arrivée, sauvetage et scènes futures |
| [Gameplay détaillé](docs/GAMEPLAY_DETAILLE.md) | Règles, ressources, progression, envies, motivations et peurs |
| [Sauvetage v0.6](docs/SAUVETAGE_V0.6.md) | Portage, harnais, câble, réception et recette |
| [Ambiance v0.6](docs/AMBIANCE_V0.6.md) | Nuages, horizon, pluie et rendu |
| [Confort v0.6](docs/CONFORT_V0.6.md) | Réglages, migration, pause, focus et valeurs |

Les fonctions programmées et les cibles de campagne sont distinguées. Alma, la piscine, l’intérieur d’Hespérie, les cavernes, le bunker, le seuil 666, les fins et Mountain Hole ne sont pas jouables dans cette tranche.

## Développer et vérifier

Ouvrir prototype/project.godot avec Godot 4.7.2, puis lancer la scène principale. Les scripts de validation utilisent Python 3 et l’exécutable Godot.

Commande : python3 tools/run_validation.py --godot /chemin/vers/godot

La [procédure v0.6](docs/VALIDATION_V0.6.md) décrit construction figée, exports, contrôles des ressources embarquées, captures natives et revue des documents. Une erreur moteur reste bloquante même si le processus renvoie zéro.

Les captures sont des vues du moteur natif Linux à partir d’états préparés. Elles ne constituent pas une partie humaine sous Windows ou dans un navigateur, ni une mesure de performances. La PR reste en brouillon ; main conserve son état précédent.
