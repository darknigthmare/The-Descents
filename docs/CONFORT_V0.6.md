# Options et confort — The Tower Descent v0.8

Le fichier conserve son nom historique et décrit les réglages conservés en 0.8. Le dossier et le bilan ajoutent leurs propres commandes de lecture ; l’épilogue reprend le choix de mouvements réduits, la coupure sonore et la pause explicite. Ces ajouts ne modifient pas le format des préférences.

## Intention

Le joueur doit pouvoir adapter son regard et son écoute avant le déploiement, puis corriger ses réglages au cours d’une intervention sans perdre son point sûr. Le menu conserve les couleurs, les polices et la hiérarchie de l’accueil cinématique : fond bleu nuit, accents or, rubriques turquoise et chiffres lisibles. Les réglages du joueur sont distincts du cadrage choisi pour les plans de cinéma.

Depuis la 0.6, le panneau propose trois curseurs et l’inversion verticale, réunit l’ensemble des réglages dans une fenêtre défilante, et ouvre cette même fenêtre depuis la pause. Les réglages sont appliqués immédiatement. Le retour ferme la fenêtre ; aucune action « Appliquer » supplémentaire n’est nécessaire.

## Réglages livrés

| Réglage | Valeur initiale | Plage / action | Effet concret |
| --- | --- | --- | --- |
| Activer le son | Oui | Oui / non | Coupe ou rétablit le bus principal, indépendamment du volume mémorisé. |
| Volume général | 100 % | 0 à 100 %, pas de 5 % | Modifie le gain du bus principal ; les rapports entre ambiance, radio, effets, musique et rotors sont conservés. |
| Sensibilité de la souris | × 1,00 | × 0,25 à × 2,50, pas de 0,05 | Multiplie la valeur de base de 0,0024 radian par pixel du contrôleur. |
| Champ de vision en jeu | 77° | 65° à 100°, pas de 1° | Change la propriété FOV de la caméra du joueur. Les plans du menu, les trois premiers plans d’arrivée et les trois plans d’épilogue gardent leur cadrage. Le dernier raccord mobile rejoint le FOV choisi avant de rendre la main ; le plan fixe du mode à mouvements réduits garde son cadrage. |
| Inverser le regard vertical | Non | Oui / non | Inverse l’axe vertical de la souris et des flèches ; l’axe horizontal et les déplacements restent identiques. |
| Réduire les mouvements de caméra | Oui | Oui / non | Conserve les plans fixes et supprime le balancement du regard ; l’ambiance maritime suit également ce choix. |
| Activer les éclairs lumineux | Non | Oui / non | Autorise l’effet lumineux facultatif de l’orage. |
| Afficher l’introduction au lancement | Oui | Oui / non | Détermine le lancement automatique de la signature et du titre à la prochaine ouverture du jeu. |

À 0 %, le volume utilise un gain fini de −80 dB. Le bouton « Activer le son » constitue la coupure audio explicite. Monter le curseur pendant que le son est désactivé ne réactive pas ce bouton.

La sensibilité de la souris ne modifie pas la vitesse des flèches. L’inversion verticale s’applique aux deux moyens de regard, pour éviter un axe inversé à la souris mais opposé au clavier. Les angles verticaux restent limités à ±1,35 radian.

## Parcours

### Depuis l’accueil

1. Ouvrir **Options**.
2. Parcourir les sections **Son**, **Regard** et **Mise en scène**.
3. Ajuster un curseur ou un bouton ; le réglage est aussitôt appliqué et enregistré.
4. Fermer avec **Retour** ou **Échap** : le focus revient à l’action principale de l’accueil.

### Pendant une intervention

1. Mettre l’intervention en pause.
2. Ouvrir **Options et confort**.
3. Ajuster le volume ou le regard sans réactiver le personnage.
4. **Retour** ou **Échap** revient à la pause. Il faut choisir **Reprendre** pour reprendre le jeu.

La fenêtre ne remet pas le chronomètre en marche, ne rejoue pas l’arrivée, ne réinitialise pas l’équipe et ne crée pas de point de sauvegarde. Le fond reste figé pendant les réglages en pause.

Pendant l’épilogue introduit en 0.7 et conservé en 0.8, Échap suspend la séquence. Les options restent accessibles depuis cette pause et leur fermeture y revient ; Reprendre rend la main au réalisateur. Le passage de séquence est disponible hors pause. Le journal se parcourt au clavier avec Tab, les flèches sur ses quatre onglets et Page ↑ / Page ↓ dans son lecteur ; fermer le journal final revient au bilan sans réactiver le personnage.

### Commandes et valeurs par défaut

Le bouton **Commandes** ouvre l’aide au-dessus des options. Après fermeture de l’aide, le joueur retrouve ses réglages.

Le bouton **Rétablir les valeurs par défaut** restaure les huit valeurs du tableau, les applique immédiatement et les enregistre. Il ne réinitialise ni la mission, ni les observations, ni les ressources. Le choix initial favorise le confort : mouvements réduits activés, éclairs désactivés, inversion désactivée.

## Lisibilité et navigation

La fenêtre reste dans le cadre logique de 1440 × 900. Le contenu long défile dans une zone de hauteur fixe ; les actions de retour et de rétablissement restent accessibles au bas du panneau. Le redimensionnement conserve le mode d’affichage du projet.

- **Tab / Maj + Tab** : parcourir les commandes.
- **Flèche gauche / droite** sur un curseur : diminuer / augmenter.
- **Molette** dans la zone des réglages : faire défiler le panneau.
- **Échap** : revenir au niveau précédent.
- La zone défilante suit le contrôle qui reçoit le focus.
- Le curseur ne capte pas la molette pour changer une valeur accidentellement pendant le défilement.
- Chaque valeur apparaît en chiffres, avec son unité : pourcentage, multiplicateur ou degrés.
- Les sous-titres sont conservés, y compris lorsque le son est désactivé.

Le jeu ne fournit pas encore un remappage complet des touches, un menu de résolution, des profils de manette, un mélangeur séparé musique/voix/effets ni un réglage d’échelle des sous-titres. Ces fonctionnalités ne sont pas simulées par des boutons inactifs.

## Données et compatibilité

Les préférences restent dans `user://preferences.cfg`, section `comfort`. Elles ne font pas partie du fichier de progression. Le format de sauvegarde de mission reste inchangé.

Les quatre clés historiques sont conservées : `audio`, `reduced_motion`, `flashes`, `startup_intro`. Les nouvelles clés sont `master_volume`, `mouse_sensitivity`, `field_of_view` et `invert_y`.

Le lecteur utilise une valeur par défaut indépendante pour chaque champ absent. Un fichier écrit par la v0.5 conserve donc ses quatre choix et reçoit les quatre nouvelles valeurs initiales. Lire ce fichier ne le réécrit pas. Un lecteur ne transforme pas la chaîne `"true"` en booléen, ni la chaîne `"90"` en nombre.

Les valeurs numériques finies d’un fichier modifié à la main sont ramenées aux bornes supportées. Les nombres non finis et les types incorrects retrouvent la valeur initiale de leur champ. Les clés inconnues sont ignorées. Les dictionnaires fournis par l’appelant ne sont pas modifiés.

Le chemin d’écriture valide les valeurs avant toute ouverture du fichier temporaire. Les valeurs hors plage, non finies ou de type incorrect sont refusées. Les anciens appels fournissant les quatre booléens obligatoires restent acceptés ; les nouveaux champs absents y reçoivent leurs valeurs initiales. Une écriture réussie passe par un fichier temporaire puis un remplacement, comme auparavant. Une erreur d’écriture conserve le dernier fichier valide et le jeu signale que seuls les réglages de la session ont été appliqués.

## Contrat d’intégration

`DescentPreferences.normalize(settings)` produit un dictionnaire complet et sûr. `valid_value(key, value)` vérifie une valeur avant toute modification en direct.

`DescentPlayer.apply_comfort(settings)` applique la sensibilité, le champ de vision, l’inversion et les mouvements réduits. Il accepte un appel avant la création de la caméra ; la caméra reçoit alors le bon FOV dès sa construction. Après reconstruction du monde ou chargement, le même contrat est réappliqué au nouveau personnage.

Le signal de l’interface reste `setting_changed` ; sa valeur accepte maintenant le type `Variant`, car les trois curseurs émettent des nombres et les cinq boutons émettent des booléens. Le contrôleur de mission valide la valeur, l’applique au joueur, au bus audio et à l’ambiance, synchronise les commandes, puis enregistre.

`open_settings_from_pause()` présente la fenêtre autonome. `settings_closed` rend la main au panneau de pause. Une fermeture silencieuse lors d’un changement d’écran évite de rouvrir ce panneau après reprise du jeu.

## Vérification prévue par le code

La suite `prototype/tests/test_comfort.gd` exerce les préférences et les véritables signaux de l’interface. Elle vérifie notamment :

- la lecture d’un fichier historique sans modification de ses octets ;
- les bornes, types incorrects, nombres non finis et écritures refusées ;
- l’application du regard avant et après construction du personnage ;
- la transformation du regard de la souris, avec et sans inversion verticale, et le blocage du regard lorsque le personnage est inactif ;
- le volume et la coupure sonore indépendante ;
- la persistance de chaque curseur et du bouton d’inversion ;
- le maintien du cadrage des trois plans d’approche et le raccord final mobile au champ de vision choisi ;
- la réapplication après création d’une nouvelle intervention ;
- l’accès depuis la pause, le retour par Échap et la reprise explicite ;
- la restauration complète des valeurs initiales sans modification du point sûr.

Les suites existantes de préférences et d’intégration cinématique conservent leurs assertions ; leurs dictionnaires attendus intègrent les nouveaux champs. Les résultats effectivement obtenus et les captures sont consignés dans les rapports de validation de la livraison. Une vérification logique ne démontre pas à elle seule la lisibilité du rendu ni le ressenti de la souris sur Windows.

## Manifestations de la 0.8

Les silhouettes discrètes ne secouent pas la caméra pour forcer le regard. Elles ne retirent ni contrôle, ni santé, ni matériel et ne sont pas nécessaires à la réussite des secours. Une pause ou une lecture ne fait pas avancer leur horloge active ; les silhouettes peuvent être masquées par la fusée pendant sa durée. Les réglages de mouvements réduits et de son demeurent indépendants du scénario.

La vérité de la campagne ne varie pas selon le confort choisi : les expériences et la traversée infernale restent réelles. Les scènes futures doivent conserver leurs preuves par plusieurs supports, avec lecture des gestes hostiles et des chemins sans flash ni volume extrême. Les interfaces de sauvegarde et les refuges certifiés restent fiables.
