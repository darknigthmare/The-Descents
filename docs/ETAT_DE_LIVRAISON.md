# État de livraison — version 0.7

**25 novembre 2026 — runtime, captures et Bible v0.7 contrôlés.**

La 0.7 poursuit la tranche avec un journal à quatre onglets, un bilan issu des faits de mission et un épilogue en jeu de quinze secondes. Le périmètre jouable reste le toit d’Aube et les étages 30–25. La clôture exige les trois réceptions confirmées, l’incident stabilisé et l’activation du relais au refuge ; elle n’ouvre aucun étage supplémentaire.

## Résultats constatés

| Élément | Résultat | Preuve |
| --- | --- | --- |
| Sources | **24 suites, 4 840 contrôles réussis**, runtime inchangé, aucune erreur moteur détectée | [VERIFICATION.json](validation/v0.7/VERIFICATION.json) |
| Exports Windows et Web | Deux constructions à partir du runtime testé et gelé ; commandes et empreintes consignées | [EXPORTS.json](validation/v0.7/EXPORTS.json) |
| Ressources embarquées | **90 contrôles réussis**, 45 par pack, chargement depuis des dossiers isolés | [EXPORTED_PACK_VERIFICATION.json](validation/v0.7/EXPORTED_PACK_VERIFICATION.json) |
| Rendu du jeu | **30 PNG natifs de 1440 × 900**, tous ouverts et examinés | [Provenance](captures/v0.7/CI_PROVENANCE.json) · [Revue visuelle](validation/v0.7/VISUAL_REVIEW.json) |
| Bible complète | **14 sources, 72 395 mots sources, 149 pages** ; Word de 1 737 paragraphes et 58 tableaux | [DOCUMENT_BUILD.json](validation/v0.7/DOCUMENT_BUILD.json) |
| Revue documentaire | **149 pages finales examinées** ; Word final également rendu avec le moteur documentaire local et comparé au rendu canonique revu | [DOCUMENT_REVIEW.json](validation/v0.7/DOCUMENT_REVIEW.json) |
| Archives de livraison | Le rapport final vérifie les deux ZIP, les fichiers sources, les exports, les captures et les documents approuvés | [VERIFICATION_V0.7.json](../releases/VERIFICATION_V0.7.json) |

La [construction de revue](https://github.com/darknigthmare/The-Descents/actions/runs/45557532133) a réussi. Elle part de la source `50145b56eeb81757a6a318ec3e7a886a5b29ea42`, avec une demande isolée au commit `ca8753a510486e969040460ec0f5db9b75253091`. Les preuves ont été publiées au commit `e8e376c2f88b008728aed3e1f4a3835c042eef63`.

Les rapports de revue relient leurs verdicts aux octets finaux. La phase **release** exige ces revues, reconstruit les exports, recharge leurs ressources et assemble les ZIP. [CI_BUILD.json](validation/v0.7/CI_BUILD.json) donne l’exécution et le commit de cette phase ; le rapport des archives est la référence pour leurs tailles, empreintes et nombre de membres. Une sortie moteur en erreur reste bloquante même si le processus renvoie zéro.

## Ce qui change en 0.7

| Domaine | Comportement livré dans le runtime |
| --- | --- |
| Dossier | Situation, Rescapés, Indices et Transmissions ; lieu, ressources, état structurel et point sûr |
| Vérité des secours | Une personne au harnais ou au treuil reste distincte d’une réception confirmée au toit |
| Indices | Seuls les titres et récits des documents récupérés sont transmis au lecteur ; les autres emplacements restent fermés |
| Transmissions | Jusqu’à 32 échanges reçus, dans leur ordre, avec indicatifs et temps de mission ; aucun ajout dû à une relecture |
| Clôture | Refuge 25, trois personnes confirmées et incident stabilisé ; sauvegarde réussie avant toute présentation de fin |
| Échec d’écriture | Ancien point sûr préservé, intervention encore active, message visible et relais réessayable |
| Épilogue | Quinze secondes, trois plans de cinq secondes : poste médical, terminal du refuge et tours après impact |
| Pause et confort | Horloge de présentation indépendante, monde figé, pause et options cohérentes, cadrages fixes en mouvements réduits |
| Bilan | Trois cartes nominatives, preuves, durée, ressources, fragment du relais et trois actions de consultation |
| Reprise et relecture | Une mission terminée s’ouvre au bilan ; revoir la séquence ne réécrit ni la sauvegarde ni la radio |

La caméra du poste médical cadre les trois places de réception avec les équipiers au premier plan. L’un d’eux recouvre partiellement le bord proche de la civière d’Ana ; Ana et sa prise en charge restent identifiables. Le terminal du refuge et les tours après impact sont visibles dans leurs plans respectifs. Ces observations concernent les images exactes, pas des assets définitifs.

## Ouverture et intervention conservées

La signature du studio dure **quinze secondes** et l’arrivée **vingt-huit secondes en quatre plans**. Deux hélicoptères se posent, ouvrent leurs portes et déposent les six membres des toits. L’accueil correspond au dernier point sûr : approche, toit ou étage atteint, avant ou après l’incident, jusqu’au refuge final.

Le parcours conserve Ana Rios, Samuel Breton et Nora Haddad, trois preuves, deux réserves, douze observations facultatives, rappel guidé, ancrages, radio, journal, lampe, fusées et refuge. Le portage de première personne, le panier et le câble rendent le secours visible. Le treuil dure cinq secondes ; une prise en charge cosmétique de 4,2 secondes suit la confirmation médicale. Un rechargement restaure directement les places finales.

Après le premier sauvetage et le départ des appareils, l’observation à la baie Est du 29 déclenche l’effondrement. Le détour après l’impact et le repli de Bravo restent liés à l’état stable de l’incident. Le ciel maritime, la pluie, la mer et les réglages de confort sont conservés. La sauvegarde reste au schéma 3, avec migration stricte des versions 1 et 2.

## Livrables

- [Windows x64 v0.7](../releases/The-Tower-Descent-v0.7-Windows-x64.zip) et [guide de démarrage](DEMARRAGE_WINDOWS.md).
- [Projet et sources v0.7](../releases/The-Tower-Descent-v0.7-Sources.zip).
- [Bible Word v0.7](The-Tower-Descent-Bible-v0.7.docx) et [Bible PDF v0.7](The-Tower-Descent-Bible-v0.7.pdf).
- [Galerie des 30 captures](CAPTURES_V0.7.md).
- [Exports, provenance et licences](EXPORTS.md).
- [Empreintes des archives](../releases/SHA256SUMS.txt).

La PR reste ouverte en brouillon sur `feat/live-tower-collapse`. Cette continuation ne fusionne pas `main`. Les archives des versions précédentes sont conservées.

## Portée des vérifications et limites de production

Le moteur utilisé est **Godot 4.7.2 officiel, Compatibility**, sous Linux pour la construction et les captures. Les ressources de Windows x64 et du Web sont chargées séparément sous Godot Linux. Ce contrôle ne constitue pas une exécution de l’EXE sur un PC Windows ni une partie Web dans un navigateur. Aucun relevé de performances sur machines cibles n’est revendiqué. Les images proviennent d’états préparés ; les suites d’intégration contrôlent séparément pause, passage, reprise, sauvegarde et relecture.

Le PDF final est issu du Word via LibreOffice 24.2 et Poppler dans la construction CI. La police demandée Arial y est résolue en Liberation Sans. Les 149 PNG de ce PDF ont été examinés directement. Le Word final a aussi été rendu par `render_docx.py` : les 149 pages obtenues sont identiques aux pages canoniques déjà examinées. Les deux DOCX comparés ont les mêmes 19 membres décompressés ; seule leur enveloppe ZIP diffère. Les empreintes et la portée de chaque revue figurent dans le rapport documentaire.

Les blancs de fin d’annexe sont conservés. Une coupure entre les pages 143 et 144 sépare le guillemet fermant de « ÉVAC. » ; le texte reste complet et le guillemet ouvre une ligne de prose, sans ligne isolée. Ce détail typographique est consigné comme observation non bloquante. Une autre installation Word peut produire une pagination différente.

Figures, hélicoptères, sangles, poses et décors sont procéduraux. La réception suit des trajectoires préparées, sans navigation autonome, contacts physiques des mains ou animation faciale. Le câble est calculé ; les cinq secondes de treuil compressent le temps de secours. Les sous-titres sont présents ; les voix ne sont pas doublées. Le remappage complet reste à produire. Le fond des options conserve une transparence légère sans gêner les contrôles.

La campagne complète, Alma, la piscine, l’intérieur d’Hespérie, les cavernes, le bunker, le seuil 666, les fins, Mountain Hole et UE5 gardent leur statut de conception. Ces cibles sont décrites dans la bible et ne sont pas annoncées comme des niveaux jouables livrés.

## Repère historique

La livraison **v0.6** reste conservée avec ses propres preuves : 21 suites et 4 500 contrôles sources, 60 contrôles de packs, 22 captures et 139 pages issues de 13 sources. Son [rapport d’archives](../releases/VERIFICATION_V0.6.json) reste distinct. Les chiffres de cette section ne servent pas de validation à la v0.7.

Les contrats détaillés figurent dans [Sauvetage](SAUVETAGE_V0.6.md), [Ambiance](AMBIANCE_V0.6.md), [Confort](CONFORT_V0.6.md), [Gameplay](GAMEPLAY_DETAILLE.md), [Scènes](SCENES_CINEMATIQUES.md) et [Dossier et épilogue](DOSSIER_ET_EPILOGUE_V0.7.md). Les noms historiques des trois annexes v0.6 sont conservés ; leurs contrats restent applicables à la tranche actuelle.
