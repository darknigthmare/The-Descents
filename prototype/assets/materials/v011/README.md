# Matériaux Nacre — v0.11

Ce lot contient huit images originales générées pour les surfaces du prototype **The Tower Descent**. La direction visuelle associe matériaux d’hôtel côtier haut de gamme, teintes sobres et usure récente : sels, poussière fine, petites abrasions. Chaque PNG est une carte de couleur de base (albedo), vue de face, sans scène, texte, logo ou éclairage dramatique.

## Fichiers et échelle proposée

Les chemins sont relatifs au dépôt. Une taille physique décrit la surface couverte par **une répétition entière du PNG**, et reste un choix de direction artistique.

| Fichier dans `prototype/assets/materials/v011/` | Surface suggérée par répétition | Usage prévu |
| --- | --- | --- |
| `salt_concrete.png` | 2 × 2 m | Béton architectural légèrement salin |
| `smoked_oak.png` | 1,2 × 1,2 m | Quatre lames de chêne fumé verticales |
| `dark_stone.png` | 2 × 2 m | Pierre graphite des sols et parements |
| `brushed_steel.png` | 0,6 × 0,6 m | Métal brossé et équipement |
| `rescue_red_paint.png` | 0,5 × 0,5 m | Peinture rouge du matériel de secours |
| `black_rubber.png` | 0,4 × 0,4 m | Poignées et surfaces en caoutchouc |
| `teal_carpet.png` | 1 × 1 m | Moquette pétrole des espaces intérieurs |
| `porcelain_tile.png` | 1,2 × 1,2 m | Quatre carreaux de porcelaine de 60 cm |

## Résolution et intégration

Les huit images sont des **PNG RGB 8 bits de 1254 × 1254 pixels**, à leur résolution native. Une taille de 2048 × 2048 était demandée dans les prompts, mais l’outil a retourné 1254 × 1254. Aucun agrandissement, recadrage, correction colorimétrique ou traitement des pixels n’a été appliqué aux livrables.

Les textures sont destinées au canal de couleur de base en sRGB. Elles ne constituent pas un ensemble PBR complet : ce lot ne contient ni normales, ni rugosité, ni métallicité, ni hauteur, ni occlusion, ni émission. Ces propriétés relèvent des matériaux du moteur. Les couleurs produites sont des choix artistiques plausibles, pas des mesures de réflectance.

Le fichier `manifest.json` conserve les prompts exacts, la provenance, les dimensions, le poids, les empreintes SHA256 et les identifiants des blobs Git. Il distingue les vérifications réalisées et celles restant à effectuer.

## Contrôle visuel et raccords

Les huit images originales ont été affichées et examinées. Des aperçus de quatre copies en grille 2 × 2 ont été produits pour vérifier les raccords ; sept ont été réellement ouverts et examinés. Les aperçus sont des montages temporaires de contrôle et ne modifient pas les PNG source.

- L’acier, la peinture rouge, le caoutchouc et la moquette ne montrent pas de couture fortement visible à l’échelle de ces aperçus.
- Le béton conserve un motif minéral périodique identifiable.
- Le bois présente une légère rupture du veinage au raccord haut-bas.
- La pierre sombre présente une légère limite horizontale de texture au raccord haut-bas.
- La porcelaine a été examinée seule : grille régulière, joints droits, pas de reflet directionnel marqué. Son aperçu répété a été généré, mais son ouverture a échoué lorsque l’environnement d’exécution est devenu indisponible.

**Aucune garantie de périodicité parfaite (« seamless ») n’est donnée.** Les bords n’ont pas été égalisés par traitement de pixels. Le contrôle en situation dans le moteur, ainsi que l’examen du dernier aperçu répété, restent nécessaires. Les éventuelles corrections d’image doivent préserver la traçabilité de la génération.

## Conservation et vérification des octets

Après l’interruption de l’exécuteur, les huit retours originaux Imagegen étaient encore disponibles sous forme de données PNG. Ils ont été enregistrés directement comme blobs GitHub, sans régénération et sans déplacement de branche.

Pour chacun, la signature PNG, les dimensions IHDR, les CRC de tous les chunks et la présence d’un IEND complet ont été vérifiés en mémoire. Les SHA256 ont été calculés sur les octets décodés ; ceux du béton et du bois concordent avec les mesures locales indépendantes effectuées avant l’interruption. La création de ces blobs ne constitue pas à elle seule un commit ni une publication.
