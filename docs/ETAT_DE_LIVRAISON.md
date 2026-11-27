# État de livraison de la version 0.13.0

**26 novembre 2026 — candidature résidentielle A19–A17.**

La source ajoute Jeanne Morel au 19, Marc Morel au 18 et Inès Vidal au 17. Tous doivent arriver physiquement au refuge 20 par les escaliers. Le rappel personnel traverse le duplex ; le retour de service se débloque au Halligan depuis le 18. Le relais du 17 exige alimentation, lecture de la plaque, validation réessayable de la destination et de la référence, puis maintien de l’action d’émission. Le compte rendu final se transmet au **17**, après les trois réceptions au **20** et les trois nouveaux constats.

**Statut : candidat 0.13.0 en vérification finale.** Les résultats consolidés des suites, des exports et des captures sont encore en cours de gel. Les liens de distribution ci-dessous sont des cibles prévues ; ils ne constituent pas une attestation de publication. Aucun ancien résultat de la 0.12 n’est compté comme preuve actuelle.

## Éléments de la candidature

| Domaine | Contenu ou statut actuel | Source de référence |
| --- | --- | --- |
| Parcours | A19 résidences, A18 duplex, A17 télécommunications ; retour des escortes au refuge 20 | [Supplément détaillé](CONTINUATION_A19_A17_V0.13.md) |
| Personnes et enquête | 3 nouvelles identités, 11 au total ; 3 nouveaux constats, 10 pièces possibles | [Contrat de mission](../prototype/scripts/residential_director.gd) |
| Liaisons | S20_19 nord, S19_18 sud, S18_17 nord, R19_18 dans le duplex ; 16 liens au total | [Catalogue](../prototype/scripts/route_catalog.gd) |
| Actions | Préparation de Jeanne, Halligan, alimentation, référence durable, validation du relais et émission | [Logique résidentielle](../prototype/scripts/residential_director.gd) |
| Sauvegarde | Schéma 6 ; lecture des schémas 1–5 sans réécriture automatique ; reprise stable et rollback de session distincts | [Stockage](../prototype/scripts/save_store.gd) |
| Modèles | 12 GLB ; 428 pièces source ; 155 152 triangles ; 5 203 300 octets GLB | [Modèles et source Blender](assets/v0.13/MODELS.md) · [Manifeste](../prototype/assets/models/residential_v013/manifest.json) |
| Matières | Papier peint en lin et sol antistatique, 2 PNG natifs de 1254 × 1254 | [Manifeste des textures](../prototype/assets/materials/v013/manifest.json) |
| Documentation | Supplément de 11 pages en Word/PDF ; rendu, contrôle du texte et examen individuel des pages | [Revue documentaire](validation/v0.13/DOCUMENT_REVIEW.json) · [Texte et tableaux](validation/v0.13/DOCUMENT_CONTENT.json) |
| Tests sources, packs et captures | Vérification finale en cours ; résultats à lier à leurs empreintes exactes | [Protocole v0.13](VALIDATION_V0.13.md) |
| Archives | Assemblage et publication à confirmer au terme du contrôle de livraison | [Formats et contenu](EXPORTS.md) |

Le document possède sa propre preuve de mise en page. Celle-ci ne certifie ni les déplacements, ni le rendu du moteur, ni les plateformes d’export. Le statut de candidature sera actualisé à partir des rapports finaux, sans anticiper leur verdict ou leur total.

## Cibles de distribution

| Format | Chemin prévu |
| --- | --- |
| Windows x86_64 | [TheTowerDescent-v0.13-Windows-x86_64.zip](../releases/v0.13/TheTowerDescent-v0.13-Windows-x86_64.zip) |
| Projet éditable | [TheTowerDescent-v0.13-Godot-Source.zip](../releases/v0.13/TheTowerDescent-v0.13-Godot-Source.zip) |
| Export Web | [TheTowerDescent-v0.13-Web.zip](../releases/v0.13/TheTowerDescent-v0.13-Web.zip) |

Le projet source s’ouvre depuis `prototype/project.godot` avec Godot 4.7.2. Le paquet Windows conserve ses lanceurs et notices ; le paquet Web doit être servi par HTTP. Les membres exacts, tailles et SHA-256 seront ceux du manifeste établi après assemblage. Une source sur la branche de la PR ne vaut pas à elle seule nouvel export disponible ni fusion de `main`.

## Continuité et limites

Les secours au toit, Léa et Idris au refuge 25, puis Mina, Théo et Sofia au refuge 20 restent acquis. La nouvelle clôture exige les trois réceptions supplémentaires, le relais vérifié et les trois constats résidentiels. Les anciennes pièces facultatives restent facultatives. Une erreur de saisie du relais ne retire aucun indice ni aucune réception et permet de réessayer.

Une escorte interrompue par une véritable reprise revient en attente à son contact initial. Un échec d’écriture pendant la partie conserve les personnages vivants, leurs positions et leurs curseurs de parcours. La progression durable reste au dernier point sûr valide ; aucun état suspendu sur corde ou au milieu d’un escalier n’est restauré.

Le parcours s’arrête au **17**. Le Répondant est une apparition facultative ; les formes humaines et une partie des décors restent procédurales. Les modèles importés sont des éléments statiques. Le soin de Jeanne est une interaction abstraite, pas une simulation médicale. Les matières sont des créations artistiques avec normales et rugosité approximées, sans scans PBR mesurés. Le rendu Godot conserve l’intention lumineuse du projet, sans revendiquer la parité avec Lumen.

Les essais de mouvements physiques utilisent des corps et collisions réels, avec un guidage synthétique lorsque le rapport le précise. Les captures préparent des états de mission. Charger un pack dans Godot Linux ne constitue pas une exécution de l’application Windows ni une partie WebAssembly dans un navigateur ; les performances sur GPU de joueur restent à mesurer. Les réserves visuelles finales seront celles des images effectivement examinées.

Les étages 16 à 1, les laboratoires SILLAGE, la traversée de l’Enfer, Alma, l’intérieur d’Hespérie, le combat et le portage UE5 restent à produire. Les tours commencent toujours intactes et l’effondrement a lieu pendant l’intervention.

## Historique de livraison v0.12

Les chiffres, commits et archives suivants appartiennent à la livraison antérieure.

<details>
<summary>Consulter les preuves historiques v0.12</summary>

### État historique de la version 0.12

**25 novembre 2026 — galerie, cuisines et refuge du 20.**

La source 0.12 prolonge le parcours par trois étages et trois escortes individuelles. Mina Bensaïd, Théo Lenoir et Sofia Renard doivent arriver physiquement au refuge 20. Le Halligan, la coupure du réchauffeur, la couverture et le relais ont des actions contextuelles. Le Retranché du 22 peut être apaisé à distance, lampe baissée ; il ne possède pas encore de combat. Les deux constats maintiennent une enquête progressive sur les événements antérieurs à la catastrophe.

**Statut : revue de la candidature achevée, sans blocage identifié sur son périmètre vérifié.** Les résultats sources, exports, captures et document sont consignés ci-dessous avec leurs preuves. La présence du [manifeste final des archives v0.12](../releases/VERIFICATION_V0.12.json), accompagné des trois ZIP dont il précise les tailles et empreintes, atteste leur assemblage vérifié et leur disponibilité.

La candidature examinée est [`9756f0b707c1ffc72284754ec1f1ff301ffdd960`](https://github.com/darknigthmare/The-Descents/commit/9756f0b707c1ffc72284754ec1f1ff301ffdd960), issue de la source [`2e4de42ce85a42c80dae97a1de9985194430d9b6`](https://github.com/darknigthmare/The-Descents/commit/2e4de42ce85a42c80dae97a1de9985194430d9b6). Les verdicts s’appliquent aux fichiers dont les empreintes figurent dans les rapports ; les anciens résultats ne sont pas réutilisés comme preuves du nouveau chapitre.

## Résultats vérifiés de la candidature v0.12

| Domaine | Résultat observé | Preuve |
| --- | --- | --- |
| Import, logique et intégration | **8 291 contrôles réussis dans 43 suites** ; runtime inchangé pendant les essais | [VERIFICATION.json](validation/v0.12/VERIFICATION.json) |
| Exports construits | Windows x64 et Web, avec modèles officiels Godot 4.7.2 vérifiés | [CANDIDATE_EXPORTS.json](validation/v0.12/CANDIDATE_EXPORTS.json) · [Modèles du moteur](validation/v0.12/CANDIDATE_TEMPLATES.json) |
| Ressources embarquées | **572 contrôles réussis : 286 par pack**, montés séparément depuis des répertoires vides sous Godot Linux | [EXPORTED_PACK_VERIFICATION.json](validation/v0.12/EXPORTED_PACK_VERIFICATION.json) |
| Captures et revue visuelle | **21 PNG ouverts et examinés par trois agents : 18 Compatibilité et 3 Forward+** ; aucune vue demandée n’a été remplacée par un autre moteur | [Catalogue des captures](CAPTURES_V0.12.md) · [VISUAL_REVIEW.json](validation/v0.12/VISUAL_REVIEW.json) |
| Document de continuation | **Neuf pages PDF examinées**, avec contrôle ordonné du texte du Word, des tableaux et de leur présence dans le PDF | [DOCUMENT_REVIEW.json](validation/v0.12/DOCUMENT_REVIEW.json) · [DOCUMENT_CONTENT.json](validation/v0.12/DOCUMENT_CONTENT.json) |
| Modèles du chapitre | **Douze GLB**, source Blender éditable et manifeste ; chargement des modèles également exercé dans les packs | [Guide et source Blender](assets/v0.12/MODELS.md) · [Manifeste GLB](../prototype/assets/models/commerce_v012/manifest.json) |
| Archives de distribution | Noms et contenu prévus ci-dessous ; tailles, membres et empreintes à lire dans le manifeste publié après assemblage | [VERIFICATION_V0.12.json](../releases/VERIFICATION_V0.12.json) |

Le [rapport automatique de candidature](validation/v0.12/CANDIDATE.json) conserve son état antérieur à la revue visuelle. La décision d’examen des images est portée séparément par `VISUAL_REVIEW.json`. Le workflow de candidature dispose uniquement de droits de lecture sur le dépôt ; il ne fabrique aucune approbation visuelle ni publication. Les contrôles des packs ne sont pas compris dans les 8 291 contrôles sources.

## Contenu de la candidature

| Domaine | Contenu |
| --- | --- |
| Étages | A22 galerie, A21 cuisines, A20 logistique ; choix explicite depuis le bilan du 23 |
| Personnes | Mina, Théo et Sofia ; cinq réceptions antérieures conservées, huit au total |
| Liaisons | Trois nouveaux escaliers voisins et un rappel facultatif 22–21 ; douze passages au total |
| Interventions | Volet au Halligan, isolation, couverture, désescalade facultative du Retranché, relais |
| Enquête | Registre du 22 et consigne du 21 ; jusqu’à sept pièces dans le dossier |
| Modèles | Douze GLB, 176 430 triangles, 485 pièces dans la source Blender ; douze aperçus et une planche |
| Matières | Terrazzo ivoire et carrelage sauge, deux PNG natifs 1254² |
| Documentation | Supplément de neuf pages Word/PDF, source Markdown détaillée et volumes antérieurs préservés |
| Sauvegarde | Schéma 5, migrations 1–4, progression antérieure et réceptions conservées |
| Corrections | Interaction à portée et sans obstacle, annulation de transfert de rappel bloqué, protection du checkpoint vivant |

La [procédure v0.12](VALIDATION_V0.12.md) décrit les étapes et leurs limites. Le [guide Windows](DEMARRAGE_WINDOWS.md) présente l’itinéraire et les commandes ; le [supplément de Bible](CONTINUATION_A22_A20_V0.12.md) sépare les fonctions intégrées des scènes de campagne à produire.

## Disponibilité et contenu des archives

Les liens suivants désignent les archives produites par `tools/package_release.py`. Le [manifeste final v0.12](../releases/VERIFICATION_V0.12.json), publié avec les ZIP après réussite du contrôle de livraison, établit leur disponibilité, leurs tailles et leurs SHA-256.

- [The-Tower-Descent-v0.12-Windows-x64.zip](../releases/The-Tower-Descent-v0.12-Windows-x64.zip) : EXE avec paquet embarqué, deux lanceurs, guide et licences.
- [The-Tower-Descent-v0.12-Sources.zip](../releases/The-Tower-Descent-v0.12-Sources.zip) : projet éditable, modèles et sources Blender, matières, tests, guides, rapports et documents.
- [The-Tower-Descent-v0.12-Captures-native.zip](../releases/The-Tower-Descent-v0.12-Captures-native.zip) : les 21 PNG examinés, deux manifestes et deux provenances, aux chemins d’origine.

Les trois archives ont pour racine `The-Tower-Descent/`. Sources et Captures-native peuvent être extraites dans le même dossier parent. Les captures sont facultatives pour ouvrir le projet. Le [guide des exports](EXPORTS.md) décrit les membres attendus, la limite de 100 Mio par archive et la vérification des fichiers Web.

## Limites du chapitre

Le parcours s’arrête au 20. Les humains ont encore des silhouettes et poses procédurales ; les modèles importés sont statiques, sans rig ni LOD. Les variantes de galerie, le faux appel sophistiqué, l’eau dynamique, le combat du Retranché/E11 et les scènes sociales détaillées du refuge restent à produire. Les niveaux 19 à 1, les laboratoires, l’Enfer, Alma, l’intérieur d’Hespérie et UE5 ne sont pas intégrés.

Les parcours utilisent les vrais corps et collisions. Le test des civils emploie un guide de sauvetage synthétique, sans téléporter les civils pendant leur marche. Les captures préparent des états de mission et d’interface. Les exports sont montés et interrogés par Godot Linux, sans exécuter l’application sous Windows ni le WebAssembly dans un navigateur. Le rendu Vulkan logiciel de CI ne mesure pas les performances d’un GPU de joueur.

Les éléments mobiles sont exclus de la géométrie statique de l’éclairage global. L’intention lumineuse de Lumen reste adaptée aux fonctions Godot, sans parité revendiquée. La disparition de la fumée du réchauffeur est immédiate à la validation de la couverture dans cette version.

La revue visuelle conserve des réserves non bloquantes : personnages, flammes et fumée géométriques et stylisés ; certains libellés 3D passent derrière le HUD ou chevauchent une notification ; l’aide de commandes est parfois peu contrastée sur le sol clair. Les comptes rendus, les compteurs et les commandes principales restent lisibles, y compris dans les deux vues à 1024 × 640. Deux formulations d’interface restent perfectibles : la règle générale sur une personne encore portée apparaît même au bilan 8/8, et le menu achevé propose encore « Reprendre l’intervention ». Les observations par image figurent dans [la revue exacte](validation/v0.12/VISUAL_REVIEW.json).


</details>

## Historique de livraison v0.11

Les chiffres et preuves ci-dessous restent ceux de la version 0.11.

### État historique de la version 0.11

**25 novembre 2026 — matières, lumière et outils de secours.**

La 0.11 enrichit le parcours existant du toit au 23. Elle apporte huit albedos originaux, seize modèles éditables et quatre interventions contextuelles : réserve à ouvrir à la hache au 29, foyer à éteindre au 28, armoire de soins au 25 et projecteur à libérer au 24. Les outils apparaissent en main, se rangent pendant les secours et les traversées et conservent leurs résultats dans la sauvegarde de schéma 4.

**État de la revue : candidat 0.11 approuvé.** Les **7 932 contrôles sources**, les **300 contrôles des packs**, les **71 captures natives** et les **21 vues Blender** sont validés sur les fichiers identifiés dans les rapports. L’assemblage des trois archives exige cette approbation. Le résultat de l’assemblage et le verdict de livraison doivent être lus dans [le rapport final des archives](../releases/VERIFICATION_V0.11.json), établi uniquement après vérification des membres, des tailles et des empreintes.

## Éléments de preuve v0.11

| Domaine | Résultat mesuré et portée | Preuve |
| --- | --- | --- |
| Génération des modèles | 16 GLB, source Blender éditable, 21 aperçus examinés ; 150 304 triangles et 5 261 324 octets GLB | [Source et manifeste](assets/v0.11/README.md) · [Revue des modèles](validation/v0.11/MODEL_VISUAL_REVIEW.json) |
| Compilation, import et logique | 7 932 contrôles réussis dans 37 suites ; runtime inchangé pendant les essais | [VERIFICATION.json](validation/v0.11/VERIFICATION.json) |
| Exports Windows et Web | Deux exports construits à partir des modèles officiels du moteur | [EXPORTS.json](validation/v0.11/EXPORTS.json) |
| Ressources embarquées | 300 contrôles réussis, 150 par pack, chargés depuis des dossiers isolés | [EXPORTED_PACK_VERIFICATION.json](validation/v0.11/EXPORTED_PACK_VERIFICATION.json) |
| Présentation du jeu et moteurs | 71 PNG natifs de 1440 × 900, cinq groupes ; Forward+ et Compatibility effectivement obtenus et images examinées | [Catalogue](CAPTURES_V0.11.md) · [Revue du jeu](validation/v0.11/VISUAL_REVIEW.json) |
| Examen des octets exacts | Approbation des 71 captures, 21 aperçus, modèles, matières, guides, source éditable et quatre documents préservés | [approval.json](../.review/v0.11/approval.json) |
| Assemblage des trois archives | Membres exacts, tailles, SHA256, comparaison des octets et limite de 100 Mio par archive exigés avant publication | [VERIFICATION_V0.11.json](../releases/VERIFICATION_V0.11.json) |

Un rapport vaut pour le commit et les empreintes qu’il nomme. Les résultats d’une génération préparatoire ne constituent pas, seuls, une revue des nouvelles images ou une validation des archives finales. Le workflow garde ces étapes séparées et ne crée pas lui-même d’approbation visuelle.

La [construction de revue finale](https://github.com/darknigthmare/The-Descents/actions/runs/45674669046) contrôle la source [`edd0d935204b`](https://github.com/darknigthmare/The-Descents/commit/edd0d935204b276e9671270b9993d87373534b34). La [revue initiale](validation/v0.11/INITIAL_VISUAL_REVIEW.json) a motivé les corrections de priorité de la hache, de revers des enseignes, de placement du projecteur et du sac, ainsi que de synchronisation des outils dans les captures. Les nouveaux fichiers ont été examinés après reconstruction ; les empreintes des vues Blender déjà approuvées sont restées identiques.

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
