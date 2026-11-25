extends RefCounted
class_name DescentFieldProps
## Optional, reconstructible reading points. They never alter mission or save data.
## Positions are on the existing floor slabs and outside the protected rope sockets.

const GROUP_NAME: String = "FieldInspectionPoints"
const RANGE: float = 2.4
const PATIENTS: Array = [
	["survivor_30", "Ana Rios"],
	["survivor_28", "Samuel Breton"],
	["survivor_26", "Nora Haddad"],
]

const ENTRIES: Array = [
	{
		"id": "inspect_roof_register", "floor": 31, "position": Vector3(8, 42, -3.2), "focus_offset": Vector3(0, 1.35, 0),
		"title": "Registre du poste médical", "category": "PRISE EN CHARGE", "source": "P11", "geometry": "register",
		"usage": "Le registre relie chaque arrivée au treuil à une prise en charge au poste médical d’Aube. Une ligne est confirmée seulement lorsque le transfert de la personne est terminé.",
		"intact": "Le poste comporte trois emplacements de réception pour les personnes signalées dans Aube. L’équipe conserve un accès dégagé entre le treuil et les couvertures.",
		"aftermath": "Le poste reste en service après le choc. Les prises en charge confirmées sont maintenues ; la perte de contact avec Hespérie ne les remet pas en cause.",
		"action_intact": "Retrouvez les rescapés aux étages 30, 28 et 26. Ramenez chaque personne à la balise de son étage pour déclencher sa remontée.",
		"action_aftermath": "Poursuivez les évacuations encore nécessaires. Après les trois réceptions, rejoignez le refuge au 25.",
		"team_intact": "POSTE MÉDICAL — Une personne repérée ou attachée n’est pas encore une personne reçue. Attendez la confirmation du treuillage.",
		"team_aftermath": "POSTE MÉDICAL — Nous gardons les personnes déjà reçues à l’abri. Continuez à nous annoncer les transferts depuis les balises.",
	},
	{
		"id": "inspect_roof_winch", "floor": 31, "position": Vector3(4.4, 42, -4), "focus_offset": Vector3(0, 1.15, 0),
		"title": "Carnet de la ligne principale", "category": "LIGNE DE SECOURS", "source": "P02 / P04", "geometry": "winch",
		"usage": "Ce carnet distingue le treuil de secours à l’est et les rappels personnels à l’ouest. La ligne principale remonte les rescapés ; Alex suit des tronçons locaux et des escaliers entre les étages.",
		"intact": "La fiche de contrôle est fixée au poste du treuil. La traverse reste visible au-dessus du puits ; la ligne orange descend dans son axe.",
		"aftermath": "La traverse d’Aube et le treuil restent en place. Les rappels locaux et les escaliers intérieurs restent praticables malgré les dommages de la façade Est.",
		"action_intact": "Rejoignez le repère bleu du rappel personnel. E engage la longe ; S descend et Z/W remonte. Espace verrouille le descendeur. Les balises orange sont réservées aux rescapés.",
		"action_aftermath": "Reprenez les mêmes rappels et escaliers pour le retour. Au 28, contournez l’obstacle Est par l’intérieur ; le treuil orange et la station bleue restent distincts.",
		"team_intact": "ÉQUIPE ALPHA — Le marquage identifie une ligne suivie par le poste. Les ancrages secondaires stabilisent le balancement ; le carnet ne commande aucun mécanisme.",
		"team_aftermath": "VARGA — Notre treuil tient. Une radio dégradée ne signifie pas que la ligne est rompue.",
	},
	{
		"id": "inspect_30_table", "floor": 30, "position": Vector3(-7, 36, -7), "focus_offset": Vector3(0, 1.15, 0.35),
		"title": "Le couvert resté prêt", "category": "BELVÉDÈRE · SALLE", "source": "P23", "geometry": "table",
		"usage": "Cette table appartient au service du Belvédère. Les couverts et le bon de préparation permettent de lire ce qui a été interrompu dans la salle.",
		"intact": "Une assiette attend sous une serviette pliée. Le bon de préparation est resté sur le plateau, sans heure de clôture. Aucun couvert n’a été débarrassé.",
		"aftermath": "Le couvert est toujours sur la table après le choc. Le service s’était arrêté avant l’effondrement d’Hespérie ; celui-ci n’explique pas à lui seul l’abandon de la salle.",
		"action_intact": "Gardez la voie vers Ana libre. Approchez-la du côté intérieur de la salle, puis revenez à la balise avec elle.",
		"action_aftermath": "Lisez la scène depuis le passage entre les tables. Le mobilier ne doit pas détourner du prochain appel de secours.",
		"team_intact": "OBSERVATION D’ALEX — Un service interrompu est un constat. Sans témoin ni horaire fiable, je ne peux pas dater le départ des clients.",
		"team_aftermath": "OBSERVATION D’ALEX — La salle raconte plusieurs moments. Je garde séparés l’abandon du service et le choc que nous venons de voir.",
		"rescue_id": "survivor_30", "rescue_note": "Ana Rios a été reçue au poste médical. Le restaurant n’attend plus son évacuation.",
		"rescued_action": "Ana est à l’abri. Rejoignez la baie Est du 29 si le contact visuel reste à établir, puis poursuivez les secours aux étages inférieurs.",
	},
	{
		"id": "inspect_30_service", "floor": 30, "position": Vector3(-7, 36, -10.5), "focus_offset": Vector3(0, 1.58, 0.4),
		"title": "Le registre de service", "category": "BELVÉDÈRE · COMPTOIR", "source": "P25", "geometry": "service",
		"usage": "Le registre posé sur le comptoir organise les tables et les passages du personnel. Il décrit le fonctionnement du restaurant, sans constituer une liste de personnes évacuées.",
		"intact": "La dernière page préparée porte des numéros de table. Les cases de fin de service sont vides. Derrière, les bouteilles et le matériel sont encore rangés.",
		"aftermath": "Le registre reste accessible sur le comptoir après le choc. Les cases vides ne prouvent ni que les clients sont encore dans la tour, ni qu’ils ont déjà été secourus.",
		"action_intact": "Contournez le bar par la salle. Pour les secours, fiez-vous aux personnes effectivement rencontrées et aux confirmations du poste médical.",
		"action_aftermath": "Rejoignez le puits par la salle du restaurant. Le registre de service n’ajoute aucune recherche de client à l’évacuation en cours.",
		"team_intact": "ÉQUIPE ALPHA — Une réservation, une présence et une réception médicale sont trois informations différentes.",
		"team_aftermath": "POSTE MÉDICAL — Notre registre de réception reste la référence pour Ana, Samuel et Nora.",
	},
	{
		"id": "inspect_29_luggage", "floor": 29, "position": Vector3(10, 30, 4), "focus_offset": Vector3(0, 0.82, 0.35),
		"title": "La valise des suites", "category": "SUITES · EFFETS PERSONNELS", "source": "P28", "geometry": "luggage",
		"usage": "Une valise et son étiquette racontent un séjour interrompu. Les affaires personnelles restent dans la chambre ; ce ne sont pas des réserves de matériel de secours.",
		"intact": "Une sangle est encore tendue sur le bagage. L’étiquette porte un numéro de chambre, sans indication d’évacuation. Le bagage est posé à l’écart du passage vers la baie.",
		"aftermath": "Le bagage est toujours là, côté intérieur. Sa présence après le choc ne permet pas de localiser son propriétaire. La baie Est a changé, mais le passage vers le noyau demeure.",
		"action_intact": "Après le sauvetage d’Ana, gagnez la baie Est pour établir le contact visuel demandé par Bravo.",
		"action_aftermath": "Revenez vers le noyau puis poursuivez vers les bureaux au 28. L’étiquette ne remplace pas un appel ou une personne visible.",
		"team_intact": "OBSERVATION D’ALEX — Quelqu’un a préparé ses affaires. Je ne sais pas encore quand cette personne est partie.",
		"team_aftermath": "ÉQUIPE ALPHA — Un objet resté sur place ne suffit pas à déclarer une personne disparue. Priorité aux secours confirmés dans Aube.",
	},
	{
		"id": "inspect_29_glazing", "floor": 29, "position": Vector3(11.3, 30, 8.3), "focus_offset": Vector3(0, 1.35, 0),
		"title": "Le témoin de la baie Est", "category": "FAÇADE · CONSTAT", "source": "P19", "geometry": "glazing",
		"usage": "La plaquette de la baie identifie le vitrage extérieur. L’appui et le garde-corps sont distincts des panneaux transparents : ils matérialisent la limite de circulation.",
		"intact": "La baie est vitrée. Au-delà se dresse Hespérie, où Bravo vient de se déployer. Le point de contact visuel se trouve plus au nord, dans l’axe de la baie.",
		"aftermath": "Les panneaux Est ont cédé au choc. L’appui et le garde-corps restent présents. Les dommages visibles ne donnent aucune confirmation sur le sort de l’équipe Bravo.",
		"action_intact": "Restez du côté intérieur de l’appui. Rejoignez le point d’observation de la baie lorsque le commandement le demande.",
		"action_aftermath": "Éloignez-vous du bord et retrouvez le noyau. Le détour du 28 reste accessible par l’intérieur des bureaux.",
		"team_intact": "ÉQUIPE ALPHA — Gardez le repère de la baie et celui du puits. Ils resteront utiles si la visibilité se dégrade.",
		"team_aftermath": "VARGA — Bravo ne répond plus. Ce silence reste une absence de contact, pas une confirmation de perte.",
	},
	{
		"id": "inspect_28_archive", "floor": 28, "position": Vector3(-5, 24, -8), "focus_offset": Vector3(0.55, 0.96, 0.25),
		"title": "Le dossier de maintenance", "category": "ARCHIVES · BUREAU", "source": "P29 / P30", "geometry": "archive",
		"usage": "Le dossier papier accompagne le poste informatique des archives. Il identifie les accès de service d’Aube sans dépendre de l’alimentation de l’écran.",
		"intact": "Un plan de circulation dépasse d’une chemise. Le noyau central relie les paliers ; la façade Est constitue une autre voie. Samuel attend de l’aide dans la partie Est des bureaux.",
		"aftermath": "Le plan est antérieur au choc. La voie Est du 28 est maintenant coupée par un élément tombé ; le passage intérieur contourne cet obstacle et rejoint Samuel.",
		"action_intact": "Rejoignez Samuel depuis le noyau. Après l’avoir sécurisé, ramenez-le à la balise orange du même étage.",
		"action_aftermath": "Depuis la balise, passez par l’intérieur et contournez l’obstacle du côté nord avant d’atteindre Samuel. Revenez par cette même voie avec lui.",
		"team_intact": "OBSERVATION D’ALEX — Le plan aide à lire les accès. Il ne remplace pas ce que je vois sur le palier.",
		"team_aftermath": "ÉQUIPE ALPHA — Le noyau reste ouvert. Ne cherchez pas à franchir les débris avec une personne sur les épaules.",
		"rescue_id": "survivor_28", "rescue_note": "Samuel Breton a été reçu au poste médical. Le détour reste disponible pour les passages suivants.",
		"rescued_intact": "Le plan de circulation dépasse toujours de sa chemise. Samuel a quitté les bureaux par la ligne de secours et sa réception au toit est confirmée.",
		"rescued_aftermath": "Le plan reste antérieur au choc : le passage Est est coupé, le détour intérieur reste ouvert. La réception de Samuel au toit est confirmée.",
		"rescued_action": "Rejoignez la balise par un passage dégagé. Vérifiez les secours encore attendus avant de poursuivre vers le refuge.",
	},
	{
		"id": "inspect_28_relay", "floor": 28, "position": Vector3(5.3, 24, -9.8), "focus_offset": Vector3(0, 1.15, 0),
		"title": "Le boîtier radio de palier", "category": "TRANSMISSIONS", "source": "P22", "geometry": "relay",
		"usage": "Ce boîtier repère le réseau de communication du palier. Sa fiche distingue le poste Alpha, installé sur Aube, de l’équipe Bravo engagée dans Hespérie.",
		"intact": "La fiche de réseau est encore lisible : Alpha sur Aube, Bravo sur Hespérie. Le poste du toit accompagne les évacuations par le puits.",
		"aftermath": "Le réseau est dégradé après le choc. Le boîtier ne donne aucune confirmation sur Bravo ; le poste d’Aube poursuit les consignes de secours.",
		"action_intact": "Utilisez R pour appeler le commandement. La consultation du boîtier ne change ni le canal ni la portée de votre radio.",
		"action_aftermath": "Utilisez R depuis un appui sûr pour rappeler le poste. Poursuivez la route intérieure du 28 en suivant les consignes reçues.",
		"team_intact": "VARGA — Identifiez toujours la tour et l’équipe qui parlent. Nous recevons les rescapés sur Aube.",
		"team_aftermath": "ÉQUIPE ALPHA — Un indicateur matériel ne vaut pas une réponse humaine. Aucune intervention sur ce boîtier n’est demandée.",
	},
	{
		"id": "inspect_27_locker", "floor": 27, "position": Vector3(-6.9, 18, -9.5), "focus_offset": Vector3(0, 1.18, 0),
		"title": "L’étiquette du jardin", "category": "JARDIN DES MARÉES", "source": "P32", "geometry": "locker",
		"usage": "Les petits casiers gardent les affaires du Jardin des Marées. Une étiquette sert à reconnaître une place ; elle n’est pas un signal de présence.",
		"intact": "Une étiquette dessinée à la main est glissée dans son porte-nom. Le prénom s’est effacé. Aucun appel ne vient de ce casier.",
		"aftermath": "Le porte-nom est toujours fixé après la secousse. La rangée demeure silencieuse. Rien dans cette étiquette ne permet d’ajouter un enfant au registre des personnes à secourir.",
		"action_intact": "Observez le jardin depuis ses passages dégagés. Les personnes signalées aux étages 30, 28 et 26 restent la priorité tant que leur réception au toit n’est pas confirmée.",
		"action_aftermath": "Continuez vers le spa au 26 si Nora n’a pas encore été évacuée. Le jardin reste une étape de lecture entre les secours.",
		"team_intact": "OBSERVATION D’ALEX — Ce lieu a servi à des enfants. Je conserve cette trace sans lui inventer un témoin.",
		"team_aftermath": "ÉQUIPE ALPHA — Les noms du poste médical viennent des personnes réellement rencontrées, pas des étiquettes du mobilier.",
	},
	{
		"id": "inspect_26_filtration", "floor": 26, "position": Vector3(-9.7, 12, 3.8), "focus_offset": Vector3(0, 1.3, 0),
		"title": "Le manomètre de filtration", "category": "SPA · LOCAL TECHNIQUE", "source": "P38", "geometry": "filtration",
		"usage": "La plaque identifie les conduites du bassin et leur filtration. Le cadran renseigne sur cette installation ; il ne mesure pas votre réserve d’air.",
		"intact": "Le cadran est figé sous son verre. La plaque relie les conduites au bassin, sans indiquer l’état de la pièce entière. Nora attend de l’aide de l’autre côté du spa.",
		"aftermath": "Après le choc, aucune nouvelle mesure n’est certifiée sur cette installation. Le bassin et les conduites ne constituent pas la route de retour vers le puits.",
		"action_intact": "Gardez la lampe disponible avec F. Si la silhouette se rapproche, une fusée avec G la fait reculer. Secourez Nora puis ramenez-la à la balise.",
		"action_aftermath": "Traversez par les espaces secs et dégagés. Gardez la lampe et les fusées pour la silhouette ; la consultation du cadran ne la repousse pas.",
		"team_intact": "ÉQUIPE ALPHA — Ce cadran appartient au réseau d’eau. Pour votre progression, surveillez la visibilité et la réserve affichée au harnais.",
		"team_aftermath": "VARGA — Pas d’intervention sur la filtration. Notre priorité reste la personne à évacuer et votre trajet vers la ligne.",
		"rescue_id": "survivor_26", "rescue_note": "Nora Haddad a été reçue au poste médical. Le spa n’attend plus son évacuation.",
		"rescued_intact": "Le cadran reste figé sous son verre. Nora a été évacuée et sa réception au toit est confirmée ; le réseau du bassin n’a pas été modifié.",
		"rescued_aftermath": "Nora est au poste médical. Aucune nouvelle mesure n’est certifiée sur la filtration après le choc ; le trajet sec vers le puits reste votre repère.",
		"rescued_action": "Rejoignez le puits sans traverser le bassin. La silhouette peut encore occuper le spa ; conservez lampe et fusées pour votre passage.",
	},
	{
		"id": "inspect_25_atmosphere", "floor": 25, "position": Vector3(4.7, 6, -9.5), "focus_offset": Vector3(0, 1.18, 0),
		"title": "Le contrôle du refuge", "category": "REFUGE · ATMOSPHÈRE", "source": "P42", "geometry": "atmosphere",
		"usage": "Le poste de contrôle identifie le refuge comme zone sûre. Cette indication décrit ce local ; elle est distincte de la quantité d’air restant dans votre réserve.",
		"intact": "Le support porte la mention REFUGE et un indicateur de contrôle. Le palier offre un appui calme, à distance des fumées du parcours.",
		"aftermath": "Le refuge reste sûr après l’incident. Son état ne confirme pas celui des autres étages : une pièce sûre ne rend pas toute la tour praticable.",
		"action_intact": "Utilisez le refuge pour vous orienter, puis rejoignez les secours encore en attente. Le terminal consigne la situation de l’intervention.",
		"action_aftermath": "Après les trois réceptions médicales, rejoignez le terminal du refuge pour établir le bilan. Une consultation de ce support ne valide pas le bilan à sa place.",
		"team_intact": "POSTE D’AUBE — Le refuge est un point d’appui. Les bouteilles visibles dans la pièce ne sont pas toutes des recharges disponibles.",
		"team_aftermath": "POSTE D’AUBE — Nous conservons un lieu calme pour le compte rendu. Les secours confirmés restent inscrits au registre du toit.",
	},
	{
		"id": "inspect_25_extinguisher", "floor": 25, "position": Vector3(10.4, 6, -2), "focus_offset": Vector3(0, 1.1, 0),
		"title": "Le poste incendie", "category": "REFUGE · MATÉRIEL FIXE", "source": "P43", "geometry": "extinguisher",
		"usage": "L’extincteur est rangé sur son support de service. Sa forme, sa poignée et son flexible le distinguent des bouteilles de réserve respiratoire.",
		"intact": "L’appareil est maintenu dans son support. Aucun foyer ne bloque le refuge et aucun prélèvement n’est demandé à ce poste.",
		"aftermath": "Le poste incendie reste en place après le choc. Il signale l’usage du local ; le passage au terminal demeure ouvert.",
		"action_intact": "Pour renouveler vos ressources, cherchez une caisse de secours. Ce support n’est pas une recharge d’air ni un objet à emporter.",
		"action_aftermath": "Gardez l’accès au terminal dégagé. Si les trois rescapés sont au toit, rejoignez-le pour faire le point avec le commandement.",
		"team_intact": "ÉQUIPE ALPHA — Gardez les fonctions du matériel distinctes : éclairer, signaler, respirer et protéger un local ne sont pas le même usage.",
		"team_aftermath": "POSTE D’AUBE — Rien à prélever ici pour conclure l’intervention. Le bilan dépend des secours accomplis.",
	},
]

static func catalogue() -> Array:
	return ENTRIES.duplicate(true)

static func read(id_value: String, context: Dictionary = {}) -> Dictionary:
	var record: Dictionary = {}
	for candidate: Dictionary in ENTRIES:
		if candidate["id"] == id_value:
			record = candidate
			break
	if record.is_empty():
		return {}
	var aftermath: bool = context.get("incident_state", "intact") == "aftermath"
	var phase: String = "aftermath" if aftermath else "intact"
	var rescued: Array = context.get("rescued", []) if context.get("rescued", []) is Array else []
	var observation: String = record[phase]
	var team_note: String = record["team_" + phase]
	var action: String = record["action_" + phase]
	var status_label: String = "APRÈS LE CHOC" if aftermath else "AVANT LE CHOC"
	if id_value == "inspect_roof_register":
		var confirmed: Array[String] = []
		var pending: Array[String] = []
		for patient: Array in PATIENTS:
			if rescued.has(patient[0]):
				confirmed.append(patient[1])
			else:
				pending.append(patient[1])
		status_label = "RÉCEPTIONS CONFIRMÉES · %d / 3" % confirmed.size()
		observation += "\n\nÀ l’abri au toit : %s." % (", ".join(confirmed) if not confirmed.is_empty() else "aucune réception confirmée")
		if not pending.is_empty():
			observation += "\nRéception encore attendue : %s." % ", ".join(pending)
		else:
			observation += "\nLes trois personnes sont prises en charge."
	var rescue_id: String = record.get("rescue_id", "")
	if not rescue_id.is_empty() and rescued.has(rescue_id):
		observation = record.get("rescued_" + phase, observation)
		action = record.get("rescued_action", action)
		team_note += "\n\n" + record.get("rescue_note", "")
	return {
		"id": record["id"], "title": record["title"], "category": record["category"],
		"floor": record["floor"], "floor_label": "TOIT D’AUBE" if record["floor"] == 31 else "ÉTAGE %02d" % record["floor"],
		"status_label": status_label, "usage": record["usage"], "observation": observation,
		"description": observation, "action": action, "team_note": team_note,
	}

func build(parent: Node3D) -> Array[Node3D]:
	var previous: Node = parent.get_node_or_null(GROUP_NAME)
	if is_instance_valid(previous):
		previous.free()
	var group: Node3D = Node3D.new()
	group.name = GROUP_NAME
	parent.add_child(group)
	var materials: Dictionary = _materials()
	var points: Array[Node3D] = []
	for entry: Dictionary in ENTRIES:
		var point: Node3D = Node3D.new()
		point.name = entry["id"]
		point.position = entry["position"]
		point.set_meta("kind", "inspect")
		point.set_meta("id", entry["id"])
		point.set_meta("floor", entry["floor"])
		point.set_meta("title", entry["title"])
		point.set_meta("description", entry["usage"])
		point.set_meta("focus_offset", entry["focus_offset"])
		point.set_meta("range", RANGE)
		point.set_meta("used", false)
		group.add_child(point)
		_dress(point, entry["geometry"], materials)
		points.append(point)
	return points

func _materials() -> Dictionary:
	return {
		"metal": _material(Color(0.16, 0.22, 0.24), 0.6),
		"dark": _material(Color(0.035, 0.07, 0.085), 0.15),
		"paper": _material(Color(0.82, 0.79, 0.66)),
		"white": _material(Color(0.87, 0.88, 0.81)),
		"teal": _material(Color(0.17, 0.55, 0.51)),
		"amber": _material(Color(0.85, 0.48, 0.12)),
		"red": _material(Color(0.58, 0.12, 0.095), 0.25),
		"light": _material(Color(0.3, 0.78, 0.63), 0.05, 0.35),
	}

func _dress(point: Node3D, geometry: String, m: Dictionary) -> void:
	match geometry:
		"register":
			_stand(point, 1.34, Vector2(0.8, 0.55), m)
			_clipboard(point, Vector3(0, 1.36, 0.03), Vector2(0.65, 0.43), m)
			_plate(point, Vector3(0, 1.17, 0.3), "MÉDICAL", 0.62, m)
		"winch":
			_stand(point, 1.13, Vector2(0.7, 0.52), m)
			_clipboard(point, Vector3(0, 1.15, 0), Vector2(0.5, 0.4), m)
			_plate(point, Vector3(0, 0.97, 0.29), "LIGNE AUBE", 0.63, m)
			_box(point, Vector3(-0.24, 1.19, 0.13), Vector3(0.025, 0.025, 0.22), m.amber)
		"table":
			_cylinder(point, Vector3(0, 1.075, 0.3), 0.22, 0.025, m.white)
			_box(point, Vector3(0, 1.095, 0.3), Vector3(0.23, 0.02, 0.19), m.paper)
			_box(point, Vector3(-0.3, 1.08, 0.3), Vector3(0.025, 0.02, 0.28), m.metal)
			_box(point, Vector3(0.3, 1.08, 0.3), Vector3(0.025, 0.02, 0.28), m.metal)
			_clipboard(point, Vector3(0.48, 1.0725, -0.28), Vector2(0.22, 0.32), m)
			_cylinder(point, Vector3(-0.35, 1.175, -0.15), 0.065, 0.23, m.white)
		"service":
			_box(point, Vector3(0, 1.54, 0.38), Vector3(0.7, 0.055, 0.42), m.teal)
			_clipboard(point, Vector3(0, 1.58, 0.4), Vector2(0.61, 0.33), m)
			_box(point, Vector3(0.4, 1.57, 0.37), Vector3(0.025, 0.025, 0.23), m.amber)
		"luggage":
			_box(point, Vector3(0, 0.711, 0), Vector3(0.075, 0.02, 0.81), m.metal)
			_box(point, Vector3(0.29, 0.728, 0.28), Vector3(0.24, 0.015, 0.16), m.paper)
			_box(point, Vector3(0.29, 0.739, 0.28), Vector3(0.14, 0.006, 0.025), m.dark)
			_box(point, Vector3(-0.14, 0.78, -0.18), Vector3(0.04, 0.14, 0.04), m.metal)
			_box(point, Vector3(0.14, 0.78, -0.18), Vector3(0.04, 0.14, 0.04), m.metal)
			_box(point, Vector3(0, 0.84, -0.18), Vector3(0.31, 0.04, 0.04), m.dark)
		"glazing":
			_stand(point, 1.2, Vector2(0.4, 0.3), m)
			_box(point, Vector3(0, 1.36, 0), Vector3(0.32, 0.3, 0.075), m.metal)
			_plate(point, Vector3(0, 1.38, 0.042), "BAIE EST", 0.3, m)
			_box(point, Vector3(0, 1.28, 0.05), Vector3(0.23, 0.018, 0.02), m.amber)
		"archive":
			_box(point, Vector3(0.55, 0.925, 0.25), Vector3(0.61, 0.04, 0.5), m.teal)
			_clipboard(point, Vector3(0.56, 0.955, 0.25), Vector2(0.52, 0.43), m)
			_box(point, Vector3(0.56, 0.967, 0.25), Vector3(0.021, 0.006, 0.32), m.amber)
			_box(point, Vector3(0.56, 0.967, 0.25), Vector3(0.37, 0.006, 0.021), m.amber)
		"relay":
			_stand(point, 0.94, Vector2(0.48, 0.38), m)
			_box(point, Vector3(0, 1.13, 0), Vector3(0.38, 0.35, 0.25), m.metal)
			_box(point, Vector3(0, 1.16, 0.135), Vector3(0.29, 0.2, 0.025), m.dark)
			_plate(point, Vector3(0, 1.18, 0.153), "ALPHA", 0.27, m)
			_cylinder(point, Vector3(-0.12, 1.55, 0), 0.012, 0.5, m.dark)
			_cylinder(point, Vector3(0.13, 1.01, 0.155), 0.032, 0.025, m.amber).rotation.x = PI / 2.0
		"locker":
			_box(point, Vector3(0, 1.18, -0.047), Vector3(0.6, 0.2, 0.035), m.metal)
			_box(point, Vector3(0, 1.18, -0.025), Vector3(0.53, 0.14, 0.012), m.paper)
			_box(point, Vector3(0.03, 1.18, -0.013), Vector3(0.24, 0.018, 0.008), m.teal)
			_box(point, Vector3(-0.19, 1.18, -0.013), Vector3(0.045, 0.085, 0.008), m.amber)
		"filtration":
			_box(point, Vector3(0, 0.13, 0), Vector3(0.7, 0.26, 0.55), m.dark)
			_cylinder(point, Vector3(0, 0.64, 0), 0.09, 0.9, m.metal)
			_cylinder(point, Vector3(0, 1.2, 0), 0.23, 0.12, m.metal).rotation.x = PI / 2.0
			_cylinder(point, Vector3(0, 1.2, 0.071), 0.19, 0.025, m.paper).rotation.x = PI / 2.0
			_box(point, Vector3(0.045, 1.235, 0.091), Vector3(0.12, 0.018, 0.01), m.dark).rotation.z = 0.55
			_plate(point, Vector3(0, 0.85, 0.11), "BASSIN", 0.46, m)
		"atmosphere":
			_stand(point, 0.96, Vector2(0.46, 0.34), m)
			_box(point, Vector3(0, 1.16, 0), Vector3(0.25, 0.35, 0.14), m.amber)
			_box(point, Vector3(0, 1.2, 0.08), Vector3(0.2, 0.13, 0.025), m.dark)
			_box(point, Vector3(0, 1.21, 0.096), Vector3(0.14, 0.06, 0.008), m.light)
			_cylinder(point, Vector3(0, 1.07, 0.084), 0.035, 0.015, m.dark).rotation.x = PI / 2.0
			_plate(point, Vector3(0, 0.88, 0.2), "REFUGE", 0.42, m)
		"extinguisher":
			_box(point, Vector3(0, 0.05, 0), Vector3(0.52, 0.1, 0.42), m.dark)
			_box(point, Vector3(0, 0.76, -0.12), Vector3(0.39, 1.42, 0.07), m.metal)
			_cylinder(point, Vector3(0, 0.66, 0.04), 0.14, 0.7, m.red)
			_cylinder(point, Vector3(0, 1.02, 0.04), 0.06, 0.09, m.metal)
			_box(point, Vector3(0, 1.1, 0.04), Vector3(0.22, 0.045, 0.08), m.dark)
			_box(point, Vector3(0.18, 0.87, 0.04), Vector3(0.035, 0.43, 0.04), m.dark).rotation.z = 0.2
			_box(point, Vector3(0, 0.71, 0.179), Vector3(0.16, 0.24, 0.015), m.white)
			_plate(point, Vector3(0, 1.3, -0.075), "INCENDIE", 0.35, m)

func _stand(parent: Node3D, height: float, top: Vector2, m: Dictionary) -> void:
	_box(parent, Vector3(0, 0.035, 0), Vector3(top.x * 0.8, 0.07, top.y * 0.8), m.dark)
	_box(parent, Vector3(0, height / 2.0, 0), Vector3(0.06, height, 0.06), m.metal)
	_box(parent, Vector3(0, height, 0), Vector3(top.x, 0.035, top.y), m.metal)

func _clipboard(parent: Node3D, position: Vector3, size_value: Vector2, m: Dictionary) -> void:
	_box(parent, position, Vector3(size_value.x, 0.015, size_value.y), m.paper)
	_box(parent, position + Vector3(0, 0.016, -size_value.y * 0.4), Vector3(size_value.x * 0.3, 0.018, 0.04), m.metal)
	for line in range(4):
		_box(parent, position + Vector3(0, 0.01, size_value.y * (-0.2 + line * 0.14)), Vector3(size_value.x * (0.7 if line < 3 else 0.45), 0.004, 0.008), m.dark)

func _plate(parent: Node3D, position: Vector3, text: String, width: float, m: Dictionary) -> void:
	_box(parent, position, Vector3(width, 0.1, 0.016), m.dark)
	var label: Label3D = Label3D.new()
	label.position = position + Vector3(0, 0, 0.011)
	label.text = text
	label.font = preload("res://assets/fonts/OpenSans-CondBold.ttf")
	label.font_size = 28
	label.pixel_size = minf(width / maxf(text.length() * 18.0, 1.0), 0.002)
	label.modulate = Color(0.8, 0.85, 0.8)
	label.outline_size = 0
	label.no_depth_test = false
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	parent.add_child(label)

func _material(color: Color, metallic: float = 0.0, emission: float = 0.0) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = color
	material.metallic = metallic
	material.roughness = 0.72
	if emission > 0.0:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = emission
	return material

func _box(parent: Node3D, position: Vector3, size_value: Vector3, material: Material) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var shape: BoxMesh = BoxMesh.new()
	shape.size = size_value
	mesh.mesh = shape
	mesh.material_override = material
	mesh.position = position
	parent.add_child(mesh)
	return mesh

func _cylinder(parent: Node3D, position: Vector3, radius: float, height: float, material: Material) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var shape: CylinderMesh = CylinderMesh.new()
	shape.top_radius = radius
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = 16
	shape.rings = 1
	mesh.mesh = shape
	mesh.material_override = material
	mesh.position = position
	parent.add_child(mesh)
	return mesh
