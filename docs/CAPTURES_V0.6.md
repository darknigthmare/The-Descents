# Captures natives — The Tower Descent 0.6

Les vingt-deux images ci-dessous proviennent du moteur **Godot 4.7.2 officiel**, rendu **Compatibility / OpenGL 3**, à **1440 × 900**. Elles ont été produites sous Linux par Xvfb et Mesa à partir d’états préparés par la scène de capture. Il s’agit des scènes, menus, personnages procéduraux et interfaces du jeu.

## Provenance

- [Construction figée et résultats](https://github.com/darknigthmare/The-Descents/actions/runs/45496447511)
- Commit capturé : `a17aa103f5daa350e2f2c2c09dc6e1a047bc2110`.
- [Manifeste de provenance](captures/v0.6/CI_PROVENANCE.json) : moteur, méthode, source, fixture, empreintes du runtime et des vingt-deux PNG.
- [Revue visuelle terminée](validation/v0.6/VISUAL_REVIEW.json) : image examinée, empreinte exacte, méthode, observations et limites.
- [Dérivés de consultation](captures/v0.6/REVIEW_DERIVATIVES.json) : relation entre certains PNG volumineux et leurs JPEG de revue, sans redimensionnement ni recadrage.

Les PNG restent les preuves natives. Pour les lecteurs limités aux fichiers de moins de 1 Mio, la construction produit des JPEG de même taille, qualité 95, chroma 4:4:4. Cette conversion est avec perte ; les deux empreintes sont conservées et la revue indique précisément quel fichier a été vu. La génération d’un fichier ne vaut pas approbation visuelle.

## Ouverture et accueil

| Capture | État présenté |
| --- | --- |
| [01 — Accueil avant intervention](captures/v0.6/01_menu_arrivee.png) | Tours intactes, signature visuelle, commandes et contexte initial |
| [02 — Options](captures/v0.6/02_options.png) | Volume, regard, mise en scène et actions du panneau complet |
| [03 — Nouvelle intervention](captures/v0.6/03_nouvelle_intervention.png) | Briefing, disposition du niveau et confirmation du départ |
| [04 — Signature du studio](captures/v0.6/04_signature_studio.png) | Identité du studio dans le prologue de quinze secondes |
| [05 — Titre](captures/v0.6/05_titre.png) | Présentation du titre et composition de la signature |
| [06 — Approche à 3 secondes](captures/v0.6/06_approche_03.png) | Plan large maritime et horizon brumeux |
| [06 — Approche à 10 secondes](captures/v0.6/06_approche_10.png) | Deux tours, deux appareils et répartition des équipes |
| [06 — Approche à 17 secondes](captures/v0.6/06_approche_17.png) | Dépose des groupes et liaison entre Aube et Hespérie |
| [06 — Approche à 25 secondes](captures/v0.6/06_approche_25.png) | Équipe du toit et raccord vers Alex |
| [07 — Pause de l’approche](captures/v0.6/07_pause_intro.png) | Séquence suspendue, reprise et options |
| [08 — Accueil aux archives](captures/v0.6/08_menu_archives.png) | Point sûr du 28, une personne reçue et reprise contextuelle |
| [09 — Dossier après le choc](captures/v0.6/09_dossier_apres.png) | Situation, équipe et parcours mis à jour après l’incident |
| [10 — Accueil au refuge](captures/v0.6/10_menu_refuge.png) | Intervention achevée au 25, trois personnes reçues |

## Terrain, secours et confort

| Capture | État présenté |
| --- | --- |
| [11 — Registre du toit](captures/v0.6/11_inspection_toit.png) | Consultation médicale avant les sauvetages |
| [12 — Archives avant l’incident](captures/v0.6/12_inspection_archives.png) | Observation facultative et lecture du plan antérieur |
| [13 — Archives après l’incident](captures/v0.6/13_inspection_apres.png) | Constat adapté aux dégâts et au passage condamné |
| [14 — Équipe au toit](captures/v0.6/14_toit_equipe.png) | Appareil, secours, portique, civière et abri |
| [15 — Portage](captures/v0.6/15_portage.png) | Ana visible dans le support de première personne, mains, sangles et route centrale |
| [16 — Treuillage](captures/v0.6/16_treuillage.png) | Montée à 1,8 seconde, panier, câble et avancement ; annotations flottantes suspendues |
| [17 — Réception](captures/v0.6/17_reception.png) | Transfert médical 1,8 seconde après la confirmation du toit |
| [18 — Météo du toit](captures/v0.6/18_meteo_toit.png) | Nuages, brume, pluie extérieure et lecture des deux tours |
| [19 — Options depuis la pause](captures/v0.6/19_options_pause.png) | Panneau partagé ouvert pendant une intervention suspendue |

## Ce que ces images établissent

La revue couvre la disposition, la lisibilité, les éléments visibles, les raccords de l’horizon et les principales intersections dans les cadrages indiqués. Le plan du treuil a été corrigé après la première revue : les grands libellés flottants masquaient le câble ; leur couche de rendu est désormais suspendue durant la montée puis rétablie à son état précédent.

La capture du portage et les deux vues de transfert passent par les actions du jeu puis échantillonnent une horloge préparée. Les images d’arrivée montrent quatre instants, pas une vidéo complète. Les tests de continuité complètent la revue des images pour la pause, les confirmations, la reprise et l’absence de duplication.

La légère transparence du fond du panneau d’options reste visible sur certains écrans sans masquer les contrôles. Les modèles, poses, matériaux et paysages sont procéduraux ; ce lot ne valide pas des assets de production photoréalistes.

Ces captures ne constituent pas une partie humaine de l’exécutable Windows, un essai Web dans un navigateur, ni un relevé de performances. Le détail des contrôles est dans [l’état de livraison](ETAT_DE_LIVRAISON.md) et [la procédure de validation](VALIDATION_V0.6.md).
