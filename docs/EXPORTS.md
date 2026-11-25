# Exports du prototype 0.7

**Moteur fixé : Godot 4.7.2 stable officiel — rendu Compatibility.** Ce guide décrit le contrat de construction et le contenu attendu des paquets v0.7. Le statut de publication et les résultats réellement obtenus sont consignés dans [État de livraison](https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/ETAT_DE_LIVRAISON.md) ; la présence de ce guide ne valide aucun export.

## Formats attendus

| Format | Emplacement de livraison | Usage et contenu |
| --- | --- | --- |
| Windows x64 | releases/The-Tower-Descent-v0.7-Windows-x64.zip | Extraire puis lancer TheTowerDescent.exe ; instructions et notices jointes |
| Sources | releases/The-Tower-Descent-v0.7-Sources.zip | Ouvrir prototype/project.godot ; code, tests, documents complets et preuves de livraison |
| Web | dist/ | Chargeur, WebAssembly, paquet de ressources et licences à servir ensemble |
| Bible | docs/The-Tower-Descent-Bible-v0.7.docx et .pdf | Volume complet issu de quatorze sources, soumis à revue de chaque page |

Windows embarque son paquet de ressources dans l’exécutable. Le dossier Web n’établit pas à lui seul qu’un site public a été déployé. Les archives, documents et preuves v0.6 restent conservés pendant la préparation de cette version.

## Construction et vérification

Le workflow **release-v07** reçoit une demande explicite après la source figée. Le commit de demande modifie uniquement `.review/v0.7/build-request.json` et désigne son propre parent. La branche reste `feat/live-tower-collapse` ; aucune fusion de la branche principale n’est effectuée par ce workflow.

La phase **review** exécute les 24 suites obligatoires, exporte Windows et Web, puis charge les deux paquets depuis des dossiers neufs et vides sous Godot Linux. Le test externe n’est pas inclus dans les ressources du jeu. Il doit notamment retrouver `mission_dossier.gd`, `mission_dossier_panel.gd` et `epilogue_director.gd`, lire les quatre onglets et échantillonner les trois plans de clôture depuis les ressources réellement embarquées. Son compte de vérifications est calculé à l’exécution.

Les modèles d’export sont ceux de Godot 4.7.2 stable officiel. Le pipeline vérifie tailles et SHA256 contre `EXPORT_TEMPLATE_PROVENANCE.json`. Version du moteur, commandes, empreintes du runtime et sorties doivent figurer dans les rapports v0.7. Toute erreur moteur détectée fait échouer le contrôle, même si le processus retourne zéro.

La construction prépare aussi les 30 captures natives et le Word/PDF complet. Chaque capture et chaque page finale nécessitent une revue explicite de leurs fichiers exacts. La phase **release** conserve ces octets approuvés, reconstruit les exports, teste à nouveau leurs ressources et vérifie les archives. Une source ou une image modifiée ne peut pas réutiliser une approbation qui porte sur d’autres empreintes.

L’archive Sources doit contenir les trois nouveaux modules, les trois suites correspondantes, les quatorze sources de bible, les deux formats du volume et les 30 captures approuvées avec leurs preuves. Chaque membre est comparé au fichier dont il provient. Caches, fichiers temporaires et pages PNG de revue documentaire sont exclus ; les PNG natifs du jeu restent inclus.

## Portée des contrôles

Une suite source vérifie ses invariants. Le chargement d’un paquet vérifie ses ressources embarquées depuis un répertoire isolé. Les captures montrent Godot Linux avec des états préparés. La revue des pages examine les documents construits. Les résultats de ces étapes sont conservés séparément afin de ne pas confondre logique, contenu exporté, rendu et mise en page.

Ces étapes ne constituent pas une partie humaine de l’EXE sous Windows, une partie Web dans un navigateur ou une mesure de fréquence d’images. Ces essais restent séparés et doivent être identifiés lorsqu’ils sont réalisés. Aucun doublage enregistré ni mixage final n’est certifié par le simple chargement des ressources audio.

## Licences et conservation

Godot et Open Sans accompagnent les exports avec leurs notices. Les archives 0.1, 0.2, 0.4, 0.5 et 0.6 restent conservées. `SHA256SUMS.txt` couvre les archives effectivement présentes ; il est réécrit après la fabrication des nouveaux ZIP sans supprimer les anciennes entrées.

Le pipeline conserve les preuves et les fichiers de plateforme dans un artefact Actions avant publication. Il ne pousse ses sorties que si la branche pointe encore sur le commit demandé. Une évolution concurrente conserve cet artefact sans forcer l’historique.

La [procédure complète](https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/VALIDATION_V0.7.md), le [contrat des captures](https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/CAPTURES_V0.7.md) et [l’état de livraison](https://github.com/darknigthmare/The-Descents/blob/feat/live-tower-collapse/docs/ETAT_DE_LIVRAISON.md) décrivent les rapports attendus dans `docs/validation/v0.7` et le contrôle final `releases/VERIFICATION_V0.7.json`.
