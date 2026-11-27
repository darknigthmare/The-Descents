# Catalogue des captures v0.12

**Revue achevée : 21 PNG natifs ouverts et examinés individuellement par trois agents**, répartis entre 18 vues Compatibilité et trois vues Forward+. Les fichiers appartiennent à la candidature `9756f0b707c1ffc72284754ec1f1ff301ffdd960`, issue de la source `2e4de42ce85a42c80dae97a1de9985194430d9b6`. La [revue visuelle](validation/v0.12/VISUAL_REVIEW.json) conserve une observation, une taille et une empreinte SHA-256 par image.

Les captures proviennent de Godot 4.7.2 sous Linux, avec un affichage graphique et des **états de mission préparés** par [visual_commerce_preview.gd](../prototype/tests/visual_commerce_preview.gd). Elles ne constituent pas une partie humaine, une exécution native de Windows ou du WebAssembly dans un navigateur, ni un benchmark de GPU. Les parcours physiques et les conditions de réception sont contrôlés séparément dans les [43 suites sources](validation/v0.12/VERIFICATION.json).

| Groupe | Images effectivement examinées | Dimensions | Métadonnées |
| --- | ---: | --- | --- |
| Compatibilité, `gl_compatibility` | 18 | 16 en 1440 × 900 ; deux en 1024 × 640 | [Manifeste](captures/v0.12/commerce/compatibility/MANIFEST.json) · [Provenance](captures/v0.12/commerce/compatibility/PROVENANCE.json) |
| Forward+, `forward_plus` | 3 | 1440 × 900 | [Manifeste](captures/v0.12/commerce/forward_plus/MANIFEST.json) · [Provenance](captures/v0.12/commerce/forward_plus/PROVENANCE.json) |

## Compatibilité — 18 vues

| Capture exacte | État préparé examiné |
| --- | --- |
| [01_bilan_23.png](captures/v0.12/commerce/compatibility/01_bilan_23.png) | Bilan du 23, cinq premières réceptions et choix explicite de poursuite |
| [02_gallery_22.png](captures/v0.12/commerce/compatibility/02_gallery_22.png) | Galerie, vitrines, terrazzo et circulation |
| [03_mina_shutter_closed.png](captures/v0.12/commerce/compatibility/03_mina_shutter_closed.png) | Volet fermé et Mina dans la réserve |
| [04_mina_shutter_open.png](captures/v0.12/commerce/compatibility/04_mina_shutter_open.png) | Volet soulevé après l’action et accès à Mina |
| [05_retranche_close.png](captures/v0.12/commerce/compatibility/05_retranche_close.png) | Proximité du Retranché, posture de protection et consigne de recul |
| [06_retranche_calm.png](captures/v0.12/commerce/compatibility/06_retranche_calm.png) | Distance conservée, lampe abaissée et dialogue achevé |
| [07_kitchen_before.png](captures/v0.12/commerce/compatibility/07_kitchen_before.png) | Cuisine, équipements importés, foyer et fumée avant intervention |
| [08_kitchen_after.png](captures/v0.12/commerce/compatibility/08_kitchen_after.png) | Réchauffeur isolé, couverture déployée et foyer contenu |
| [09_stairs_22_21.png](captures/v0.12/commerce/compatibility/09_stairs_22_21.png) | Trémie, marches et garde-corps de l’escalier local nord |
| [10_rope_22_21.png](captures/v0.12/commerce/compatibility/10_rope_22_21.png) | Rappel personnel, descendeur et mesures du HUD |
| [11_refuge_20.png](captures/v0.12/commerce/compatibility/11_refuge_20.png) | Refuge avant réception, lits, paravents et marques d’accueil |
| [12_receptions_20.png](captures/v0.12/commerce/compatibility/12_receptions_20.png) | État préparé des trois personnes reçues ; leurs trajets sont testés séparément |
| [13_journal_people.png](captures/v0.12/commerce/compatibility/13_journal_people.png) | Dossier, compteur de huit personnes et liste défilable |
| [14_journal_clues.png](captures/v0.12/commerce/compatibility/14_journal_clues.png) | Registre des livraisons et consigne de maintenance collectés |
| [15_bilan_20.png](captures/v0.12/commerce/compatibility/15_bilan_20.png) | Bilan des trois nouveaux secours et conservation des cinq précédents |
| [16_menu_20.png](captures/v0.12/commerce/compatibility/16_menu_20.png) | Accueil contextuel au refuge 20 |
| [17_compact_journal.png](captures/v0.12/commerce/compatibility/17_compact_journal.png) | Journal à 1024 × 640, onglets et commande de fermeture |
| [18_compact_bilan.png](captures/v0.12/commerce/compatibility/18_compact_bilan.png) | Bilan à 1024 × 640, cartes nominatives et commandes de retour |

## Forward+ — trois vues comparables

Ces trois vues ont réellement été rendues avec Forward+ ; elles ne sont pas des copies du groupe Compatibilité. Le même nom désigne un cadrage comparable, distingué par son chemin complet.

| Capture exacte | État préparé examiné |
| --- | --- |
| [02_gallery_22.png](captures/v0.12/commerce/forward_plus/02_gallery_22.png) | Vitrines, terrazzo, ombres et lecture des volumes de la galerie |
| [07_kitchen_before.png](captures/v0.12/commerce/forward_plus/07_kitchen_before.png) | Équipements de cuisine, lumière locale, feu et fumée stylisés |
| [11_refuge_20.png](captures/v0.12/commerce/forward_plus/11_refuge_20.png) | Lits, paravents, appuis et espace d’accueil |

## Observations et conservation

Aucun blocage visuel n’a été relevé sur ces états. Les réserves consignées concernent les personnages et effets de feu/fumée stylisés, quelques superpositions de notifications et de libellés 3D, ainsi qu’une aide de commandes parfois peu contrastée. Les textes longs du journal et du bilan compact restent dans des panneaux à défilement ; leur fonctionnement interactif ne se déduit pas d’une image fixe. Les formulations génériques sur une personne encore portée et le libellé « Reprendre l’intervention » au bilan achevé restent perfectibles.

Les 21 PNG et leurs quatre fichiers de manifeste/provenance forment le contenu de [The-Tower-Descent-v0.12-Captures-native.zip](../releases/The-Tower-Descent-v0.12-Captures-native.zip), sous `The-Tower-Descent/docs/captures/v0.12/`. La présence du [manifeste final v0.12](../releases/VERIFICATION_V0.12.json), publié avec l’archive après contrôle, confirme sa disponibilité et son empreinte. L’extraction dans le même dossier parent que Sources réunit les chemins du projet et des captures.

Les aperçus Blender des [douze modèles](assets/v0.12/MODELS.md), les textures et les [neuf pages du supplément revues](validation/v0.12/DOCUMENT_REVIEW.json) forment des preuves distinctes, non comptées parmi les 21 images du moteur. Les [71 captures v0.11](CAPTURES_V0.11.md) restent historiques et ne sont pas présentées comme une nouvelle série v0.12. Voir aussi [État de livraison](ETAT_DE_LIVRAISON.md) et [Exports](EXPORTS.md).
