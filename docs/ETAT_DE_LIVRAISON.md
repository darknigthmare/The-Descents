# État de livraison — version 0.7

**25 novembre 2026 — candidat 0.7.0 en préparation.**

La 0.7 poursuit la tranche avec un dossier de mission à quatre onglets, un bilan issu des faits réels et un épilogue en jeu de quinze secondes. Le périmètre jouable reste le toit d’Aube et les étages 30–25. La clôture exige les trois réceptions confirmées, l’incident stabilisé et l’activation du relais ; elle n’ouvre aucun étage supplémentaire.

## Statut de la 0.7

Les résultats v0.7 et leurs liens d’exécution restent à compléter après les tests, les exports et la revue. Les nombres ci-dessous décrivent **le contrat à satisfaire**, et non des résultats déjà obtenus. Les preuves v0.6 conservées plus bas ne valent pas validation de ce nouveau candidat.

| Élément | Contrat v0.7 | État à renseigner |
| --- | --- | --- |
| Suites sources | 24 suites obligatoires, dont dossier, épilogue et intégration de clôture ; journaux sans erreur moteur | Résultats de `validation/v0.7/VERIFICATION.json` attendus |
| Exports Windows et Web | Deux constructions à partir du runtime testé et gelé | Rapport `validation/v0.7/EXPORTS.json` attendu |
| Ressources embarquées | Deux packs montés dans des dossiers vides, avec dossier, panel et réalisateur de clôture présents | Rapport `validation/v0.7/EXPORTED_PACK_VERIFICATION.json` attendu |
| Rendu natif | 30 captures exactes, 1440 × 900, incluant quatre onglets, trois plans de clôture et bilan | Provenance `captures/v0.7/CI_PROVENANCE.json` attendue |
| Revue du jeu | Chaque image finale examinée et reliée à son SHA256 | Revue `validation/v0.7/VISUAL_REVIEW.json` attendue |
| Bible complète | 14 sources intégrales, Word et PDF, chaque page rendue ; nombre de pages calculé après construction | Rapport `validation/v0.7/DOCUMENT_BUILD.json` attendu |
| Revue documentaire | Chaque page finale examinée ; mêmes sources, Word, PDF et PNG que la construction | Revue `validation/v0.7/DOCUMENT_REVIEW.json` attendue |
| Archives | ZIP Windows et Sources, 30 captures approuvées dans Sources, contrôle d’intégrité et de provenance | Rapport `../releases/VERIFICATION_V0.7.json` attendu |

La [procédure v0.7](VALIDATION_V0.7.md) conserve deux phases : **review** construit les preuves ; **release** exige les revues correspondantes avant de reconstruire et vérifier les exports et archives. Le workflow ne produit pas d’approbation visuelle automatique. La demande de chaque phase doit être le seul fichier d’un commit distinct, après le code et les documents concernés.

## Comportements ajoutés au candidat

| Domaine | Contrat de la 0.7 |
| --- | --- |
| Dossier | Situation, Rescapés, Indices et Transmissions ; projection des ressources, de la structure et du point sûr |
| Vérité des secours | Une personne au harnais ou au treuil reste distincte d’une réception confirmée |
| Preuves | Aucun texte d’indice non collecté divulgué ; ordre de réception conservé pour l’historique radio |
| Épilogue | Trois plans de cinq secondes dans le monde réel, passables et suspendus par Échap |
| Bilan | Noms, durée, preuves et ressources de la mission ; retour au dossier, relecture et accueil |
| Persistance | Checkpoint achevé écrit avec succès avant la présentation ; erreur réessayable au relais, schéma 3 conservé |
| Reprise | Chargement d’une mission terminée directement au bilan ; aucune relecture automatique |
| Relecture | Aucun nouveau sauvetage, dialogue archivé, temps consommé ou fichier réécrit |
| Documentation | Quatorzième source intégrée à la bible ; anciennes annexes de sauvetage, ambiance et confort conservées |

L’[annexe de dossier et d’épilogue](DOSSIER_ET_EPILOGUE_V0.7.md) et le [contrat des captures](CAPTURES_V0.7.md) détaillent les états à examiner. La compilation et les tests logiques ne suffisent pas à valider la composition des plans, la lisibilité du journal ou le rendu des pages.

## Référence validée conservée de la v0.6

La livraison précédente, datée du 24 novembre 2026, a établi le portage visible, le harnais de treuil, la réception accompagnée, l’ambiance maritime et les réglages de confort. Ses résultats et archives ci-dessous restent attribués à cette version historique.

| Élément | Résultat | Preuve |
| --- | --- | --- |
| Suites sources | 21 suites, 4 500 contrôles réussis | [VERIFICATION.json](validation/v0.6/VERIFICATION.json) |
| Exports Windows et Web | Deux constructions sans erreur moteur détectée | [EXPORTS.json](validation/v0.6/EXPORTS.json) |
| Ressources embarquées | 30 contrôles Windows et 30 contrôles Web, chargés dans des dossiers isolés | [EXPORTED_PACK_VERIFICATION.json](validation/v0.6/EXPORTED_PACK_VERIFICATION.json) |
| Rendu natif | 22 captures 1440 × 900 ; sortie du moteur sans erreur | [Provenance](captures/v0.6/CI_PROVENANCE.json) |
| Revue des captures | 22 images couvertes avec leurs empreintes exactes | [VISUAL_REVIEW.json](validation/v0.6/VISUAL_REVIEW.json) |
| Bible | 13 sources, 67 188 mots sources, 139 pages Word/PDF | [DOCUMENT_BUILD.json](validation/v0.6/DOCUMENT_BUILD.json) |
| Revue documentaire | Chaque page finale couverte par son PNG rendu | [DOCUMENT_REVIEW.json](validation/v0.6/DOCUMENT_REVIEW.json) |
| Archives de livraison | Contrôle obligatoire des ZIP, sources, empreintes, licences et exports | [Rapport final](../releases/VERIFICATION_V0.6.json) |

La [construction de revue](https://github.com/darknigthmare/The-Descents/actions/runs/45496447511) a testé le commit `a17aa103f5daa350e2f2c2c09dc6e1a047bc2110`. Les empreintes du runtime relient les suites, les ressources exportées et les captures. La phase de livraison conserve les documents et les images approuvés, reconstruit les deux exports, teste à nouveau leurs ressources et conditionne la publication au résultat PASS du rapport final des archives.

Les captures sont inspectées visuellement. Les pages identiques à une revue antérieure conservent leur approbation seulement si leur SHA256 complet est identique ; les pages modifiées sont réaffichées. Les fichiers de revue précisent les révisions et le support effectivement examiné. Les deux documents finaux restent reliés à leurs treize sources par empreintes.

## Réalisations de la 0.6

| Domaine | Comportement livré |
| --- | --- |
| Portage | Personne unique dans un support visible, mains, manches, sangles, boucle et poignée ; axe de déplacement dégagé |
| Treuil | Verrouillage, montée et dépose en cinq secondes ; panier, câble calculé, opérateur et avancement affiché |
| Lisibilité du sauvetage | Consignes renouvelées à l’attache et à la réception ; annotations flottantes suspendues pendant la montée puis restaurées |
| Réception | Accompagnement cosmétique de 4,2 secondes vers les emplacements médicaux ; retour des équipiers à leur poste |
| Continuité | Pause figée ; confirmation unique ; rechargement à la place médicale finale ; aucune animation transitoire dans la sauvegarde |
| Atmosphère | Ciel à plusieurs couches, horizon brumeux raccordé à la mer, pluie extérieure, huit voiles distants |
| Confort | Volume, sensibilité, champ de vision, inversion verticale et panneau complet depuis la pause |
| Navigation | Focus des options, curseurs, défilement et fermeture prioritaire de l’aide ; son réactivé sans interrompre la pause |
| Documentation | Trois nouvelles annexes détaillées et mise à jour du périmètre dans les dix dossiers conservés |

Le placement du panier et de la civière tient compte des obstacles réels du toit : portique, balise, pieds de l’abri et bouteilles. La représentation est cosmétique ; les identifiants de mission, les ressources et la sauvegarde restent gérés par la logique existante.

Le problème de libellé géant devant le treuil a été repéré sur le rendu natif puis corrigé. La construction du ciel réutilise la ressource existante pour éviter des textures laissées à la fermeture du rendu Compatibility. Les erreurs moteur restent bloquantes, même lorsque le processus se termine avec le code zéro.

## Ouverture et intervention conservées

La signature du studio dure quinze secondes et l’arrivée vingt-huit secondes en quatre plans. Deux hélicoptères se posent, ouvrent leurs portes et déposent les six membres de toit. L’accueil correspond au dernier point sûr : approche, toit ou étage atteint, avant ou après l’incident, jusqu’au refuge final.

Le parcours conserve Ana Rios, Samuel Breton et Nora Haddad, trois preuves, deux réserves, douze observations facultatives, rappel guidé, ancrages, radio, journal, lampe, fusées et refuge. Après le premier sauvetage et le départ des appareils, l’observation à la baie Est du 29 déclenche l’effondrement. Le détour après l’impact et le repli de Bravo restent liés à l’état stable de l’incident. La sauvegarde reste au schéma 3.

## Livrables validés de la v0.6 conservés

- [Windows x64 v0.6](../releases/The-Tower-Descent-v0.6-Windows-x64.zip) et [démarrage](DEMARRAGE_WINDOWS.md).
- [Sources v0.6](../releases/The-Tower-Descent-v0.6-Sources.zip).
- [Bible Word](The-Tower-Descent-Bible-v0.6.docx) et [Bible PDF](The-Tower-Descent-Bible-v0.6.pdf).
- [Galerie des 22 captures](CAPTURES_V0.6.md).
- [Exports, provenance et portée](EXPORTS.md).
- [Empreintes des archives](../releases/SHA256SUMS.txt).

Les anciennes archives restent conservées. La PR reste ouverte en brouillon sur `feat/live-tower-collapse` ; cette livraison ne fusionne pas la branche principale.

## Limites des essais et de la production

Dans la livraison v0.6 citée ici, le jeu et les captures utilisent **Godot 4.7.2 officiel, Compatibility**, sous Linux pour la construction. Les ressources de ses Windows x64 et Web ont été chargées séparément sous Godot Linux. Ce contrôle ne constitue pas une exécution de l’EXE sur un PC Windows ni une partie Web dans un navigateur. Aucun relevé de performances sur machines cibles n’est revendiqué.

La revue documentaire v0.6 porte sur son PDF issu du Word et ses pages rendues par LibreOffice/Poppler. La police demandée Arial est résolue en Liberation Sans sur ce runner. Le rendu peut varier dans une autre installation Word. La mise en page des 139 pages de cette livraison historique a été examinée ; cela ne préjuge pas de la pagination ni de la revue v0.7.

Figures, hélicoptères, sangles, poses et décors sont procéduraux. La réception suit des trajectoires préparées, sans navigation autonome, contacts physiques des mains ou animation faciale. Le câble est calculé ; les cinq secondes de treuil compressent le temps de secours. Les sous-titres sont présents ; les voix ne sont pas doublées. Le remappage complet reste à produire. Le fond des options conserve une transparence légère sans gêner les contrôles.

La campagne complète, Alma, la piscine, l’intérieur d’Hespérie, les cavernes, le bunker, le seuil 666, les fins, Mountain Hole et UE5 gardent leur statut de conception. Ces cibles sont décrites dans la bible et ne sont pas annoncées comme des niveaux jouables livrés.

Les contrats détaillés figurent dans [Sauvetage](SAUVETAGE_V0.6.md), [Ambiance](AMBIANCE_V0.6.md), [Confort](CONFORT_V0.6.md), [Gameplay](GAMEPLAY_DETAILLE.md), [Scènes](SCENES_CINEMATIQUES.md) et [Dossier et épilogue](DOSSIER_ET_EPILOGUE_V0.7.md). Les noms historiques des trois annexes v0.6 sont conservés ; leurs contrats restent applicables à la tranche actuelle.
