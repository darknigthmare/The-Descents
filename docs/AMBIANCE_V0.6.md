# Ambiance maritime — The Tower Descent v0.8

Le fichier conserve son nom historique. Depuis la 0.7, cette ambiance accompagne les plans de clôture conservés en 0.8 ; le journal, le bilan et l’épilogue ne relancent pas la simulation météo de l’intervention terminée. La caméra animée de clôture conserve sa propre horloge de présentation.

## Intention de mise en scène

L’opération Orphée commence dans une ville submergée, sous un ciel chargé, avec deux tours encore debout. La météo doit donner une profondeur à cet espace et rendre la distance sensible. Elle accompagne le menu contextualisé, l’approche des hélicoptères et les vues depuis les étages. Les informations de secours, les silhouettes de l’équipe, les balises et la ligne de rappel conservent la priorité visuelle.

La composition maritime introduite en 0.6 est conservée dans la 0.8 : plafond nuageux en deux nappes, bande de brume au niveau de l’horizon, voiles de pluie dans le lointain et deux volumes de précipitations à l’extérieur des bâtiments. Les couleurs appartiennent à la même gamme froide que Nacre et les façades mouillées. Les éclairages ambre et vert des équipements gardent ainsi leur fonction de repères.

Le ciel représente la même situation météorologique avant et après la réplique. L’effondrement modifie la tour et sa poussière, sans déclencher artificiellement un changement de saison, un lever de soleil ou une nouvelle tempête.

## Composition et paramètres réalisés

| Élément | Construction | Fonction visible |
| --- | --- | --- |
| Ciel maritime | Shader de ciel statique ; nappe basse et couche supérieure à deux échelles de bruit, trois octaves chacune | Donner du relief au plafond nuageux sans animation permanente du ciel |
| Horizon | Teinte commune `#3c5965` au brouillard et au bas du ciel ; énergie du brouillard 1,0 ; densité 0,0036 | Raccorder la mer lointaine au ciel et absorber la limite finie du plan d’eau |
| Mer | Plan de 6 400 × 6 400 m déjà présent, houle et rides existantes conservées | Préserver l’étendue maritime et son relief ; rendre désormais son animation contrôlable par la pause |
| Pluie proche | 640 traînées instanciées, rayon de base 18 à 82 m, longueur 0,78 m, vitesse 18 m/s | Lire les précipitations depuis les baies et les bords du toit |
| Pluie distante | 384 traînées instanciées, rayon 100 à 350 m, longueur 1,9 m, vitesse 22 m/s | Ajouter une seconde profondeur dans les vues extérieures |
| Voiles lointains | Huit plans de 390 × 280 m répartis à 540 m des tours | Suggérer des nappes de précipitations au-dessus de la ville et de la mer |
| Volume vertical | Base à y = −138 m, hauteur de 240 m | Couvrir les vues sur la ville, les étages jouables et l’approche aérienne |
| Budget géométrique | Deux MultiMesh, 1 024 traînées et huit plans ; aucune collision | Limiter le nombre d’objets de rendu et préserver les trajets de secours |

La bande du ciel située sous l’horizon reprend la couleur du brouillard. Elle évite de révéler un fond sombre sous la mer lorsque le plan d’eau atteint la distance de coupe de la caméra. Le raccord se contrôle sur les captures natives de l’approche et du toit ; la correspondance des paramètres, seule, ne remplace pas cette vérification visuelle.

Les voiles restent suffisamment éloignés pour ne pas traverser les pièces. Les colonnes de pluie excluent une enveloppe carrée de 29 m autour d’Aube et de l’emprise initiale d’Hespérie. Le vent incline chaque petite traînée sans déplacer sa colonne à travers les murs. Cette mise en scène ne simule pas l’accumulation d’eau, les gouttes sur la visière ni le ruissellement sur les personnages.

## Confort et continuité

Le réglage **Mouvements réduits**, activé par défaut, conserve le ciel et les voiles fixes. Il masque les traînées animées et immobilise la houle. L’ambiance reste composée ; aucun mouvement continu supplémentaire ne s’impose au joueur. La désactivation rétablit les précipitations et l’animation de la mer immédiatement.

Le réglage des flashes reste piloté par le monde existant. Ce module ne crée aucun éclair, flash blanc, stroboscope ou modification de l’intensité de la lumière principale. Le ciel ne dépend pas des changements d’éclairage de la réplique.

La mer utilisait auparavant l’horloge globale du shader. Elle reçoit maintenant une horloge explicite, comme les précipitations et les voiles. La pause, la lecture d’un objet et les autres écrans qui suspendent le monde suspendent donc aussi ces animations. Leur remise en mouvement suit la reprise du monde.

## Fonctionnement reproductible

Le module `MaritimeAtmosphere` reçoit l’horloge de présentation du monde. Il ne possède pas de boucle de traitement autonome et ne modifie pas le chronomètre de mission. Chaque échantillon remplace les paramètres précédents : avancer, reculer puis demander le même instant reconstruit le même état visuel.

Les horloges envoyées au GPU sont ramenées à des périodes bornées. Pour la pluie, 120 secondes correspondent à un nombre entier de traversées du volume pour chacune des deux vitesses. Les voiles bouclent sur leur période sinusoïdale. La mer boucle sur la période commune de ses fréquences existantes. Ces périodes limitent la perte de précision après une longue session et conservent la continuité des mouvements.

Le placement des traînées repose sur une répartition arithmétique. Il ne consomme ni le générateur aléatoire de l’étage ni celui du monde. L’ancien volume de pluie reste alloué, mais caché, afin de conserver les tirages déjà utilisés par la construction historique du niveau. Aucun nouveau champ de sauvegarde n’est nécessaire.

Le module ne crée ni corps physique, ni surface de déplacement, ni interaction. Les volumes de visibilité déclarés englobent toute la hauteur parcourue par les traînées dans le shader, pour éviter leur disparition lorsque leur position dessinée dépasse la position de leur instance de base.

## Intégration dans le projet

| Fichier | Responsabilité |
| --- | --- |
| `prototype/scripts/maritime_atmosphere.gd` | Création des couches, raccord d’environnement, distribution déterministe, échantillonnage et préférences |
| `prototype/shaders/storm_sky.gdshader` | Plafond nuageux statique et bande de brume |
| `prototype/shaders/maritime_rain.gdshader` | Chute bornée des traînées extérieures |
| `prototype/shaders/storm_curtain.gdshader` | Voiles de pluie éloignés |
| `prototype/shaders/water.gdshader` | Houle existante passée à une horloge explicite |
| `prototype/tests/test_atmosphere.gd` | Contrôles du raccord, des volumes, de la pause, des préférences et de l’absence d’effet sur le gameplay |

Le constructeur du monde installe l’atmosphère après la création de l’ancienne pluie. Le monde transmet son horloge et la préférence de mouvement à chaque mise à jour. Une modification de préférence force immédiatement un nouvel échantillon, même lorsque le jeu est en pause.

La suite vérifie notamment les colonnes hors des pièces, les volumes de visibilité, la limite d’instances, les données finies, la reconstruction après recherche temporelle, les véritables images de pause et de reprise, le maintien des collisions et des interactions, ainsi que la conservation de l’état du générateur aléatoire. Le rapport d’exécution de la livraison établit le résultat de ces contrôles.

## Lecture artistique et limites de production

Cette étape donne à la scène un ciel construit et une profondeur de précipitations. Elle reste un rendu procédural du prototype Godot. Elle n’introduit pas de capture vidéo, de texture photographique de nuages, de simulation météorologique physique ou de brouillard volumétrique. Aucun objectif de fréquence d’images n’est déclaré sans mesure sur le matériel visé.

Pour une production ultérieure, les références à développer sont la variation de taille des vagues près des structures, le ruissellement sur les surfaces exposées, les éclaboussures au contact du rotor et une direction d’éclairage peinte sur les nuages. Ces pistes n’ajoutent pas de mécanique cachée à l’intervention actuelle.

## Références techniques

- [Godot — Sky shaders](https://docs.godotengine.org/en/stable/tutorials/shaders/shader_reference/sky_shader.html) : calcul du ciel, passage de cubemap et mises à jour provoquées par les uniformes.
- [Godot — Sky](https://docs.godotengine.org/en/stable/classes/class_sky.html) : matériau de ciel et modes de calcul de la radiance.
- [Godot — MultiMesh](https://docs.godotengine.org/en/stable/classes/class_multimesh.html) : instanciation, données personnalisées et volume de visibilité.

## Contraste avec les manifestations et les profondeurs

La v0.8 conserve l’horizon maritime et les repères du monde pour que les petites anomalies des étages hauts aient un contexte lisible. Une apparition ne change pas toute la palette, n’ajoute pas un éclair obligatoire et ne fait pas disparaître la météo pour annoncer un démon. Les traces humides restent proches des matériaux ordinaires du bâtiment.

La campagne future élargit ensuite le contraste : lumière fonctionnelle des chambres d’essai, zones de contamination matérielle, puis horizons et matières réellement infernaux. L’Enfer possède une composition propre — cendre, structures de contrainte, ouvrages étrangers et enclaves Pelagos transférées — au lieu d’un simple voile rouge. Les effets restent subordonnés aux chemins, aux attaques lisibles et aux appuis de retour.
