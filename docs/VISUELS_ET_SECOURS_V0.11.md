# The Tower Descent — visuels et matériel de secours v0.11

Cette version développe la présentation et les gestes d’intervention sur le parcours existant, du toit d’Aube à l’exposition du 23. Elle apporte huit albedos originaux générés pour le projet, seize modèles de secours éditables, quatre outils utilisables et deux profils d’éclairage Godot. Les fichiers et les résultats de validation sont identifiés par empreinte dans les manifestes de la version.

## Intention visuelle

Nacre conserve le contraste entre un établissement côtier autrefois luxueux et les installations de secours improvisées après l’impact. Le béton salin et les métaux froids portent la structure ; le bois fumé, la pierre sombre, la moquette bleu-vert et la porcelaine rappellent les espaces publics et les suites. Le rouge, le jaune et l’orange du matériel restent lisibles sur ces surfaces.

Les premières phases de l’horreur restent discrètes. Ce chantier ne révèle pas de monstre précoce, ne confirme pas le sort de Bravo et ne déplace pas Alma dans les étages supérieurs. Le récit, les trois premières réceptions au toit, l’escorte du congrès et les deux relevés de l’exposition sont conservés. Le 22 et les niveaux inférieurs restent à produire.

## Éclairage sous Godot

Le profil **cinématique** demande Forward+ au lancement. Il combine SDFGI, SSIL, SSAO, réflexions en espace écran, ombres de lumières locales, brouillard volumétrique et glow modéré. La réponse tonale ACES et un remplissage ambiant limité préservent la lisibilité des pièces sans effacer les zones sombres. Les réglages exacts sont dans `prototype/scripts/cinematic_lighting.gd`.

Il s’agit d’une interprétation de l’intention lumineuse demandée, avec des rebonds, des sources pratiques et de la profondeur atmosphérique. Ce n’est pas une implémentation de Lumen ni une promesse de parité. SDFGI éclaire les surfaces opaques fixes d’Aube. Les personnages, les outils, les hélicoptères, Hespérie en mouvement, le vitrage et les effets mobiles sont exclus de ses occluders statiques. Les ombres directes continuent de fonctionner. Une invalidation bornée du cache accompagne le changement structurel stabilisé afin d’éviter de conserver les voxels d’une ancienne configuration.

Le profil **Compatibilité** conserve les modèles, textures, lumières directes, ombres locales et brouillard maritime classique. Il utilise un remplissage ambiant adapté et ne prétend pas exécuter SDFGI, SSIL, SSR ou le brouillard volumétrique. Le Web choisit ce moteur. Les lanceurs Windows permettent de choisir le moteur avant le démarrage ; le changement de moteur ne se fait pas à chaud.

| Lancement | Moteur demandé | Profil réellement activé |
| --- | --- | --- |
| `JOUER_CINEMATIQUE.cmd` ou lancement direct de l’EXE | Forward+ / Vulkan | Cinématique uniquement si Godot rapporte Forward+, un RenderingDevice et un affichage natif |
| `JOUER_COMPATIBILITE.cmd` | Compatibility / OpenGL 3 | Portable |
| Export Web | Compatibility | Portable |
| Tests headless | Affichage sans rendu natif | Portable, identifié comme contrôle de logique |

L’API `world.lighting_snapshot()` rapporte le moteur obtenu et les effets actifs. La fixture de comparaison attend 96 images de stabilisation par cadrage et refuse un moteur différent de celui demandé. Elle produit les mêmes vues du toit, du restaurant, du congrès et des archives après impact dans les deux modes. Ces captures permettent une comparaison visuelle, sans constituer un benchmark d’une carte graphique de joueur.

Sources techniques officielles : [SDFGI](https://docs.godotengine.org/en/4.5/tutorials/3d/global_illumination/using_sdfgi.html), [moteurs de rendu](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html), [brouillard volumétrique](https://docs.godotengine.org/en/4.4/tutorials/3d/volumetric_fog.html). Les propriétés effectivement appliquées sont contrôlées avec la version Godot 4.7.2 du projet.

## Huit matières

Chaque fichier est un PNG RGB de **1254 × 1254 pixels**, résolution native obtenue lors de la génération. Les prompts demandaient 2048² ; les images n’ont pas été agrandies pour simuler cette définition. Le manifeste conserve les prompts complets, les SHA256, les dimensions et les observations.

| Identifiant | Usage principal | Répétition dans le décor |
| --- | --- | --- |
| `salt_concrete` | Dalles, structure, surfaces techniques | 2,0 m |
| `smoked_oak` | Boiseries et mobilier | 1,4 m |
| `dark_stone` | Pierre sombre et éléments minéraux | 1,8 m |
| `brushed_steel` | Métal brossé, accessoires | 0,8 m |
| `rescue_red_paint` | Peinture rouge du matériel | 0,8 m |
| `black_rubber` | Caoutchouc, prises et protections | 0,5 m |
| `teal_carpet` | Moquette bleu-vert | 1,0 m |
| `porcelain_tile` | Surfaces claires et spa | 1,2 m |

Les surfaces de décor utilisent une projection triplanaire à l’échelle du monde. Les objets mobiles reçoivent une variante locale pour éviter que la texture glisse lorsqu’ils tournent. Un microrelief et une rugosité de détail périodiques sont produits de façon déterministe en 128². Ces petites cartes sont des approximations artistiques, pas des mesures de matériaux scannés. La métallicité et la rugosité de base restent distinctes pour chaque matière.

Les modèles importés partagent les albedos métal, peinture rouge et caoutchouc par référence. Ils ne réembarquent pas une copie des PNG dans chaque GLB. La couleur blanche du multiplicateur évite de teinter deux fois l’albedo ; les paramètres metallic et roughness des matériaux du modèle sont conservés.

La répétition révèle quelques raccords, notamment sur le bois et la pierre. Les observations exactes figurent dans [le guide des textures](../prototype/assets/materials/v011/README.md) et [leur manifeste](../prototype/assets/materials/v011/manifest.json). Le lot n’est pas présenté comme un ensemble de scans PBR ni comme des textures parfaitement raccordables dans toutes les conditions.

## Seize modèles éditables

Les modèles sont construits dans Blender avec des pièces nommées, des biseaux, des normales et des UV. Le fichier `.blend` garde les pièces séparées. L’export regroupe les pièces par objet en un maillage à plusieurs surfaces afin de limiter le nombre de nœuds importés. Chaque GLB utilise les mètres et possède son origine au point de pose. Dans Godot, +Y est le haut et -Z la face avant du modèle.

| Modèle | Détails et fonction dans cette version |
| --- | --- |
| Hache de secours | Lame biseautée, pic, douille, manche et prises ; outil en main et râtelier |
| Extincteur | Corps, valve, goupille, manomètre, flexible et buse ; outil en main, poste fixe et station de toit |
| Halligan | Fourche, bec et barre ; outil de déblocage |
| Coupe-boulon | Mâchoires, articulation et poignées ; libération d’un projecteur |
| Lampe de secours | Corps, lentille et prise ; modèle de la lampe du joueur et accessoire de poste |
| Projecteur portatif | Tête lumineuse et support ; source activable au congrès |
| Radio | Antenne, écran et commandes ; poste d’Alpha |
| Sac médical | Compartiments et sangles ; toit et refuge |
| Corde lovée | Réserve de corde sur la mallette |
| Mousqueton | Corps et fermeture ; râtelier |
| Descendeur en huit | Corps et anneaux ; accessoire de râtelier, distinct du descendeur à levier du rappel déjà jouable |
| Bouteille d’oxygène | Corps, robinet, manomètre et flexible ; matériel médical au poste et au refuge |
| Casque | Coque et éléments de protection ; comptoir d’Alpha |
| Brancard | Cadre, toile et sangles ; postes de secours |
| Mallette | Corps, couvercle et fermetures ; réserve matérielle |
| Balise | Corps, protection et feu ; repérage des postes |

Les dimensions, les positions de prise, les triangles et les empreintes **mesurés dans la construction finale** sont consignés dans [le manifeste de modèles](assets/v0.11/rescue_equipment_manifest.json). [Le guide d’édition](assets/v0.11/README.md) donne la commande de reconstruction et les conventions. Les vues Blender servent à vérifier les formes ; les captures Godot vérifient leur intégration dans le moteur.

## Quatre gestes jouables

Les touches physiques **1 à 4**, ainsi que les touches correspondantes du pavé numérique, choisissent un outil. Cette liaison fonctionne sur les rangées numériques AZERTY et QWERTY. L’outil apparaît en main ; **maintenir E** déclenche le travail sur un site visé, proche et accessible. Les durées ci-dessous correspondent à des paramètres de jeu.

| Outil | Site facultatif | Durée | Conséquence |
| --- | --- | --- | --- |
| Hache | Réserve de balisage, pièce ouest des suites 29 | 1,8 s | Ouverture visuelle et une fusée supplémentaire, plafond six |
| Extincteur | Corbeille en feu, passage intérieur des archives 28 | 3,0 s | Foyer local éteint et une charge consommée sur trois |
| Halligan | Armoire médicale, ouest du refuge 25 | 2,2 s | Armoire ouverte et jusqu’à vingt points d’état physique, plafond cent |
| Coupe-boulon | Projecteur enchaîné dans le foyer du congrès 24 | 1,6 s | Projecteur libéré et éclairage allumé |

Ces sites apparaissent après la stabilisation de l’impact. Le quatrième n’existe dans le monde jouable qu’après le choix de continuation. Ils restent hors des passages protégés et ne conditionnent ni un sauvetage, ni une preuve, ni l’ouverture du 23. L’extincteur retire son foyer et sa fumée locale ; il ne supprime pas les autres dangers enfumés du plateau.

La validation vérifie la distance, l’orientation du regard, la visibilité réelle, l’étage, l’appui au sol, le bon outil et les mains libres. Un mur interposé refuse le geste. Relâcher E, s’éloigner, changer d’outil, ouvrir un panneau ou perdre ce contexte annule la progression sans charge consommée. Les outils sont rangés pendant le portage, le treuil, le rappel, la secousse et les séquences de présentation. Les mouvements réduits diminuent leur animation cosmétique.

Les résultats achevés utilisent des identifiants `equipment_*` distincts dans le registre `supplies_used` du schéma 4. Les caisses de secours gardent leurs deux identifiants et leur compteur propre. Cette extension n’impose pas de migration de sauvegarde supplémentaire. Une action interrompue n’est pas enregistrée en cours ; une action terminée ne peut pas produire deux récompenses. La reprise reconstruit les objets ouverts, le foyer éteint et le projecteur allumé à partir du registre. Le dossier Situation expose les travaux achevés et la réserve de l’extincteur.

## Validation et contenu des paquets

La construction sépare trois étapes : génération des modèles et contrôle du candidat, revue du runtime gelé, puis emballage après approbation explicite des fichiers. Les scripts ne créent pas eux-mêmes une approbation visuelle. Les rapports se trouvent dans `docs/validation/v0.11` et `.review/v0.11` ; chaque résultat doit être lu avec le commit et les empreintes qu’il cite.

Le contrôle source couvre les comportements historiques et les nouveaux outils, matériaux et profils. Les ressources Windows et Web sont également chargées depuis des dossiers isolés. Le plan de revue comporte 42 états du secteur initial, 13 de continuation, 8 d’équipement et 4 cadrages comparables dans chacun des deux moteurs. Les images du jeu sont des états préparés, avec la méthode inscrite dans leurs manifestes. Elles ne constituent pas un enregistrement d’une partie humaine.

Le ZIP Windows contient le programme, les deux lanceurs, le guide et les notices. Le ZIP Sources conserve les scripts, textures, modèles, source Blender, guides, tests et captures de la version, ainsi que la Bible intégrale Word/PDF v0.9 et son supplément Word/PDF v0.10. Les archives précédentes restent disponibles dans leur version d’origine. Le pack source reste limité à moins de 100 Mio, comme le pack Windows.

Le rendu et la performance sur un PC Windows de joueur, une carte graphique dédiée ou un navigateur doivent encore être mesurés sur ces environnements. Les personnages, animations de mains, véhicules et une partie importante de l’architecture restent procéduraux. Les modèles de secours constituent un lot d’assets de prototype éditables ; les LOD, les collisions détaillées de chaque accessoire et les animations de combat ne sont pas livrés ici. Les outils présentés servent aux interventions contextuelles décrites ci-dessus.
