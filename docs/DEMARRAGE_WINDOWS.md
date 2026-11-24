# The Tower Descent — prototype 0.6

## Lancer l’intervention

1. Extraire tout le ZIP **The-Tower-Descent-v0.6-Windows-x64.zip** dans un dossier.
2. Ouvrir **TheTowerDescent.exe**. Aucune installation de Godot n’est nécessaire.
3. Passer ou regarder la signature du studio, ouvrir **Commencer l’intervention**, puis confirmer **Déployer Alpha**. La disposition proposée convient pour une première partie.

La signature de 15 secondes précède un accueil lié à votre dernier point sûr. L’approche en jeu de 28 secondes montre la ville, les deux tours encore droites et les équipes de secours en quatre plans. Les deux hélicoptères approchent et se posent ; les portes s’ouvrent pendant le déploiement des équipes, puis se referment avant la prise de contrôle. **E**, **Entrée** ou le bouton **Passer** permettent de passer la séquence. **Échap** met l’approche en pause. Le chronomètre de mission démarre après le raccord au joueur. Vous prenez ensuite le contrôle sur le toit d’Aube ; Bravo se déploie sur Hespérie.

Rejoignez la balise orange au bord du puits, appuyez sur **E**, puis descendez avec **S**. À hauteur d’une dalle, **E** vous fait quitter le rappel.

## Objectif

Retrouvez les trois personnes aux étages **30, 28 et 26**. Appuyez sur **E** à proximité pour les prendre en charge, puis revenez à la balise de l’étage et utilisez **E** pour lancer le treuil. Attendez la confirmation du toit.

Après le sauvetage d’**Ana au 30** et le départ des hélicoptères, rejoignez la **baie Est du 29**. Regardez Bravo dans Hespérie pendant **0,8 seconde**, ou appuyez sur **E** près de la balise d’observation. L’alerte, la réplique, l’effondrement et l’impact se déroulent en 25 secondes ; vous gardez le contrôle. Éloignez-vous des vitres et gardez le noyau intérieur à portée.

Après l’impact, le couloir Est du **28** est condamné : contournez-le par le noyau pour atteindre Samuel, puis ramenez-le au treuil. Les rescapés déjà arrivés au toit restent en sécurité. Une fois les trois sauvetages confirmés et la scène terminée, activez le relais du refuge **25**.

Les lueurs bleues signalent les indices ; les caisses fournissent du matériel. Dans le spa, la lampe ralentit la silhouette et une fusée la repousse pendant vingt secondes.

## Examiner les lieux

Douze objets peuvent être examinés du toit au refuge : registre médical, treuil, table du restaurant, passe de service, bagage, vitrage, dossier des archives, relais, casier, filtration, contrôle d’air et extincteur. Approchez-vous et regardez l’objet pour afficher son interaction, puis appuyez sur **E**.

La fiche présente sa fonction, le constat sur place, une consigne et une note de l’équipe. Son contenu tient compte de l’incident et des personnes déjà reçues au toit. La lecture met l’intervention et la radio en pause. Utilisez la molette ou **Page ↑ / Page ↓** pour défiler ; **Fermer et reprendre** ou **Échap** rend les commandes.

Ces observations restent facultatives. Les lire ne consomme aucun matériel et ne remplace pas le point de reprise. Terminez d’abord un portage, un treuillage ou une manœuvre de rappel avant d’ouvrir une fiche ; les consignes d’urgence gardent la priorité pendant la secousse.

## Commandes essentielles

| Action | Touche |
| --- | --- |
| Déplacement | ZQSD ou WASD |
| Regard | Souris ou flèches |
| Interaction / examiner un objet / passer l’approche | E |
| Défiler dans une fiche de terrain | Molette / Page ↑ / Page ↓ |
| Fermer une fiche et reprendre | Échap ou bouton de fermeture |
| Descendre / remonter sur corde | S / Z ou W |
| Ancrage secondaire sur corde | X |
| Lampe / fusée | F / G |
| Radio / journal | R / J |
| Courir / s’accroupir / sauter | Maj / Ctrl / Espace |
| Pause et options | Échap |

La pause fige l’effondrement. Les mouvements de caméra sont réduits par défaut ; les éclairs lumineux sont facultatifs. Les réglages sont accessibles avant la partie et conservés sur cet appareil. **Revoir l’introduction** relance la signature sans modifier la sauvegarde.

Une sauvegarde locale est créée au départ, après les treuillages, au refuge et avant/après l’incident. Si vous quittez pendant l’effondrement, la reprise revient au point sûr qui le précède. Après stabilisation, les dégâts sont conservés. **Déployer Alpha** confirme une nouvelle intervention et crée un point sûr ; **Reprendre l’intervention** poursuit le précédent. Les anciennes sauvegardes de schémas 1 et 2 valides sont migrées automatiquement vers le schéma 3. Le journal conserve les 32 dernières transmissions et reste accessible dans le bilan final. Les données ne sont pas envoyées en ligne.

## Portée de cette version

Prototype solo avec un toit et six étages jouables, des hélicoptères et personnages procéduraux, réalisé avec **Godot 4.7.2**. La campagne complète et le futur portage UE5 sont décrits dans la bible. L’export Windows a été construit et ses ressources embarquées ont réussi 28 contrôles isolés avec Godot sous Linux. L’exécutable de cette livraison n’a pas été lancé sur un PC Windows dans l’environnement de fabrication. Consultez `EXPORTS.md` pour les résultats et la méthode de vérification.

[Projet, sources et bible sur GitHub](https://github.com/darknigthmare/The-Descents/tree/feat/live-tower-collapse)

Les archives 0.1, 0.2 et 0.4 présentes dans le dépôt sont historiques. Utilisez la **0.6** pour l’arrivée animée, les modèles enrichis et les observations de terrain, en plus des menus et cinématiques.

Les licences du moteur et de ses composants sont jointes dans `GODOT_LICENSES.txt`. La notice et la licence des polices Open Sans accompagnent également cette archive.

## Réglages ajoutés en 0.6

Accueil → Options et confort, ou Échap → Options et confort pendant l’intervention. Volume 0–100 %, sensibilité ×0,25–×2,5, champ de vision 65–100° et regard vertical inversé sont appliqués immédiatement. Fermer ce panneau en partie retourne à la pause ; Reprendre rend le contrôle. Les réglages restent distincts du point sûr.

Le portage montre le harnais et les mains d’Alex. Le treuil conserve ses cinq secondes, puis l’équipe prend la personne en charge au toit. La pluie et la mer suivent la pause ; les mouvements réduits conservent une ambiance fixe.
