# Validation de The Tower Descent 0 13

La recette relie les résultats aux sources et fichiers exacts de la candidature résidentielle A19 à A17. Les anciens résultats de la 0.12 sont historiques. Le simple ajout d'un document ou d'une liste de tests n'établit pas leur réussite.

## 1 Sources et périmètre

Importer `prototype/project.godot` avec Godot 4.7.2, puis exécuter `tools/run_validation.py` avec l'exécutable retenu. Le script découvre les suites `prototype/tests/test_*.gd`, à l'exception de la suite réservée aux packs exportés. Conserver le rapport et les sorties du moteur ; une erreur de script reste bloquante même si le processus retourne zéro.

Le périmètre de la 0.13 comprend Jeanne au 19, Marc au 18, Inès au 17, les trois escaliers S20_19, S19_18 et S18_17, le rappel personnel R19_18, le dégagement du service, le relais et les trois constats. Les tests doivent vérifier les actions, les refus et les retours vers le refuge 20, puis protéger les chapitres déjà livrés.

Le rapport décrit les cas réellement exécutés et leur résultat, sans total anticipé. Un échec doit rester visible jusqu'à sa correction et à la nouvelle exécution du cas concerné. Une correction des routes nécessite une vérification physique des routes affectées ; elle ne se valide pas seulement en comparant des identifiants.

## 2 Logique de mission et relais

Vérifier le passage volontaire du bilan 20 à la tranche résidentielle. Lire le bilan, le dossier ou les options ne doit pas démarrer la mission. Tester les prérequis de Jeanne, le Halligan pour le service au 18, l'alimentation du 17, la lecture de la référence AUBE-20 / NACRE-204, la validation et le refus d'une destination ou référence incorrecte.

Le refus du relais doit permettre une nouvelle tentative. L'alimentation seule ne vaut pas liaison confirmée. Les trois constats restent collectables dans un ordre libre ; une mauvaise confirmation ne retire ni un document ni une personne déjà reçue. Le bilan exige les trois réceptions physiques au 20, les constats et le relais validé, puis la présence d'Alex sur un appui stable au 17 pour transmettre le résultat.

L'apparition facultative du Répondant respecte les contextes de pause, secours, radio et rappel. Son absence ne peut bloquer la mission. La présence d'un acteur visuel n'établit pas un système de combat ou de poursuite.

## 3 Déplacements et accès

Les escortes de Jeanne, Marc et Inès utilisent les vrais `CharacterBody3D` et leurs collisions. Examiner les trois routes jusqu'aux repères distincts du refuge 20, les virages du circuit ouest, les montées d'escalier, les arrêts au-delà de cinq mètres et la reprise après attente. Un personnage ne doit pas traverser la grille fermée, le mobilier ou les murs.

Le test de réception vérifie la bonne identité, l'appui stable et l'arrivée du corps sur la bonne zone. Ajouter un cas sous la dalle, un cas à distance et une répétition de la réception pour vérifier l'absence de double attribution. Contrôler l'arrêt des corps pendant les menus.

Pour R19_18, vérifier descente et remontée, visibilité de l'appui bas, garde-corps, cohérence du trou dans les deux dalles et volumes de transfert. Tester une sortie obstruée et l'annulation vers un appui valide. Aucune escorte ne doit utiliser la corde. Le service ouvert reste franchissable dans les deux sens.

Un guidage synthétique d'Alex peut servir à rendre les parcours reproductibles. Le rapport doit l'indiquer ; il ne s'agit pas d'une partie humaine. Les fixtures qui placent directement les personnages vérifient un état local, pas l'ensemble d'un déplacement.

## 4 Sauvegardes et erreurs écriture

Valider la migration des schémas 1 à 5 vers le schéma 6. Les données de chapitres précédents, secours, indices, ressources et incident doivent rester cohérentes. Refuser les identités, phases et combinaisons de prérequis invalides. Une ancienne clôture au 20 doit rester consultable sans démarrer automatiquement le nouveau chapitre.

Tester séparément la véritable reprise et l'échec d'écriture. Après reprise, une escorte non reçue revient en attente à son contact initial, conformément au contrat annoncé. En cas d'échec I/O pendant une session, le rollback conserve la position physique et l'état de suivi vivant ; il ne doit pas appliquer la normalisation réservée aux checkpoints.

Vérifier que le dernier fichier valide reste disponible si la nouvelle écriture échoue. Une demande pendant le rappel attend un appui stable. La clôture n'est publiée dans la sauvegarde qu'après écriture réussie. Les personnes reçues restent à leurs destinations après reprise et ne se dupliquent pas au départ.

## 5 Captures et assets

Produire des captures natives du 19, du duplex depuis chaque niveau, du service fermé et ouvert, du 17, du relais avant et après validation, du refuge avec les nouvelles personnes, du dossier et du bilan. Une vue de l'apparition facultative doit préciser son état préparé. Vérifier également un format compact pour les consignes longues du relais et le dossier.

Chaque image doit indiquer le profil Godot réellement utilisé, la résolution, le commit et les états préparés. Si Forward+ n'est pas disponible, conserver cette limite ; ne pas renommer une capture Compatibilité. Ouvrir chaque image finale et consigner les défauts observés ainsi que son SHA256. Une observation ne se transfère à une autre image que lorsque ses octets sont identiques.

Vérifier les douze GLB avec leur manifeste : fichier, empreinte, dimensions, axes, pivot et usage. Les vues de modèles issues de Blender restent identifiées comme telles. Les deux textures se contrôlent en original et en répétition ; leur résolution et leurs cartes réellement fournies sont consignées. La présence d'une source Blender ou d'un PNG ne démontre pas leur intégration dans le jeu.

## 6 Document Word et PDF

Le générateur `tools/build_residential_document.py` lit `docs/CONTINUATION_A19_A17_V0.13.md`. Exécuter avec le Python du runtime primaire :

```bash
"$CODEX_PRIMARY_RUNTIME_PYTHON" tools/build_residential_document.py
```

Le générateur produit le Word et un rapport de construction, sans déclarer de revue visuelle. Rendre le Word avec `render_docx.py` de la compétence Documents et l'option `--emit_pdf`. Le PDF final doit être celui de cette conversion. Copier uniquement les fichiers finaux correspondants, puis contrôler le contenu :

```bash
"$CODEX_PRIMARY_RUNTIME_PYTHON" tools/verify_document_content.py --docx docs/The-Tower-Descent-Continuation-v0.13.docx --pdf docs/The-Tower-Descent-Continuation-v0.13.pdf --output docs/validation/v0.13/DOCUMENT_CONTENT.json
```

Examiner chaque PNG au format lisible. Vérifier marges, coupures de paragraphes, lignes de tableaux, en-têtes répétés, accents, pagination et absence de contenu masqué. Corriger puis refaire le rendu si nécessaire. `DOCUMENT_REVIEW.json` doit conserver les SHA256 du Markdown, du générateur, du DOCX, du PDF, des pages et les observations effectivement réalisées. Le contrôle de texte ne remplace pas cette revue.

## 7 Exports et publication

Le statut de source vérifiée reste distinct d'une livraison d'exécutable. Un export Windows ou Web doit être construit depuis la révision retenue, puis contrôlé avec ses ressources réelles. Monter le pack dans Godot Linux vérifie son contenu et son chargement dans ce contexte ; cela ne lance pas l'application sous Windows ni le WebAssembly dans un navigateur.

Les archives ne sont annoncées comme disponibles qu'après création, vérification de leurs CRC, membres, octets et empreintes, puis publication. Les liens doivent pointer vers les fichiers réellement présents. Conserver une description explicite des tests non réalisés, des réserves visuelles et de la portée jouable. La publication sur la branche de PR ne vaut pas fusion de `main`.
