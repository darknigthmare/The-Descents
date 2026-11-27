# Communications et continuité des équipes

**Version 0.8.0 — 25 novembre 2026**

Ce dossier fixe ce que le joueur peut conclure à partir des personnes visibles, d’un appel radio et du journal. Le poste d’Aube confirme les prises en charge. Bravo devient difficile à joindre après l’effondrement, sans que son silence prouve sa mort. Les communications peuvent être ambiguës ; le registre des personnes effectivement sauvées reste fiable.

La 0.4.0 rétablit les comportements développés pendant la continuation 0.3 interrompue. Elle les intègre à une nouvelle présentation d’accueil et d’approche. Les résultats d’essai de l’ancienne session ne valent pas validation de cette reconstruction : les vérifications courantes figurent dans [État de livraison](ETAT_DE_LIVRAISON.md).

La 0.5 réutilise les six membres des deux toits pour le débarquement des appareils. Les portes s’ouvrent après chaque posé, les figures sortent puis rejoignent leurs emplacements préparés. Le binôme d’observation du 29 est distinct ; il devient visible à la remise du contrôle. Pendant la réplique, les poses de repli reprennent la priorité sur les poses d’arrivée. Le poste médical conserve les trois identités de rescapés, indépendamment du nombre de figures décoratives visibles.

Les nouvelles fiches d’observation n’ajoutent aucune transmission à l’historique. Leur « note de l’équipe » est une information de lecture présentée dans la fiche, sans émission vocale ni événement radio supplémentaire. Le registre médical affiche les réceptions confirmées, tandis que les fiches de baie et de réseau maintiennent l’incertitude sur Bravo après la perte de liaison. Lire une fiche suspend la transmission en cours ; fermer la fiche la reprend avec le temps restant.

## Répartition des responsabilités

| Groupe | Emplacement initial | Fonction dans le prototype |
| --- | --- | --- |
| Alex et Corde | Toit d’Aube puis puits | Exploration, contact et déclenchement du transfert |
| Varga | Poste d’Aube | Objectif, confirmation de réception et consignes de structure |
| Médical | Secteur du toit hors du puits | Présentation des trois personnes prises en charge |
| Bravo au toit | Hespérie | Trois silhouettes établissant une opération parallèle |
| Bravo à la galerie | Hespérie face au 29 | Deux silhouettes observables avant le choc et le repli |
| Pilotes Alpha et Bravo | Deux appareils distincts | Dépose, départ et limitation météorologique du retour |

Les figurants sont construits avec la même géométrie simple que le reste du monde. Leurs vêtements et casques suffisent à distinguer secours et civils. Les gestes fins, les visages, les voix enregistrées et une navigation autonome demeurent des besoins artistiques et techniques de campagne.

## Repli de Bravo

La galerie possède une porte identifiable dans la façade ; le toit dispose d’un noyau de service. La position de chaque membre dérive de sa position initiale, d’une destination préparée et de l’horloge de l’incident. Pendant les huit secondes d’avertissement, les figures se tournent et commencent leur déplacement. Pendant les six secondes de secousse, elles gagnent l’intérieur. Au début de la chute, elles terminent le passage à couvert et cessent d’être visibles.

Le passage entre `warning`, `quake` et `collapse` est continu. Une lecture directe d’une phase doit donner la même pose qu’une lecture obtenue en traversant les phases précédentes. Une nouvelle partie remet les groupes à leurs positions initiales ; une reprise après impact ne rejoue pas le repli. Cette action préparée ne consulte aucun chemin de navigation et n’ajoute aucun corps de collision.

La fiction s’arrête à l’observation d’un repli et à la perte de contact. Ni l’interface ni le journal n’inscrivent un décès sans preuve prévue par le scénario. Une réapparition radio ultérieure conserve plusieurs explications : émission directe, reprise enregistrée, relais ou imitation. La campagne décidera du sort des personnes par des scènes et des indices distincts.

## Réception des personnes sauvées

Le compteur n’avance qu’à la confirmation de fin du treuillage. La figure du rescapé quitte alors son emplacement d’origine et sa représentation au poste médical devient visible. Le panneau collectif indique le nombre de personnes à l’abri ; chaque emplacement conserve son nom.

| Identifiant | Personne | Présentation de maquette au toit |
| --- | --- | --- |
| `survivor_30` | Ana Rios | Allongée sur une civière, couverture claire, nom et statut |
| `survivor_28` | Samuel Breton | Silhouette sous une couverture jaune, nom et statut |
| `survivor_26` | Nora Haddad | Pose abaissée près d’un siège, couverture claire, nom et statut |

`world.set_rescued_people(rescued)` projette la liste de mission dans ces trois emplacements. Les figures sont préconstruites : appeler la méthode deux fois ne crée aucun doublon. Les identifiants inconnus sont ignorés. Passer `[]` rétablit un poste sans rescapé à chaque nouvelle partie. Une reprise affiche uniquement les personnes inscrites au checkpoint, même si une autre avait commencé son transfert dans la session interrompue.

Cette réception occupe le bord arrière du toit, hors du point d’arrivée, du puits et des balises. Les accessoires sont visuels et sans collision. Ils ne donnent aucune interaction médicale à exécuter et ne constituent pas une simulation de soins. L’enrichissement futur doit préserver l’accès à la ligne, la lisibilité des noms et la stabilité des prises en charge.

## Ordonnancement des sous titres

Le directeur radio distingue la réception d’un message de son affichage immédiat. Un message peut être reçu et archivé alors que le joueur lit encore une autre consigne. Cette séparation empêche plusieurs répliques ordinaires de se remplacer avant lecture.

| Cas | Affichage | Historique |
| --- | --- | --- |
| Message ordinaire, canal libre | Commence immédiatement | Ajouté à la réception |
| Message ordinaire, sous-titre occupé | Attend dans une file de six maximum | Ajouté à la réception |
| Doublon ordinaire déjà visible ou en attente | Ignoré | Ne crée pas une seconde entrée |
| File ordinaire pleine | Le plus ancien message en attente quitte la file | Son texte reste dans l’historique borné |
| Alerte prioritaire | Remplace le sous-titre et retire la file ancienne | Tous les textes déjà reçus restent conservés dans la limite du journal |
| Commentaire ordinaire pendant l’incident | Peut être seulement archivé | Disponible pour lecture ultérieure |
| Pause de la partie | Durée de lecture figée | Aucun temps de mission consommé |

La priorité concerne les appels de structure et les instructions opérationnelles qui doivent être utiles tout de suite : rejoindre la balise avec quelqu’un au harnais, attendre le treuil, comprendre le retour nécessaire avant clôture. Elle ne sert pas à multiplier les interruptions décoratives. Une frame longue ne peut consommer la durée d’un nouveau sous-titre avant que celui-ci ait été présenté.

Les choix de priorité ne doivent pas effacer un indice. Le journal conserve au plus trente-deux transmissions, puis retire les plus anciennes. Ce n’est pas un enregistreur illimité. Le texte de chaque transmission porte un indicatif, un contenu et le temps local de réception dans la mission.

## Journal et compte rendu

Le journal introduit en 0.7 et conservé en 0.8 présente quatre onglets : **Situation**, **Rescapés**, **Indices** et **Transmissions**. Situation réunit l’objectif, le point sûr, l’état structurel, les ressources et les derniers échanges ; Rescapés distingue personne à secourir, au harnais, au treuil et réellement reçue. Indices ne révèle le texte que des pièces collectées. Transmissions conserve les mots reçus et leurs temps de mission. La touche J ouvre le dossier pendant l’intervention et suspend la simulation. Depuis la fin, le bouton de compte rendu ouvre le même contenu en maintenant le monde arrêté ; fermer le journal retourne au bilan.

Une heure de réception ne certifie pas l’heure d’émission. Le fragment Bravo porte donc un temps local dans le journal sans que celui-ci authentifie sa source. L’indicatif livré le désigne comme un écho non vérifié. Cette distinction doit être conservée dans la localisation et le futur doublage : l’incertitude concerne l’origine du signal, pas le fonctionnement de la montre d’Alex.

Au chargement, le journal reprend les entrées enregistrées. La file d’attente et l’ancien sous-titre ne sont pas rejoués. Les appels de reprise donnent l’objectif courant au lieu de diffuser successivement tout ce qui avait été entendu avant l’arrêt.

La clôture au refuge ajoute un épilogue de présentation après l’enregistrement réussi de la mission achevée. En cas d’échec, le relais reste réessayable et aucune séquence ne démarre. Ses sous-titres rappellent la réception d’Ana, Samuel et Nora, puis un fragment de relais dont l’origine reste non confirmée. Ils appartiennent au réalisateur de la séquence et n’ajoutent pas de ligne au journal radio. Revoir ou passer cet épilogue ne modifie donc ni les trente-deux transmissions conservées ni les marqueurs `bravo_echo` et `bravo_verification`. La consultation d’une sauvegarde achevée ouvre directement le bilan.

## Écho facultatif après Samuel

Le fragment livré est : « Bravo à Aube. On vous voit à la baie Est... Notre toit tient. Vous nous recevez ? » Il commence comme une observation ordinaire avant le choc. Après l’incident, la même phrase dans un autre contexte produit le doute. Son indicatif est « BRAVO / ÉCHO NON VÉRIFIÉ » et sa durée d’affichage prévue est de huit secondes.

| Étape | Conditions |
| --- | --- |
| Autoriser la scène | Mission active, incident `aftermath`, Samuel confirmé au toit |
| Recevoir l’écho | Joueur au 27, six secondes continues de radio libre, hors rappel, portage et treuillage |
| Vérifier le signal | Écho déjà reçu, sous-titres terminés, deux secondes continues de calme au 27, au 25 ou au toit |
| Persister | Identifiant ajouté et checkpoint demandé sur le niveau sûr courant |
| Interrompre les conditions | Le compteur de calme repart de zéro ; aucun déclenchement pendant pause, arrivée, épilogue ou bilan |

La réponse livrée, sous l’indicatif « VARGA / VÉRIFICATION DU SIGNAL », est : « J’ai reçu le même fragment. Aucun contact confirmé avec Bravo. Gardez les consignes du poste d’Aube ; nous vérifions la liaison. » Sa durée prévue est de neuf secondes. Elle garde ouvertes les hypothèses d’un enregistrement et d’un appel en direct. La scène ne fait apparaître aucune menace au 27 et ne retire aucune personne du poste médical.

Quitter le 27 avant l’écho ne bloque pas la mission. Après l’écho, la vérification peut survenir plus tard si le joueur descend aider Nora ou remonte au toit. Terminer sans attendre l’un ou l’autre reste possible. Un message qui a été entendu puis correctement sauvegardé ne se rejoue pas. Si l’écriture échoue, la session courante le conserve, mais une reprise du dernier checkpoint valide peut revenir avant cette réception.

## Persistance et migration

Le schéma 3 ajoute `transmissions` et `radio_events` sans changer le chemin historique `user://save_v1.json`. Les anciens schémas sont validés strictement avant migration. Un fichier incomplet ou présentant des champs inattendus n’est pas transformé silencieusement en partie valide.

| Schéma lu | Résultat en mémoire |
| --- | --- |
| 1 valide, mission en cours | Incident `intact`, ancien progrès conservé, radio vide |
| 1 valide, mission terminée | Incident `aftermath`, bilan conservé, radio vide |
| 2 valide | État d’incident conservé, radio vide |
| 3 valide | Progression, incident, transmissions et événements conservés |

Les événements autorisés sont `bravo_echo` et `bravo_verification`, chacun une seule fois. La vérification exige l’écho ; chaque événement exige l’incident stabilisé et Samuel sauvé. Les transmissions ont des champs exacts, des textes bornés et des temps finis chronologiques compatibles avec le temps de mission. Les limites détaillées sont dans [Systèmes procéduraux](SYSTEMES_PROCEDURAUX.md).

## Direction de doublage et extension de campagne

Une voix authentique donne d’abord une action et son destinataire. Varga ne décrit pas au joueur l’implémentation d’un checkpoint : elle confirme un résultat ou un chemin. Les témoins utilisent des observations précises et leurs mots propres. Ana reconnaît les usages de l’hôtel ; Samuel connaît les archives ; Nora décrit ce qu’elle a entendu au spa. Les variantes de texte doivent respecter leur ordre de rencontre et l’état réel de l’incident.

Le Répondant de campagne imitera des fragments, sans disposer automatiquement des détails récents de la mission. Un code contextuel doit s’appuyer sur une information que le joueur peut consulter. L’absence de réponse n’autorise jamais à cocher une personne comme morte. Les fausses voix ne peuvent obtenir le même statut typographique de confirmation que Médical : les événements de registre proviennent exclusivement du système de mission.

La future localisation conservera les identifiants de réplique, la priorité, la fenêtre de contexte et une durée minimale de lecture par langue. Une coupe de doublage ne supprimera pas le texte du journal. La lecture sans son doit permettre de distinguer voix directe, transmission coupée et source non authentifiée sans révéler prématurément la vérité de la fiction.

Sources du comportement : [mission](../prototype/scripts/main.gd), [directeur radio](../prototype/scripts/radio_director.gd), [monde](../prototype/scripts/world_builder.gd), [sauvegarde](../prototype/scripts/save_store.gd) et [interface](../prototype/scripts/hud.gd).

## Ce qui est incertain et ce qui devient établi

Dans les étages hauts, un bruit perçu, une silhouette ou une phrase ancienne ne reçoit pas automatiquement une authentification radio. Le journal consigne les mots reçus et les documents trouvés ; il n’annonce pas « démon détecté » ni « Enfer confirmé » au 26. Une trace humide peut être constatée sans en attribuer immédiatement l’auteur.

Dans la campagne future, les témoignages croisés, les supports enregistrés et les transferts matériels finissent par établir l’existence d’une dimension infernale. L’équipe peut alors nommer le fait sans continuer artificiellement à parler de simple fatigue. Le doute restant porte sur l’identité d’un appel, l’intention d’un interlocuteur ou la sécurité d’une route. Les transmissions de Nacre et celles relayées à travers la brèche gardent une provenance distincte. Couper la liaison infernale ne supprime jamais les réceptions médicales déjà confirmées.
