# Validation et livraison de la v0.7

Ce document décrit la construction des preuves et des distributions de la v0.7. Les résultats réels se trouvent dans les rapports JSON de cette version. La présence du workflow ne constitue pas un résultat de test.

## Deux étapes distinctes

La phase **review** exécute les suites du jeu, produit les exports Windows et Web, charge leurs ressources dans des répertoires vides, capture les états visuels avec le véritable moteur Godot et construit la bible en Word et PDF. Elle rend également chaque page du PDF en PNG. Ces images permettent une revue visuelle explicite.

La phase **release** exige les revues terminées des captures et de toutes les pages. Elle conserve les octets approuvés du Word, du PDF et des captures. Elle reconstruit les exports, teste leurs packs, crée les archives, puis vérifie les sources, les empreintes et les preuves de livraison avant publication.

La revue de capture ne constitue pas une partie jouée par une personne. Le test d'un pack Windows par Godot Linux ne constitue pas une exécution sous Windows. Le test du PCK Web ne constitue pas un essai WebGL dans un navigateur. L'écoute des sons demande une vérification distincte.

## Déclenchement sur la branche de travail

Le workflow est **.github/workflows/release-v07.yml**. Il accepte uniquement la branche **feat/live-tower-collapse**. Il ne fusionne aucune branche.

Publier d'abord le code, les tests et les sources documentaires. Créer ensuite un commit qui modifie uniquement **.review/v0.7/build-request.json**, avec ce schéma :

~~~json
{
  "format": 1,
  "version": "0.7.0",
  "phase": "review",
  "source_commit": "SHA_DU_COMMIT_IMMEDIATEMENT_PRECEDENT",
  "request_id": "v07-review-01"
}
~~~

Le champ **source_commit** doit contenir les 40 caractères hexadécimaux du commit parent. L'identifiant distingue les demandes successives. Le workflow refuse un commit de demande qui modifie aussi du code ou d'autres fichiers.

Une fois les images inspectées et les éventuels défauts corrigés, publier les revues JSON. Créer alors un nouveau commit de demande avec **phase: "release"** et le SHA de son propre parent. Une modification du runtime ou des sources de la bible impose une nouvelle construction et une revue qui correspond aux nouvelles empreintes.

## Preuves produites

| Fichier ou dossier | Rôle |
| --- | --- |
| docs/validation/v0.7/VERIFICATION.json | Résultats des suites, journaux et empreintes du runtime avant/après. |
| docs/validation/v0.7/EXPORTS.json | Commandes d'export, erreurs éventuelles, octets et empreintes des sorties. |
| docs/validation/v0.7/EXPORTED_PACK_VERIFICATION.json | Tests des deux packs dans des répertoires vides, avec leurs limites explicites. |
| .review/v0.7/request.json | Demande de capture liée au runtime, au script de capture et au rapport de tests. |
| docs/captures/v0.7/CI_PROVENANCE.json | Empreintes des 30 captures, moteur, commit et exécution Actions. |
| docs/captures/v0.7/REVIEW_DERIVATIVES.json | Correspondance entre les grands PNG natifs et leurs JPEG de lecture, avec les deux empreintes. |
| docs/captures/v0.7/review_jpeg/ | Dérivés plein format, qualité 95, uniquement pour les PNG de plus de 900 000 octets. |
| docs/validation/v0.7/DOCUMENT_BUILD.json | Empreintes des 14 sources, des deux formats et de chaque page rendue. |
| docs/validation/v0.7/rendered/ | Images A4 de toutes les pages et texte extrait pour la revue. |
| docs/validation/v0.7/VISUAL_REVIEW.json | Revue explicite du jeu, associée à chaque capture finale. |
| docs/validation/v0.7/DOCUMENT_REVIEW.json | Revue explicite de chaque page finale, associée à son empreinte. |
| releases/VERIFICATION_V0.7.json | Résultat de la vérification finale des archives et de leur cohérence. |
| releases/SHA256SUMS.txt | Empreintes des archives actuelles et historiques conservées. |

Les journaux complets des suites sont conservés. Un message SCRIPT ERROR, ERROR, Parse Error ou FAIL fait échouer le contrôle, même si le processus retourne zéro. Le nombre de vérifications est calculé à partir des sorties effectives des tests.

Les 24 suites obligatoires conservent les 21 domaines de la v0.6 et ajoutent le modèle du dossier de mission, le réalisateur de l’épilogue et leur intégration à la fin de mission. Elles vérifient notamment la cohérence des quatre onglets, les trois plans de clôture, le retour au bilan, la sauvegarde achevée et la relecture sans réécriture des transmissions. Tout fichier supplémentaire **prototype/tests/test_*.gd** est exécuté automatiquement, sauf le test externe des packs qui reste compté séparément.

## Contrat des revues

La revue du jeu doit porter sur les 30 captures finales. Elle conserve **all_pass: true**, le **source_commit** de CI_PROVENANCE.json, et la liste **captures** contenant pour chaque image son nom court et son **sha256**. Une image modifiée ne peut pas réutiliser une ancienne approbation.

Lorsque le lecteur de fichiers ne retourne pas un PNG de plus de 1 Mio, les JPEG dérivés permettent d'examiner son contenu en 1 440 × 900, sans recadrage ni redimensionnement, à la qualité 95 et sans sous-échantillonnage chromatique. Le manifeste relie chaque dérivé au PNG original, vérifie que celui-ci n'a pas changé et conserve leurs empreintes distinctes. La revue indique le fichier réellement affiché et sa méthode de lecture ; ses champs **file** et **sha256** continuent de désigner le PNG natif. Les JPEG sont des copies avec compression destructive destinées à la lecture ; les PNG et leurs contrôles de livraison restent les preuves originales. La création de ces copies ne vaut pas approbation visuelle.

La revue documentaire conserve les 14 sources, les deux formats, le nombre de pages et une entrée par page dans l'ordre. Chaque entrée de **pages** comprend **page**, **status: "pass"** et le **sha256** de l'image effectivement inspectée. Les empreintes doivent correspondre à DOCUMENT_BUILD.json.

Les huit états ajoutés sont les onglets Situation, Rescapés, Indices et Transmissions, les plans d’épilogue échantillonnés à 2, 7 et 12 secondes, puis le bilan au refuge. Les 22 états antérieurs sont également recapturés et revus avec le runtime v0.7. Les noms attendus sont déclarés dans **tools/capture_evidence.py** ; le manifeste doit contenir exactement ces 30 noms, sans doublon.

Le workflow n'écrit aucune approbation visuelle à la place du lecteur. Une nouvelle phase review retire les rapports de revue de la tentative v0.7 précédente pour que des résultats anciens ne puissent pas être confondus avec la nouvelle livraison. Les versions historiques restent intactes.

## Construction documentaire

Le Word provient du générateur du dépôt et de l'intégralité des quatorze sources déclarées. Le runner convertit ce Word avec LibreOffice, puis rend les pages avec Poppler à 2 000 pixels de hauteur. DOCUMENT_BUILD.json précise le logiciel et la police effectivement résolue sur le runner ; document-fonts.txt décrit les polices incorporées au PDF.

La construction sur Actions utilise cette chaîne explicite. Elle ne prétend pas avoir exécuté le moteur de rendu du workspace local lorsqu'il n'est pas disponible. Toutes les pages finales nécessitent une revue visuelle, y compris les pages dont la pagination aurait changé par rapport à la version précédente.

La quatorzième source est **docs/DOSSIER_ET_EPILOGUE_V0.7.md**. Les trois annexes SAUVETAGE_V0.6, AMBIANCE_V0.6 et CONFORT_V0.6 gardent leurs noms et leur contenu de référence ; leur intégralité figure encore dans le volume. Le générateur et le vérificateur exigent la même liste ordonnée de 14 sources.

Les PNG de travail restent accessibles dans le dossier de validation, mais sont exclus de l'archive Sources pour éviter de multiplier le poids du livrable. Le Word, le PDF, les sources complètes et les rapports restent inclus.

## Publication et conservation

Le runner conserve les preuves et les fichiers de plateforme dans un artefact Actions avant toute tentative de publication. Il ne pousse ses fichiers générés que si la branche pointe encore sur le commit demandé. Une évolution concurrente de la branche conserve l'artefact sans forcer l'historique.

Le binaire Windows complet reste dans l'artefact de construction et dans le ZIP Windows ; il n'est pas ajouté individuellement au dépôt. La distribution Web est mise à jour dans dist. Les archives, documents et captures de la v0.6 et des versions antérieures sont conservés.

Les deux packs doivent contenir les modules **mission_dossier.gd**, **mission_dossier_panel.gd** et **epilogue_director.gd**. Le test externe charge leurs ressources dans chaque pack et exerce le dossier ainsi que les plans du réalisateur. Les tests de développement restent exclus des exports. L’archive Sources conserve ces modules, les trois nouvelles suites, la quatorzième source, les 30 captures approuvées et leurs preuves.

La commande de vérification finale contrôle chaque membre de l'archive Sources contre le fichier dont il provient, les deux formats de bible, les preuves visuelles, les journaux, les empreintes des exports, l'exécutable x64 embarqué, les tailles Web et les notices de licence.
