# Exports du prototype 0.11

Le workflow **release-v011** construit les exports Windows x64 et Web avec **Godot 4.7.2 stable officiel**. Il s’appuie sur les textures originales et les modèles éditables déjà générés, importés et figés dans le dépôt. [Windows v0.11](../releases/The-Tower-Descent-v0.11-Windows-x64.zip) · [Sources v0.11](../releases/The-Tower-Descent-v0.11-Sources.zip) · [résultats mesurés](ETAT_DE_LIVRAISON.md) · [rapport final des archives](../releases/VERIFICATION_V0.11.json).

## Rendu et contenu

Windows démarre en **Forward+**. `JOUER_CINEMATIQUE.cmd` demande explicitement Forward+ avec Vulkan ; `JOUER_COMPATIBILITE.cmd` demande Compatibility avec OpenGL 3. Le profil lumineux réellement actif dépend du moteur obtenu. Le premier combine SDFGI, SSIL, SSAO, SSR et brouillard volumétrique ; le second conserve les matières, lumières directes, ombres locales et brouillard classique. Le Web utilise Compatibility. Les choix et leurs limites sont décrits dans [Visuels et secours](VISUELS_ET_SECOURS_V0.11.md).

Le ZIP Windows contient exactement huit fichiers : l’exécutable avec son paquet embarqué, les deux lanceurs, le guide de démarrage renommé `README.md`, ce guide des exports, les licences Godot et les deux notices Open Sans. Tous doivent être extraits ensemble.

Le ZIP Sources contient le projet Godot, ses huit PNG de matière en résolution native 1254², seize GLB, le catalogue d’import, le fichier Blender éditable, les manifestes et les vingt et une vues de modèles. Il conserve les tests, scripts, workflows, guides, rapports textuels historiques et captures natives de la version courante. La Bible intégrale Word/PDF v0.9 et son supplément Word/PDF v0.10 restent identiques octet par octet. Les captures anciennes et les autres compilations historiques restent accessibles dans le dépôt et leurs archives d’origine.

`dist/` reçoit l’export Web au commit de livraison. Ce dossier ne constitue pas, à lui seul, la publication d’un site public. Les archives ZIP, caches Godot et Python et rendus temporaires de pages ne sont pas réemballés dans le ZIP Sources. Les deux archives sont limitées chacune à moins de 100 Mio ; le rapport final compare leur ensemble exact de membres, leurs tailles et leurs octets avec les sources prévues.

## Construction, examen et livraison

La génération des modèles est une étape distincte, documentée par `ASSET_BOOTSTRAP.json`. Le générateur Blender conserve les pièces nommées dans le fichier source, puis exporte un maillage à plusieurs surfaces par objet. Le vérificateur contrôle les seize identifiants, UV, normales, dimensions, matériaux, empreintes et budgets. Les prévisualisations utilisent Cycles CPU, sans dépendre d’un débruiteur optionnel absent de certains binaires Blender.

La demande `.review/v0.11/build-request.json` est seule dans son commit et nomme son parent immédiat. La phase **review** exige les assets déjà figés, exécute les 37 suites sources, construit les packs Windows/Web et charge leurs ressources depuis des dossiers isolés. Elle produit 71 états natifs : 42 du secteur initial, 13 de continuation, 8 du matériel et les mêmes 4 cadrages sous chacun des deux moteurs. Le rendu Forward+ emploie un affichage natif et un pilote Vulkan logiciel dans la CI ; le manifeste exige le moteur réel et les capacités actives, sans assimiler cette exécution à un benchmark sur GPU de joueur.

Chaque image du jeu et chaque vue Blender nécessite une observation après ouverture du fichier exact. L’approbation lie également les modèles, textures, guides, source éditable et quatre documents préservés à leurs SHA256. Le workflow ne produit pas lui-même cette approbation. Un changement dans le runtime, un test, une fixture, un guide lié ou un outil de livraison invalide les preuves correspondantes.

La phase **release** exige cette revue explicite, vérifie à nouveau les packs, crée les ZIP et contrôle chaque membre. La publication avance uniquement `feat/live-tower-collapse` si son commit est toujours celui demandé ; elle ne fusionne pas `main` et ne force pas une branche ayant évolué. Les fichiers sont également conservés dans l’artefact Actions de l’exécution.

Les tests source, l’import des GLB, les chargements de packs sous Linux et les captures préparées ont des portées différentes. Ils ne constituent ni une partie humaine de l’EXE Windows, ni une partie WebAssembly dans un navigateur, ni une mesure de fréquence d’images sur une carte dédiée. Les résultats et limites du candidat exact figurent dans les rapports v0.11 ; une simple source sur la branche n’est pas un export validé.

## Contrat historique v0.10

Le workflow **release-v010** construit Windows x64 et Web, puis vérifie leurs ressources depuis des dossiers isolés. Le moteur et les modèles restent Godot 4.7.2 stable officiels. [Windows v0.10](../releases/The-Tower-Descent-v0.10-Windows-x64.zip) · [Sources v0.10](../releases/The-Tower-Descent-v0.10-Sources.zip) · [preuves de livraison](ETAT_DE_LIVRAISON.md).

La demande `.review/v0.10/build-request.json` doit être seule dans son commit et nommer son parent. La phase review exécute les 32 suites, construit les packs, produit 42 captures de référence et 13 nouvelles vues, vérifie le texte du supplément puis rend ses pages. Le fichier d’approbation est rédigé après examen effectif des fichiers exacts. La phase release exige cette approbation, revérifie ou reconstruit les packs, prépare les ZIP et compare chaque membre et ses octets. Une branche ayant avancé n’est pas forcée ; main n’est pas modifiée.

La Bible intégrale v0.9 reste inchangée. Les documents de la 0.10 sont un supplément Word/PDF distinct et les sources Markdown actualisées. Le ZIP Sources inclut ces deux volumes et les captures courantes, sans recopier les anciennes captures. Les deux ZIP restent strictement sous 100 Mio. `dist/` contient l’export Web au commit de livraison ; sa présence ne signifie pas qu’un site public a été déployé.

Les vérifications de packs montent les ressources avec Godot Linux ; elles n’exécutent pas Windows ou WebAssembly. Le matériel artistique et les poses restent procéduraux. Les performances et le mixage final nécessitent des essais distincts.

## Contrat historique v0.9

### Exports historiques du prototype 0.9

**Moteur fixé : Godot 4.7.2 stable officiel — rendu Compatibility.** Ce guide décrit les formats, le contenu et les contrôles de la v0.9. Les résultats observés et les limites figurent dans [État de livraison](https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/ETAT_DE_LIVRAISON.md).

## Formats de distribution

| Format | Emplacement de livraison | Usage et contenu |
| --- | --- | --- |
| Windows x64 | [ZIP Windows v0.9](https://github.com/darknigthmare/The-Descents/raw/refs/heads/feat/live-tower-collapse/releases/The-Tower-Descent-v0.9-Windows-x64.zip) | Extraire puis lancer TheTowerDescent.exe ; guide et notices joints |
| Sources | [ZIP Sources v0.9](https://github.com/darknigthmare/The-Descents/raw/refs/heads/feat/live-tower-collapse/releases/The-Tower-Descent-v0.9-Sources.zip) | Code, assets actifs, tests, guides, Bible source et preuves ; captures et Word/PDF courants |
| Web | dist/ | Chargeur, WebAssembly, paquet de ressources et licences à servir ensemble |
| Bible | [Word v0.9](https://github.com/darknigthmare/The-Descents/raw/refs/heads/feat/live-tower-collapse/docs/The-Tower-Descent-Bible-v0.9.docx) · [PDF v0.9](https://github.com/darknigthmare/The-Descents/raw/refs/heads/feat/live-tower-collapse/docs/The-Tower-Descent-Bible-v0.9.pdf) | Volume complet de seize sources ; 186 pages PDF ; 186/186 pages PDF examinées ; Word contrôlé séparément sur 186 pages |

Windows embarque son paquet de ressources dans l’exécutable. La distribution Web figure dans `dist/` au commit de livraison ; elle n’est pas incluse dans le ZIP Sources. Ce dossier n’établit pas à lui seul qu’un site public a été déployé. Le [rapport final des archives](../releases/VERIFICATION_V0.9.json) est produit après l’emballage et reste accessible séparément.

## Construction et vérification

Le workflow **release-v09** reçoit une demande explicite après la source figée. Le commit de demande modifie uniquement `.review/v0.9/build-request.json` et désigne son propre parent. La branche reste `feat/live-tower-collapse` ; le workflow ne fusionne pas `main`. Le workflow v0.8 et ses preuves restent dans le dépôt.

La phase **review** exécute les **29 suites obligatoires**, exporte Windows et Web, puis charge les deux paquets séparément depuis des dossiers neufs et vides sous Godot Linux. Les trois domaines ajoutés sont `rope_traversal`, `vertical_routes` et `traversal_integration`. Ils couvrent le modèle de rappel, la topologie et les collisions physiques, puis les effets sur la mission, les paliers, les secours et les sauvegardes. Les résultats consolidés sont **Validés — 6 989 contrôles sources** et **Conformes — 140 contrôles des packs**.

Le test externe n’est pas inclus dans les ressources du jeu. Lancé avec `--main-pack`, il doit retrouver et charger `route_catalog.gd`, `rope_traversal.gd` et `rope_presentation.gd` depuis chacun des packs. Il vérifie les six liens, l’alternance, le déplacement suspendu, le verrou, la pause, la stabilisation et les bornes locales. Il instancie également la présentation du descendeur, échantillonne ses états et vérifie l’absence de collider. Cette inspection structurelle ne constitue pas une approbation visuelle.

Les contrôles déjà présents conservent menus, cinématiques, secours, dossier, épilogue, manifestations perceptives, sauvegardes, préférences et sons importés. Les modules d’horreur et le son positionnel `uncertain_steps.wav` restent requis. Une réussite du modèle isolé ne remplace pas le contrôle des ressources réellement embarquées.

Les modèles d’export sont ceux de Godot 4.7.2 stable officiel. Le pipeline vérifie tailles et SHA256 contre `EXPORT_TEMPLATE_PROVENANCE.json`. Version du moteur, commandes, empreintes du runtime et sorties figurent dans les rapports v0.9. Toute erreur moteur détectée fait échouer le contrôle, même si le processus retourne zéro.

## Captures et documents exacts

La construction produit **42 captures natives**, reconstruit le Word issu des **16 sources** et vérifie le PDF canonique préparé pour ce Word. Les 33 états de la 0.8 sont recapturés avec le runtime courant ; neuf vues supplémentaires couvrent station, descente, verrou, remontée, trois escaliers, palier intermédiaire et aide des commandes.

L’entrée [`.review/v0.9/canonical-document.json`](../.review/v0.9/canonical-document.json) fixe les empreintes des seize sources, du script générateur, de chaque fichier interne décompressé du Word et du PDF préparé à son emplacement de livraison. La CI exige les ensembles exacts et les mêmes empreintes : aucun fichier interne ajouté, retiré ou modifié n’est toléré. Tout écart interrompt la construction. Poppler rend ensuite les PNG des pages du PDF exact ; `DOCUMENT_BUILD.json` identifie ce PDF préparé, son manifeste et son moteur d’origine.

[DOCUMENT_CONTENT.json](validation/v0.9/DOCUMENT_CONTENT.json) consigne le contrôle exhaustif et ordonné de tous les paragraphes du corps et de toutes les lignes de tableau, avec vérification de chaque cellule dans sa ligne et de ses paragraphes dans sa cellule. Ce contrôle conserve les multiplicités : un texte présent ailleurs ne remplace pas une ligne manquante. Une absence bloque la construction. La normalisation Unicode, de casse, d’espacement et de ponctuation facilite la comparaison après mise en page ; elle ne valide ni la typographie ni la visibilité du texte.

Chaque capture et chaque page finale nécessitent une revue explicite de leurs fichiers exacts. Les résultats restent **42/42 examinées individuellement par l’assistant** pour les images du jeu et **186/186 pages PDF examinées ; Word contrôlé séparément sur 186 pages** pour les documents. Le générateur, le convertisseur et le vérificateur d’empreintes ne créent aucune approbation à la place d’un lecteur.

La phase **release** exige ces revues, conserve les octets approuvés du Word, du PDF et des captures, revérifie le manifeste documentaire et réexécute le contrôle de complétude sur les fichiers finaux. Elle reconstruit les exports, teste à nouveau leurs ressources, crée les archives et les vérifie. Une source, une image ou un document modifié ne peut pas réutiliser une approbation portant sur une autre empreinte. La revue du Word et celle des PNG rendus en CI depuis le PDF préparé identifient leurs supports exacts ; aucune conversion ou comparaison textuelle ne vaut approbation visuelle.

## Portée exacte du ZIP Sources v0.9

Le ZIP Sources comprend l’ensemble des éléments actifs du projet et son historique textuel :

| Inclus | Détail |
| --- | --- |
| Projet Godot | Tous les scripts, scènes, assets actifs, configuration et tests ; notamment catalogue de routes, modèle et présentation du rappel |
| Documentation source | Les seize sources intégrales de Bible, tous les guides Markdown et les annexes historiques |
| Construction | Scripts Python, workflows conservés et demandes de revue/livraison |
| Rapports | Rapports et revues textuels courants et historiques |
| Médias courants | Word et PDF v0.9, 42 PNG natifs v0.9, provenance et éventuels JPEG de lecture v0.9 |

Les **captures des versions antérieures** et les **anciennes Bibles Word/PDF** ne sont plus recopiées dans chaque nouveau ZIP. Elles restent intégralement conservées dans GitHub et dans les archives historiques. Cette politique retire une duplication de médias ; elle conserve le code actif, les sources documentaires, les tests et les guides nécessaires à la modification du jeu.

`source_package_paths()` dans `tools/qa_common.py` définit la sélection commune. Le constructeur et le vérificateur utilisent cette même fonction. Le contrôle final exige l’égalité de l’ensemble complet des membres, puis compare chaque membre à son fichier d’origine. Les exclusions usuelles restent les caches Godot et Python, les sorties visuelles temporaires, les journaux temporaires et les PNG de rendu des pages. Les autres archives ZIP et `dist/` ne font pas partie du ZIP Sources.

Les ZIP Windows et Sources doivent rester chacun strictement sous **100 Mio — 104 857 600 octets**. Une archive atteignant cette limite bloque la livraison. Le [rapport final des archives](../releases/VERIFICATION_V0.9.json) consigne le nombre de membres Sources, les tailles, les empreintes et le résultat de la comparaison exacte après emballage.

## Portée des contrôles

Une suite source vérifie ses invariants. Un parcours physique exerce la capsule dans les passages. Le chargement d’un pack vérifie ses ressources depuis un répertoire isolé. Les captures montrent Godot Linux avec des états préparés. La revue des pages examine les documents construits. Les rapports conservent séparément ces résultats de logique, de contenu exporté, de rendu et de mise en page.

Ces étapes ne constituent pas une partie humaine de l’EXE sous Windows, une partie Web dans un navigateur ou une mesure de fréquence d’images. Ces essais restent à identifier lorsqu’ils sont réalisés. Aucun doublage enregistré ni mixage final n’est certifié par le simple chargement des ressources audio. Les assets et poses du jeu restent procéduraux.

## Licences, publication et conservation

Godot et Open Sans accompagnent les exports avec leurs notices. Les archives 0.1, 0.2, 0.4, 0.5, 0.6, 0.7 et **0.8** restent conservées avec leurs médias et preuves d’origine. `SHA256SUMS.txt` couvre les archives effectivement présentes ; il est réécrit après la fabrication des nouveaux ZIP sans supprimer les anciennes entrées.

Le pipeline conserve les preuves et les fichiers de plateforme dans un artefact Actions avant publication. Il ne pousse ses sorties que si la branche pointe encore sur le commit demandé. Une évolution concurrente conserve cet artefact sans forcer l’historique. L’exécutable Windows reste dans l’artefact et le ZIP Windows ; il n’est pas ajouté individuellement au dépôt.

La [procédure complète v0.9](https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/VALIDATION_V0.9.md), le [catalogue des captures](https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/CAPTURES_V0.9.md) et [l’état de livraison](https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/ETAT_DE_LIVRAISON.md) relient les rapports dans `docs/validation/v0.9` et le contrôle final `releases/VERIFICATION_V0.9.json`.
