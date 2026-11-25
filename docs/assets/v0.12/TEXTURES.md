# Textures v0.12 — galerie commerciale et cuisines

Deux matières originales complètent les huit albedos v0.11. Elles sont destinées à la galerie commerciale du 22 et aux cuisines du 21. Chaque PNG contient une seule matière.

| ID recommandé | Fichier | Usage | Échelle UV proposée | Réglages de départ |
| --- | --- | --- | --- | --- |
| `ivory_terrazzo` | `prototype/assets/materials/v012/ivory_terrazzo.png` | Sol continu ivoire des boutiques et de la galerie | 2 × 2 m par répétition | Métal 0 ; rugosité 0,64 |
| `kitchen_sage_tile` | `prototype/assets/materials/v012/kitchen_sage_tile.png` | Carrelage technique gris vert des cuisines | 2 × 2 m, soit 5 × 5 carreaux nominaux de 40 cm | Métal 0 ; rugosité 0,88 |

## Origine et résolution

Les deux images ont été créées par génération originale avec l'outil intégré Imagegen, sans image de référence. Chaque demande décrivait une matière vue orthographiquement, une couleur diffuse uniforme, une répétition sur les bords et l'absence d'objet ou de texte.

La demande indiquait 2048 × 2048 pixels. Le résultat natif réel est **1254 × 1254 pixels, RGB 8 bits** pour chacune. Les fichiers livrés conservent les octets d'origine ; aucun agrandissement ni retouche n'a été appliqué.

Les prompts exacts, les paramètres exposés, les noms des sources générées, les tailles et les empreintes SHA256 figurent dans [le manifeste](../../../prototype/assets/materials/v012/manifest.json).

## Intégration

Ces fichiers sont uniquement des cartes de **couleur de base / albedo sRGB**. Ils ne contiennent pas de carte de normales, de hauteur, de rugosité, de métal ou d'occlusion. Les valeurs du tableau sont des choix de direction artistique pour le matériau Godot, pas des propriétés physiques mesurées.

Utiliser une teinte de matériau blanche lors du premier réglage pour préserver leur couleur. Adapter ensuite l'éclairage et la rugosité à la scène. La répétition doit être activée avec une échelle cohérente en mètres ; la grille de cuisine ne doit pas être étirée dans un axe.

Le terrazzo s'emploie dans les commerces et leur circulation principale, avec le bois fumé v0.11 pour le mobilier. Le carrelage gris vert distingue les zones de service et de préparation, avec l'acier brossé v0.11 pour les plans de travail. Cela conserve le contraste entre espaces publics luxueux et espaces techniques sans introduire de matière infernale prématurée.

## Vérification et limites

Les deux originaux ont été inspectés visuellement, puis répétés exactement en 2 × 2 dans des aperçus temporaires et inspectés individuellement. Le décodage complet des PNG, leurs dimensions, leur mode couleur et leurs empreintes ont été vérifiés.

- **Terrazzo** : grains fins et luminosité moyenne régulière ; la distribution des agrégats et quelques taches rendent le motif périodique visible de près.
- **Carrelage** : grille 5 × 5 conservée et joints alignés en répétition ; légère variation d'épaisseur du joint de bord.
- La répétition est exploitable visuellement, mais les bords n'ont pas été égalisés mathématiquement. Aucune certification « seamless » n'est donnée.
- Le terme antidérapant décrit l'intention visuelle du carrelage ; cette image ne fournit aucune caractéristique physique réelle.
- La revue dans le moteur reste à effectuer après branchement dans les scènes. Ce lot ne modifie aucun script.

Les aperçus temporaires servent uniquement à la revue ; ils ne remplacent pas les PNG d'origine.
