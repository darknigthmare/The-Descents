# État de livraison — version 0.9

**25 novembre 2026 — Version 0.9.0.**

La 0.9 développe la circulation du toit au refuge 25 : trois rappels personnels alternent avec trois escaliers praticables, chacun entre deux étages adjacents. Le joueur peut revenir par les mêmes passages. Les rappels ajoutent montée, descente, précision, accélération, frein automatique, verrou persistant, repos assuré, stabilisation et transferts confrontés aux collisions. L’ouverture, les secours, le dossier, l’épilogue et l’horreur progressive de la 0.8 restent dans cette tranche.

Le canon conserve la progression **perceptions discrètes → phénomènes persistants → humains dangereux → expériences SILLAGE → passage physique en Enfer**. Les humains hostiles, les laboratoires profonds et la dimension infernale restent des contenus de campagne à produire.

## Résultats et preuves v0.9

Le contrat prévoit **29 suites**, **42 captures natives**, **16 sources documentaires** et **64 fiches de props**. Les résultats ci-dessous proviennent des rapports de la construction finale. Aucune revue n’est déduite de la simple création des fichiers.

| Élément | Résultat et portée v0.9 | Preuve |
| --- | --- | --- |
| Sources | Validés — 6 989 contrôles dans 29 suites | [VERIFICATION.json](validation/v0.9/VERIFICATION.json) |
| Windows et Web | Construits, ressources vérifiées — deux exports, commandes, octets et empreintes du runtime | [EXPORTS.json](validation/v0.9/EXPORTS.json) |
| Ressources embarquées | Conformes — 140 contrôles dans deux packs chargés séparément depuis des dossiers vides | [EXPORTED_PACK_VERIFICATION.json](validation/v0.9/EXPORTED_PACK_VERIFICATION.json) |
| Rendu du jeu | 42/42 produites avec le moteur natif — 42 noms attendus, PNG natifs de 1440 × 900 | [CI_PROVENANCE.json](captures/v0.9/CI_PROVENANCE.json) |
| Revue du jeu | 42/42 examinées individuellement par l’assistant — observations et SHA256 des fichiers effectivement examinés | [VISUAL_REVIEW.json](validation/v0.9/VISUAL_REVIEW.json) |
| Bible complète | 16 sources, 93 871 mots sources, 186 pages PDF, 2 116 paragraphes et 71 tableaux principaux du Word | [DOCUMENT_BUILD.json](validation/v0.9/DOCUMENT_BUILD.json) |
| Complétude documentaire | Contrôle ordonné de tous les paragraphes, lignes et cellules du Word dans le PDF exact ; résultat dans le rapport | [DOCUMENT_CONTENT.json](validation/v0.9/DOCUMENT_CONTENT.json) |
| Revue documentaire | 186/186 pages PDF examinées ; Word contrôlé séparément sur 186 pages — Word, PDF et chaque page finale reliés à leurs empreintes | [DOCUMENT_REVIEW.json](validation/v0.9/DOCUMENT_REVIEW.json) |
| Archives | Tailles, empreintes, nombre de membres et résultat consignés après emballage | [VERIFICATION_V0.9.json](../releases/VERIFICATION_V0.9.json) |

La [construction de revue v0.9](https://github.com/darknigthmare/The-Descents/actions/runs/45632857245) identifie la source [`9c55464aee77cb95e1282b518696e5af5f694845`](https://github.com/darknigthmare/The-Descents/commit/9c55464aee77cb95e1282b518696e5af5f694845) et la demande [`96e278c0e6bcc0e756b5418129317f04d44650ff`](https://github.com/darknigthmare/The-Descents/commit/96e278c0e6bcc0e756b5418129317f04d44650ff). Le [rapport final des archives](../releases/VERIFICATION_V0.9.json) consigne les mesures après emballage. Les exécutions de livraison et les fichiers publiés se retrouvent dans [l’historique Actions](https://github.com/darknigthmare/The-Descents/actions/workflows/release-v09.yml) et [l’historique de la branche](https://github.com/darknigthmare/The-Descents/commits/feat/live-tower-collapse/).

La [procédure v0.9](VALIDATION_V0.9.md) sépare **review** et **release**. La première produit les preuves ; la seconde exige les revues des fichiers exacts, reconstruit les exports et vérifie les archives. Le workflow n’écrit aucune approbation visuelle automatique. Une nouvelle construction invalide les verdicts attachés à des fichiers modifiés.

## Accès à la version 0.9

- [Windows x64 v0.9](../releases/The-Tower-Descent-v0.9-Windows-x64.zip) · [Sources actives et documents v0.9](../releases/The-Tower-Descent-v0.9-Sources.zip).
- [Bible Word v0.9](The-Tower-Descent-Bible-v0.9.docx) · [Bible PDF v0.9](The-Tower-Descent-Bible-v0.9.pdf).
- [Catalogue des 42 captures v0.9](CAPTURES_V0.9.md) · [Démarrage Windows](DEMARRAGE_WINDOWS.md) · [Empreintes des archives](../releases/SHA256SUMS.txt).

## Traversée effectivement intégrée

| Liaison | Descente | Retour |
| --- | --- | --- |
| R31_30 — rappel | Toit → restaurant 30 | Remontée au toit |
| S30_29 — escalier | Restaurant 30 → suites 29 | Marche vers le 30 |
| R29_28 — rappel | Suites 29 → archives 28 | Remontée au 29 |
| S28_27 — escalier | Archives 28 → jardin 27 | Marche vers le 28 |
| R27_26 — rappel | Jardin 27 → spa 26 | Remontée au 27 |
| S26_25 — escalier | Spa 26 → refuge 25 | Marche vers le 26 |

Les rappels se trouvent dans la moitié ouest du puits. Les stations bleues annoncent la paire desservie ; le treuil orange des rescapés conserve son trajet séparé vers le toit. Les escaliers comprennent deux volées, un palier intermédiaire et des garde-corps. Ils utilisent la marche et les collisions de la capsule, dans les deux sens.

| Domaine | Comportement v0.9 |
| --- | --- |
| Rappel local | Une paire d’étages adjacents ; limites haute et basse, chemin de retour |
| Mouvement | Descente 2,8 m/s ; montée 1,6 ; précision 0,75 ; descente rapide 4,2 |
| Frein et verrou | Relâcher freine automatiquement ; Espace conserve le verrou jusqu’au prochain appui |
| Endurance | Montée et descente rapide consomment ; repos récupère ; zéro impose un arrêt assuré sans chute forcée |
| Stabilisation | X agit seize secondes ; consommation seulement sur activation acceptée, sans doublon actif |
| Raccordements | Entrée et sortie de 0,85 s, capsule confrontée au décor, attache conservée pendant le transfert |
| Sortie | Terminal à ±0,45 m, vitesse ≤0,05 m/s, balancement ≤0,25 m et passage dégagé |
| Palier de mission | Hors corde et escalier, support sous les pieds, vitesse verticale ≤0,15 m/s et hauteur de dalle à ±0,35 m |
| Sauvegarde | Demande pendant une liaison différée au prochain palier stable ; schéma 3 conservé |
| Secours | Rappel personnel avec mains libres ; extraction à la balise orange de l’étage du rescapé |
| Présentation | Corde, descendeur, mousqueton, mains, état de verrou et mesures dans le HUD |
| Confort | Pause de l’horloge et de l’endurance ; mouvements réduits pour la présentation |

La nouvelle annexe [Traversée et rappel](TRAVERSEE_ET_RAPPEL_V0.9.md) décrit les règles, les données, les scènes, les erreurs de parcours, les props et les pistes de campagne. Les fiches P61 à P64 portent le catalogue à **64 références**. Elles complètent les douze observations facultatives déjà jouables.

## Parcours et mise en scène conservés

La signature dure quinze secondes ; l’arrivée en quatre plans dure vingt-huit secondes. Les deux hélicoptères se posent et les équipes gagnent leurs postes. L’accueil reconstruit le dernier point sûr et l’état des tours.

Ana Rios, Samuel Breton et Nora Haddad restent au 30, au 28 et au 26. Le portage visible, les cinq secondes de treuil et la réception médicale de 4,2 secondes restent présents. Après la première réception et le départ des appareils, l’observation de Bravo à la baie Est du 29 déclenche l’incident : alerte, secousse, basculement et impact. Le passage Est du 28 est remplacé par un détour intérieur ; les liaisons verticales restent accessibles.

Le dossier conserve Situation, Rescapés, Indices et Transmissions. Sa Situation distingue maintenant la liaison en cours, l’étage réellement atteint et le point sûr enregistré. Après les trois réceptions et la stabilisation, le relais du 25 enregistre la clôture puis montre quinze secondes en trois plans. Le bilan et la relecture n’ajoutent ni secours ni écritures à la mission.

Les manifestations restent discrètes au début : silhouette aux suites, traces aux archives après impact et rémanence au spa. Elles ne poursuivent pas Alex et ne lui infligent pas de dégâts. Les priorités de secours, de radio, d’incident et de traversée restent conservées.

## Contenu et taille des archives

Le ZIP Sources courant inclut tous les modules, assets actifs, tests, sources de Bible, guides, scripts, workflows, demandes et rapports textuels historiques. **Seuls les captures et les Word/PDF de la v0.9 sont recopiés comme médias de livraison dans ce nouveau ZIP.** Les anciennes captures et les Bibles compilées restent intégralement dans le dépôt et dans leurs archives d’origine.

Une sélection commune au constructeur et au vérificateur définit l’ensemble exact des membres. Chaque fichier est comparé à son origine. Les ZIP Windows et Sources doivent mesurer chacun strictement moins de **100 Mio — 104 857 600 octets**. Caches, pages PNG de travail, autres ZIP et `dist/` ne sont pas inclus dans l’archive Sources. Le rapport final consigne la portée et les tailles effectives.

## Historique conservé : v0.8

La v0.8 reste attachée à ses preuves : **26 suites, 5 019 contrôles sources, 108 contrôles de packs, 33 captures, 15 sources, 83 314 mots et 168 pages**. Le catalogue y comptait 60 fiches de props. Ces mesures ne sont pas réutilisées comme résultats de la 0.9.

- [Windows x64 v0.8](../releases/The-Tower-Descent-v0.8-Windows-x64.zip) · [Sources v0.8](../releases/The-Tower-Descent-v0.8-Sources.zip).
- [Word v0.8](The-Tower-Descent-Bible-v0.8.docx) · [PDF v0.8](The-Tower-Descent-Bible-v0.8.pdf) · [captures](CAPTURES_V0.8.md).
- [Rapport source](validation/v0.8/VERIFICATION.json) · [revue des captures](validation/v0.8/VISUAL_REVIEW.json) · [revue documentaire](validation/v0.8/DOCUMENT_REVIEW.json) · [archives](../releases/VERIFICATION_V0.8.json).
- [Revue v0.8](https://github.com/darknigthmare/The-Descents/actions/runs/45569546416) · [livraison v0.8](https://github.com/darknigthmare/The-Descents/actions/runs/45572100961) · [état livré v0.8](https://github.com/darknigthmare/The-Descents/commit/639c2afaa61e2f2bb0938ae27d5b74db6861179f).

La v0.7 reste accessible avec **24 suites, 4 840 contrôles sources, 90 contrôles de packs, 30 captures et 149 pages issues de 14 sources** : [Windows](../releases/The-Tower-Descent-v0.7-Windows-x64.zip), [Sources](../releases/The-Tower-Descent-v0.7-Sources.zip), [Word](The-Tower-Descent-Bible-v0.7.docx), [PDF](The-Tower-Descent-Bible-v0.7.pdf), [captures](CAPTURES_V0.7.md) et [rapport](../releases/VERIFICATION_V0.7.json).

Les archives et preuves antérieures sont conservées. La [PR #1](https://github.com/darknigthmare/The-Descents/pull/1) reste le même brouillon sur `feat/live-tower-collapse` ; le pipeline ne fusionne pas `main`.

## Portée de la validation et de la production

Godot 4.7.2 officiel, rendu Compatibility, est utilisé sous Linux pour la construction et les captures. Le chargement des ressources de l’EXE Windows sous Godot Linux ne constitue pas une exécution sur un PC Windows. Le chargement du PCK Web ne constitue pas une partie WebAssembly/WebGL dans un navigateur. Aucun résultat de performances sur matériel cible ni mixage sonore final n’est déduit des tests automatisés.

Les captures partent d’états préparés. Les seuils et les escaliers sont également couverts par des déplacements réels de capsule dans les suites dédiées ; une image fixe ne démontre pas à elle seule leur franchissement. Les rapports distinguent logique, intégration, packs et présentation. Les verdicts de revue appartiennent aux empreintes finales effectivement examinées.

Le Word complet provient de seize sources. Le PDF canonique préparé à partir du Word normalisé est lié par [manifeste](../.review/v0.9/canonical-document.json) aux empreintes des sources, du générateur, de chaque fichier interne du Word et du PDF. La CI reconstruit le Word, exige toutes ces correspondances puis rend les pages du PDF retenu avec Poppler. Le rapport de construction consigne la provenance de ce PDF préparé, les outils, les polices, son nombre de pages et les empreintes. Il ne présente pas cette entrée comme une nouvelle conversion réalisée par la CI.

Le contrôle de complétude examine dans l’ordre chaque paragraphe du corps et chaque ligne de tableau, puis vérifie les cellules à l’intérieur de leur ligne et leurs paragraphes à l’intérieur de leur cellule. Une occurrence répétée ailleurs ne valide pas une ligne absente. `DOCUMENT_CONTENT.json` rattache le résultat aux fichiers exacts, et la livraison réexécute le contrôle. La normalisation du texte ne certifie ni ponctuation, ni typographie, ni visibilité : les revues du Word éditable et de chaque page du PDF restent distinctes et identifient leur support.

Personnages, hélicoptères, matériel, décors, matériaux et poses restent procéduraux. Le jeu d’acteurs, le doublage, les assets définitifs, la corde libre avec enroulement, les relais improvisés, le remappage complet et les essais sur matériels cibles restent à produire. La campagne complète, les humains hostiles, les laboratoires profonds, les retrouvailles et l’accompagnement d’Alma, la chute dans l’ancien bassin enfoui, l’intérieur d’Hespérie, les cavernes, le bunker, le seuil 666, l’Enfer, les fins, Mountain Hole et UE5 gardent un statut de conception.
