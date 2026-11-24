> **Archive de l’interruption.** La continuation a ensuite été reconstruite et intégrée à la version 0.4, avec une nouvelle validation. Ce document décrit l’état historique avant cette reprise ; les octets locaux v0.3 d’origine n’ont pas été récupérés. Voir [l’état actuel](ETAT_DE_LIVRAISON.md).

# Point de reprise — continuation v0.3 interrompue

**24 novembre 2026.** La version disponible dans cette branche reste la **v0.2**. Ce document conserve l'état exact du travail v0.3 effectué localement avant que l'environnement soit déclaré indisponible. Les sources et exports v0.3 n'ont pas été transférés dans le dépôt ; ce point de reprise ne constitue pas une livraison v0.3.

## Livraison disponible

La v0.2 complète est publiée au commit `1357eb2ee8bf59373721fa78c7b6ce6dd751e90c`, dans la [PR #1](https://github.com/darknigthmare/The-Descents/pull/1), ouverte, en brouillon et non fusionnée.

Les 101 fichiers récupérés ont été vérifiés par leurs SHA Git. Le [workflow de publication des binaires](https://github.com/darknigthmare/The-Descents/actions/runs/45447123361) a terminé avec succès et retiré ses morceaux temporaires.

- [Windows x64 v0.2](https://github.com/darknigthmare/The-Descents/raw/1357eb2ee8bf59373721fa78c7b6ce6dd751e90c/releases/The-Tower-Descent-v0.2-Windows-x64.zip)
- [Sources v0.2](https://github.com/darknigthmare/The-Descents/raw/1357eb2ee8bf59373721fa78c7b6ce6dd751e90c/releases/The-Tower-Descent-v0.2-Sources.zip)
- [Bible PDF v0.2, 65 pages](https://github.com/darknigthmare/The-Descents/blob/1357eb2ee8bf59373721fa78c7b6ce6dd751e90c/docs/The-Tower-Descent-Bible-v0.2.pdf)
- [Bible Word v0.2](https://github.com/darknigthmare/The-Descents/raw/1357eb2ee8bf59373721fa78c7b6ce6dd751e90c/docs/The-Tower-Descent-Bible-v0.2.docx)

## Direction conservée

Une île de luxe dévastée par typhon, séisme et tsunami. Les tours Aube et Hespérie sont debout à l'arrivée, avec deux hélicoptères et des équipes de secours sur leurs toits. Pendant la descente dans Aube, le joueur assiste à une réplique et à l'effondrement partiel d'Hespérie contre Aube, sans perdre le contrôle.

Le prototype est réalisé sous Godot 4.7.2 : toit et étages 30 à 25, trois personnes à sauver. La campagne complète et son portage UE5 sont décrits dans la bible, mais ne sont pas implémentés dans cette tranche.

## Travail v0.3 réalisé localement

### Équipes et rescapés

- Les trois silhouettes Bravo du toit et les deux de la galerie se tournent et se replient pendant l'alerte, la secousse et la chute, puis disparaissent à couvert. Ces poses préparées ne constituent pas une IA de navigation et ne prouvent pas leur mort.
- Les sauvetages confirmés font apparaître Ana, Samuel et Nora au poste médical du toit : civière ou couverture, nom et statut à l'abri.
- L'API `world.set_rescued_people(rescued)` reconstruit cet état au chargement. Elle ignore doublons et identifiants inconnus et ne change pas les collisions.

### Radio et journal

- Nouveau `radio_director.gd` : affichage séquentiel, maximum six messages en attente et historique de 32 transmissions.
- Les consignes prioritaires interrompent les messages ordinaires ; ceux déjà reçus restent dans le journal.
- Les messages ordinaires reçus pendant l'incident sont archivés sans masquer les alertes.
- Après le sauvetage de Samuel, un ancien message de Bravo peut revenir au 27 après six secondes de silence. Varga peut ensuite proposer une vérification après deux secondes de silence, aux emplacements sûrs prévus.
- Ces événements facultatifs ne se déclenchent pas pendant la pause, l'arrivée, le portage, le treuillage ou le rappel. Ils sont enregistrés pour ne pas se répéter après chargement.
- Le journal affiche les rescapés nommés, l'état structurel, les indices et les transmissions horodatées. Il reste consultable depuis le bilan final.

### Sauvegardes et corrections validées

- Schéma JSON 3 : ajout des transmissions et événements radio, migration stricte en lecture des schémas 1 et 2, écriture atomique conservant le dernier fichier valide en cas d'erreur.
- Correction d'une incompatibilité de type numérique lors de la lecture de la version JSON des anciens fichiers.
- Correction de l'écran de fin qui masquait le journal.
- Correction du calcul du silence radio lors d'une frame longue.
- Les appels opérationnels de transport et de fin de sauvetage ont priorité sur une ancienne file de sous-titres.

## Résultats effectivement observés

Les 11 suites v0.3 ont réussi, sans erreur Godot dans les journaux finaux :

| Suite | Contrôles |
| --- | ---: |
| Génération | 820 |
| Sauvegarde | 199 |
| Mission | 83 |
| Trajets physiques | 205 |
| Effondrement | 27 |
| Intégration de l'incident | 63 |
| Trajets de l'incident | 130 |
| Effets après impact | 17 |
| Réactions de l'équipe | 27 |
| Radio | 28 |
| Intégration radio | 53 |
| **Total** | **1 652** |

Les deux suites physiques comprennent 231 segments réellement parcourus avec les collisions. Les suites d'intégration utilisent aussi des placements directs pour isoler les règles ; elles ne représentent pas une partie humaine complète.

Les exports Windows et Web v0.3 ont été reconstruits. Le premier export Web a été interrompu ; une nouvelle construction a réussi et a remplacé l'ancien paquet. Chaque export final a passé **10 contrôles supplémentaires** portant sur ses ressources réellement empaquetées : version 0.3.0, démarrage de mission, radio et sauvegarde/chargement de schéma 3. Ces 20 contrôles ne sont pas inclus dans les 1 652 ci-dessus.

Ces essais utilisent Godot sous Linux. **Aucun lancement sous Windows, rendu WebGL dans un navigateur ou contrôle visuel natif de la v0.3 n'a été confirmé.**

Les résultats et empreintes de fichiers lus avant la panne sont conservés dans [VALIDATION_AVANT_INTERRUPTION.json](reprise-v0.3/VALIDATION_AVANT_INTERRUPTION.json). Les journaux complets et les fichiers correspondant à ces empreintes restent à récupérer depuis l'environnement ; ils ne sont pas inclus dans ce point de reprise.

## État du document

Les six sources Markdown et le générateur Word ont été actualisés. Le Word v0.3 a été écrit, avec 33 747 mots source, 828 paragraphes et 31 tableaux.

Le dernier rendu entièrement terminé comportait 72 pages. La revue a trouvé deux lignes isolées à la fin de l'annexe architecture ; le texte a été condensé et un nouveau rendu a été lancé. **Sa fin d'exécution et son nombre de pages n'ont pas pu être vérifiés.** Le total attendu de 71 pages reste à confirmer.

Sur le rendu de 72 pages :

- Pages 1–8, 21–60, 62, 71–72 : inspectées visuellement.
- Pages 9–20 et 63–70 : revue restante.
- Page 61 : défaut identifié et source corrigée ; correction à vérifier dans le dernier rendu.

Le PDF final n'a pas été copié dans `docs/`. Les archives v0.3 n'ont pas été produites. Le Word/PDF ne doivent pas être présentés comme une livraison v0.3 validée.

## Chemins de reprise, si l'environnement redevient accessible

Ces chemins ont été observés avant la panne ; leur disponibilité actuelle n'est pas garantie.

| Élément | Chemin |
| --- | --- |
| Copie de travail v0.3 | `/tmp/tower_descent_resume_20261124` |
| Original récupéré v0.2 | `/tmp/tower_descent_20261124` |
| Validation complète v0.3 | `/tmp/tower_descent_qa_resume/FINAL_VERIFIED.json` |
| Preuves préparées pour le dépôt | `/tmp/tower_descent_resume_20261124/docs/validation/v0.3/` |
| Dernier rendu terminé, 72 pages | `/tmp/tower-descent-v03-doc-qa-delivery` |
| Rendu final lancé, résultat non vérifié | `/tmp/tower-descent-v03-doc-qa-release` |
| État et recette de publication v0.2 | `/tmp/tower_descent_publication_v02/` |

## Travail restant pour livrer la v0.3

1. Récupérer les fichiers locaux et comparer les scripts et exports aux SHA256 conservés. Ne pas assimiler une reconstruction de mémoire aux fichiers déjà testés.
2. Terminer le rendu et la revue du Word, vérifier les pages modifiées et copier le PDF final dans `docs/The-Tower-Descent-Bible-v0.3.pdf`. Les corps 1–59 devraient rester identiques au rendu précédent ; comparer avant de reporter les validations. En cas de total de 71 pages, les anciennes pages 62–72 deviennent 61–71.
3. Actualiser `docs/ETAT_DE_LIVRAISON.md` et `docs/EXPORTS.md`, qui décrivent encore la v0.2. Le README et le guide Windows ont déjà été modifiés localement pour la v0.3.
4. Renommer les journaux de `docs/validation/v0.3/` de `.log` en `.txt` et corriger les liens JSON, ou adapter explicitement leur inclusion : le conditionnement actuel exclut les fichiers `.log`.
5. Exécuter `python3 tools/package_release.py`, puis `python3 tools/verify_release.py`. Ce dernier script vérifie les ZIP et SHA256, l'égalité de chaque membre de l'archive des sources avec les fichiers locaux, l'exécutable Windows et la correspondance entre l'export Web et `dist/`.
6. Vérifier `git diff --check`, publier les changements dans la même PR, et comparer l'arbre distant aux fichiers figés. Le gros ZIP Windows peut utiliser la recette de transport vérifiée de la v0.2 ; le wasm inchangé n'a pas besoin d'être retransféré.
7. Conserver les archives v0.1/v0.2. Ne pas fusionner la PR sans instruction de fusion.

## Limites connues à conserver dans le rapport

La tranche reste limitée à six étages, avec figures géométriques, rappel guidé, absence d'assets et d'animations définitifs, doublage et manette non configurés. L'accroupissement ne réduit pas la capsule. La recherche d'interaction utilise une proximité horizontale et ne vérifie pas encore systématiquement la ligne de vue. La campagne de trente étages, Alma, l'intérieur d'Hespérie, les souterrains et les fins restent des éléments de conception.
