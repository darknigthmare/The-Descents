# État de livraison — version 0.8

**25 novembre 2026 — candidat 0.8.0 en préparation.**

La 0.8 aligne le premier secteur sur une horreur progressive : présence périphérique au 29, traces humides après impact au 28 et présence stationnaire au spa du 26. L’ancienne poursuite avec dégâts d’E00 est remplacée par une manifestation perceptive. Le périmètre jouable reste le toit et les étages 30–25.

Le canon de campagne est précisé : les hallucinations possibles du début cèdent progressivement à des phénomènes persistants, à des humains dangereux puis à la découverte des expériences SILLAGE avec une dimension infernale réelle. Le joueur devra franchir le seuil et atteindre physiquement l’Enfer dans la campagne. Les humains hostiles, les laboratoires profonds, la brèche et l’Enfer restent des contenus à produire.

## Statut du candidat v0.8

Les chiffres de cette table sont **les exigences du contrat**, pas des résultats déjà obtenus. Les comptes de contrôles réussis, la pagination et le volume de mots seront établis à partir des sorties effectives. Les preuves historiques v0.7 ne valent pas validation de la v0.8.

| Élément | Contrat | Preuve à produire |
| --- | --- | --- |
| Sources | 26 suites obligatoires, dont manifestations et intégration ; runtime inchangé et absence d’erreur moteur | [VERIFICATION.json](validation/v0.8/VERIFICATION.json) |
| Windows et Web | Deux exports issus du runtime testé, avec commandes, octets et empreintes | [EXPORTS.json](validation/v0.8/EXPORTS.json) |
| Ressources embarquées | Deux packs chargés séparément dans des dossiers vides ; nouveaux modules et son positionnel réellement présents | [EXPORTED_PACK_VERIFICATION.json](validation/v0.8/EXPORTED_PACK_VERIFICATION.json) |
| Rendu du jeu | 33 captures natives de 1440 × 900, dont les trois manifestations | [CI_PROVENANCE.json](captures/v0.8/CI_PROVENANCE.json) |
| Revue du jeu | Chaque PNG final examiné et associé à son empreinte et à une observation | [VISUAL_REVIEW.json](validation/v0.8/VISUAL_REVIEW.json) |
| Bible complète | 15 sources intégrales ; Word et PDF, chaque page rendue | [DOCUMENT_BUILD.json](validation/v0.8/DOCUMENT_BUILD.json) |
| Revue documentaire | Chaque page finale examinée ; mêmes sources et artefacts que la construction | [DOCUMENT_REVIEW.json](validation/v0.8/DOCUMENT_REVIEW.json) |
| Archives | ZIP Windows et Sources, intégrité, fichiers approuvés et cohérence des livrables | [VERIFICATION_V0.8.json](../releases/VERIFICATION_V0.8.json) |

La [procédure v0.8](VALIDATION_V0.8.md) sépare **review** et **release**. La première construit les preuves ; la seconde exige les revues correspondantes puis reconstruit les exports et vérifie les archives. Le workflow n’écrit pas d’approbation visuelle automatique. Chaque phase est déclenchée par une demande isolée, après les sources ou les revues concernées.

## Comportements visés dans cette continuation

| Domaine | Comportement v0.8 |
| --- | --- |
| Suites 29 | Présence humaine fugace à la périphérie du regard ; aucun démon montré dès le début |
| Archives 28 | Traces humides après l’impact ; leur persistance laisse un constat encore interprétable |
| Spa 26 | Présence stationnaire avec rémanence ; E00 ne poursuit plus le joueur et n’inflige plus de dégâts |
| Priorités | Rappel, portage, treuil, radio et incident gardent la priorité sur les manifestations |
| Présentation | Effets dans le monde 3D, aucun collider ajouté aux routes, aucun flash ni caméra forcée |
| Son | Pas discrets positionnels, originaux ; pause, volume et coupure du son cohérents avec les réglages |
| Sauvegarde | Schéma 3 conservé ; le dossier et les secours ne reçoivent pas de fausses preuves ou réceptions |
| Révélation future | Dimension infernale réelle, expériences humaines et passage physique en Enfer ; connaissance progressive d’Alex |

La Bible inclut une nouvelle annexe [Progression de l’horreur](PROGRESSION_HORREUR_V0.8.md). Le catalogue passe à **60 props** ; le dossier des menaces distingue **E00** et **16 archétypes de campagne**. Les comportements futurs, leurs valeurs proposées et leurs props ne sont pas annoncés comme des systèmes déjà jouables.

## Parcours conservé

La signature du studio dure quinze secondes ; l’arrivée en quatre plans dure vingt-huit secondes. Deux hélicoptères se posent et les équipes gagnent leurs postes. L’accueil reconstruit le dernier point sûr et la situation des tours.

Ana Rios, Samuel Breton et Nora Haddad conservent leurs sauvetages au 30, au 28 et au 26. Le portage visible, les cinq secondes de treuil et la réception médicale de 4,2 secondes sont conservés. L’incident observé à la baie Est du 29 modifie le passage du 28, sans annuler les personnes déjà reçues.

Les trois indices, deux réserves, douze observations, le rappel, les ancrages, les fusées, la lampe et la radio restent présents. Le journal possède quatre onglets. Le refuge 25 exige une sauvegarde finale réussie avant l’épilogue de quinze secondes ; reprise et relecture conservent le bilan sans rejouer les secours ni réécrire les transmissions.

## Dernière livraison validée conservée : v0.7

La v0.7 reste accessible pendant la préparation : **24 suites et 4 840 contrôles sources**, **90 contrôles de packs**, **30 captures** et **149 pages issues de 14 sources**. Ces résultats appartiennent à son runtime et à ses fichiers exacts.

- [Windows x64 v0.7](../releases/The-Tower-Descent-v0.7-Windows-x64.zip).
- [Sources v0.7](../releases/The-Tower-Descent-v0.7-Sources.zip).
- [Bible Word v0.7](The-Tower-Descent-Bible-v0.7.docx) et [Bible PDF v0.7](The-Tower-Descent-Bible-v0.7.pdf).
- [Captures v0.7](CAPTURES_V0.7.md) et [rapport d’archives v0.7](../releases/VERIFICATION_V0.7.json).

Les archives et preuves antérieures sont conservées. La PR reste ouverte en brouillon sur `feat/live-tower-collapse` ; le pipeline ne fusionne pas `main`.

## Portée de la validation et de la production

Godot 4.7.2 officiel, rendu Compatibility, est utilisé sous Linux pour la construction et les captures. Le chargement des ressources de l’EXE Windows sous Godot Linux ne constitue pas une exécution du programme sur un PC Windows. Le chargement du PCK Web ne constitue pas une partie WebAssembly/WebGL dans un navigateur. Aucun résultat de performances sur matériel cible ni mixage sonore final n’est déduit des tests automatisés.

Les captures partent d’états préparés. Elles doivent être examinées à leur dimension native, puis reliées aux empreintes finales. Les transitions, les priorités et l’absence de dommages demandent également les suites de logique et d’intégration. Une image d’apparition ne constitue pas une vidéo intégrale du phénomène.

Le Word complet provient des quinze sources. Le PDF est converti par LibreOffice puis rendu par Poppler dans la construction CI ; le rapport consigne les polices effectivement résolues. Chaque page finale doit faire l’objet d’une revue visuelle, y compris lorsque son numéro a changé depuis la v0.7. Un nombre de pages calculé ne vaut pas approbation de mise en page.

Personnages, hélicoptères, décors, matériaux et poses restent procéduraux. Le jeu d’acteurs, le doublage, les assets définitifs, le remappage complet et les essais sur matériels cibles restent à produire. Les références à Condemned et Doom guident la tension et la révélation ; le jeu conserve ses personnages, créatures et lieux originaux.

La campagne complète, les humains hostiles, les laboratoires profonds, Alma, la piscine, l’intérieur d’Hespérie, les cavernes, le bunker, le seuil 666, l’Enfer, les fins, Mountain Hole et UE5 gardent un statut de conception. La réalité de la dimension infernale dans le canon ne signifie pas que sa traversée est livrée dans le prototype actuel.
