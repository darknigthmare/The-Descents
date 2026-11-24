# Publication GitHub de la version 0.2

Les sources et les exports sont ceux du projet récupéré le 24 novembre 2026.
Le connecteur de publication limite chaque requête à 16 Mio. Le moteur Web
et les deux archives Windows dépassent cette limite de transport.

Pour conserver leurs octets sans modification, la première publication contient
temporairement des morceaux de 9 000 000 octets dans `.publication/v0.2/chunks/`.
Le manifeste `.publication/v0.2/manifest.json` consigne la taille et le SHA256 de
chaque morceau et de chaque fichier complet. Aucun téléchargement externe
n'est requis pour reconstituer ces fichiers.

Le workflow `Materialize v0.2 release binaries` reconstitue les fichiers à leurs
chemins habituels, vérifie tous les SHA256, puis ajoute les binaires complets
et retire les morceaux de la branche `feat/live-tower-collapse`. Il ne fusionne
pas la pull request et ne modifie pas `main`.

## Reconstitution locale si le workflow n'a pas terminé

Depuis la racine du dépôt, avec Python 3.9 ou supérieur :

```bash
python3 tools/materialize_published_binaries.py
```

Le moteur Web se trouve alors dans `dist/index.wasm` ; les archives Windows
0.1 et 0.2 dans `releases/`. Le script vérifie les fichiers déjà présents et
refuse de remplacer un export différent. Les documents, les archives de sources,
les fichiers audio et les captures sont publiés directement, sans reconstitution.

Cette étape confirme uniquement l'intégrité des livrables. Elle ne constitue
pas un test d'exécution Windows ni un test de rendu WebGL2. Les vérifications
et limites du prototype sont détaillées dans `ETAT_DE_LIVRAISON.md`.
