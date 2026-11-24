# Exports du prototype 0.2

Les presets se trouvent dans `prototype/export_presets.cfg`. La version 0.2 a été reconstruite à partir de ses sources avec Godot 4.7.2. Pour reproduire les exports :

```bash
godot --headless --path prototype --export-release "Windows Desktop"
godot --headless --path prototype --export-release "Web"
```

Créer préalablement les dossiers `builds/windows` et `builds/web`. Après les exports, actualiser `dist/` puis lancer `tools/package_release.py` pour produire les archives et `releases/SHA256SUMS.txt`. Relancer ces étapes après toute modification des sources.

## Résultats

| Cible | Résultat | Vérification disponible |
| --- | --- | --- |
| Windows x64 | `builds/windows/TheTowerDescent.exe`, ressources embarquées | Export terminé avec succès ; format PE32+ x86-64 vérifié. Exécution sur Windows non testée. |
| Web | `builds/web/index.html` et fichiers associés, copiés dans `dist/` | Export sans threads terminé avec succès, distribution 0.2 actualisée. Rendu 3D navigateur non vérifié. |
| Archives | `releases/The-Tower-Descent-v0.2-Windows-x64.zip` et `releases/The-Tower-Descent-v0.2-Sources.zip` | Intégrité ZIP et contenu vérifiés ; sommes SHA256 dans `releases/SHA256SUMS.txt`. |

La version recommandée est la **0.2**, avec son approche sur deux tours intactes et son effondrement pendant la descente. Les archives 0.1 restent dans le dépôt comme historique et ne contiennent pas ces changements. Le ZIP des sources 0.2 inclut la bible `The-Tower-Descent-Bible-v0.2.docx`, sa version PDF et les huit suites de tests.

Le dossier Web doit être servi par HTTP ou HTTPS avec ses fichiers `.wasm`, `.pck` et JavaScript ; ouvrir directement le HTML en `file://` ne constitue pas une installation correcte. L'export utilise le rendu Compatibility. Les exigences WebAssembly et WebGL 2 sont décrites dans la [documentation officielle Godot](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).

## Provenance des modèles d’export

Source : [archive officielle Godot 4.7.2](https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_export_templates.tpz).

Seules les entrées `version.txt`, `web_nothreads_release.zip` et `windows_release_x86_64.exe` ont été extraites par requêtes HTTP Range avec réponses 206. Les tailles décompressées et les CRC32 ont été comparés au répertoire central du ZIP. L'archive complète de 1,28 Go n'a pas été téléchargée ; son SHA256 global n'a donc pas été vérifié.

Les modèles sont installés localement sous `~/.local/share/godot/export_templates/4.7.2.stable/`. Ils ne font pas partie des sources du jeu. Pour distribuer la version Windows, compresser l'exécutable dans un ZIP ; sa taille brute dépasse 100 Mio.
