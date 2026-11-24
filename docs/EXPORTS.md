# Exports du prototype 0.6

**Moteur : Godot 4.7.2 stable officiel — rendu Compatibility.**

## Formats de livraison

| Format | Emplacement | Usage |
| --- | --- | --- |
| Windows x64 | releases/The-Tower-Descent-v0.6-Windows-x64.zip | Extraire puis lancer TheTowerDescent.exe |
| Sources | releases/The-Tower-Descent-v0.6-Sources.zip | Ouvrir prototype/project.godot |
| Web | dist/ | Servir les fichiers avec un hébergement WebAssembly |
| Bible | docs/The-Tower-Descent-Bible-v0.6.docx et .pdf | Document complet, treize sources |

Windows embarque son paquet de ressources. Le ZIP contient instructions et notices. Le dossier Web comprend chargeur, WebAssembly, paquet et licences. Sa présence ne signifie pas qu’un site public a été déployé.

## Construction et vérification

Le workflow release-v06 reçoit une demande explicite après la source figée. Il vérifie scripts et mission, exporte Windows et Web, puis charge les deux paquets depuis des dossiers isolés sous Godot Linux. Le test externe n’est pas inclus dans les ressources du jeu.

Les modèles d’export sont ceux de Godot 4.7.2 stable officiel. Tailles et SHA256 sont vérifiés contre EXPORT_TEMPLATE_PROVENANCE.json. Version du moteur, commandes, empreintes du runtime et sorties figurent dans les rapports v0.6.

La phase finale conserve captures et documents approuvés. Elle exige les revues liées à leurs octets exacts, reconstruit les exports et vérifie les archives. Les sources du ZIP doivent correspondre aux fichiers de livraison. Caches, fichiers temporaires et pages PNG de revue sont exclus du ZIP Sources.

## Portée des contrôles

Une suite source valide ses invariants. Le chargement d’un paquet vérifie les ressources embarquées. Les captures montrent Godot Linux avec des états préparés. La revue des pages vérifie les documents construits.

Ces étapes ne constituent pas une partie humaine de l’EXE sous Windows, une partie Web dans un navigateur ou une mesure de fréquence d’images. Ces essais restent séparés et doivent être identifiés lorsqu’ils sont réalisés.

## Licences et archives conservées

Godot et Open Sans accompagnent les exports avec leurs notices. Les archives 0.1, 0.2, 0.4 et 0.5 restent conservées. SHA256SUMS.txt couvre les archives présentes.

La provenance et les résultats exécutés figurent dans ETAT_DE_LIVRAISON.md, docs/validation/v0.6 et releases/VERIFICATION_V0.6.json.
