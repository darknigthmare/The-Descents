# Modèles des résidences et télécommunications — v0.13

Douze modèles originaux complètent les accessoires de secours et le mobilier de la v0.12. Les fichiers GLB sont utilisés dans les résidences A19–A18, le relais A17 et les trois repères de réception supplémentaires du refuge 20.

La source [residential_equipment.blend](residential_equipment.blend) conserve les pièces nommées. Le [générateur](../../../tools/generate_residential_models.py) reconstitue la géométrie et le [manifeste](../../../prototype/assets/models/residential_v013/manifest.json) donne les empreintes SHA-256, dimensions, nombres de pièces et triangles.

## Inventaire

| Modèle | Dimensions L × H × P (m) | Pièces source | Triangles | Aperçu Blender |
| --- | --- | ---: | ---: | --- |
| Fauteuil de repos résidentiel | 0.890 × 1.112 × 0.827 | 21 | 2556 | [rest_armchair](previews/residential_rest_armchair.png) |
| Armoire de soins des résidents | 0.585 × 0.700 × 0.251 | 25 | 13376 | [medicine_cabinet](previews/residential_medicine_cabinet.png) |
| Bibliothèque commune en noyer | 1.420 × 2.002 × 0.380 | 129 | 10172 | [resident_bookcase](previews/residential_resident_bookcase.png) |
| Table basse et album des résidents | 1.140 × 0.546 × 0.690 | 14 | 3216 | [coffee_table](previews/residential_coffee_table.png) |
| Lampe de lecture sur pied | 0.554 × 1.605 × 0.648 | 8 | 3220 | [reading_lamp](previews/residential_reading_lamp.png) |
| Interphone des résidences | 0.220 × 0.390 × 0.161 | 15 | 7808 | [wall_intercom](previews/residential_wall_intercom.png) |
| Commande du passage de service | 0.280 × 0.470 × 0.205 | 11 | 18828 | [service_latch_panel](previews/residential_service_latch_panel.png) |
| Baie de télécommunications | 0.700 × 2.105 × 0.789 | 89 | 21768 | [telecom_rack](previews/residential_telecom_rack.png) |
| Panneau de brassage local | 0.510 × 0.320 × 0.354 | 30 | 29440 | [patch_panel](previews/residential_patch_panel.png) |
| Alimentation secourue du relais | 0.551 × 0.750 × 0.719 | 18 | 18460 | [ups_battery](previews/residential_ups_battery.png) |
| Console de contrôle du relais A17 | 1.560 × 1.577 × 0.780 | 52 | 15544 | [relay_console](previews/residential_relay_console.png) |
| Enregistreur à deux canaux | 0.240 × 0.119 × 0.177 | 16 | 10764 | [voice_recorder](previews/residential_voice_recorder.png) |

Total : **12 modèles**  **428 pièces source**  **155 152 triangles** et **5 203 300 octets** de GLB.

## Intégration

Les GLB utilisent le mètre, +Y vers le haut et −Z vers la face avant. Leur origine est centrée sous leur enveloppe. Les pièces source gardent leurs noms dans Blender ; le rendu est regroupé en une seule maille par modèle, avec surfaces séparées par matériau. Les UV sont projetés par pièce ; les matières partagées acier et caoutchouc sont appliquées dans Godot en coordonnées locales.

Les collisions sont ajoutées par la présentation du chapitre. Les meubles restent hors des couloirs des escortes et des appuis du rappel. Les éléments muraux sont fixés à des cloisons ou montants visibles. Les indications de destination et de référence du relais sont du texte Godot lisible sur une plaque, indépendant des petites inscriptions des meshes.

La grille du passage 18–19 est une géométrie dynamique distincte : son état physique suit l’action au Halligan. Le modèle de loquet reste attaché au montant. Les baies, la console et l’alimentation secourue sont des éléments de décor associés aux actions du jeu.

## Vérification et limites

Le test `prototype/tests/test_residential_assets.gd` charge les douze GLB et vérifie leurs mailles, surfaces, UV, dimensions et pivots. Le test de parcours du chapitre vérifie les collisions des escortes dans le décor réellement assemblé. Les résultats complets sont consignés dans les rapports de la version.

La [revue des douze aperçus](previews/residential_visual_review.json) consigne les observations et empreintes des images finales. Les douze aperçus sont des rendus Blender Cycles ; ils ne constituent pas des captures du jeu. Ils permettent de contrôler silhouette, assemblage, pièces manquantes, orientation, échelle et lisibilité des marquages. Les modèles sont statiques : aucun rig, animation de pièce, LOD ou scan de matériau n’est revendiqué. Les personnages restent procéduraux.
