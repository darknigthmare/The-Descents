# Validation de The Tower Descent 0.12

La validation associe les résultats aux fichiers exacts. Les tests de logique, les déplacements physiques, les captures, les exports et les documents ont des portées distinctes.

## 1. Figer la source

Importer et vérifier le projet avec Godot 4.7.2. Le script `tools/run_validation.py` découvre toutes les suites `prototype/tests/test_*.gd`, sauf le test externe réservé aux packs. Les six nouvelles suites requises sont `commerce`, `commerce_integration`, `commerce_routes`, `addon_schema`, `interaction_safety` et `rope_abort`.

Les parcours de civils testent les vrais `CharacterBody3D`, leurs collisions et les appuis. Le guide d’escorte est synthétique ; aucune téléportation de civil n’est utilisée pendant un trajet. Les tests de mission et d’interface préparent leurs placements pour vérifier chaque état et contrôle, sans prétendre jouer une partie humaine complète.

Les modifications de source, fixtures, assets et documents doivent précéder le commit de demande. `.review/v0.12/candidate-request.json` est ensuite seul dans un commit fils du `source_commit` déclaré. Il contient la version, un identifiant de demande, le dictionnaire exact `runtime_sha256` et les deux listes `expected_captures.compatibility` et `expected_captures.forward_plus`.

## 2. Construire la candidature

Le workflow `.github/workflows/commerce-review.yml` s’exécute sur `feat/live-tower-collapse` lorsque ce fichier de demande change. Il utilise `contents: read`, contrôle le parent et les empreintes, puis appelle `tools/build_commerce_candidate.py`.

La construction exécute les suites sources, installe les modèles d’export officiels vérifiés, exporte Windows et Web, puis monte chaque pack dans un dossier isolé avec Godot Linux. `test_exported_pack.gd` vérifie les ressources réellement embarquées et la reprise des états. Ce montage ne lance ni l’EXE sous Windows ni le WebAssembly dans un navigateur.

Les captures emploient un affichage natif sous Xvfb. Dix-huit PNG Compatibility sont attendus : bilan du 23, galerie, volet fermé/ouvert, Retranché proche/apaisé, cuisine avant/après, escalier, rappel, refuge vide/réceptions, dossier personnes/indices, bilan final, accueil et deux interfaces compactes. Les seize premiers font 1440 × 900 ; les deux derniers 1024 × 640.

Une sonde Vulkan détermine si trois cadrages Forward+ peuvent être produits : galerie, cuisine avant intervention et refuge. Une indisponibilité explicite conserve cette limite ; si la sonde réussit, une erreur du moteur ou de la fixture invalide la construction. Les captures déclarent `prepared_states: true` et `human_playthrough: false`.

L’artefact Actions `tower-descent-v012-candidate-<commit>` contient les preuves, captures et exports pendant sept jours. Le workflow ne crée aucune approbation, archive de livraison, modification de branche ou fusion.

## 3. Examiner les fichiers

Ouvrir chaque image native finale. Consigner les observations et SHA256 dans `docs/validation/v0.12/VISUAL_REVIEW.json`, lié au `source_commit`, au commit de demande et au SHA du rapport `CANDIDATE.json`. Une ancienne observation n’est transférable que si les octets sont identiques. Toute correction du runtime nécessite une nouvelle candidature et de nouvelles captures.

Les aperçus des douze modèles sont examinés séparément ; ils proviennent de Blender Cycles et ne sont pas des captures Godot. Les textures sont contrôlées en original et en répétition. Leurs guides et manifestes conservent les limites de production.

Le supplément Word/PDF doit conserver son texte, ses tables et ses neuf pages. `DOCUMENT_CONTENT.json` vérifie le contenu Word dans le PDF. `DOCUMENT_REVIEW.json` lie le Markdown, le générateur, les deux documents, les neuf PNG finaux examinés et leurs observations. Les images de pages sont conservées dans `docs/validation/v0.12/document-pages/`.

## 4. Assembler et vérifier la livraison

Après revue effective, copier l’export Web vérifié dans `dist/`, puis exécuter `tools/package_release.py`. Les ZIP Windows, Sources et Captures-native sont complémentaires. Le contrat de sources conserve tous les modules et assets, les documents courants, la Bible v0.9 et le supplément v0.10, ainsi que les rapports textuels historiques ; les anciennes captures restent dans leurs archives.

`tools/verify_commerce_release.py` confronte la candidature aux tests, packs, images approuvées, documents, runtime, archives et distribution Web. Il exige l’intégrité ZIP, l’ensemble exact des membres, leurs octets, leurs SHA256 et une taille strictement inférieure à 100 Mio pour chaque archive. Son rapport final est `releases/VERIFICATION_V0.12.json`.

La publication ajoute les fichiers validés à la branche existante après vérification de son dernier commit. Elle ne force pas une branche modifiée par ailleurs et ne fusionne pas la PR dans `main`.
