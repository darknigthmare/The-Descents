# Modèles de commerces, cuisines et refuge — v0.12

Lot original éditable pour **The Tower Descent**. Les douze modèles sont livrés en GLB séparés et dans un fichier Blender commun. Les objets sont conçus pour les secteurs A22, A21 et A20 ; leur présence dans une scène et leur éventuelle interaction restent déterminées par le code de mission.

## Contenu

| ID | Destination | Dimensions X × Y × Z, m | Triangles | Pièces éditables |
| --- | --- | --- | ---: | ---: |
| `retail_display_case` | A22 · galerie | 1.410 × 1.192 × 0.670 | 9,152 | 48 |
| `cash_register` | A22 · boutique | 0.440 × 0.491 × 0.372 | 6,636 | 30 |
| `shutter_control` | A22 · passage de service | 0.130 × 0.325 × 0.099 | 5,088 | 18 |
| `service_trolley` | A21 · circulation de service | 0.696 × 1.001 × 0.564 | 17,368 | 58 |
| `industrial_sink` | A21 · plonge | 1.200 × 1.314 × 0.699 | 10,608 | 42 |
| `kitchen_stove` | A21 · cuisson | 1.030 × 1.135 × 0.880 | 22,816 | 68 |
| `extraction_hood` | A21 · au-dessus de cuisson | 1.455 × 0.811 × 0.975 | 8,678 | 45 |
| `utility_cutoff_panel` | A21 · local technique | 0.400 × 0.580 × 0.231 | 27,320 | 22 |
| `fire_blanket_cabinet` | A21 · sécurité incendie | 0.290 × 0.410 × 0.109 | 24,532 | 14 |
| `folding_cot` | A20 · refuge | 0.772 × 0.530 × 2.000 | 8,636 | 34 |
| `water_canister` | A20 · réserve de secours | 0.286 × 0.458 × 0.276 | 11,040 | 29 |
| `privacy_screen` | A20 · zone de soins | 1.858 × 1.744 × 0.475 | 24,556 | 77 |

Total : **12 GLB**, **176,430 triangles**, **6,153,872 octets**. Source `.blend` compressée : **2,148,209 octets**. Les valeurs exactes et SHA256 figurent dans `prototype/assets/models/commerce_v012/manifest.json`.

## Construction et lisibilité

- **Vitrine de boutique** — Vitrine vitrée, pieds/plinthes en noyer et laiton, tablette intérieure et supports de présentation.
- **Caisse et terminal de paiement** — Caisse avec tiroir, terminal incliné, imprimante et lecteur de paiement ; aucun paiement réel.
- **Commande de rideau de service** — Boîtier mural à clé et boutons haut/arrêt/bas ; comportement décidé par le système de mission.
- **Chariot de service inox** — Chariot inox à trois plateaux, roues pivotantes et poignées ; modèle statique.
- **Plonge de cuisine et robinet** — Cuve ouverte, rebords, égouttoir nervuré, siphon, robinet col-de-cygne et pieds réglables.
- **Fourneau professionnel** — Fourneau à quatre foyers, commandes, vitre de four sombre, poignée et ventilation inférieure.
- **Hotte et filtres d'extraction** — Hotte suspendue, deux filtres à chicanes, prises de main, lumières sous capot et conduit supérieur.
- **Coffret de coupure A21** — Coffret mural avec joint, charnières, poignée rouge de sectionnement, voyant et presse-étoupes.
- **Armoire de couverture anti-feu** — Armoire rouge de couverture anti-feu, instructions en relief et deux languettes.
- **Lit pliant de refuge** — Lit de deux mètres, toile tendue légèrement fléchie, pieds croisés, attaches, oreiller et couverture pliée.
- **Jerrican d'eau 10 litres** — Jerrican dix litres à poignée ajourée, bouchon nervuré, robinet et repère EAU.
- **Paravent de secours trois panneaux** — Paravent trois panneaux à vrais plis, anneaux, charnières et six roulettes.

Les pièces du fichier Blender restent distinctes et nommées. Les arêtes métalliques et polymères ont des chanfreins, les corps cylindriques des normales lissées et les surfaces des coordonnées UV. Les GLB regroupent chaque objet en un maillage à plusieurs surfaces de matériaux pour limiter le nombre de nœuds de rendu. La cuve de la plonge et la hotte ont une géométrie ouverte réelle ; la toile du lit et le paravent ont une épaisseur.

## Repères et intégration

- Unités : mètres. Blender : +Z en haut, +Y vers l’avant. Godot/glTF : +Y en haut, −Z vers l’avant.
- Origine : centre au sol de la géométrie exportée. Les dimensions sont mesurées sur les sommets réels après application des modificateurs, avec une vérification indépendante du GLB.
- La hotte et les boîtiers muraux gardent la même convention : l’intégration place leur origine à la hauteur de montage voulue.
- Les GLB n’embarquent aucune collision. L’environnement choisit les volumes utiles au passage du joueur ; une vitrine n’autorise pas une interaction à travers une cloison.
- Les valeurs `grip` indiquent des points de manipulation potentiels ; elles n’annoncent ni prise en main ni animation jouable pour ces accessoires.

```gdscript
const CommerceAssets = preload("res://scripts/commerce_asset_catalog.gd")

var model: Node3D = CommerceAssets.instantiate("industrial_sink")
if model != null:
	add_child(model)
	model.position = Vector3(5.0, 0.0, -3.0)
```

Le catalogue expose `all_ids()`, `asset_path(id)`, `dimensions(id)`, `metadata_for(id)`, `grip_offset(id)` et `instantiate(id)`. Une instance reçoit `commerce_asset_id` et `authored_model`. Les matériaux inox, rouge et caoutchouc peuvent réutiliser les albedos v0.11 ; les autres couleurs sont des matériaux éditables à rugosité/métallicité scalaires.

## Implantation dans la tranche A22–A20

L’implantation complète les GLB par de petits supports construits dans la scène. Les coffrets de coupure, de couverture anti-feu et de relais reposent sur des racks fixés au sol, avec plaques arrière et collisions. Leurs faces restent accessibles depuis les cibles d’intervention. La commande du volet est appliquée sur la face de la cloison qui donne dans la galerie. Le coffret du refuge reçoit une plaque « RELAIS A20 » couvrant l’identification cuisine du modèle partagé.

La caisse repose à la hauteur réelle du comptoir, le jerrican sur le plateau supérieur du chariot et la couverture déployée sur les supports de cuisson. Les fourneaux et les plonges présentent leurs commandes vers l’allée. Les trois hottes sont espacées sans chevauchement, puis raccordées au plafond par conduits et suspentes. Ces corrections ne modifient ni les GLB ni les points de parcours des escortes.

Les trois lits et les paravents conservent un dégagement entre les couchages, leurs extrémités et les marques de réception. La vérification de ces placements repose sur les dimensions des modèles, les coordonnées de scène, les parcours physiques et les rayons d’interaction. Elle ne constitue pas une nouvelle revue d’images Godot.

Lors de la confirmation de la couverture, le foyer et la fumée locale deviennent immédiatement invisibles et l’exposition associée cesse. La v0.12 ne simule pas une dissipation progressive des fumées.

## Reproduction

```bash
blender --background --factory-startup --python tools/generate_commerce_models.py -- --root . --render
```

Le générateur réemploie les primitives et exporteurs de `tools/generate_rescue_models.py` sans modifier le lot v0.11. Il écrit les GLB et le manifeste dans `prototype/assets/models/commerce_v012/`, le catalogue Godot, `docs/assets/v0.12/commerce_equipment.blend` et douze aperçus Cycles dans `docs/assets/v0.12/previews/commerce_*.png`.

## Vérification et réserves

`prototype/assets/models/commerce_v012/validation.json` consigne le contrôle des douze fichiers binaires : intégrité glTF 2, empreintes, index de triangles, normales unitaires finies, UV finies, dimensions transformées et centre bas. Ce contrôle ne remplace ni l’import moteur ni la vérification des placements.

Les aperçus individuels sont des rendus **Blender Cycles CPU**, et ne sont pas des captures de gameplay. La revue a corrigé le raccord écran/boîtier du lecteur de paiement, la vitre du four et le contraste de l’instruction TIRER. La vitrine transparente reste sensible à l’ordre de transparence et aux fonctions du moteur.

Les objets restent statiques : pas de rig, de LOD, de mécanisme articulé ni de simulation physique embarquée. Les paramètres de matière sont artistiques et ne constituent pas des scans PBR mesurés. Aucun niveau de performance GPU ou de qualité finale AAA n’est certifié par ce lot.
