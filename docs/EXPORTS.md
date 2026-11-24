# Exports du prototype 0.4

**Version recommandée : 0.4.0 — Godot 4.7.2 stable, rendu Compatibility.** Les exports contiennent la signature du studio, l’accueil contextuel, l’approche en quatre plans et les fonctions de communication reconstruites pour cette livraison. Les archives 0.1 et 0.2 sont conservées comme historique. La reprise 0.3 interrompue n’est pas distribuée comme une version autonome vérifiée.

## Reproduire la livraison

Les deux presets sont versionnés dans `prototype/export_presets.cfg`. Installer Godot 4.7.2 et ses modèles d’export correspondants. Le script fourni peut récupérer uniquement les trois entrées nécessaires à cette livraison :

```bash
python tools/fetch_export_templates.py --version 4.7.2-stable
mkdir -p builds/windows builds/web dist
godot4 --headless --path prototype --export-release "Windows Desktop" "$PWD/builds/windows/TheTowerDescent.exe"
godot4 --headless --path prototype --export-release Web "$PWD/builds/web/index.html"
cp builds/web/* dist/
python tools/build_bible.py
```

Le nom du binaire peut être `godot` au lieu de `godot4` selon l’installation. Le générateur de la bible produit le Word ; son rendu PDF et le contrôle visuel des pages font partie de la fabrication documentaire. Après avoir généré le PDF, actualisé les preuves de validation et figé les documents :

```bash
python tools/package_release.py
python tools/verify_release.py
```

Ces deux scripts lisent la version dans `project.godot`. Le premier fabrique les ZIP et leur manifeste SHA256. Le second vérifie leur intégrité, chaque fichier du ZIP source contre l’arbre local, la présence des livrables, l’exécutable Windows, les tailles de l’export Web et les empreintes des sources testées. Toute modification après l’empaquetage nécessite de reconstruire les archives concernées.

## Fichiers livrés et portée des contrôles

| Cible | Fichiers | Contrôle et limite |
| --- | --- | --- |
| Windows x64 | `builds/windows/TheTowerDescent.exe` ; ZIP `releases/The-Tower-Descent-v0.4-Windows-x64.zip` | Export release réussi ; exécutable PE32+ x86-64 avec paquet embarqué. Le paquet est chargé et exercé avec Godot sous Linux ; ce contrôle n’est pas une exécution de l’application sous Windows. |
| Web | `builds/web/index.html` et fichiers associés, recopiés dans `dist/` | Export release sans threads réussi. Le paquet est chargé et exercé avec Godot sous Linux. Les tailles déclarées dans le HTML sont comparées aux fichiers distribués ; le rendu WebGL dans un navigateur n’est pas certifié par cette vérification. |
| Sources | `releases/The-Tower-Descent-v0.4-Sources.zip` | Projet Godot modifiable, scripts de fabrication, quatorze suites de tests, test externe des paquets, références de l’introduction, captures natives et documentation Markdown/Word/PDF. Les caches Godot et les fichiers de travail sont exclus. |
| Bible | `docs/The-Tower-Descent-Bible-v0.4.docx` et `.pdf` | Génération reproductible depuis les chapitres Markdown ; mise en page A4 et contrôle visuel du document rendu. |

Les empreintes des ZIP se trouvent dans [`releases/SHA256SUMS.txt`](../releases/SHA256SUMS.txt). Les résultats détaillés des suites, leurs journaux et les empreintes de l’arbre testé se trouvent dans [`docs/validation/v0.4/`](validation/v0.4/). Les captures et leur protocole sont documentés dans [CAPTURES_V0.4.md](CAPTURES_V0.4.md).

Les tests sont exclus des paquets exportés par `exclude_filter="tests/*"`. `prototype/tests/test_exported_pack.gd` est donc exécuté comme un script externe depuis un répertoire vide, avec `--main-pack` pointant vers l’exécutable Windows ou le paquet Web. Cela vérifie que les ressources nécessaires proviennent bien du paquet distribué et non du projet source voisin. Le scénario utilise des fichiers de sauvegarde et de préférences réservés aux essais.

Le dossier Web doit être servi par HTTP ou HTTPS avec ses fichiers `.wasm`, `.pck` et JavaScript. Le shell affiche un lien vers la branche de travail de ce dépôt. Les exigences WebAssembly et WebGL 2 sont décrites dans la [documentation officielle Godot](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).

## Provenance des modèles d’export

Source : [archive officielle Godot 4.7.2](https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz). Le relevé exact est conservé dans [EXPORT_TEMPLATE_PROVENANCE.json](EXPORT_TEMPLATE_PROVENANCE.json).

Seules les entrées `version.txt`, `web_nothreads_release.zip` et `windows_release_x86_64.exe` ont été extraites par requêtes HTTP Range avec réponses 206. Les tailles décompressées et les CRC32 ont été comparés au répertoire central du ZIP ; les SHA256 des fichiers installés sont enregistrés dans le relevé. La récupération a transféré 48 115 904 octets sur une archive de 1 281 349 702 octets. **Le SHA256 de l’archive complète n’a pas été vérifié**, puisque celle-ci n’a pas été téléchargée intégralement.

Les modèles sont installés sous `~/.local/share/godot/export_templates/4.7.2.stable/` sur la machine de fabrication ; ils ne font pas partie du code source du jeu. L’export Windows utilise un paquet embarqué et doit être téléchargé sous forme de ZIP. Il n’est pas signé numériquement.

## Licences jointes

Les notices de Godot et de ses composants sont jointes au ZIP Windows et au dossier Web. Open Sans est accompagné de sa licence Apache 2.0 et de sa notice d’origine. Les onze sons sont synthétisés par `tools/generate_audio.py` ; aucun enregistrement vocal ou morceau commercial n’est inclus. La couronne vectorielle et le nom du studio reprennent les références de l’auteur relevées dans [REFERENCES_INTRO.md](REFERENCES_INTRO.md).
