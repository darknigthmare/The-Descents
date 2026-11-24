# The Tower Descent

**Version 0.2 — prototype de sauvetage et d’horreur en vue subjective, accompagné de sa bible de jeu.**

Sur l’île de Nacre, la ville est submergée mais les deux tours Orphée sont encore droites et intactes. Deux hélicoptères déposent Alpha sur Aube et Bravo sur Hespérie, puis repartent devant le retour de la tempête. Pendant votre descente, une réplique fait basculer Hespérie contre votre tour. Vous gardez le contrôle tandis que le décor se transforme, puis poursuivez les sauvetages avec une liaison radio dégradée et Bravo devenu silencieux.

Le titre du jeu est **The Tower Descent**. Le dépôt conserve le nom **The-Descents**.

## Jouer au prototype

### Version Windows

Télécharger [The-Tower-Descent-v0.2-Windows-x64.zip](releases/The-Tower-Descent-v0.2-Windows-x64.zip), extraire le ZIP, puis lancer **TheTowerDescent.exe**. Godot n’a pas besoin d’être installé. L’exécutable n’a pas été lancé sur un PC Windows dans cet environnement ; le détail des contrôles figure dans l’[état de livraison](docs/ETAT_DE_LIVRAISON.md).

**La version recommandée est la 0.2.** Les archives 0.1 conservées dans le dépôt sont historiques et ne contiennent pas la nouvelle séquence.

### Projet modifiable dans Godot

Le [ZIP des sources 0.2](releases/The-Tower-Descent-v0.2-Sources.zip) contient le projet modifiable et la documentation. Pour l’ouvrir :

1. Télécharger ce dépôt ou le cloner.
2. Installer [Godot 4.7.2 standard](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable), sans .NET. C’est la version utilisée pour les essais de cette livraison.
3. Dans Godot, choisir **Importer**, puis le fichier `prototype/project.godot`.
4. Ouvrir le projet et appuyer sur **F5**. Le menu permet de choisir une graine ou de reprendre un checkpoint local.

Avec Godot dans le PATH :

```sh
godot --path prototype
```

Sous Windows, `JOUER_WINDOWS.cmd` lance le même projet si `godot.exe` est dans le PATH ou si l’exécutable Godot se trouve à côté du script. Sous Linux et macOS, `./jouer.sh` utilise la commande `godot` installée.

Le projet ne demande aucun compte, service distant, clé API ou achat d’asset. Il utilise des modèles et matériaux procéduraux et des sons originaux synthétisés. Le moteur jouable est **Godot 4.7.2** ; l’adaptation à Unreal Engine 5 est décrite dans les documents, mais n’est pas réalisée.

## Contenu effectivement jouable

Le toit et **six étages distincts**, du 30 au 25, forment une intervention complète :

| Niveau | Lieu | Objectifs et événements |
|---|---|---|
| Toits | Alpha sur Aube, Bravo sur Hespérie | Approche de 6 secondes, deux hélicoptères, équipes visibles, départ des appareils et consignes radio |
| 30 | Restaurant panoramique | Secourir Ana Rios ; apprendre le retour au treuil |
| 29 | Suites et baie Est | Observer Bravo après le sauvetage d’Ana ; vivre la réplique et l’impact ; collecter Chambre 2908 et récupérer une caisse |
| 28 | Bureaux et archives | Contourner le couloir Est condamné par le noyau ; secourir Samuel Breton et le ramener au treuil |
| 27 | Jardin d’enfants évacué | Découvrir le dessin des deux tours ; respiration sans danger |
| 26 | Spa | Secourir Nora Haddad ; relever SILLAGE 06 ; repousser la silhouette |
| 25 | Refuge technique | Se réapprovisionner et activer le relais après les trois sauvetages et l’effondrement |

### Vivre l’effondrement

1. Passez l’approche avec **E**, ou laissez ses six secondes se dérouler. Descendez au **30**, sécurisez Ana et confirmez son treuillage à la balise orange.
2. Rejoignez la **baie Est du 29**, une fois les hélicoptères partis. Regardez Bravo dans Hespérie pendant **0,8 seconde**, ou utilisez **E** près de la balise d’observation.
3. L’événement enchaîne **8 s d’alerte, 6 s de secousse, 7 s d’effondrement et 4 s d’impact**. Vous pouvez regarder et marcher librement ; aucune mort automatique ni QTE n’est imposé.
4. Les vitres, la position d’Hespérie et les débris restent modifiés. Au **28**, passez par le noyau intérieur pour rejoindre Samuel. Les personnes déjà réceptionnées au toit restent sauvées.

La scène attend la progression et l’observation du joueur. Elle ne démarre pas pendant un portage ou un treuillage. **Échap** fige la séquence ; les mouvements de caméra sont réduits par défaut.

Les personnes sécurisées sont transportées au harnais de façon abstraite : votre déplacement ralentit, puis le treuil les remonte visiblement au toit. Elles sont comptées sauvées après la confirmation du poste de secours. Il n’y a pas encore d’animation complète de portage ou d’IA d’escorte.

### Commandes

| Action | Commande |
|---|---|
| Marcher | ZQSD ou WASD |
| Regarder | Souris ou flèches |
| Courir | Maj |
| S’accroupir | Ctrl |
| Sauter | Espace |
| Interagir, attacher la corde, quitter le rappel à hauteur d’un étage | E |
| Passer l’approche ou confirmer l’observation à la baie Est | E |
| Descendre en rappel | S |
| Remonter en rappel | Z ou W |
| Balancement latéral | Q ou A, et D |
| Poser un ancrage secondaire sur corde | X |
| Lampe | F |
| Fusée lumineuse | G |
| Radio | R |
| Journal | J |
| Pause et confort visuel | Échap |

Approchez une balise orange du puits et appuyez sur **E** avant de descendre. Sur corde, arrêtez-vous près d’une dalle puis appuyez à nouveau sur **E**. Les consignes s’affichent au centre de l’écran. Les ancrages secondaires stabilisent le balancement sans interrompre la ligne principale.

La réserve d’air diminue dans les étages enfumés. Les fusées repoussent la silhouette du spa pendant vingt secondes. Les refuges restent sûrs. Les mouvements de caméra sont réduits par défaut, les dialogues sont sous-titrés et le son peut être désactivé dans la pause.

## Sauvegarde

La progression s’enregistre au départ, après un treuillage confirmé, au refuge 25, ainsi qu’**avant et après l’effondrement**. Elle conserve la graine, les ressources, les indices, les sauvetages et l’état des tours. Une interruption pendant la séquence reprend au point sûr qui la précède ; une reprise après stabilisation conserve les dégâts. Un transport non encore validé n’est pas acquis : la personne réapparaît à son emplacement.

Le schéma est passé en **version 2**, en conservant le nom local `save_v1.json` pour retrouver les anciennes parties. Une sauvegarde 0.1 valide est migrée à la lecture : partie en cours avec tours intactes, partie terminée avec effondrement acquis. Les données ne sont jamais envoyées en ligne. Un fichier corrompu est refusé sans interrompre le menu.

## Lire la bible et préparer la suite

- [Bible 0.2 au format Word](docs/The-Tower-Descent-Bible-v0.2.docx) : document réuni et modifiable.
- [Bible 0.2 au format PDF](docs/The-Tower-Descent-Bible-v0.2.pdf) : document de lecture.
- [Effondrement en direct](docs/EFFONDREMENT_EN_DIRECT.md) : déroulé de la séquence, conséquences et intentions pour la campagne.
- [Bible complète](docs/BIBLE_DU_JEU.md) : univers, personnages, récit, systèmes, horreur, fins et production.
- [Catalogue des étages](docs/CATALOGUE_ETAGES.md) : les trente étages, la tour condamnée, les souterrains, le bunker, le niveau 666 et Mountain Hole.
- [Génération et sauvegardes](docs/SYSTEMES_PROCEDURAUX.md) : données, invariants, reproductibilité et contraintes.
- [Architecture et portage Unreal Engine 5](docs/ARCHITECTURE_ET_PORTAGE_UE5.md) : état réel du prototype et adaptation proposée.
- [État de livraison et vérifications](docs/ETAT_DE_LIVRAISON.md) : portée des essais et fonctions restantes.

**La campagne de trente étages, Alma, la chute dans la piscine, les cavernes, le bunker, les fins et Mountain Hole sont conçus dans les documents. Ils ne sont pas implémentés dans cette version.** Le prototype est solo. Ni Unreal Engine 5 ni Unity n’ont été utilisés pour le compiler.

## Structure

```text
prototype/
  project.godot
  scenes/main.tscn
  scripts/           contrôleur, monde, rappel, interface, génération et sauvegarde
  shaders/           eau procédurale
  assets/audio/      sons originaux du prototype
  tests/             génération, persistance, mission et collisions
docs/                bible, catalogue et conception technique
tools/               scripts reproductibles de fabrication
releases/            archives Windows et sources avec sommes SHA256
dist/                version Web exportée
```

## Vérifier le projet

```sh
godot --headless --path prototype --editor --import --quit
godot --headless --path prototype --script tests/test_generation.gd
godot --headless --path prototype --script tests/test_save.gd
godot --headless --path prototype --script tests/test_mission.gd
godot --headless --fixed-fps 60 --path prototype --script tests/test_routes.gd
godot --headless --path prototype --script tests/test_collapse.gd
godot --headless --path prototype --script tests/test_incident_integration.gd
godot --headless --fixed-fps 60 --path prototype --script tests/test_incident_routes.gd
godot --headless --path prototype --script tests/test_incident_effects.gd
```

**Les huit suites totalisent 1 452 contrôles réussis.** Les tests de mission et d’intégration utilisent des téléportations pour isoler les règles et la persistance. Les deux suites de trajets vérifient **231 segments physiques**, dont l’accès à la baie et le détour du 28 ; elles confirment également six blocages attendus. Ces essais ne certifient pas le rendu ou les performances sur toutes les machines.

## Références et créations

L’idée initiale et les notes sont celles de Darknigthmare. *Gremlins 2* et *Skyscraper* sont des références d’organisation des espaces et de catastrophe verticale ; leurs personnages, modèles, bandes originales et extraits ne sont pas intégrés. Le lien de sirène fourni dans le brief est une référence à examiner, pas un son téléchargé ni livré. Les noms, le programme SILLAGE, les dialogues, les géométries et les sons de cette version constituent une proposition originale de développement.

Godot et les composants qu’il embarque conservent leurs [licences respectives](docs/GODOT_LICENSES.txt), également jointes aux distributions. Ce dépôt ne modifie pas le régime de droits du projet appartenant à son auteur.
