# Exports du prototype 0.13.0

**Candidature v0.13.0 en vérification finale.** Le projet utilise **Godot 4.7.2**. Les trois chemins ci-dessous sont les cibles de distribution retenues ; tailles, empreintes, membres exacts et disponibilité seront confirmés après construction et contrôle des archives. Les résultats historiques conservés plus bas ne certifient pas la 0.13.

Windows propose **Forward+** par défaut. **JOUER_CINEMATIQUE.cmd** demande Vulkan/Forward+ ; **JOUER_COMPATIBILITE.cmd** demande OpenGL/Compatibility. Le Web utilise Compatibility. Les parcours, modèles, textures et règles de secours restent communs aux profils ; les effets de lumière dépendent du moteur effectivement obtenu.

## Archives prévues

| Format | Cible de distribution | Contenu attendu |
| --- | --- | --- |
| Windows x86_64 | [TheTowerDescent-v0.13-Windows-x86_64.zip](../releases/v0.13/TheTowerDescent-v0.13-Windows-x86_64.zip) | Exécutable avec ressources embarquées, deux lanceurs, guide et licences |
| Sources Godot | [TheTowerDescent-v0.13-Godot-Source.zip](../releases/v0.13/TheTowerDescent-v0.13-Godot-Source.zip) | Projet éditable, actifs, sources Blender, tests, outils, guides et documents |
| Web | [TheTowerDescent-v0.13-Web.zip](../releases/v0.13/TheTowerDescent-v0.13-Web.zip) | Chargeur HTML/JavaScript, WebAssembly, paquet de ressources et notices à servir ensemble |

Le manifeste final de la livraison doit établir les fichiers présents et leurs SHA-256. Tant que son contrôle n’est pas terminé, ces liens décrivent l’emplacement visé et non une attestation de publication. Le statut courant figure dans [État de livraison](ETAT_DE_LIVRAISON.md).

## Ouvrir et utiliser chaque format

### Windows

Extraire l’ensemble de l’archive dans un même dossier et lancer l’un des deux fichiers `.cmd`. Le paquet conserve `TheTowerDescent.exe`, `JOUER_CINEMATIQUE.cmd`, `JOUER_COMPATIBILITE.cmd`, le guide de démarrage, `EXPORTS.md`, `GODOT_LICENSES.txt` et les notices Open Sans. L’exécutable contient son paquet de ressources ; l’utilisateur n’a pas à installer l’éditeur Godot. Les commandes et étapes de mission sont décrites dans [Démarrage Windows](DEMARRAGE_WINDOWS.md).

### Projet éditable

Ouvrir `prototype/project.godot` avec Godot 4.7.2 et laisser l’import des ressources se terminer. Le projet conserve les catalogues de **quarante GLB** et les **douze PNG de matière** actifs. Le nouveau lot résidentiel apporte douze GLB, 428 pièces source, 155 152 triangles et 5 203 300 octets GLB. Les dimensions et empreintes individuelles figurent dans son [manifeste](../prototype/assets/models/residential_v013/manifest.json).

Les sources de modèles restent `docs/assets/v0.11/rescue_equipment.blend`, `docs/assets/v0.12/commerce_equipment.blend` et `docs/assets/v0.13/residential_equipment.blend`. Le nouveau [guide des modèles](assets/v0.13/MODELS.md) indique les identifiants, pivots et usages. Les papiers peints et sols du lot v0.13 gardent leur résolution native de 1254 × 1254 et leurs prompts ; ce sont des créations artistiques, avec détail de surface approximé par le moteur.

La Bible complète v0.9, les suppléments v0.10, v0.12 et v0.13, leurs sources Markdown et les rapports associés restent conservés. Les captures du jeu et les aperçus Blender ont des provenances différentes. Leur disponibilité dans l’archive finale doit correspondre à l’inventaire réellement vérifié ; aucun nouveau total d’images n’est annoncé avant la revue.

### Web

Extraire le chargeur, le module WebAssembly et le paquet de ressources sans renommer séparément les fichiers. Servir ce dossier par HTTP avec les paramètres nécessaires à l’export Godot retenu. Ouvrir directement le fichier HTML par `file://` ne constitue pas le mode de lancement attendu. Le Web utilise le rendu Compatibility ; les données de reprise restent locales au contexte de navigation.

La présence de l’archive Web ou d’un dossier d’export n’établit pas le déploiement d’un site public. Les résultats de construction, de chargement des ressources et d’exécution en navigateur doivent rester identifiés séparément.

## Contrôles de la candidature

La [procédure v0.13](VALIDATION_V0.13.md) décrit la validation de logique, les parcours physiques, les erreurs d’écriture, les captures et le supplément Word/PDF. Les contrôles finaux sont en cours. Les résultats publiés devront lier leur verdict au moteur, aux commandes, aux fichiers et à leurs empreintes exactes.

Le chargement d’un pack Windows ou Web par Godot Linux vérifie les ressources embarquées dans ce contexte. Il ne lance pas l’application sur Windows ni le WebAssembly dans un navigateur. Les captures sont des états préparés du moteur et les parcours automatisés peuvent employer un guide synthétique. Ces preuves ne valent pas partie humaine complète ni mesure de performance sur GPU de joueur.

Après assemblage, contrôler les CRC, l’inventaire, les tailles et les octets des membres, puis calculer les SHA-256 des archives. Le contrat historique conserve une limite de **100 Mio — 104 857 600 octets — par archive** ; une nouvelle répartition doit être décrite et vérifiée avant publication.

## Contrat historique v0.12

Les chemins, résultats et outils ci-dessous appartiennent à la livraison antérieure.

<details>
<summary>Consulter les exports et preuves historiques v0.12</summary>

### Exports historiques du prototype 0.12

La candidature 0.12 utilise **Godot 4.7.2 stable officiel** et ses modèles d’export vérifiés par empreinte. **Sa revue est achevée** : 43 suites et 8 291 contrôles sources, 572 contrôles de packs, 21 PNG natifs examinés et neuf pages de document revues. Les preuves concernent la demande `9756f0b707c1ffc72284754ec1f1ff301ffdd960` et sa source `2e4de42ce85a42c80dae97a1de9985194430d9b6`. Le workflow **commerce-review** construit les exports et preuves ; il ne publie aucun fichier dans la branche et ne crée aucune approbation.

Le rendu Windows utilise Forward+ par défaut. Les lanceurs **JOUER_CINEMATIQUE.cmd** et **JOUER_COMPATIBILITE.cmd** demandent respectivement Vulkan/Forward+ et OpenGL/Compatibility. Le Web utilise Compatibility. Les modèles, matières, parcours et règles de secours sont communs.

## Archives et manifeste de livraison

Les chemins suivants sont ceux de [package_release.py](../tools/package_release.py). La disponibilité des archives est attestée par la présence de leur [manifeste final `releases/VERIFICATION_V0.12.json`](../releases/VERIFICATION_V0.12.json), publié avec les trois ZIP après réussite du contrôle de livraison. Le manifeste donne les tailles, les empreintes et les membres effectivement vérifiés.

| Archive | Contenu |
| --- | --- |
| [The-Tower-Descent-v0.12-Windows-x64.zip](../releases/The-Tower-Descent-v0.12-Windows-x64.zip) | Exécutable avec son paquet embarqué, deux lanceurs, guide et licences |
| [The-Tower-Descent-v0.12-Sources.zip](../releases/The-Tower-Descent-v0.12-Sources.zip) | Projet éditable, dix albedos originaux, vingt-huit GLB, deux sources Blender, tests, outils, guides, rapports et documents |
| [The-Tower-Descent-v0.12-Captures-native.zip](../releases/The-Tower-Descent-v0.12-Captures-native.zip) | 21 PNG examinés et quatre fichiers de manifeste/provenance, aux chemins d’origine |

Le contrat des trois ZIP utilise la racine `The-Tower-Descent/`. Extraire Sources et Captures-native dans le même dossier parent réunit le projet et les preuves visuelles. Les captures restent facultatives pour jouer ou modifier le projet. Le ZIP Sources doit conserver la Bible complète v0.9 et les suppléments v0.10 et v0.12 en Word/PDF. Les anciennes archives et captures restent rattachées à leurs livraisons historiques.

Le ZIP Windows doit contenir exactement huit fichiers : `TheTowerDescent.exe`, `JOUER_CINEMATIQUE.cmd`, `JOUER_COMPATIBILITE.cmd`, `README.md` issu du guide de démarrage, `EXPORTS.md`, `GODOT_LICENSES.txt`, `fonts/LICENSE.txt` et `fonts/NOTICE.txt`. Les deux sources éditables de modèles sont `docs/assets/v0.11/rescue_equipment.blend` et `docs/assets/v0.12/commerce_equipment.blend` dans le ZIP Sources. Le projet s’ouvre depuis `prototype/project.godot`.

## Exports et captures réellement vérifiés

| Élément construit | Chemin dans l’espace de construction | Contrôle réalisé |
| --- | --- | --- |
| Windows x64 | `builds/windows/TheTowerDescent.exe` | Paquet embarqué monté par Godot Linux : **286 contrôles** ; l’application Windows n’a pas été exécutée |
| Web | `builds/web/index.html`, `index.js`, `index.wasm`, `index.pck` et notices | PCK monté par Godot Linux : **286 contrôles** ; aucun lancement WebAssembly dans un navigateur |
| Compatibilité | `docs/captures/v0.12/commerce/compatibility/` | **18 PNG ouverts et examinés**, dont 16 en 1440 × 900 et deux en 1024 × 640 |
| Forward+ | `docs/captures/v0.12/commerce/forward_plus/` | **Trois PNG ouverts et examinés** en 1440 × 900 ; Vulkan était disponible et ce moteur a réellement produit ces vues |

Les [exports construits](validation/v0.12/CANDIDATE_EXPORTS.json), les [572 contrôles de packs](validation/v0.12/EXPORTED_PACK_VERIFICATION.json), le [catalogue des 21 images](CAPTURES_V0.12.md) et [leur revue](validation/v0.12/VISUAL_REVIEW.json) relient ces résultats aux fichiers exacts. Chaque groupe de captures possède un `MANIFEST.json` et un `PROVENANCE.json`. Les 21 images ont été réparties entre trois agents pour examen effectif ; ce sont des états préparés du moteur. La [revue des neuf pages](validation/v0.12/DOCUMENT_REVIEW.json) et le [contrôle du texte Word/PDF](validation/v0.12/DOCUMENT_CONTENT.json) sont distincts.

Le vérificateur [verify_commerce_release.py](../tools/verify_commerce_release.py) exige les tests, packs, provenances et revues, puis compare les membres et octets exacts des ZIP avec leurs sources. Il écrit `releases/VERIFICATION_V0.12.json` seulement après réussite de ces contrôles. Chaque archive doit rester strictement sous **100 Mio — 104 857 600 octets**. Les fichiers Web destinés à `dist/` doivent correspondre exactement à l’export vérifié ; ce dossier n’établit pas à lui seul la publication d’un site public.

La procédure détaillée est dans [Validation v0.12](VALIDATION_V0.12.md). Le [rapport de livraison](ETAT_DE_LIVRAISON.md) distingue revue et disponibilité. Les captures natives sous Linux et les packs montés ne constituent pas une partie humaine sous Windows ou dans un navigateur, ni un benchmark de GPU. Personnages, feu et fumée restent stylisés ; quelques superpositions de libellés 3D et de notifications ainsi qu’une aide parfois peu contrastée sont consignées dans la revue.


</details>

## Contrat historique v0.11

### Exports historiques du prototype 0.11

Le workflow **release-v011** construit les exports Windows x64 et Web avec **Godot 4.7.2 stable officiel**. Il s’appuie sur les textures originales et les modèles éditables déjà générés, importés et figés dans le dépôt. Le contrat de livraison prévoit les trois archives ci-dessous après la revue du candidat gelé et les contrôles d’emballage. Leur description ne vaut pas constat de production : les [résultats mesurés](ETAT_DE_LIVRAISON.md) et le rapport `releases/VERIFICATION_V0.11.json`, produit après emballage, établissent l’état effectif de la livraison.

## Rendu et contenu

Windows démarre en **Forward+**. `JOUER_CINEMATIQUE.cmd` demande explicitement Forward+ avec Vulkan ; `JOUER_COMPATIBILITE.cmd` demande Compatibility avec OpenGL 3. Le profil lumineux réellement actif dépend du moteur obtenu. Le premier combine SDFGI, SSIL, SSAO, SSR et brouillard volumétrique ; le second conserve les matières, lumières directes, ombres locales et brouillard classique. Le Web utilise Compatibility. Les choix et leurs limites sont décrits dans [Visuels et secours](VISUELS_ET_SECOURS_V0.11.md).

Les trois archives prévues utilisent la racine `The-Tower-Descent/` :

| Archive prévue | Contenu et usage |
| --- | --- |
| `The-Tower-Descent-v0.11-Windows-x64.zip` | Programme Windows avec ses deux lanceurs, guides et notices |
| `The-Tower-Descent-v0.11-Sources.zip` | Projet modifiable complet, assets, documents et rapports |
| `The-Tower-Descent-v0.11-Captures-native.zip` | Preuves visuelles natives et leurs manifestes, à extraire facultativement avec les sources |

Le ZIP Windows conservera exactement huit fichiers : l’exécutable avec son paquet embarqué, les deux lanceurs, le guide de démarrage renommé `README.md`, ce guide des exports, les licences Godot et les deux notices Open Sans. Tous doivent être extraits ensemble.

Le ZIP Sources conservera le projet Godot, ses huit PNG de matière en résolution native 1254², seize GLB, le catalogue d’import, le fichier Blender éditable, les manifestes des assets et les vingt et une vues de modèles. Il inclura les tests, scripts, workflows, guides et rapports textuels, y compris les rapports historiques. La Bible intégrale Word/PDF v0.9 et son supplément Word/PDF v0.10 resteront identiques octet par octet. Les captures anciennes et les autres compilations historiques restent accessibles dans le dépôt et leurs archives d’origine.

Le ZIP Captures-native réunira **81 fichiers** : les **71 PNG natifs** et les fichiers `MANIFEST.json` et `PROVENANCE.json` de chacun des cinq groupes `baseline`, `continuation`, `equipment`, `lighting_forward` et `lighting_compat`. Leurs chemins `docs/captures/v0.11/<groupe>/` seront conservés sous la racine commune. Ces 81 fichiers seront les seuls éléments déplacés du ZIP Sources vers cette archive de preuves ; les aperçus Blender resteront dans Sources.

Pour réunir le projet et ses preuves visuelles, extraire **Sources** puis, facultativement, **Captures-native** dans le **même dossier parent**. Les deux extractions compléteront ainsi un seul dossier `The-Tower-Descent/`, avec les chemins attendus par les guides et les manifestes. L’archive de captures n’est pas nécessaire pour jouer au programme Windows ou modifier le projet.

`dist/` reçoit l’export Web au commit de livraison. Ce dossier ne constitue pas, à lui seul, la publication d’un site public. Les archives ZIP, caches Godot et Python et rendus temporaires de pages ne seront pas réemballés dans le ZIP Sources. **Chacune des trois archives devra rester strictement sous 100 Mio, soit 104 857 600 octets.** Le rapport final devra comparer l’ensemble exact des membres de chaque archive, leurs tailles et leurs octets avec les fichiers prévus ; séparer les captures ne retire aucun contrôle de complétude ou d’empreinte.

## Construction, examen et livraison

La génération des modèles est une étape distincte, documentée par `ASSET_BOOTSTRAP.json`. Le générateur Blender conserve les pièces nommées dans le fichier source, puis exporte un maillage à plusieurs surfaces par objet. Le vérificateur contrôle les seize identifiants, UV, normales, dimensions, matériaux, empreintes et budgets. Les prévisualisations utilisent Cycles CPU, sans dépendre d’un débruiteur optionnel absent de certains binaires Blender.

La demande `.review/v0.11/build-request.json` est seule dans son commit et nomme son parent immédiat. La phase **review** exige les assets déjà figés, exécute les 37 suites sources, construit les packs Windows/Web et charge leurs ressources depuis des dossiers isolés. Elle produit 71 états natifs : 42 du secteur initial, 13 de continuation, 8 du matériel et les mêmes 4 cadrages sous chacun des deux moteurs. Le rendu Forward+ emploie un affichage natif et un pilote Vulkan logiciel dans la CI ; le manifeste exige le moteur réel et les capacités actives, sans assimiler cette exécution à un benchmark sur GPU de joueur.

Chaque image du jeu et chaque vue Blender nécessite une observation après ouverture du fichier exact. L’approbation lie également les modèles, textures, guides, source éditable et quatre documents préservés à leurs SHA256. Le workflow ne produit pas lui-même cette approbation. Un changement dans le runtime, un test, une fixture, un guide lié ou un outil de livraison invalide les preuves correspondantes.

La phase **release** exige cette revue explicite, vérifie à nouveau les packs, crée les trois ZIP et contrôle chaque membre. Le changement de répartition des archives impose une nouvelle revue complète du candidat gelé avant leur production ; il n’accorde aucune dérogation aux contrôles ou aux empreintes approuvées. La publication avance uniquement `feat/live-tower-collapse` si son commit est toujours celui demandé ; elle ne fusionne pas `main` et ne force pas une branche ayant évolué. Les fichiers sont également conservés dans l’artefact Actions de l’exécution.

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
