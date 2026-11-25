# État de livraison de la version 0.11

**25 novembre 2026 — matières, lumière et outils de secours.**

La 0.11 enrichit le parcours existant du toit au 23. Elle apporte huit albedos originaux, seize modèles éditables et quatre interventions contextuelles : réserve à ouvrir à la hache au 29, foyer à éteindre au 28, armoire de soins au 25 et projecteur à libérer au 24. Les outils apparaissent en main, se rangent pendant les secours et les traversées et conservent leurs résultats dans la sauvegarde de schéma 4.

**État de préparation :** les seize modèles finaux et leurs 21 vues Blender ont été contrôlés. La première revue native a conduit à corriger la priorité de la hache, les enseignes, deux placements de matériel et la synchronisation des outils dans les captures. Le candidat corrigé est en reconstruction ; la revue des nouvelles images et la vérification des trois archives restent à consigner.

## Éléments de preuve v0.11

| Domaine | Preuve et portée |
| --- | --- |
| Génération des modèles | [ASSET_BOOTSTRAP.json](validation/v0.11/ASSET_BOOTSTRAP.json), source Blender, manifestes et contrôle indépendant des GLB |
| Compilation, import et logique | [VERIFICATION.json](validation/v0.11/VERIFICATION.json) : résultat des 37 suites sur les empreintes indiquées |
| Exports Windows et Web | [EXPORTS.json](validation/v0.11/EXPORTS.json), construit à partir des modèles officiels du moteur |
| Ressources embarquées | [EXPORTED_PACK_VERIFICATION.json](validation/v0.11/EXPORTED_PACK_VERIFICATION.json), chargement des deux packs depuis des dossiers isolés |
| Présentation du jeu et moteurs | [Catalogue](CAPTURES_V0.11.md), [REVIEW_MANIFEST.json](validation/v0.11/REVIEW_MANIFEST.json), manifestes et provenance de chacun des cinq groupes |
| Examen des octets exacts | [approval.json](../.review/v0.11/approval.json), observations individuelles des captures et vues Blender, empreintes des assets et documents |
| Archives finales | [VERIFICATION_V0.11.json](../releases/VERIFICATION_V0.11.json), membres exacts, tailles, SHA256 et comparaison des octets |

Un rapport vaut pour le commit et les empreintes qu’il nomme. Les résultats d’une génération préparatoire ne constituent pas, seuls, une revue des nouvelles images ou une validation des archives finales. Le workflow garde ces étapes séparées et ne crée pas lui-même d’approbation visuelle.

## Changements de présentation

Le profil Forward+ utilise SDFGI, SSIL, SSAO, SSR, ombres locales, brouillard volumétrique et réponse tonale ACES. Le profil Compatibilité garde les mêmes matières et modèles avec ses lumières directes, ombres et brouillard classique. Deux lanceurs Windows demandent explicitement le moteur choisi ; le Web utilise Compatibilité. Les états rapportés par Godot et les captures comparables font foi pour les capacités réellement actives.

Les huit PNG conservent leur résolution native de 1254² et leurs octets originaux. Ils ont été inspectés seuls puis en répétition 2 × 2. Les légers raccords du bois et de la pierre sont consignés. Le microrelief et la rugosité de détail utilisés par le moteur sont des données procédurales ; le lot n’est pas présenté comme une série de scans PBR mesurés.

Le fichier Blender conserve les pièces nommées des seize accessoires. Les GLB emploient les mètres, des UV et normales, et un maillage à plusieurs surfaces par objet. Les textures partagées restent des ressources du projet, sans copie embarquée dans chaque GLB. Les vues de contrôle servent à examiner les formes ; les images natives vérifient leur présentation dans le jeu.

## Continuité et limites de cette livraison

La mission conserve les trois réceptions au toit, l’incident d’Hespérie, les huit liaisons locales, Léa et Idris à accompagner au refuge et les deux pièces de l’exposition. Les quatre nouveaux sites sont facultatifs. Une action interrompue n’utilise aucune charge ; un résultat achevé ne donne pas une seconde récompense. Les nouvelles entrées de matériel restent distinctes des deux caisses de secours dans le dossier.

La Bible intégrale Word/PDF v0.9 et son supplément Word/PDF v0.10 sont conservés octet par octet dans le ZIP Sources, avec le code, les textures, les modèles, le fichier Blender, les aperçus, les guides et les rapports. Le ZIP Captures natives contient les 71 images du jeu, leurs cinq manifestes et leurs cinq provenances, avec les mêmes chemins relatifs sous `The-Tower-Descent/`. Les deux archives se réunissent par extraction dans le même dossier ; le projet s’ouvre avec le seul ZIP Sources. Les anciennes archives restent disponibles. Le [guide v0.11](VISUELS_ET_SECOURS_V0.11.md) détaille les modèles, les quatre gestes, les profils et les commandes.

Les contrôles s’exécutent sous Godot Linux. Les captures préparent des états du jeu et le profil Forward+ de CI utilise un pilote Vulkan logiciel. Aucune partie humaine sous Windows ou dans un navigateur, aucune mesure sur un GPU de joueur et aucun mixage final ne sont déduits de ces essais. Les personnages, les mains, les véhicules et une partie importante de l’architecture restent procéduraux. Les accessoires n’incluent pas de LOD ni d’animations de combat ; leurs usages livrés sont les interventions décrites.

Le parcours s’arrête au 23. A22 et les niveaux inférieurs, les humains hostiles, les laboratoires SILLAGE, l’Enfer, Alma, l’intérieur d’Hespérie et le portage UE5 restent à produire. L’éclairage Godot répond à l’intention visuelle demandée sans revendiquer une implémentation ni une parité complète avec Lumen.

## Historique de livraison v0.10

**25 novembre 2026 — continuation A24 et A23.**

La version 0.10 ouvre deux niveaux après le bilan initial : le congrès du 24 et l’exposition Histoire de Nacre du 23. Elle ajoute l’escalier nord S25_24, le rappel R24_23, l’accompagnement physique de Léa Mercier et Idris Kaci jusqu’au refuge, deux relevés historiques et un compte rendu local. Les huit passages sont réversibles ; les trois premiers secours et l’effondrement sont conservés.

## Preuves du candidat exact

| Domaine | Résultat mesuré | Rapport de référence |
| --- | --- | --- |
| Compilation et sources | 7 317 contrôles réussis dans 32 suites ; runtime inchangé pendant les essais | [VERIFICATION.json](validation/v0.10/VERIFICATION.json) |
| Exports Windows x64 et Web | Deux exports construits avec les modèles officiels vérifiés | [EXPORTS.json](validation/v0.10/EXPORTS.json) |
| Ressources chargées depuis les deux packs isolés | 212 contrôles réussis : 106 par pack | [EXPORTED_PACK_VERIFICATION.json](validation/v0.10/EXPORTED_PACK_VERIFICATION.json) |
| 42 vues du secteur initial et 13 vues de continuation | 55 PNG natifs produits et examinés individuellement ; observations mineures consignées | [Catalogue](CAPTURES_V0.10.md) · [manifeste](validation/v0.10/REVIEW_MANIFEST.json) · [revue visuelle](validation/v0.10/VISUAL_REVIEW.json) |
| Supplément Word et PDF | 6 pages Word et 6 pages PDF examinées ; 69 blocs et 28 cellules vérifiés sans omission | [Revue du document](validation/v0.10/DOCUMENT_SUPPLEMENT.json) · [complétude du texte](validation/v0.10/SUPPLEMENT_CONTENT.json) |
| Approbation des fichiers exacts | 55 captures et 6 pages finales, Word contrôlé séparément ; empreintes vérifiées | [approval.json](../.review/v0.10/approval.json) |
| Archives et comparaison des membres octet par octet | Tailles, empreintes et verdict final consignés après assemblage | [VERIFICATION_V0.10.json](../releases/VERIFICATION_V0.10.json) |

Les nombres de contrôles, empreintes, versions du moteur et dates d’exécution sont consignés par ces rapports. Un verdict vaut uniquement pour les fichiers qu’il identifie. Le workflow ne crée aucune approbation visuelle et ne fusionne pas la PR.

La [seconde construction de revue](https://github.com/darknigthmare/The-Descents/actions/runs/45648920894) contrôle la source [`5d6e3878b0e1`](https://github.com/darknigthmare/The-Descents/commit/5d6e3878b0e103216d995f8b49944d847b834b79). L’examen de la première série a entraîné des corrections de signalétique, de cadrage de la maquette, de placement de la légende et de contraste des consignes. Les images modifiées ont été rouvertes après reconstruction ; seuls les verdicts de fichiers strictement identiques ont été conservés.

## Continuité et contenu

L’ancien bilan reste une réussite locale. Le bouton de poursuite enregistre l’ouverture du nouveau secteur avant de construire les accès. Le schéma 4 distingue l’intervention initiale de la continuation ; les schémas 1–3 sont migrés après validation de leurs règles d’origine. Une lecture de sauvegarde achevée ne déclenche ni nouveaux secours ni écriture.

Léa et Idris marchent à 1,5 m/s sur une route préparée, attendent au-delà de cinq mètres et rencontrent les collisions du décor. Un signe donné face au groupe lance ou suspend son déplacement. Une escorte interrompue reprend depuis la cabine ; une réception confirmée reste au refuge. Les deux corps doivent atteindre les places d’accueil et trouver un appui. Le rappel personnel ne transporte pas le groupe.

La maquette et la photographie restent visibles après lecture. Le terminal du 23 clôt la reconnaissance après réception et collecte des deux pièces. E01 est facultative, sans attaque, sans collision et sans reçu de preuve automatique. Les sources de Bible précisent les lieux, les comportements, les paramètres et les limites de la livraison.

Le ZIP Sources conserve la Bible intégrale v0.9, son supplément v0.10, tous les modules et documents source, les captures courantes et les preuves textuelles historiques. Les captures anciennes et les autres volumes historiques restent dans GitHub et leurs archives. Les nouvelles archives n’écrasent aucune livraison antérieure.

## Limites

Les tests natifs et la lecture des packs s’exécutent sous Godot Linux. Ils ne constituent ni une partie humaine sur Windows ni une partie WebAssembly dans un navigateur. Les captures sont des états préparés. Les personnages et décors restent procéduraux, la photographie est un panneau d’archive stylisé et l’écran incliné ne tombe pas. Aucun résultat de performance ou de mixage final n’est déduit des essais automatiques.

Le parcours s’arrête au 23. A22 et les étages inférieurs, les humains hostiles, les laboratoires, l’Enfer, Alma, l’intérieur d’Hespérie et UE5 restent des productions futures.

## Historique de livraison v0.9

Le compte rendu suivant est conservé avec ses chiffres et ses preuves propres.

### État historique de livraison — version 0.9

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
