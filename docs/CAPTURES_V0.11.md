# Catalogue des captures v0.11

Ce document définit les **71 captures natives attendues** pour la revue de la version **0.11.0** de *The Tower Descent*. Les noms correspondent aux scènes de capture et au périmètre exigé par `tools/build_visual_ci.py`.

**Statut de ce catalogue : périmètre prévu, sans verdict natif.** Une ligne ci-dessous ne signifie pas que l’image a déjà été produite ou approuvée. Les résultats mesurés, les fichiers effectivement obtenus et leur revue sont établis par `docs/validation/v0.11/REVIEW_MANIFEST.json`, les manifestes de chaque groupe et `.review/v0.11/approval.json`.

## Répartition attendue

Les chemins des groupes sont relatifs à la racine du dépôt. Chaque tableau détaillé donne les noms de fichiers à placer dans le dossier indiqué.

| Groupe | Nombre attendu | Dossier | Moteur de rendu exigé |
| --- | ---: | --- | --- |
| Interface et intervention supérieure | 42 | `docs/captures/v0.11/baseline/` | Compatibility natif : `gl_compatibility` |
| Poursuite du congrès 24 à l’exposition 23 | 13 | `docs/captures/v0.11/continuation/` | Compatibility natif : `gl_compatibility` |
| Équipement de secours | 8 | `docs/captures/v0.11/equipment/` | Compatibility natif : `gl_compatibility` |
| Éclairage cinématique | 4 | `docs/captures/v0.11/lighting_forward/` | Forward+ natif : `forward_plus` |
| Éclairage portable | 4 | `docs/captures/v0.11/lighting_compat/` | Compatibility natif : `gl_compatibility` |
| **Total** | **71** | **Cinq groupes** | **Le moteur réellement actif doit être enregistré.** |

## Portée de la preuve visuelle

Les scènes de capture préparent les positions de caméra, les étapes de mission et certains temps d’animation pour rendre les états comparables. Elles utilisent le monde, les interfaces et les systèmes du prototype. Certaines actions passent par la logique de jeu et certains mouvements sont avancés par le scénario automatisé ; d’autres positions et étapes sont directement préparées. Chaque description doit être lue dans ce cadre.

Les captures servent à examiner la lisibilité, les chevauchements, le cadrage, l’état des outils, les matériaux et la cohérence de l’éclairage. Elles ne constituent pas l’enregistrement d’une partie humaine complète. Les collisions, la progression, la sauvegarde et les conditions d’action sont également couvertes par les suites de tests ; une image isolée ne remplace pas ces vérifications.

Le rendu natif prévu utilise un affichage graphique sous Linux en CI. La présence d’un export Windows ou Web dans la livraison n’en fait pas une capture prise sur ces plateformes. Les images ne sont pas un benchmark : aucune fréquence d’affichage, classe de carte graphique ou durée de jeu fluide n’est déduite de leur production.

Les deux groupes d’éclairage partagent les mêmes positions et cibles de caméra. Chaque vue attend **96 images effectivement rendues à son emplacement** avant l’enregistrement, pour laisser les effets temporels se stabiliser. Le manifeste doit indiquer le moteur actif obtenu par `RenderingServer.get_current_rendering_method()`, l’affichage et l’état du profil. Un repli vers Compatibility ne valide pas une demande Forward+.

## 1. Interface et intervention supérieure — 42 captures

Dossier : `docs/captures/v0.11/baseline/`.

Scène : [visual_frontend_preview.tscn](../prototype/tests/visual_frontend_preview.tscn), pilotée par [visual_frontend_preview.gd](../prototype/tests/visual_frontend_preview.gd). Ce groupe conserve les états de référence du parcours supérieur et de son interface.

| Fichier attendu | État préparé et point à examiner |
| --- | --- |
| `01_menu_arrivee.png` | Menu initial sans sauvegarde, deux tours intactes et lisibilité des choix d’accueil. |
| `02_options.png` | Options accessibles avant la partie, disposition des réglages et de leurs libellés. |
| `03_nouvelle_intervention.png` | Panneau de préparation de la première intervention. |
| `04_signature_studio.png` | Carton de signature du studio au repère de deux secondes. |
| `05_titre.png` | Révélation du titre au repère de onze secondes. |
| `06_approche_03.png` | Approche en jeu préparée à trois secondes : premier cadrage de l’arrivée. |
| `06_approche_10.png` | Approche en jeu préparée à dix secondes : progression du cadrage. |
| `06_approche_17.png` | Approche en jeu préparée à dix-sept secondes : présentation des tours et du secours. |
| `06_approche_25.png` | Approche en jeu préparée à vingt-cinq secondes : dernier repère de cette série. |
| `07_pause_intro.png` | Menu de pause pendant l’approche et séparation visuelle entre menu et scène. |
| `08_menu_archives.png` | Accueil au point sûr des archives 28, après la réplique. |
| `09_dossier_apres.png` | Dossier de mission actualisé après l’impact confirmé. |
| `10_menu_refuge.png` | Accueil après la clôture de l’intervention supérieure, avec le refuge comme point sûr. |
| `11_inspection_toit.png` | Fiche du registre de réception sur le toit, avant les sauvetages. |
| `12_inspection_archives.png` | Fiche des archives avant l’incident structurel. |
| `13_inspection_apres.png` | Fiche des archives après l’impact, avec consigne actualisée. |
| `14_toit_equipe.png` | Détail du toit : Alpha posé, porte et équipe dans l’état préparé. |
| `15_portage.png` | Portage d’Ana : harnais, personne et mains, avec l’objectif de mission visible. |
| `16_treuillage.png` | Remontée d’Ana dans le puits : harnais et câble sous tension. |
| `17_reception.png` | Réception et transfert d’Ana vers l’abri, avec l’équipe médicale. |
| `18_meteo_toit.png` | Atmosphère maritime : plafond nuageux, pluie extérieure et horizon de Nacre. |
| `19_options_pause.png` | Réglages accessibles pendant une intervention suspendue. |
| `20_journal_situation.png` | Onglet Situation du journal, avec une réception et un indice dans l’état préparé. |
| `21_journal_rescapes.png` | Onglet Rescapés du même journal, noms et état de réception. |
| `22_journal_indices.png` | Onglet Indices du même journal et présentation de la pièce recueillie. |
| `23_journal_transmissions.png` | Onglet Transmissions du même journal et lecture de l’historique. |
| `24_epilogue_02.png` | Premier repère d’épilogue, à deux secondes, après trois réceptions. |
| `24_epilogue_07.png` | Deuxième repère d’épilogue, à sept secondes, après trois réceptions. |
| `24_epilogue_12.png` | Troisième repère d’épilogue, à douze secondes, après trois réceptions. |
| `25_bilan_refuge.png` | Bilan nominatif du refuge : trois réceptions, deux indices et historique de l’intervention préparée. |
| `26_suites_presence.png` | Présence périphérique des suites 29, avec pose préparée et directeur avancé de 3,4 secondes. |
| `27_archives_traces.png` | Traces humides des archives 28 après impact, présentées sans ajout d’indice au journal. |
| `28_spa_remanence.png` | Seconde présence au spa 26 après extinction et attente calme, dans un scénario sans poursuite ni dommage. |
| `29_station_rappel_toit.png` | Repère bleu du rappel personnel toit–30, distinct du treuil orange, à partir d’une pose préparée. |
| `30_rappel_descente.png` | Descente contrôlée sur R31_30, après transfert et mouvement pilotés : capsule, descendeur et HUD. |
| `31_rappel_verrouille.png` | Verrouillage du descendeur sur la même liaison : état d’arrêt et indication dans l’interface. |
| `32_escalier_30_29.png` | Escalier restaurant 30–suites 29 : ouverture de dalle, première volée et signalétique. |
| `33_escalier_palier.png` | Palier intermédiaire du 30–29 : lecture des deux volées et de la position à mi-hauteur. |
| `34_rappel_remontee.png` | Remontée pilotée depuis l’extrémité basse du rappel toit–30 : effort et état du rappel. |
| `35_aide_deplacements.png` | Aide de mission : six liaisons, commandes de rappel et distinction entre rappel et treuil. |
| `36_escalier_28_27.png` | Escalier archives 28–jardin 27 : dalle ouverte et passage intérieur. |
| `37_escalier_26_25.png` | Escalier spa 26–refuge 25 et fin de cette liaison locale. |

## 2. Poursuite A24–A23 — 13 captures

Dossier : `docs/captures/v0.11/continuation/`.

Scène : [visual_continuation_preview.tscn](../prototype/tests/visual_continuation_preview.tscn), pilotée par [visual_continuation_preview.gd](../prototype/tests/visual_continuation_preview.gd). Le bilan du parcours supérieur et les trois secours initiaux restent le point de départ de cette série.

| Fichier attendu | État préparé et point à examiner |
| --- | --- |
| `01_bilan_poursuite.png` | Bilan supérieur conservé et bouton permettant de poursuivre vers le congrès. |
| `02_escalier_25_24.png` | Accès nord à l’escalier local, séparé de la liaison 26–25. |
| `03_congres_auditorium.png` | Auditorium du congrès, écran Pelagos incliné et foyer de secours. |
| `04_cabine_signes.png` | Léa Mercier et Idris Kaci dans la cabine, en attente d’un signe visible. |
| `05_escorte_escalier.png` | Positions préparées des deux personnes sur la volée nord vers le refuge ; ce cadrage ne documente pas à lui seul tout le trajet. |
| `06_reception_refuge.png` | État de réception des deux personnes préparé dans le refuge 25. |
| `07_rappel_24_23.png` | Ligne entre congrès et exposition, avec descendeur et mesures du rappel. |
| `08_maquette_souterrains.png` | Maquette des deux tours et des volumes absents du plan touristique actuel. |
| `09_archive_bains.png` | Panneau d’archive procédural des anciens bains : forme de porte et légende. |
| `10_remanence_exposition.png` | Routine facultative E01 à l’écart du passage, dans son état sans attaque ni dégâts. |
| `11_dossier_nacre.png` | Dossier des cinq pièces présentes dans l’instantané préparé, dont les deux preuves du 23. |
| `12_bilan_reconnaissance.png` | Compte rendu au 23, avec deux réceptions au refuge et trois au toit conservées. |
| `13_menu_exposition.png` | Accueil contextuel sur l’exposition, au dernier point sûr enregistré. |

## 3. Équipement de secours — 8 captures

Dossier : `docs/captures/v0.11/equipment/`.

Scène : [visual_equipment_v011.tscn](../prototype/tests/visual_equipment_v011.tscn), pilotée par [visual_equipment_v011.gd](../prototype/tests/visual_equipment_v011.gd). Les poses de départ et les sites sont préparés ; les interventions montrées utilisent les appels de sélection, d’action maintenue et d’achèvement de la logique de jeu. La scène attend huit images de rendu par prise de vue.

| Fichier attendu | État préparé et point à examiner |
| --- | --- |
| `01_rack_toit.png` | Râtelier du toit et outils de secours, dans un état après impact préparé. |
| `02_comptoir_toit.png` | Radio, casque, sac de soins et lampe sur le comptoir ; caméra de revue relevée pour exposer sa surface. |
| `03_hache_29.png` | Hache sélectionnée, avec action maintenue en cours sur la réserve de balisage du 29. |
| `04_extincteur_28_actif.png` | Extincteur sélectionné, action maintenue et jet cosmétique orienté vers le foyer du 28. |
| `05_foyer_28_eteint.png` | Foyer après achèvement de l’action d’extinction, avec réserve de l’extincteur actualisée. |
| `06_halligan_25.png` | Halligan en main, pendant l’intervention sur l’armoire de soins du refuge. |
| `07_coupe_boulon_24.png` | Coupe-boulon au congrès, chaîne ouverte et projecteur libéré après activation de la poursuite. |
| `08_inventaire_refuge25.png` | Poste matériel du refuge : brancard, sac de soins, bouteille et balise, avec le HUD des outils. |

## 4. Éclairage Forward+ — 4 captures

Dossier : `docs/captures/v0.11/lighting_forward/`.

Scène : [lighting_v011_preview.tscn](../prototype/tests/lighting_v011_preview.tscn), pilotée par [lighting_v011_preview.gd](../prototype/tests/lighting_v011_preview.gd), avec moteur exigé `forward_plus` et profil cinématique.

Cette série examine le monde depuis une caméra de revue, sans HUD. Le profil doit activer les effets prévus, dont SDFGI sur la géométrie fixe admissible. Les acteurs mobiles et la tour Hespérie ne doivent pas être inscrits dans cette illumination statique. Les métadonnées contrôlent ces exclusions ; l’examen des images porte sur leur résultat visible, la lisibilité du trajet, le contraste et les matériaux.

| Fichier attendu | État préparé et point à examiner |
| --- | --- |
| `01_roof_rescue.png` | Poste de secours sur le toit, béton salin et éclairage de tempête. |
| `02_restaurant_materials.png` | Restaurant 30 : pierre, bois fumé, luminaires chauds et ombres locales. |
| `03_congress_lighting.png` | Congrès 24 : moquette, scène et trajet de service sous éclairage froid. |
| `04_archive_after_impact.png` | Archives 28 après impact : lumière de secours et état après la modification d’Hespérie. |

## 5. Éclairage Compatibility — 4 captures

Dossier : `docs/captures/v0.11/lighting_compat/`.

La même scène `lighting_v011_preview.tscn` utilise ici le moteur exigé `gl_compatibility` et le profil portable. Les quatre noms sont volontairement identiques à ceux du groupe Forward+ pour comparer les mêmes caméras et les mêmes états. Le chemin complet distingue les fichiers.

Cette série examine la lecture du monde avec l’éclairage direct et les effets disponibles dans le profil portable. Elle ne doit pas être présentée comme une exécution de SDFGI. Elle emploie également les 96 images de stabilisation par cadrage.

| Fichier attendu | État préparé et point à examiner |
| --- | --- |
| `01_roof_rescue.png` | Même poste de secours sur le toit : matériaux et visibilité sous le profil portable. |
| `02_restaurant_materials.png` | Même restaurant 30 : séparation des matériaux et éclairage intérieur. |
| `03_congress_lighting.png` | Même congrès 24 : scène, moquette et lisibilité du trajet de service. |
| `04_archive_after_impact.png` | Mêmes archives 28 après impact : lumière de secours et cohérence de l’état du monde. |

## Lecture des résultats et décision de revue

Le résultat d’une exécution est à lire dans les éléments suivants, une fois produits pour les sources gelées de la demande :

| Élément | Rôle |
| --- | --- |
| `docs/captures/v0.11/<groupe>/MANIFEST.json` | Liste des prises de vue réalisées, descriptions, dimensions et informations sur le moteur de rendu réellement actif. Les groupes d’éclairage ajoutent les états du profil et les cadrages. |
| `docs/captures/v0.11/<groupe>/PROVENANCE.json` | Provenance de la génération du groupe et rattachement aux empreintes des sources. |
| `docs/validation/v0.11/REVIEW_MANIFEST.json` | Périmètre réuni de la revue : empreintes des captures, des sources, des exports et des ressources requises. |
| `.review/v0.11/approval.json` | Décision explicite de revue assistant, liée au manifeste exact, avec statut et observation visuelle pour chaque capture. |

La revue doit ouvrir les images réelles et examiner notamment les textes coupés, les superpositions de panneaux, les outils qui masquent une information utile, les matériaux absents et les zones où l’éclairage empêche de lire un passage. Une correspondance d’empreintes garantit l’identité du fichier examiné ; elle ne constitue pas un verdict visuel à elle seule.

Les aperçus Blender et les documents de provenance des modèles dans `docs/assets/v0.11/` forment un ensemble de revue distinct. Ils ne sont pas comptés parmi ces 71 captures natives Godot. Le [guide des visuels et des secours v0.11](VISUELS_ET_SECOURS_V0.11.md) précise le périmètre des ressources, des profils et des outils.

**Aucun résultat de rendu ou d’approbation n’est anticipé dans ce catalogue.** Le statut de livraison doit être reporté à partir des manifestes effectivement produits et de la revue correspondante.

