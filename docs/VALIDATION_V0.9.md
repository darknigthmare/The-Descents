# Validation et livraison de la v0.9

Ce document décrit la construction des preuves et des distributions de la v0.9. Les résultats réels appartiennent aux rapports JSON produits pour cette version. L’existence d’un test, d’une capture attendue ou d’un workflow ne constitue pas un résultat réussi.

## 1. Construction de revue et construction de livraison

La phase **review** exécute les suites du jeu sur les sources figées, construit les exports Windows et Web, charge leurs ressources depuis des répertoires vides et produit les captures avec le moteur Godot. Elle construit également le Word complet, convertit le PDF et rend chaque page de ce PDF en PNG. Ces preuves restent à examiner.

La phase **release** exige les revues terminées des images et de chaque page finale. Elle conserve les octets approuvés du Word, du PDF et des captures. Elle reconstruit les exports à partir du même runtime, teste les deux packs, crée les archives et vérifie leur contenu exact avant publication.

Les deux phases utilisent Godot 4.7.2 officiel. Le workflow vérifie l’empreinte de l’archive moteur et les fichiers des modèles d’export fixés. Une erreur du moteur, un test manquant ou une empreinte différente bloque la livraison. Aucune phase n’écrit une approbation visuelle à la place du lecteur.

La revue de captures ne constitue pas une partie humaine complète. Le test d’un pack Windows sous Godot Linux ne constitue pas une exécution du programme sur Windows ; le test du PCK Web ne lance pas WebAssembly ou WebGL dans un navigateur. Les ressources audio chargées ne certifient ni l’écoute ni le mixage sonore final.

## 2. Déclenchement sur la branche de travail

Le nouveau workflow est **.github/workflows/release-v09.yml**. Il accepte uniquement la branche **feat/live-tower-collapse** et ne fusionne aucune branche. Les workflows des versions précédentes restent conservés.

Publier d’abord le code, les tests, les sources documentaires et les scripts de construction. Créer ensuite un commit qui modifie uniquement **.review/v0.9/build-request.json** :

```json
{
  "format": 1,
  "version": "0.9.0",
  "phase": "review",
  "source_commit": "SHA_DU_COMMIT_IMMEDIATEMENT_PRECEDENT",
  "request_id": "v09-review-01"
}
```

Le SHA contient les quarante caractères hexadécimaux du parent immédiat. L’identifiant distingue les tentatives. Le garde refuse une demande mélangée à d’autres changements, une autre branche, une version incohérente ou un checkout différent du commit demandé.

Après examen des fichiers exacts, publier les revues JSON. Créer un second commit de demande avec **phase: "release"** et le SHA de son propre parent. Un changement du runtime, du script de capture ou des sources de la Bible impose de renouveler les preuves affectées et leurs revues. Une ancienne approbation ne peut pas être transférée à des fichiers modifiés.

## 3. Preuves produites

| Fichier ou dossier | Fonction |
| --- | --- |
| docs/validation/v0.9/VERIFICATION.json | Suites exécutées, journaux, compteurs et empreintes du runtime avant/après. |
| docs/validation/v0.9/EXPORTS.json | Commandes d’export, journaux, tailles et empreintes des sorties. |
| docs/validation/v0.9/EXPORTED_PACK_VERIFICATION.json | Contrôles des packs Windows et Web, chargés séparément depuis des dossiers vides. |
| .review/v0.9/request.json | Demande de capture liée au runtime, au script de capture et aux tests. |
| docs/captures/v0.9/CI_PROVENANCE.json | Empreintes des 42 PNG, moteur, commit et exécution Actions. |
| docs/captures/v0.9/REVIEW_DERIVATIVES.json | Correspondance entre les grands PNG et leurs JPEG de lecture éventuels. |
| docs/captures/v0.9/review_jpeg/ | Copies de consultation à la même dimension, sans recadrage. |
| docs/validation/v0.9/DOCUMENT_BUILD.json | Les 16 sources, le Word, le PDF et chaque page rendue reliés par empreinte. |
| docs/validation/v0.9/rendered/ | PNG de toutes les pages du PDF et texte extrait pour la revue. |
| docs/validation/v0.9/VISUAL_REVIEW.json | Décision et observation explicites pour chaque capture native finale. |
| docs/validation/v0.9/DOCUMENT_REVIEW.json | Revue des formats documentaires et de chaque page finale. |
| releases/VERIFICATION_V0.9.json | Résultat des contrôles des archives, de leur contenu et des preuves. |
| releases/SHA256SUMS.txt | Empreintes des archives courantes et historiques conservées. |

Les journaux complets restent disponibles. **SCRIPT ERROR**, **ERROR**, **Parse Error** ou **FAIL** rendent un contrôle négatif même si le processus renvoie zéro. Les compteurs proviennent des sorties effectives ; le pipeline n’inscrit pas une valeur prévue à la place d’un résultat.

## 4. Suites de logique et de parcours

Les **29 suites obligatoires** conservent les 26 domaines de la v0.8 et ajoutent **rope_traversal**, **vertical_routes** et **traversal_integration**. Tous les fichiers supplémentaires **prototype/tests/test_*.gd** sont exécutés, sauf le test externe des packs qui est compté séparément.

Le modèle de rappel doit vérifier les bornes d’un lien local, les deux sens, l’accélération, le frein automatique, le verrouillage persistant, la priorité du mode précis, l’endurance, la récupération sans chute forcée, la stabilisation, la pause et la réconciliation d’une position de capsule arrêtée par une collision. Les entrées invalides ne doivent pas corrompre une corde active.

Les contrôles de parcours portent sur la topologie des six liens adjacents, les escaliers réellement franchissables, les volumes de passage, les sorties de rappel et la séparation avec le treuil de secours. Un placement initial de fixture est distingué d’un déplacement physique : un changement direct de coordonnées ne vaut pas preuve qu’un escalier ou un seuil est praticable.

L’intégration doit également conserver les priorités de mission : portage, treuillage, incident, dossier, options, reprise et points sûrs. Le passage sur un palier intermédiaire d’escalier ne doit pas créer un checkpoint à mi-hauteur. Les modules de route et de rappel ne changent pas le schéma 3 et ne créent pas de reçu de secours.

Les suites de routes utilisent le même pas de physique de soixante hertz avec un rendu accéléré lorsque le mode **--fixed-fps 60** est applicable. Le résultat reste lié aux scripts et au runtime dont les empreintes sont consignées, et non à un simple numéro de version.

## 5. Contrat des 42 captures natives

Les 33 états antérieurs sont recapturés avec le runtime v0.9. Les neuf vues supplémentaires attendues sont :

| Nom | État examiné |
| --- | --- |
| 29_station_rappel_toit.png | Station personnelle du toit et accès au premier rappel. |
| 30_rappel_descente.png | Descente, corde, descendeur et informations de contrôle. |
| 31_rappel_verrouille.png | Verrouillage persistant et état d’arrêt. |
| 32_escalier_30_29.png | Accès local du restaurant vers les suites. |
| 33_escalier_palier.png | Palier intermédiaire, garde-corps et continuité des deux volées. |
| 34_rappel_remontee.png | Remontée et présentation de l’effort. |
| 35_aide_deplacements.png | Aide des commandes de marche, escaliers et rappel. |
| 36_escalier_28_27.png | Liaison locale des archives vers le jardin. |
| 37_escalier_26_25.png | Dernière liaison locale vers le refuge. |

Le manifeste doit contenir exactement les 42 noms déclarés dans **tools/capture_evidence.py**, sans doublon. Les PNG doivent provenir du rendu natif Compatibility et mesurer **1 440 × 900 pixels**. Le manifeste signale que les états sont préparés et qu’aucune partie humaine complète n’est certifiée.

La revue conserve **all_pass: true**, le **source_commit** de la provenance, puis une entrée **captures** pour chaque PNG avec **file**, **sha256**, **status: "pass"** et les observations du lecteur. Les empreintes doivent désigner les fichiers effectivement produits. Toute image modifiée exige un nouvel examen.

Pour les lecteurs qui refusent un PNG de plus d’un Mio, le pipeline peut produire une copie JPEG de qualité 95, en 4:4:4, sans recadrage ni redimensionnement. Le manifeste de dérivation relie les deux empreintes et contrôle que l’original reste inchangé. La revue nomme le fichier réellement affiché ; les champs d’identité de la capture continuent de désigner le PNG natif. La conversion JPEG ne constitue jamais une approbation visuelle.

Les tests du modèle ou de géométrie ne prouvent pas, à eux seuls, la qualité du cadrage, la lisibilité du HUD, la pose des mains ou l’absence d’intersections visibles. Inversement, une capture d’escalier ne prouve pas son franchissement physique : ces éléments relèvent de contrôles complémentaires.

## 6. Bible complète et revue des pages

Le générateur Word reprend intégralement **seize sources** dans l’ordre de **PARTS**, identique à **DOCUMENT_SOURCES**. La nouvelle seizième source est **docs/TRAVERSEE_ET_RAPPEL_V0.9.md**, ajoutée comme annexe N. La progression de l’horreur reste **docs/PROGRESSION_HORREUR_V0.8.md** ; les annexes de secours, d’ambiance, de confort et de dossier conservent également leurs noms historiques.

Les contenus sont compilés dans **The-Tower-Descent-Bible-v0.9.docx**. Le runner convertit ce Word en PDF avec LibreOffice, puis rend toutes les pages à 2 000 pixels de hauteur avec Poppler. **DOCUMENT_BUILD.json** décrit la conversion, les logiciels, les polices résolues, le nombre effectif de pages et les empreintes. Le nombre de pages n’est pas annoncé avant la construction finale.

La revue documentaire couvre les seize sources et les deux formats. Chaque entrée de **pages** fournit le numéro, la décision et l’empreinte du PNG examiné, dans l’ordre complet. Les empreintes et le nombre de pages doivent correspondre à **DOCUMENT_BUILD.json**. Les formats Word et PDF ne peuvent pas être remplacés après leur revue par une conversion différente, même si le texte paraît identique.

Le rendu canonique local du Word, lorsqu’il est utilisé pour examiner le document éditable, doit identifier ses fichiers exacts et rester distinct du rendu du PDF produit sur Actions. Une correspondance prouvée des fichiers peut relier deux examens ; le seul succès d’une conversion ne permet jamais de déclarer une page approuvée.

Une nouvelle phase **review** retire les approbations de la tentative v0.9 précédente avant de produire ses preuves. Les validations historiques restent intactes. Les PNG de travail des pages sont conservés pour la revue, mais ne sont pas copiés dans le ZIP Sources.

## 7. Contrôles des exports

Le test externe **test_exported_pack.gd** est fourni par son chemin absolu, depuis un répertoire vide, à Godot chargé avec **--main-pack**. Les ressources **res://** proviennent donc du pack de l’EXE Windows ou du PCK Web, et non d’un voisinage de sources locales.

Les modules **route_catalog.gd**, **rope_traversal.gd** et **rope_presentation.gd** doivent être présents et chargeables. Le test examine les six liens, leur alternance, l’attache, le mouvement, le verrouillage, le gel en pause, la stabilisation, la limite locale et la sortie vers le palier attendu. Il instancie le descendeur et ses mains, échantillonne leur état et vérifie qu’ils n’ajoutent pas de collider. Ces contrôles ne déclarent pas la présentation visuellement approuvée.

Les contrôles conservés portent aussi sur les menus, cinématiques, secours, dossier, épilogue, manifestations perceptives, sons importés, sauvegardes et préférences. Les tests de développement restent exclus des ressources exportées. Les empreintes des packs sont contrôlées avant et après leur chargement.

## 8. Contenu exact du ZIP Sources v0.9

À partir de cette livraison, le ZIP Sources contient **tous les modules, assets actifs, tests, guides Markdown, rapports textuels, scripts, workflows et demandes de construction**, ainsi que **les captures et les Word/PDF de la version courante uniquement**.

Les captures des versions antérieures et leurs anciennes Bibles compilées ne sont plus recopiées dans chaque nouvelle archive. Elles restent intégralement conservées dans le dépôt GitHub et dans les ZIP historiques. Cette sélection évite que l’accumulation de médias identiques fasse dépasser la limite de publication d’un fichier. Elle ne retire aucun code actif, aucun contenu source de la Bible et aucun rapport historique textuel.

La sélection est définie par **source_package_paths()** dans **tools/qa_common.py**. Le constructeur et le vérificateur utilisent cette même fonction. Le contrôle exige l’égalité de l’ensemble complet des membres, puis compare les octets de chaque membre à son fichier d’origine. Il ne se contente pas de rechercher quelques fichiers indispensables.

Les archives Windows et Sources courantes doivent mesurer strictement moins de **100 Mio**, soit **104 857 600 octets** chacune. Une archive trop grande bloque la livraison. Le rapport final indique la portée du ZIP Sources, la vérification de son ensemble exact de membres et cette limite.

Les exclusions usuelles restent les caches Godot et Python, les sorties visuelles temporaires, les journaux temporaires et les PNG de rendu des pages. Le ZIP Sources n’inclut ni les autres ZIP ni la distribution Web **dist/**. Le Word/PDF courant, les 42 captures, leurs éventuels JPEG de lecture, les sources intégrales et les rapports sont inclus.

## 9. Publication et conservation

Le runner conserve les preuves et les fichiers de plateforme dans un artefact Actions avant de publier. Il ne pousse ses sorties générées que si la branche pointe encore sur le commit demandé. Si la branche a avancé, l’artefact est conservé et aucun historique n’est forcé.

L’exécutable Windows complet reste dans l’artefact et dans le ZIP Windows ; il n’est pas ajouté individuellement au dépôt. La distribution Web est mise à jour dans **dist/**, avec les notices requises. Les archives, documents, captures et rapports historiques de la v0.8 et des versions précédentes ne sont ni supprimés ni réécrits.

La vérification finale couvre l’intégrité ZIP, les empreintes des archives, chaque source embarquée, les formats de Bible approuvés, les captures, les journaux de tests, l’identité des exports, l’exécutable PE x64, les tailles Web et les licences. La description de la PR doit citer les résultats de cette vérification finale et distinguer le jeu effectivement livré des objectifs de campagne.
