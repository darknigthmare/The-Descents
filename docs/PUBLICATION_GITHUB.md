# Publication GitHub et intégrité des distributions

## Livraison initiale 0.2

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

## Livraison 0.4

La version 0.4 utilise le même transport vérifié pour les fichiers trop volumineux
pour une requête du connecteur. Leurs chemins, tailles, SHA256 et morceaux sont
décrits dans `.publication/v0.4/manifest.json`. Les blobs inchangés des versions
précédentes sont conservés. Les sources, documents et binaires plus petits sont
publiés directement. Un morceau de transport n'est pas une archive jouable.

Le workflow `Materialize verified v0.4 release binaries` travaille sur le commit
exact qui a déclenché la publication. Il reconstitue les fichiers complets après
vérification de chaque morceau et de leur SHA256 final. Un fichier déjà présent
doit correspondre au manifeste ; le script refuse de remplacer des octets différents.
Les morceaux ne sont retirés qu'une fois tous les fichiers complets vérifiés.

Avant le commit, le workflow vérifie que `feat/live-tower-collapse` pointe encore
sur sa révision source. Si la branche a avancé, les fichiers vérifiés restent dans
l'artifact du job et aucun commit n'est poussé. Le push est ordinaire, sans force ;
un changement concurrent de la branche ne peut pas être écrasé. Les actions sont
épinglées par leur SHA complet et la seule permission déclarée est `contents: write`.
La pull request n'est pas fusionnée et `main` reste inchangée.

Pour vérifier ou terminer un checkout de cette publication :

```bash
python3 tools/materialize_published_binaries.py --manifest .publication/v0.4/manifest.json
```

L'option `--clean-pieces` retire les morceaux après vérification. Le paramètre
`--manifest` est facultatif ; sans lui, le script conserve le comportement 0.2.
Les manifests de transport concernent le dépôt GitHub, pas le ZIP des sources.

Une publication est considérée complète lorsque les binaires attendus sont
présents à leurs chemins définitifs, leurs SHA Git correspondent aux fichiers
validés localement et les morceaux temporaires ont disparu de l'arbre courant.
Le [suivi des workflows](https://github.com/darknigthmare/The-Descents/actions)
et la [PR de livraison](https://github.com/darknigthmare/The-Descents/pull/1)
permettent d'identifier le commit publié. Les sommes des ZIP sont également
consignées dans `releases/SHA256SUMS.txt`.

## Preuves distinctes

Les journaux et empreintes de `docs/validation/v0.4/` décrivent les contrôles
des sources et des ressources contenues dans les exports. Les 13 captures natives
de `docs/captures/v0.4/` ont leur propre provenance : révision rendue, workflow,
résolution et SHA256. Leur revue visuelle est enregistrée séparément dans
`docs/validation/v0.4/VISUAL_REVIEW.json`. Ni le transfert vérifié ni ces états
préparés ne constituent une partie humaine complète ou une certification Windows.
