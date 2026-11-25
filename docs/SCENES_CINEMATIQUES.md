# Scènes, cinématiques et accueil

**The Tower Descent — version 0.8.0.** Cette annexe fournit le découpage de l’ouverture, de la clôture au refuge, des transitions avec le jeu et des scènes à produire pour la campagne. La direction recherche la précision d’une présentation cinématographique : composition, rythme, lisibilité des équipes et continuité du son. Le résultat actuel reste une maquette en temps réel dans Godot, avec personnages et décors procéduraux. Il ne constitue pas une livraison de personnages, d’animations faciales ou d’assets « AAA » définitifs. Les résultats d’exécution et de revue restent documentés séparément dans l’état de livraison.

## 1 Intentions et langage visuel

Le premier plan doit faire comprendre une mission de secours. La catastrophe existe à l’échelle de la ville, mais le regard découvre ensuite deux équipes et trois personnes identifiables. Le titre s’efface devant la question pratique : comment descendre, retrouver quelqu’un et le remettre à une équipe qui l’attend ? L’horreur apparaît dans un espace que le joueur a d’abord appris à lire.

La palette associe mer froide, béton désaturé, éclairage médical plus chaud et balises visibles. L’or du studio appartient à l’identité de présentation. Le vert ou le jaune d’un équipement doit ensuite annoncer une fonction précise. Les volumes restent lisibles lorsque l’orage, la transparence du verre ou les effets de grain sont désactivés. Le ciel ne doit pas brûler les silhouettes des équipes ; les contre-jours doivent conserver un liseré de vêtement ou de casque.

Trois échelles alternent : l’île pour la situation, les deux tours pour la géographie et les personnes pour la mission. Une caméra de présentation peut montrer un danger déjà confirmé par la sauvegarde. Elle ne révèle ni les profondeurs ni un effondrement qui n’a pas eu lieu dans cette partie. Les plans ne présentent pas une absence de réponse radio comme une preuve de décès.

Les références d’identité proviennent de quatre dépôts vérifiés à des commits fixes. L’orthographe **Darknigthmare Kingdoms Games Productions** et le crédit **un jeu de Darknigthmare** sont conservés. La couronne au trait de Jurassic Arsenal est adaptée à une identité maritime comprenant les deux tours. Les références, leur statut et leurs limites sont documentés dans [Références de l’introduction](REFERENCES_INTRO.md).

## 2 SC00 Cartons de lancement — livré

### Durée et ordre

La séquence dure **15 secondes**. Elle peut être passée dès son début par le bouton affiché, E ou Entrée. Elle conduit à l’accueil ; elle ne crée pas de partie. Le réglage « Afficher l’introduction au lancement » permet de la désactiver aux démarrages suivants. « Revoir l’introduction » la relance volontairement depuis le menu, sans réinitialiser la mission.

| Intervalle | Carton et fonction | Traitement actuel |
| --- | --- | --- |
| 0 à 3,6 s | Darknigthmare Kingdoms Games Productions | Emblème, nom du studio et mention Productions ; apparition et extinction progressives |
| 3,6 à 5,6 s | présente | Respiration typographique, sans information de mission |
| 5,6 à 8 s | un jeu de Darknigthmare | Attribution de l’œuvre, nom propre inchangé |
| 8 à 15 s | THE TOWER DESCENT | Titre, « Chaque vie compte. Chaque étage vous éloigne du ciel. », révélation plus claire du décor |

Les fondus de carton utilisent une fenêtre de 0,65 seconde. La scène 3D reste derrière une surimpression sombre, des bandes de cinéma et un voile graphique. L’interface utilise les fontes Open Sans embarquées, avec contraste clair sur fond sombre. L’emblème est un SVG ; il n’exige pas de texture générée à chaque lancement.

### Caméra, son et interaction

Le plan d’ensemble observe la mer et les tours avec un champ de vision de 53 degrés. En mode caméra animée, il avance lentement vers le site. Avec les mouvements réduits, activés par défaut, il conserve un point de vue fixe. Les textes et le fondu portent alors le rythme. Aucun balancement de la caméra de joueur n’est ajouté pour compenser l’immobilité.

Un motif original synthétique de 3,6 secondes fournit la signature de lancement. L’ambiance de menu prend ensuite le relais. Ce matériau est une composition procédurale reproductible, pas un enregistrement orchestral ni une musique licenciée présentée comme originale. La coupure de l’audio reste effective pendant l’introduction et après son passage.

Le contrôle de passage doit rester visible indépendamment de la phase du carton. Une longue image ou plusieurs pressions rapprochées ne doivent pas créer plusieurs menus ni lancer une intervention. Le directeur calcule le plan à partir du temps de séquence, ce qui permet une arrivée directe à l’état final. La sauvegarde de mission reste inchangée pendant ce parcours.

## 3 SC01 Accueil contextuel — livré

### Source de vérité

Le décor de l’accueil est reconstruit à partir d’une **sauvegarde validée**, en utilisant son dernier point sûr. Le menu ne récupère pas une position brute issue d’une partie interrompue en rappel ou pendant l’effondrement. Une sauvegarde rejetée ne doit pas produire un décor de progression plausible : l’accueil revient au contexte initial et la reprise n’est pas proposée.

| Point sûr validé | Cadrage de l’accueil | Informations autorisées |
| --- | --- | --- |
| Aucune partie | Mer et deux tours debout | Opération Orphée, première rotation, Alpha et Bravo |
| Toit, étage logique 31 | Poste médical d’Aube | Personnes réellement confirmées au treuil et état enregistré des tours |
| 30 | Restaurant | Dernier point sûr, personnes sauvées et état structurel sauvegardé |
| 29 | Suites et perspective vers Hespérie | Tour intacte avant l’incident ; conséquences seulement après leur confirmation |
| 28 | Archives et noyau | Passage condamné si l’impact a été sauvegardé ; détour déjà connu |
| 27 | Jardin des enfants | Dernier point sûr et bilan humain enregistré |
| 26 | Spa | État connu du secteur, sans révélation des souterrains |
| 25 ou intervention terminée | Refuge | Bilan et consultation d’une intervention achevée |

Le décor affiche le nombre de vies sauvées et le temps de mission du point sûr. La réception médicale utilise les mêmes identifiants qu’en jeu ; elle n’invente pas une personne supplémentaire pour enrichir le plan. Une fin de prototype demeure consultable et n’est pas présentée comme le début d’un nouvel étage.

Les façades extérieures des six étages sont opaques vues de dehors, tandis que leur face intérieure n’obstrue pas les cadrages intérieurs. Elles suivent les parents visuels endommagés lors de l’impact. Cette enveloppe ne crée aucune collision. Les étiquettes 3D propres au gameplay sont exclues des caméras d’accueil et de cinéma ; l’interface de présentation porte les informations nécessaires. Ces choix corrigent la lecture de tours artificiellement ouvertes en coupe depuis la mer.

### Actions et protection de la partie

La colonne principale propose **Reprendre l’intervention**, **Nouvelle intervention**, **Dossier de mission**, **Options**, **Revoir l’introduction** et **Quitter** sur ordinateur. Sans sauvegarde valide, le bouton principal devient **Commencer l’intervention** et la reprise disparaît. Une intervention terminée propose **Consulter l’intervention terminée**. Quitter n’apparaît pas dans l’export Web.

Nouvelle intervention ouvre un panneau consacré au déploiement. Le joueur y choisit la disposition, exprimée par un nombre de 1 à 999 999 ; la valeur initiale est 271104. Si une partie existe, le panneau annonce qu’elle sera remplacée et que les réglages de confort seront conservés. L’action **Déployer Alpha** confirme ce remplacement. Retour referme le panneau sans toucher à la mission.

Le dossier présente la situation et le parcours des six étages. Avant l’effondrement, les deux tours sont décrites comme debout. Après un point sûr enregistrant l’impact, il indique la liaison coupée, le noyau praticable et l’absence de réponse de Bravo. Cette information doit toujours correspondre à la sauvegarde utilisée pour le décor.

Les options sont accessibles avant une nouvelle partie. Elles comportent activation du son, volume général de 0 à 100 %, sensibilité de souris de ×0,25 à ×2,5, champ de vision jouable de 65 à 100 degrés, regard vertical inversé, réduction des mouvements, activation des éclairs lumineux et introduction au lancement. Le même panneau est accessible depuis la pause ; sa fermeture retourne à la pause sans reprendre automatiquement le jeu. Les valeurs par défaut sont audio actif, mouvements réduits actifs, éclairs désactivés et introduction active. Les sous-titres sont toujours affichés. Ces préférences sont enregistrées séparément de la mission et chargées avant le choix d’afficher le prologue.

### Composition et comportement

Le titre et les actions occupent le côté gauche sur un dégradé sombre. Le point sûr et le bilan occupent le bas droit, sans concurrencer la vue principale. Le focus clavier est visible ; Reprendre reçoit le focus quand il existe, sinon Commencer. Le retour d’un panneau replace le focus sur l’action principale.

Les mouvements réduits donnent un plan fixe. Le mode animé ajoute un déplacement de faible amplitude, sans rotation complète autour des tours ni exposition à une zone non atteinte. L’horloge du menu peut faire vivre le fond, la pluie et les rotors. Elle ne consomme ni oxygène, ni endurance, ni temps de mission. Le départ des hélicoptères ne progresse pas parce que le joueur lit les options.

## 4 SC02 Arrivée sur Aube — livré

### Déclenchement et durée

Une nouvelle intervention commence par **28 secondes**, divisées en quatre plans de sept secondes. La reprise d’un point sûr ne rejoue pas cette arrivée. Le passage volontaire conduit au joueur sur le toit avec une mission prête à commencer ; il ne saute aucun sauvetage et ne déclenche pas l’incident. La pause suspend le directeur et les communications de cette séquence.

La caméra accompagne désormais une arrivée animée des deux appareils. Leurs trajectoires, inclinaisons, portes coulissantes et déplacements des équipes sont calculés à partir du temps de la séquence. La cabine possède des volumes intérieurs, une ouverture latérale et des sièges de maquette. Les membres existants des équipes sortent et gagnent leurs postes ; les jambes et les bras prennent des poses de marche. Ce dispositif n’utilise ni capture de mouvement, ni animation faciale, ni personnage équipé d’un squelette de production. Les appareils, équipes et tours restent des représentations procédurales.

| Plan | Image, objectif et champ de vision | Carton |
| --- | --- | --- |
| 1, 0–7 s | Vue large sur la mer, la ville et les appareils en approche ; faire comprendre l’isolement, 56° | ÎLE DE NACRE ; 04:17 / PREMIÈRE ROTATION DE SECOURS |
| 2, 7–14 s | Rapprochement sur les deux toits pendant les posés successifs ; nommer la géographie, 53° | LES TOURS ORPHÉE ; AUBE / HESPÉRIE |
| 3, 14–21 s | Vue des cabines ouvertes et du déploiement des équipes ; rendre leur relation spatiale concrète, 64° | DEUX ÉQUIPES ; ALPHA SUR AUBE / BRAVO SUR HESPÉRIE |
| 4, 21–28 s | Arrivée vers le poste d’Aube et le point de prise en main ; cadrage dégagé de l’antenne, 62° vers 76° en mode animé | VOTRE LIGNE TIENT ; AUBE / POSTE DE COMMANDEMENT |

En caméra animée, chaque plan interpole une position et un regard avec accélération et décélération progressives. Les mouvements réduits conservent des cadrages fixes ; le dernier plan reste une vue stable du poste avant la remise du contrôle. Les bandes et sous-titres sont identiques dans les deux modes. Le champ de vision choisi pour la caméra jouable, 77 degrés par défaut, reprend à l’issue de la transition. Les trois premiers plans conservent leur cadrage propre. Le dernier raccord mobile rejoint progressivement le champ de vision choisi ; en mouvements réduits, le plan fixe garde son cadrage avant le retour au joueur.

### Dépose et déplacements de la version 0.5

Le premier plan établit une distance à parcourir : Alpha commence à 28 m au-dessus de son point de stationnement et Bravo à 36 m. Chaque appareil rejoint une approche à faible altitude puis son repère au toit. L’altitude des modèles reste supérieure ou égale à leur stationnement final ; ils ne traversent pas une dalle pour rejoindre une position imposée. Ces trajectoires de mise en scène ne représentent pas un modèle de vol pilotable.

| Événement | Temps de séquence | Résultat visible |
| --- | --- | --- |
| Fin d’approche de Bravo | 6,5 s | Transition vers la descente finale au-dessus d’Hespérie |
| Fin d’approche d’Alpha | 8,0 s | Transition vers la descente finale au-dessus d’Aube |
| Toucher de Bravo | 10,8 s | Appareil posé et inclinaison annulée |
| Ouverture de Bravo | 11,2 à 13,4 s | Portes latérales coulissantes |
| Toucher d’Alpha | 13,4 s | Appareil posé sur l’hélisurface d’Aube |
| Ouverture d’Alpha | 13,8 à 16,0 s | Cabine accessible visuellement avant le déploiement |
| Déploiement des équipes | 16 à 23 s | Sortie échelonnée et marche vers les postes préparés |
| Fermeture des cabines | 24 à 26 s | Appareils prêts pour leur futur départ |
| Remise de la caméra au joueur | 28 s | Équipes en place et début de l’horloge de mission |

La poussière et les embruns du rotor sont des effets de présentation proches des toits. Leur intensité augmente pendant l’approche basse et diminue avant la remise du contrôle. Ils n’exercent aucune force sur le personnage et ne constituent pas un danger. Les pales principales et de queue tournent selon l’horloge de présentation ; la pause les fige avec le son. Les mouvements réduits stabilisent les caméras tout en conservant les déplacements des appareils et des équipes nécessaires à la compréhension de la scène.

La fin naturelle, le passage à n’importe quel instant et la reprise du point sûr initial doivent donner les mêmes portes fermées, appareils posés et membres en poste. Ces poses sont absolues et peuvent être appliquées plusieurs fois sans déplacement supplémentaire. L’état d’arrivée n’est pas enregistré. Le point sûr du toit contient une intervention prête à jouer ; il ne stocke ni une caméra intermédiaire ni un équipier à mi-chemin de la cabine. Les quatre transmissions continuent à respecter leurs repères : passer la séquence ne crée pas celles qui n’ont pas encore été entendues.

Le départ opérationnel conserve une autre horloge. Il commence après dix secondes de mission pour Alpha et treize pour Bravo ; chacun suit un éloignement de vingt-trois secondes. La durée passée dans l’introduction ne réduit donc pas la présence des appareils après la prise en main. Un menu construit depuis un point sûr à un temps plus avancé replace directement les appareils selon ce temps, sans rejouer la dépose.

L’équipe Bravo possède ensuite ses propres poses de repli lors de l’incident. Restaurer ou réappliquer la fin de l’arrivée après cet incident ne doit pas faire réapparaître ses membres sur le toit. La séparation entre arrivée et repli protège la continuité du récit et évite de transformer une opération visuelle en réinitialisation des conséquences.

### Texte exact des quatre communications

À **0,6 s**, HÉLIX 2 / APPROCHE NACRE : « Nacre en vue. La ville est sous les eaux. Les deux tours sont toujours debout. » Le message reste prévu pour 6,4 secondes. Il décrit seulement ce que l’approche confirme.

À **7,2 s**, VARGA / OPÉRATION ORPHÉE : « Alpha sur Aube, Bravo sur Hespérie. On vérifie chaque signal. Aucun étage n’est déclaré sûr. » La durée prévue est 6,4 secondes. Cette phrase donne la méthode : la radio guide mais ne certifie pas à elle seule un espace.

À **14,2 s**, BRAVO / ÉQUIPE HESPÉRIE : « Bravo posé. Nous voyons votre équipe de l’autre côté. On reste en contact. » La durée prévue est de six secondes. Le lien entre les toits est posé avant que la situation se dégrade.

À **21 s**, VARGA / POSTE D’AUBE : « Alex, rejoignez la ligne de rappel. Ana Rios vous attend au restaurant du 30. On tient votre corde. » La durée prévue est de sept secondes. Le premier objectif et la destination de retour sont explicites à la prise en main.

Ces répliques sont actuellement des sous-titres. Aucun doublage enregistré n’est fourni. Les messages empruntent le système de communication du jeu et son journal, mais les indices d’émission de la cinématique sont protégés contre les doubles appels. Passer la séquence termine ses indices ; les lignes non encore émises ne sont pas artificiellement rejouées derrière le premier objectif.

### Son et remise du contrôle

Une boucle originale de rotor de huit secondes soutient l’arrivée. Le motif de menu, d’une durée de seize secondes, et la signature de lancement sont produits par le script audio du dépôt. Leur mixage reste un premier équilibre, à vérifier sur plusieurs sorties audio pendant la production. La lecture des sous-titres ne dépend pas de la présence du son.

L’horloge de mission demeure suspendue pendant l’arrivée. La caméra de cinéma est courante, le déplacement est désactivé et les dangers, départs d’appareils et treuillages n’avancent pas. À la fin, le masque se retire, le HUD revient, la caméra du joueur devient courante et le contrôle est activé si le jeu n’est pas en pause. L’objectif d’Ana est rappelé. Une pause au dernier instant ne doit pas rendre la souris captive derrière un écran encore ouvert.

## 5 SC03 Le premier sauvetage et sa réception

Cette scène est jouée. L’ouverture s’achève au poste, le joueur apprend la corde puis atteint le restaurant du 30. Les accessoires P01, P02, P04 et P11 forment une chaîne visuelle : ligne, balise, treuil et réception médicale. Aucun plan forcé ne doit cacher la commande au moment de sortir de la corde.

La 0.6 permet de sécuriser Ana avec E, puis montre le harnais et les mains d’Alex pendant le retour à la balise. La remontée de cinq secondes comprend verrouillage, montée et dépose sur le toit ; le panier, les sangles, le câble et l’opérateur matérialisent ce transfert. La fin du treuil inscrit `survivor_30` parmi les personnes sauvées et demande l’écriture du point sûr ; le dernier checkpoint réussi reste la référence tant que cette écriture n’a pas abouti. Un accompagnement cosmétique de 4,2 secondes rejoint ensuite la place médicale d’Ana. Samuel et Nora utilisent la même chaîne, avec leur nom, leur pose ou leur couverture. La caméra du joueur n’est pas déplacée vers le toit. Le chapitre [Sauvetage visible](SAUVETAGE_V0.6.md) décrit les coordonnées, les durées, les props, la pause et la reprise.

La cible de production ajoute un regard d’Alex vers la ligne tendue, un geste d’accueil de l’équipier et une réponse courte de la personne recueillie. Ces inserts doivent pouvoir être désactivés et ne jamais masquer une sortie. Ils ne demandent pas une caméra externe obligatoire : le mouvement de la corde et l’équipe au-dessus peuvent suffire. La priorité demeure la certitude qu’une personne a été prise en charge.

## 6 SC04 Effondrement d’Hespérie — livré et cible d’habillage

Le déclenchement se fait depuis l’observation du 29 après le sauvetage d’Ana et le départ des appareils. Depuis la baie Est, l’incident démarre après un regard maintenu vers Bravo ou une confirmation explicite avec E. Il n’est pas lancé pendant le transport d’une personne, un treuillage ou la traversée de la corde. Les conditions et la machine d’état sont détaillées dans [Effondrement en direct](EFFONDREMENT_EN_DIRECT.md).

Le découpage livré suit avertissement de huit secondes, réplique de six secondes, bascule de sept secondes et impact de quatre secondes. Les ordres de Bravo et Varga se succèdent avec priorité opérationnelle. Les membres visibles de Bravo se tournent puis gagnent l’intérieur ; leur disparition derrière les volumes est un repli, pas une animation de mort. Hespérie bascule suivant une animation déterministe, puis un état stable endommagé remplace le passage Est du 28 par le détour du noyau.

La caméra reste liée au joueur : elle encourage à regarder mais ne téléporte pas Alex sous les débris pour obtenir une meilleure image. L’avertissement doit être perceptible hors champ par la radio, le grondement et les premières vibrations. Une personne qui détourne le regard conserve une compréhension de l’ordre d’événements grâce aux messages et au journal.

Pour l’habillage final, le plan sonore commence par une oscillation du verre et des attaches, laisse une courte suspension avant la rupture principale, puis distingue contact, chute de débris et retour des appels. La cible évite une compression uniforme qui couvrirait Varga. La poussière révèle progressivement la géographie transformée ; elle ne doit pas conserver un écran opaque plus longtemps que nécessaire à la lecture du nouveau passage.

Les tests doivent séparer la puissance de la scène et sa justesse mécanique : trajet survivant toujours praticable, sortie de corde libre, restauration directe de l’état final, absence de dégâts issus d’une collision de décor non prévue. Le caractère spectaculaire ne valide pas ces contrats à lui seul.

## 7 SC05 L’écho de Bravo au 27 — livré

Après l’impact et le sauvetage confirmé de Samuel, le joueur peut entendre au 27 un fragment déjà prononcé par Bravo. Le jardin reste un lieu de baisse de pression. L’appel n’ajoute pas de créature et ne transforme pas ce point de respiration en piège. La scène demande six secondes calmes, sans communication active ni action de corde ou de transfert.

La vérification de Varga suit après deux nouvelles secondes calmes dans un lieu autorisé : 27, 25 ou toit. Ce déplacement possible permet au dialogue de respecter l’activité du joueur. L’événement est mémorisé : recharger ne rejoue pas éternellement la même incertitude. Les règles exactes sont décrites dans [Communications et équipes](COMMUNICATIONS_ET_EQUIPES.md).

La cible d’habillage utilise une différence discrète de couleur sonore et une absence de réponse directe. Le texte demeure lisible sans filtre sonore. Le scénario ne tranche pas ici entre répétition technique, présence et survivant. Le joueur doit pouvoir formuler une hypothèse sans qu’une interface ne lui impose une conclusion.

## 8 SC06 Refuge, épilogue et compte rendu

### Conditions et résultat durable

Le relais du 25 termine le périmètre de démonstration lorsque l’incident est stabilisé et qu’Ana, Samuel et Nora sont toutes confirmées au poste médical. Les indices et l’écho facultatif de Bravo ne conditionnent pas cette réussite. Une arrivée prématurée conserve l’objectif de retour nécessaire. Le refuge reste sûr ; consulter le bilan ne déclenche aucune attaque.

La première clôture marque la mission achevée et exige un checkpoint écrit avec succès au 25 avant d’ouvrir l’épilogue. Si l’écriture échoue, `completed` revient à `false`, le personnage et le HUD restent disponibles au refuge et le relais peut être réessayé. L’erreur est signalée, l’ancien fichier est conservé et aucune séquence ne démarre. Le réalisateur observe un monde déjà terminé. Il ne déplace pas les rescapés, ne modifie pas les ressources et n’ajoute aucune transmission au registre. Ses effets ne constituent pas de nouveaux événements de mission.

### Trois plans de clôture

L’épilogue de la 0.7 dure **15 secondes**, en trois plans de cinq secondes. Il utilise les lieux réels du monde et leurs identifiants de progression. La mission, ses dangers, sa météo et ses transferts restent suspendus. Les mouvements réduits fixent le point de vue de chaque plan ; le mode animé ajoute un déplacement lent calculé depuis le temps de séquence.

| Intervalle | Image et intention | Texte et source affichés |
| --- | --- | --- |
| 0 à 5 s | Poste médical du toit d’Aube ; confirmer les trois personnes déjà reçues, avec un champ de 62° | TROIS VIES À L’ABRI ; Varga rappelle qu’Ana, Samuel et Nora sont au poste médical |
| 5 à 10 s | Terminal réel du refuge 25 ; replacer le joueur au relais protégé, champ de 51° | LE RELAIS RÉPOND ; fragment attribué à Bravo, « On vous voit à la baie Est… » |
| 10 à 15 s | Hespérie après impact, vue extérieure sans accès à son intérieur, champ de 56° | SOUS NOS PIEDS ; origine non confirmée du fragment évoquant de la lumière au 24 |

Les cartons utilisent une entrée et une sortie de 0,65 seconde ; les fondus de changement de plan emploient 0,35 seconde. Les sous-titres restent textuels : aucun doublage enregistré n’est fourni. Leur échantillonnage n’enregistre pas un nouvel appel dans `radio.history`, y compris lors d’une relecture. La mention du 24 n’ouvre pas cet étage et n’authentifie ni l’heure ni l’origine du signal.

### Passage, pause et reprise

E, Entrée ou la commande de passage conduisent au bilan depuis n’importe quel plan, hors pause. Échap suspend l’épilogue ; les options et l’aide conservent la priorité de leurs écrans, puis Reprendre rend la main à la séquence. L’horloge d’intervention et ses ressources restent figées. Une fin naturelle, une longue image qui franchit la dernière borne et un passage volontaire doivent présenter le même bilan.

La sauvegarde ne contient ni caméra intermédiaire, ni temps d’épilogue, ni indicateur de relecture. Consulter une mission achevée depuis l’accueil ouvre directement le bilan. **Revoir la séquence** est une action explicite de ce bilan ; elle relance les trois plans puis y revient, sans réécrire le point sûr ni ajouter des mots au journal. Aucun signal provenant d’un panneau caché ne doit lancer une séquence derrière le journal.

### Bilan et dossier de mission

Le bilan utilise un cadrage fixe du refuge et la même projection de données que le journal. Il montre les trois noms, le nombre de documents recueillis, le temps de mission, les ressources restantes et le signal encore à vérifier. Il propose de consulter le dossier, revoir l’épilogue ou revenir à l’accueil. Le journal sépare **Situation**, **Rescapés**, **Indices** et **Transmissions** ; il ne dévoile pas le texte des preuves non collectées. Fermer ce journal retourne au bilan, avec le personnage inactif.

Le menu conserve ensuite son décor de refuge et son action de consultation. Le résultat n’autorise pas la présentation d’un bunker, d’Alma retrouvée ou d’une fin de campagne : ces chapitres ne sont pas jouables dans la version 0.8.0. Les champs, props, contrôles et cas de reprise sont détaillés dans [Dossier et épilogue](DOSSIER_ET_EPILOGUE_V0.7.md).

## 9 Storyboards de campagne à produire

### SC07 Retrouver Alma au socle

**Contexte et fonction.** Au A01, le joueur atteint une zone d’évacuation après avoir retrouvé les marques de l’enfant. La scène répond à une recherche concrète, avant d’ouvrir la seconde descente. Alma doit être reconnue par son nom et une interaction vérifiable ; aucune substitution par une apparition n’annule ce progrès.

**Découpage cible, 20 à 35 secondes intégrées au jeu.** Premier temps : plan à hauteur d’Alex à travers une séparation légère, silhouette immobile et bruit identifiable d’un objet. Deuxième temps : Alma répond à une question simple et désigne le groupe à rejoindre. Troisième temps : la caméra suit le geste vers un trajet court ; contrôle complet avant le premier déplacement. Les regards, le cadre de porte et l’éclairage guident sans flèche couvrant le personnage.

**Audio, état et sortie.** Le bruit extérieur baisse pendant la réponse sans disparition magique du monde. La conversation crée un état « Alma identifiée », pas « évacuée ». La sauvegarde sûre précède la transition suivante. Toute réplique passée est résumée par un objectif court. Les accessoires P31, P33 et P34 rappellent les indices rencontrés au jardin.

### SC08 Rupture de la terrasse A00

**Contexte et fonction.** La ligne protège d’abord Alex et Alma, puis la rupture d’un appui préparé provoque la chute vers les anciens bains. Cette transition est écrite et ne doit pas être attribuée à un échec de commande. Le joueur voit avant la rupture une structure qui travaille et entend un ordre de mise à couvert.

**Découpage cible, 12 à 18 secondes.** Montrer l’appui instable dans le regard du joueur, couper le mouvement pendant l’accrochage, suivre une courte traction de la ligne puis traverser la poussière. Éviter une caméra en chute libre tournant sur tous les axes. Le mode mouvements réduits emploie un fondu court entre la rupture et la reprise, avec les mêmes informations radio. Le retour de la lampe sur un repère proche donne l’orientation.

**États et reprise.** Conserver les personnes déjà mises à l’abri. Sauvegarder avant rupture puis au premier état souterrain jouable. Un crash au milieu reprend l’un de ces deux états certifiés, jamais un personnage suspendu sans issue. La réserve minimale nécessaire à la reprise est garantie ; le scénario n’exige pas une fusée conservée depuis le 30.

### SC09 Le bassin et le Porteur

**Contexte et fonction.** Au S01, une présence entraîne Alma vers une galerie. Le cadrage confirme une direction et un objectif sans violence graphique. Le Porteur, E04, est un acteur de trajet préparé ; sa scène ne dépend pas d’une poursuite physique aléatoire susceptible de coincer l’enfant.

**Découpage cible, 10 à 16 secondes.** Vision basse depuis le bassin, prise de la lampe, silhouette large franchissant un seuil, marque d’Alma sur un élément visible. Reprendre le contrôle avant la première bifurcation. Une trace matérielle et un appel sous-titré persistent si le joueur passe l’insert. Le passage n’ajoute pas un délai réel caché de survie de l’enfant.

**Contrechamp et son.** Le Porteur ne reçoit pas de gros plan explicatif. Sa masse coupe une source lumineuse puis sort du champ. L’écho du bassin diminue pour laisser entendre la galerie utile. Le premier espace jouable offre outils essentiels et point d’orientation stable.

### SC10 Le premier contrôle SILLAGE

Cette scène conserve son identifiant de campagne. Elle se déroule bien après le refuge du prototype et reste à produire ; l’épilogue introduit en 0.7 et conservé en 0.8 appartient à SC06. Le fragment de clôture ne constitue ni une visite de SILLAGE ni le début jouable de ce contrôle.

**Contexte et fonction.** Au S07 puis B01, l’architecture industrielle change la lecture de la catastrophe. Une porte et un tableau montrent que l’isolement précède le tsunami. Les informations essentielles sont réparties entre un registre, un état de porte et un témoin, pas dissimulées dans un seul long enregistrement.

**Découpage cible, 15 à 25 secondes facultatives.** Regard vers le logo de contrôle, vers la porte fermée du côté intérieur, puis vers une date et un ordre d’isolement. Le joueur peut interrompre la lecture et utiliser le sas. Sorel peut répondre à la radio depuis un lieu identifié ; son objectif est de conserver les données, ce qui crée un conflit concret sans exposé complet sur le seuil.

**Production.** P45, P47 et P48 portent les informations. E05 peut imposer une discipline d’émission dans le secteur suivant, après explication de la règle. Ne pas cumuler une transmission indispensable, un verrouillage de porte et une attaque pendant ce premier apprentissage.

### SC11 Le seuil, la fermeture et le retour

**Contexte et fonction.** Cet identifiant orchestre le dernier acte de campagne à produire. B06 prépare la ligne de retour ; P666 est le dernier sas du côté de Nacre ; SC14 conduit physiquement vers I01. La traversée jouable d’I01 à I04 fait ensuite découvrir une géographie infernale réelle. Le franchissement n’est pas une ellipse qui mènerait directement au dénouement. Les matériels transportés, l’état d’Alma et les liaisons d’Alex restent continus.

**Découpage cible du dénouement.** Dans I04, trois objectifs de contre-signal sont séparés par des appuis reconnaissables. Chacun modifie visiblement une liaison P59. E10, le Chœur bas, porte la réponse du lieu ; E16, le Gardien de brèche, constitue l’obstacle corporel du secteur. Leurs règles sont enseignées séparément avant leur combinaison. Les inserts durent deux à quatre secondes au maximum, uniquement lorsqu’une conséquence spatiale exige un autre cadrage. La progression repose sur les postes réglés et l’ouverture du retour, sans barre de vie finale arbitraire ni choix opaque remplaçant les actions.

**Retour et continuité.** P60 est franchi vers Nacre avant la galerie technique finale. Le joueur reconnaît un raccord de béton, un identifiant d’équipement et une réponse radio venant du monde d’origine. Le retour ne révoque pas ce qui a été traversé : personnes, matériel déplacé et preuves restent réels. Les confirmations de secours ne sont jamais remplacées par une révélation annonçant qu’elles étaient imaginaires.

**Conclusion cible, 35 à 60 secondes passables.** Après le retour, une galerie étroite s’ouvre vers le jour. Le son sépare de nouveau mer, vent et radio. Une réponse liée aux personnes et relais préservés confirme la continuité humaine. La vue basse des tours mesure la descente. Le bilan fournit les personnes sauvées et les preuves, sans transformer une exposition maximale au danger en score obligatoire. Passer cette conclusion rend le bilan ; passer un insert du dernier acte ne valide pas les objectifs restants.

### SC12 Le premier retranchement humain

**Contexte et fonction.** Séquence future au A21, après l’apprentissage du problème matériel des cuisines. Un humain E11 occupe la réserve et prend la lampe d’Alex pour le signe d’une intrusion. Sa silhouette reste la même lorsqu’Alex regarde ailleurs. Sa respiration, ses appuis, la porte qu’il tient et ses paroles établissent un corps présent, distinct des aperçus du haut de tour.

**Découpage cible, 12 à 20 secondes de préparation jouable.** Une vue à travers le vitrage de service révèle l’outil tenu bas et la personne derrière le battant. Une sommation explicite précède toute attaque. Le joueur garde son regard et peut reculer, répondre depuis la distance indiquée ou inspecter la route de service. Le plan ne force pas à avancer dans la portée d’E11. Une courte réponse sous-titrée explique ce qu’il protège sans faire d’un diagnostic une explication universelle de la violence.

**États et validation.** La scène se termine dès que la règle du territoire est comprise ; la rencontre continue avec les valeurs de la fiche E11. Un détour et une désescalade sont possibles. La première attaque reste annoncée après toute reprise. La personne secourable, les outils essentiels et la sortie ne dépendent pas d’une mise à mort. La sauvegarde future conserve l’accord obtenu ou la porte sécurisée ; le refuge 20 n’accepte aucune poursuite.

### SC13 La matière revenue

**Contexte et fonction.** Le laboratoire A08 prépare cette scène par une comparaison ; B03 en fournit la corroboration complète. P53 expose un échantillon, P54 rapproche les enregistrements de départ et de retour, P55 montre le résidu recueilli au seuil. Les mêmes identifiants traversent ces supports. L’explication progresse d’un phénomène mesuré vers un transfert réel ; elle ne repose pas sur la seule parole de Sorel.

**Découpage cible, 18 à 30 secondes facultatives.** Alex compare deux scellés et une marque d’outil visibles, puis un témoin ou une transmission authentifiée confirme l’origine d’un équipement revenu. Une anomalie de matière persiste hors du champ de caméra. Un insert de trois secondes au maximum peut montrer la différence de surface ; la lecture détaillée demeure volontaire. Le silence entre deux constatations laisse le joueur rapprocher les faits.

**Écriture et sortie.** Sorel emploie d’abord le vocabulaire du programme ; Alex peut demander où sont passés les opérateurs. Les preuves restent consultables et la synthèse essentielle existe sans son. Une acquisition future est liée à une interaction effectivement réalisée, avec une provenance explicite ; le simple passage d’une caméra ne crée pas un journal omniscient. La séquence ne déclenche aucune attaque pendant la lecture. Elle n’est pas présente dans le dossier du prototype.

### SC14 Le franchissement de P666

**Contexte et fonction.** La porte déformée P56, les balises P57 et la ligne P58 montrent que des équipes ont déjà travaillé sur ce passage. Les expériences ont ouvert une route vers une dimension infernale réelle. Le joueur prépare son retour du côté de Nacre, vérifie le groupe et franchit le seuil avec son matériel. Il ne se réveille pas ailleurs après une perte de connaissance imposée.

**Découpage cible, 14 à 22 secondes dont le franchissement reste contrôlé.** Première vue : l’appui arrière, le repère de la ligne et le sas. Deuxième temps : un pas amène la lampe à éclairer une matière qui n’appartient plus au bunker ; le câble demeure visible de part et d’autre. Dernier temps : le regard découvre le premier appui I01, avant tout panorama large. Le mode mouvements réduits utilise des cadres fixes et des fondus brefs aux transitions de chargement, avec les mêmes indices de continuité.

**Passage et reprise.** Passer la présentation abrège son habillage et amène au premier appui sûr d’I01 ; cela ne termine pas la traversée infernale. Les états avant et après le sas doivent être certifiés. Une interruption ne dépose pas Alex entre deux mondes et ne perd ni témoin ni équipement requis. La confirmation du franchissement est distincte de la confirmation d’un sauvetage. Aucun danger ne commence avant la remise du contrôle et l’orientation sur l’appui.

### SC15 Le premier appui en Enfer

**Contexte et fonction.** À I01, le jeu donne le temps de comprendre le changement d’échelle. Le rivage de cendres, un horizon impossible et des ouvrages dont une partie porte les numéros Pelagos établissent que l’on a réellement atteint l’autre côté. Un équipement connu répond au test ; la radio conserve ses limites de portée. Alex n’acquiert ni pouvoir magique ni connaissance immédiate de cette géographie.

**Découpage cible, 10 à 18 secondes passables.** Une vue proche identifie l’anneau d’amarrage et l’état de la ligne. Une vue plus large révèle un ouvrage d’extraction sans montrer tous les ennemis à venir. Le contrôle revient sur un sol stable face à une balise lisible. L’objectif demande d’abord de certifier l’appui de retour, puis de suivre un indice d’Alma. La découverte possède une durée minimale de sécurité, pas une immobilisation obligatoire devant le paysage.

**Son, état et recette.** Le son conserve respiration, équipement et repères de la ligne, puis ouvre une profondeur nouvelle. Il ne dépend pas d’un pic de volume. Son coupé, les changements de matière et le retour du matériel suffisent. La première rencontre infernale corporelle E14 attend I02 ; I01 enseigne lieu, distance et retour. Vérifier la continuité des personnes, la lecture de l’objectif après passage et la reprise sur le même appui, avec la même route restante.

## 10 Contrats de réalisation et validation

Chaque séquence doit déclarer son état d’entrée, son point de sortie, les événements qu’elle peut écrire et sa stratégie de passage. Le lancement et le menu n’écrivent pas de progression. L’arrivée initialise une mission puis rend le contrôle. L’effondrement produit un changement structurel persistant. La clôture exige le checkpoint achevé écrit avec succès avant son épilogue de présentation ; le réalisateur et ses relectures n’écrivent aucun fait supplémentaire. Les transitions de campagne futures doivent disposer d’une sauvegarde avant et après leur portion non jouable.

Un événement narratif n’utilise pas le temps passé dans un menu comme délai caché. La pause suspend images narratives, communications et dangers. Une longue image traverse correctement les repères temporels ; un message n’est ni doublé ni sauté par erreur d’index. Une reprise applique l’état du monde sans répéter tous les sous-titres de l’intervention précédente.

Les contrôles de présentation couvrent au minimum menu initial, tous les contextes de reprise, cartons de lancement, quatre plans d’arrivée, trois plans de clôture, les quatre onglets et le bilan, modes de mouvement, son coupé, passage immédiat et pause près de la dernière image. La revue visuelle doit aussi vérifier silhouettes sur le ciel, façades intactes avant impact, absence d’antenne devant l’objectif du dernier plan et absence d’étiquettes de gameplay dans les caméras de cinéma. Le registre affiché doit correspondre aux personnes présentes au médical et aux faits de la sauvegarde ; aucune lisibilité de texte ne peut être déduite d’un test sans rendu.

Les essais automatiques valident les durées, états, préférences, événements et garde-fous d’intégration. Une capture ne prouve pas la qualité d’une transition sonore ; un test sans fenêtre ne prouve pas la lisibilité d’une image. Les résultats de livraison et les vérifications effectivement réalisées sont consignés dans [État de livraison](ETAT_DE_LIVRAISON.md).

## 11 Sources de vérité et prochaines passes

Le découpage livré est défini par [cinematic_director.gd](../prototype/scripts/cinematic_director.gd), l’accueil par [frontend_menu.gd](../prototype/scripts/frontend_menu.gd), les cartons par [cinematic_overlay.gd](../prototype/scripts/cinematic_overlay.gd) et les options par [preferences_store.gd](../prototype/scripts/preferences_store.gd). [main.gd](../prototype/scripts/main.gd) assure le changement de caméra, les horloges et la remise du contrôle. Le décor et la réception médicale viennent de [world_builder.gd](../prototype/scripts/world_builder.gd).

La clôture de la 0.7 est échantillonnée par [epilogue_director.gd](../prototype/scripts/epilogue_director.gd). [mission_dossier.gd](../prototype/scripts/mission_dossier.gd) projette les faits de mission sans écrire dans le monde ; [mission_dossier_panel.gd](../prototype/scripts/mission_dossier_panel.gd) les présente dans le journal et le bilan. Le contrôleur de mission conserve la responsabilité du checkpoint final et du retour entre les écrans.

La progression complète est détaillée dans [De la perception incertaine à l’Enfer](PROGRESSION_HORREUR_V0.8.md). Les scènes SC07 à SC15 restent futures ; SC06 conserve la clôture jouable au refuge 25. Le menu futur pourra cadrer un appui infernal uniquement après un checkpoint de campagne validant son atteinte ; aucun plan actuel ne révèle ce lieu.

La prochaine passe de production doit d’abord valider la compréhension du parcours sans commentaire extérieur, puis remplacer les silhouettes par des rigs, travailler gestes et regards, enregistrer les voix et mixer l’ambiance. Les nouvelles ressources doivent respecter les durées et les contrats de sauvegarde. Un meilleur rendu ne justifie pas l’allongement automatique de l’ouverture ni la suppression de son passage immédiat.
