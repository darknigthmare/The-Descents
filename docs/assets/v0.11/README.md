# Équipements de secours — sources v0.11

Cette bibliothèque fournit 16 modèles 3D originaux, construits avec Blender Python. Les pièces sont de vrais volumes : outils forgés, corps sous pression, tubes, poignées, fixations, éléments souples et surfaces biseautées. Aucun modèle externe ni texture matricielle n’est incorporé aux GLB.

## Régénération

Version de référence : Blender 4.3.2. La version effectivement employée est inscrite dans le manifeste. Pour les aperçus, Pillow doit être installé dans le Python utilisé par Blender ; il assemble uniquement les images déjà rendues par Cycles.

Depuis la racine du dépôt :

~~~sh
blender --background --factory-startup --python tools/generate_rescue_models.py -- --root . --render
python tools/validate_rescue_models.py --root . --previews
~~~

Sans l’option --render, le générateur produit les modèles, la source, les manifestes et le catalogue. Avec --render, il produit aussi seize vues individuelles, une planche de contact 1600 × 900 et quatre vues de détail 800 × 800. Les rendus utilisent Cycles sur CPU, 64 échantillons pour les vues individuelles et 96 pour les détails. Le débruitage est désactivé pour fonctionner aussi avec les builds Cycles dépourvus d’OpenImageDenoiser.

Le générateur peut remplacer les fichiers qu’il produit. Il ne télécharge aucun élément, ne modifie aucune branche et ne lance aucun export du jeu.

## Fichiers produits

| Fichier ou dossier | Usage |
|---|---|
| prototype/assets/models/rescue_v011/*.glb | Modèles du jeu, sans caméra ni lumière |
| prototype/assets/models/rescue_v011/manifest.json | Mesures, pivots, triangles, matériaux, taille et SHA-256 |
| prototype/scripts/rescue_asset_catalog.gd | Catalogue Godot et points de prise mesurés |
| docs/assets/v0.11/rescue_equipment.blend | Bibliothèque éditable, un équipement par collection |
| docs/assets/v0.11/rescue_equipment_manifest.json | Copie du manifeste, près de la source |
| docs/assets/v0.11/rescue_equipment_contact_sheet.png | Planche de rendus réels |
| docs/assets/v0.11/renders/ | Vues individuelles et détails |

La source Blender est séparée du dossier du projet Godot afin de ne pas être importée ou embarquée comme ressource de jeu. Ses objets sont nommés par fonction et restent séparés pour faciliter l’édition. Les chanfreins et les normales sont appliqués ; le générateur demeure la source paramétrique reproductible.

## Échelles, axes et pivots

Toutes les mesures sont en mètres. Dans Blender, +Z est le haut et +Y la face avant. L’export glTF utilise +Y pour le haut et -Z pour l’avant. Les valeurs du manifeste et du catalogue sont exprimées dans les axes Godot.

Le pivot de chaque modèle est le centre inférieur de son volume englobant. Un objet posé à y = 0 repose donc à la hauteur du support. Le point de prise secondaire est donné par grip_offset_m dans le manifeste et grip_offset(id) dans le catalogue. Pour un outil tenu, l’intégration peut décaler le modèle de l’opposé de ce vecteur avant d’appliquer l’orientation de la main. Les dimensions définitives proviennent du modèle généré ; elles ne sont pas déduites d’une illustration.

## Identifiants stables

| ID | Équipement | Détails caractéristiques |
|---|---|---|
| fire_axe | Hache de secours | Lame effilée, tranchant, pic, douille forgée, manche courbe, grip nervuré |
| extinguisher | Extincteur ABC | Corps bombé, pied, collier, valve, poignée, levier, goupille et anneau, jauge, tuyau et buse |
| halligan | Outil Halligan | Fourche ouverte à deux dents, pointe effilée, bec biseauté, manche forgé |
| bolt_cutter | Coupe-boulons | Deux poignées, leviers articulés, rondelles, axes et mâchoires à facettes |
| rescue_flashlight | Lampe de secours | Grip, tête évasée, réflecteur, lentille, interrupteur, clip et dragonne |
| portable_worklight | Projecteur portable | Pied évasé, fourche réglable, boutons latéraux, matrice de LED, ailettes et batterie |
| rescue_radio | Radio de secours | Antenne, boutons, écran, microphone, poussoir latéral et clip |
| trauma_bag | Sac de traumatologie | Volume rembourré, poche, coutures, sangles, poignées et fermeture |
| rope_coil | Corde lovée | Dix tours de corde, attaches et extrémité libre |
| carabiner | Mousqueton | Corps en D ouvert, doigt mobile représenté, bague filetée et axes |
| descender | Descendeur en huit | Deux boucles volumétriques, taille et oreilles de retenue |
| oxygen_cylinder | Bouteille d’oxygène | Corps bombé, épaule blanche, vanne, volant, régulateur, manomètre et flexible |
| rescue_helmet | Casque de secours | Coque courbe avec épaisseur, rebord, arête supérieure, attaches et jugulaire |
| rescue_stretcher | Brancard | Cadre à taille réelle, poignées, toile, appui-tête, sangles, boucles et pieds |
| equipment_case | Valise de secours | Coque, joint, couvercle, nervures, fermoirs, charnières et poignée |
| emergency_beacon | Balise d’urgence | Socle, corps protégé, dôme optique nervuré et interrupteur |

## Matériaux et UV

Chaque modèle possède une projection UV avec îlots. Les matériaux exportent des valeurs PBR de couleur, de rugosité et de métallicité. Les noms sont conservés pour permettre une adaptation dans le moteur :

- Métaux : steel_brushed, steel_edge, steel_dark, brass_valve, anodized_blue.
- Peintures : paint_rescue_red, paint_safety_yellow, paint_rescue_orange, oxygen_green.
- Polymères : rubber_black, polymer_anthracite, lens_blue, beacon_amber.
- Tissus : fabric_red, fabric_teal, webbing_black, rope_gold.
- Signes et éclairage : label_ivory, label_ink, led_warm, screen_teal.

Les textures partagées du projet peuvent être affectées au runtime sans être dupliquées dans chacun des seize GLB. Les surfaces sont déjà lisibles avec leurs matériaux PBR seuls.

## Contrôle

Le validateur lit directement le conteneur GLB et ses données glTF. Il vérifie les seize identifiants, les empreintes, les tailles, les triangles, les attributs de position et de normales, les coordonnées UV, les matériaux, les axes, l’absence de textures dupliquées et les dimensions d’image attendues. Il impose un budget de 15 Mio pour l’ensemble des GLB et de 30 Mio pour la source éditable.

Ce contrôle technique ne remplace pas la revue des rendus ni l’inspection dans le jeu. Les verdicts visuels doivent correspondre aux images effectivement ouvertes, après génération.
