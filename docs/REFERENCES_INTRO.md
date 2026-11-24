# Références vérifiées pour l’introduction et l’accueil

**Audit du 24 novembre 2026.** Les quatre dépôts ci-dessous ont été lus via leurs fichiers source à des commits fixes. L’objectif est de reprendre l’identité déjà employée par Darknigthmare et de construire une ouverture propre à The Tower Descent.

## Identité commune constatée

La formulation **Darknigthmare Kingdoms Games Productions** apparaît exactement dans Deadwall, Dead Feed et Jurassic Arsenal. Les crédits d’auteur utilisent **Darknigthmare**, précédé de « un jeu de » ou de « by » selon le jeu. L’orthographe du nom propre est conservée.

Les dépôts ne contiennent pas tous un même emblème. Jurassic Arsenal utilise une couronne au trait doré ; Deadwall emploie un écu avec lune, enceinte, fissure et couronne ; Port de Pluie a un château-couronne au-dessus d’une vague ; Dead Feed présente des cartons typographiques. Aucun logo raster commun ni identité graphique unique imposée n’a été retrouvé. Les dessins ci-dessous sont des références existantes dans ces jeux, sans revendication d’un logo officiel universel.

## Fichiers et séquences examinés

| Jeu / état de la référence | Sources fixes | Rythme et comportement observés |
| --- | --- | --- |
| **Jurassic Arsenal**, PR 12 fusionnée | [src/intro.js](https://github.com/darknigthmare/jurassic-arsenal/blob/ca8312a852dfb6f939d209eb72b6def6c6c14b70/src/intro.js), [index.html](https://github.com/darknigthmare/jurassic-arsenal/blob/ca8312a852dfb6f939d209eb72b6def6c6c14b70/index.html), [src/style.css](https://github.com/darknigthmare/jurassic-arsenal/blob/ca8312a852dfb6f939d209eb72b6def6c6c14b70/src/style.css) | Studio 3,4 s, auteur 2,6 s, puis titre en attente d’une action. Durées multipliées par 0,6 avec mouvements réduits. Couronne tracée en 1,6 s, reflet sur le nom pendant 2,4 s après un délai de 0,6 s, bandes cinéma de 9 vh, grain et vignettage. |
| **Deadwall — The Last Enclosure**, PR 44 ouverte | [src/intro-studio218.js](https://github.com/darknigthmare/deadwall-last-enclosure/blob/13cff0506b2a7138cd9a6815f46b6a1483992cd7/src/intro-studio218.js) | Studio 0–3,6 s ; « présente » 3,6–5,6 s ; auteur 5,6–8 s ; scène nocturne à 8 s ; fissure du titre à 11 s ; révélation à 11,6 s ; écran d’accueil à 15 s. Passer conduit au titre ; une autre action ouvre le menu. |
| **Dead Feed**, PR 4 ouverte | [intro.js](https://github.com/darknigthmare/dead-feed/blob/d69b62cb7ef67588e53f2812140d15f14934ced0/intro.js), [spécification 005](https://github.com/darknigthmare/dead-feed/blob/d69b62cb7ef67588e53f2812140d15f14934ced0/specs/005-intro-accueil/spec.md) | Studio et « présente » 2,6 s ; auteur 2,4 s ; titre 3 s : 8 s au total, ou 4,3 s avec mouvements réduits. Puis « Appuyez pour commencer ». Cartons typographiques, badge LIVE et bref parasite sonore autorisé après interaction. |
| **Port de Pluie — La Baie vivante**, PR 4 ouverte | [js/ui/home-screen.js](https://github.com/darknigthmare/port-de-pluie-baie-vivante/blob/5dcc8b5ae6857c99adfe639083b03948b4301d3b/js/ui/home-screen.js), [spécification 002](https://github.com/darknigthmare/port-de-pluie-baie-vivante/blob/5dcc8b5ae6857c99adfe639083b03948b4301d3b/specs/002-intro-accueil/spec.md) | Studio 2,1 s, production 1,9 s, auteur 1,7 s, titre 2,3 s : 8 s ; puis version de 3 s aux lancements suivants. Accueil au-dessus de la baie vivante ; Reprendre apparaît selon une progression réelle, nouvelle promenade protégée par confirmation. |

Les états de PR désignent les références examinées lors de l’audit. Les URL de fichiers restent attachées à leurs commits, même si les branches évoluent ensuite.

## Couronne de référence retenue

La couronne de **Jurassic Arsenal** fournit un dessin simple déjà intégré à une version fusionnée. Sa géométrie native, à l’intérieur d’un `viewBox="0 0 64 64"`, est :

```svg
<path d="M8 46 6 18l13 12 13-20 13 20 13-12-2 28Z"/>
<path d="M12 52h40M22 38l4 6 6-8 6 8 4-6"/>
<circle cx="32" cy="22" r="2.5"/>
```

Dans le jeu source, le trait est doré (`#c9a24a`), le remplissage initial transparent et le tracé animé. Cette géométrie peut être conservée dans un asset vectoriel ou redessinée par le moteur ; les ornements propres aux dinosaures, à Deadwall ou à la baie ne sont pas transplantés dans The Tower Descent.

## Direction d’adaptation pour The Tower Descent

L’ouverture retient quatre cartons, avec un passage distinct de l’écran titre au menu :

1. Couronne et **Darknigthmare Kingdoms Games Productions**.
2. **présente**.
3. **un jeu de Darknigthmare**.
4. **THE TOWER DESCENT**, puis invitation à commencer.

Les durées finales relèvent du directeur d’introduction du prototype. Le tableau précédent documente les rythmes des références ; il ne prétend pas qu’un montage encore en cours est déjà implémenté.

L’identité du jeu repose ensuite sur le sauvetage maritime : pluie, vent, radio opérationnelle, rotor, lumière froide et balisage de secours. Le menu s’appuie sur la scène des deux tours et sur la progression sauvegardée : tours intactes avant l’incident, conséquences visibles après leur effondrement. La mise en scène de présentation ne doit ni déclencher l’incident, ni avancer la mission, ni remplacer une sauvegarde.

La nouvelle intervention mène à une arrivée en hélicoptère cohérente avec la mission : reconnaissance de l’île, identification des deux toits et des équipes, annonce de la fenêtre météo, dépose puis contrôle du sauveteur. Une reprise de sauvegarde restaure le point sûr et l’état de la tour sans rejouer cette dépose.

Les préférences de mouvements réduits, le passage volontaire et une protection contre le double déclenchement doivent être conservés. Une nouvelle intervention qui remplacerait une partie existante nécessite une confirmation dans le jeu ; la simple consultation de l’accueil reste sans effet sur la progression.

## Portée de cette vérification

Cet audit repose sur le code et les descriptions de PR, pas sur une comparaison visuelle exécutée des quatre jeux. Il confirme les libellés, dessins natifs, durées et règles d’entrée observables dans leurs sources. Il ne certifie ni une qualité « AAA », ni une sortie sonore, ni une validation sur appareil physique.
