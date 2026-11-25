extends RefCounted
class_name DescentMissionDossier
## Read-only projection of a mission snapshot. No I/O, random draws or clocks.
## In particular, an attached casualty is never counted as a confirmed rescue.
const Routes = preload("res://scripts/route_catalog.gd")
const Continuation = preload("res://scripts/continuation_director.gd")
const Equipment = preload("res://scripts/equipment_director.gd")

const ROSTER: Array = [
	{"id": "survivor_30", "name": "Ana Rios", "floor": 30, "location": "Restaurant panoramique"},
	{"id": "survivor_28", "name": "Samuel Breton", "floor": 28, "location": "Archives Pelagos"},
	{"id": "survivor_26", "name": "Nora Haddad", "floor": 26, "location": "Spa de Nacre"}
]
const FLOOR_NAMES: Dictionary = {31: "Poste du toit", 30: "Restaurant", 29: "Suites", 28: "Archives", 27: "Jardin", 26: "Spa", 25: "Refuge", 24: "Congrès", 23: "Exposition"}
const CONTINUATION_CLUES: Dictionary = {
	"continuation_model_23": {"floor": 23, "title": "Maquette des volumes enfouis", "text": "La maquette historique relie les fondations d’Aube et d’Hespérie à des galeries sous la mer. Le plan touristique actuel s’arrête aux parkings. Deux versions du même site : les volumes ont été retirés du plan récent, pas de la maquette."},
	"continuation_photo_23": {"floor": 23, "title": "Photographie des anciens bains de Nacre", "text": "Sur la photographie des bains antérieurs aux tours, une porte à double arc porte une entaille verticale. La même silhouette apparaît sur le dessin du jardin d’enfants. Le cliché précède la construction de Pelagos ; la coïncidence est désormais un constat à vérifier."}
}
const CLUE_FLOORS: Array[int] = [29, 27, 26]
const TABS: Array[String] = ["situation", "survivors", "clues", "transmissions"]
const TAB_TITLES: Dictionary = {"situation": "SITUATION", "survivors": "RESCAPÉS", "clues": "INDICES", "transmissions": "TRANSMISSIONS"}
const MAX_TRANSMISSIONS: int = 32


static func build(snapshot: Dictionary) -> Dictionary:
	var continuation = Continuation.new()
	var continuation_value: Dictionary = Continuation.normalize(snapshot.get("continuation", continuation.snapshot()))
	if not continuation_value.is_empty():
		continuation.state = continuation_value
	var extended: bool = continuation.phase != "dormant"
	var floor_number: int = int(_number(snapshot, "floor", 31, 23 if extended else 25, 31))
	var checkpoint: int = int(_number(snapshot, "checkpoint_floor", floor_number, 23 if extended else 25, 31))
	var elapsed: float = _number(snapshot, "elapsed", 0, 0, 315360000)
	var rescued: Array[String] = _ids(snapshot.get("rescued", []), ["survivor_30", "survivor_28", "survivor_26"])
	var allowed_clues: Array = ["evidence_29", "evidence_27", "evidence_26"]
	if extended:
		allowed_clues.append_array(CONTINUATION_CLUES.keys())
	var clues: Array[String] = _ids(snapshot.get("clues", []), allowed_clues)
	var supplies: Array[String] = _ids(snapshot.get("supplies_used", []), ["supply_29", "supply_25"])
	var equipment_ids: Array[String] = _ids(snapshot.get("supplies_used", []), Equipment.ACTIONS.keys())
	var complete: bool = snapshot.get("completed", false) is bool and snapshot.get("completed", false)
	var carried_id: String = _string(snapshot.get("carried_id", ""), 80)
	var hoisting_id: String = _string(snapshot.get("hoisting_id", ""), 80)
	var phase: String = _string(snapshot.get("incident_state", "intact"), 32)
	var survivors: Array[Dictionary] = []
	for person: Dictionary in ROSTER:
		var row: Dictionary = person.duplicate(true)
		row["confirmed"] = person["id"] in rescued
		row["status"] = "À SECOURIR"
		row["detail"] = "Signal confirmé au %d · %s." % [person["floor"], person["location"]]
		if row["confirmed"]:
			row["status"] = "À L’ABRI"
			row["detail"] = "réception confirmée au poste d’Aube."
		elif person["id"] == hoisting_id:
			row["status"] = "AU TREUIL"
			row["detail"] = "Remontée en cours. Attendre la réception du toit."
		elif person["id"] == carried_id:
			row["status"] = "AU HARNAIS"
			row["detail"] = "Prise en charge en cours. Rejoindre la balise orange du %d." % int(person["floor"])
		survivors.append(row)
	if extended:
		for person_name: String in ["Léa Mercier", "Idris Kaci"]:
			var received: bool = continuation.escort_state == "received"
			survivors.append({"id": "continuation_lea" if person_name == "Léa Mercier" else "continuation_idris", "name": person_name, "floor": 24, "location": "Centre de congrès", "confirmed": received,
				"status": "AU REFUGE 25" if received else ("ACCOMPAGNEMENT ENGAGÉ" if continuation.duo_briefed else "À REJOINDRE"),
				"detail": "Réception physique confirmée au relais du 25." if received else "Cabine d’interprétation du 24. Consignes visuelles et escalier de service vers le refuge ; la réception reste à confirmer."})

	var collected_records: Dictionary = {}
	var raw_records: Variant = snapshot.get("clue_records", [])
	if raw_records is Array:
		for value: Variant in raw_records:
			if not value is Dictionary:
				continue
			var id_value: String = _string(value.get("id", ""), 80)
			# The collected-ID registry decides disclosure even if a caller passes
			# every floor specification or a tampered duplicate record.
			if id_value in clues and not collected_records.has(id_value):
				collected_records[id_value] = {"title": _string(value.get("title", ""), 240), "text": _string(value.get("text", ""), 6000)}
	var evidence: Array[Dictionary] = []
	for level: int in CLUE_FLOORS:
		var id_value: String = "evidence_%d" % level
		var collected: bool = id_value in clues
		var record: Dictionary = collected_records.get(id_value, {})
		var title: String = str(record.get("title", "")) if collected else "DOCUMENT NON RÉCUPÉRÉ"
		var body: String = str(record.get("text", "")) if collected else "Le contenu reste inconnu. Les documents à recueillir sont signalés par une lueur bleue."
		if collected and title.is_empty():
			title = "Document récupéré au %d" % level
		if collected and body.is_empty():
			body = "Pièce inscrite au compte rendu. Son texte n’est pas disponible dans cet instantané."
		evidence.append({"id": id_value, "floor": level, "collected": collected, "title": title, "text": body})
	if extended:
		for id_value: String in CONTINUATION_CLUES:
			var collected: bool = id_value in clues
			var record: Dictionary = collected_records.get(id_value, {})
			evidence.append({"id": id_value, "floor": 23, "collected": collected,
				"title": str(record.get("title", "Relevé de l’exposition")) if collected else "PIÈCE NON RELEVÉE",
				"text": str(record.get("text", "Pièce inscrite au compte rendu.")) if collected else "Examinez les pièces de l’exposition pour en relever le contenu. Aucun constat n’est encore inscrit."})

	var transmissions: Array[Dictionary] = _transmissions(snapshot.get("transmissions", []))
	var route: Array[Dictionary] = []
	var visited: Variant = snapshot.get("seen_floors", [])
	var floor_list: Array = [31, 30, 29, 28, 27, 26, 25, 24, 23] if extended else [31, 30, 29, 28, 27, 26, 25]
	for level: int in floor_list:
		var seen: bool = false
		if visited is Array:
			for value: Variant in visited:
				if value is int and value == level:
					seen = true
					break
		route.append({"floor": level, "title": FLOOR_NAMES[level], "current": level == floor_number, "seen": seen, "confirmed": "survivor_%d" % level in rescued})
	var situation: Dictionary = _structural_situation(phase)
	var current_link: Dictionary = Routes.for_id(_string(snapshot.get("traversal_id", ""), 32))
	var result: Dictionary = {
		"seed": int(_number(snapshot, "seed", 271104, 1, 999999)), "floor": floor_number,
		"checkpoint_floor": checkpoint, "location": FLOOR_NAMES[floor_number],
		"elapsed": elapsed, "duration": format_time(elapsed), "completed": complete,
		"replay_available": complete and rescued.size() == 3 and not extended,
		"continuation_available": complete and rescued.size() == 3 and not extended and floor_number == 25 and phase == "aftermath",
		"continuation_phase": continuation.phase, "continuation_objective": continuation.objective(),
		"total_received": rescued.size() + (2 if extended and continuation.escort_state == "received" else 0),
		"roster_total": 5 if extended else 3, "evidence_total": 5 if extended else 3,
		"health": _number(snapshot, "health", 100, 0, 100), "oxygen": _number(snapshot, "oxygen", 100, 0, 100),
		"stress": _number(snapshot, "stress", 8, 0, 100), "anchors": int(_number(snapshot, "anchors", 4, 0, 8)),
		"flares": int(_number(snapshot, "flares", 3, 0, 6)), "supplies_count": supplies.size(),
		"equipment_events": equipment_ids, "equipment_charges": 2 if "equipment_fire_28" in equipment_ids else 3,
		"rescued_count": rescued.size(), "clue_count": clues.size(), "survivors": survivors,
		"clues": evidence, "transmissions": transmissions, "route": route,
		"structure_title": situation["title"], "structure_text": situation["text"], "incident_state": phase,
		"relay_title": "SIGNAL DU RELAIS · ORIGINE NON CONFIRMÉE" if complete else "LIAISON DE SECOURS",
		"relay_text": "Le relais du refuge accroche un fragment attribué à Bravo :\n\n« Nous sommes au 24. Il y a de la lumière dessous. »\n\nUne voix d’enfant suit le signal. L’origine et l’heure de cette émission restent à vérifier. Ce fragment ne confirme ni un contact en direct, ni le sort de l’équipe." if complete else "Le poste d’Aube coordonne les secours. Les mots reçus sont consignés dans les transmissions ; leur présence au journal ne prouve pas à elle seule la situation de leur source."
	}
	if extended:
		result["relay_title"] = "RECONNAISSANCE A24–A23 · COMPTE RENDU" if complete else "RELAIS DU REFUGE A25"
		result["relay_text"] = "Léa Mercier et Idris Kaci ont rejoint le refuge 25. La maquette des souterrains et la photographie des anciens bains ont été relevées. Les premiers secours restent au toit.\n\nCes deux constats ne confirment pas le sort de Bravo. Les galeries représentées restent à trouver ; la descente vers le 22 n’est pas encore ouverte." if complete else continuation.objective() + "\n\nLes trois réceptions de l’intervention supérieure restent acquises. Les signes visibles accompagnent chaque consigne à Léa et Idris."
	result["traversal_id"] = str(current_link.get("id", ""))
	if not current_link.is_empty():
		result["location"] = str(current_link["title"])
	result["pages"] = {
		"situation": _situation_text(result), "survivors": _survivors_text(survivors),
		"clues": _clues_text(evidence), "transmissions": _transmissions_text(transmissions)
	}
	return result


static func format_time(seconds: float) -> String:
	var safe: int = int(clampf(seconds, 0.0, 315360000.0)) if is_finite(seconds) else 0
	var hours: int = safe / 3600
	if hours > 0:
		return "%02d:%02d:%02d" % [hours, (safe / 60) % 60, safe % 60]
	return "%02d:%02d" % [safe / 60, safe % 60]


static func _situation_text(model: Dictionary) -> String:
	var mission: String = "INTERVENTION TERMINÉE\nLes réceptions confirmées sont conservées au poste du toit. Le refuge 25 reste votre point sûr." if model["completed"] else "PRIORITÉ DE L’INTERVENTION\nSecourir Ana au 30, Samuel au 28 et Nora au 26, puis rejoindre le relais du refuge 25. Les treuils ramènent les personnes au poste d’Aube."
	if model.get("continuation_phase", "dormant") != "dormant":
		mission = ("RECONNAISSANCE A24–A23 TERMINÉE\n" if model["completed"] else "RECONNAISSANCE A24–A23\n") + str(model["continuation_objective"])
	var text: String = mission + "\n\n" + str(model["structure_title"]) + "\n" + str(model["structure_text"])
	text += "\n\nPERSONNES PRISES EN CHARGE · %d / %d À L’ABRI\n" % [model["total_received"], model["roster_total"]]
	for row: Dictionary in model["survivors"]:
		text += "%s — %s\n%s\n" % [row["name"], row["status"], row["detail"]]
	text += "\nRESSOURCES À CET INSTANT\nÉtat physique %d %% · Air %d %% · Tension %d %%\nAncrages %d · Fusées %d · Réserves ouvertes %d / 2\n" % [roundi(model["health"]), roundi(model["oxygen"]), roundi(model["stress"]), model["anchors"], model["flares"], model["supplies_count"]]
	text += "\nMATÉRIEL D’INTERVENTION\n1 Hache · 2 Extincteur · 3 Halligan · 4 Coupe-boulon\nRéserve de l’extincteur %d / 3 · Travaux terminés %d / %d\n" % [model["equipment_charges"], model["equipment_events"].size(), 4 if model.get("continuation_phase", "dormant") != "dormant" else 3]
	for id: String in model["equipment_events"]:
		text += "ÉTAGE %d · %s\n" % [Equipment.ACTIONS[id]["floor"], Equipment.ACTIONS[id]["title"]]
	text += "\nPOINT SÛR\n%s · %s. La consultation ne remplace pas ce point de reprise.\n" % [_floor_label(model["checkpoint_floor"]), FLOOR_NAMES[model["checkpoint_floor"]]]
	text += "\nPASSAGES ENTRE LES ÉTAGES\nChaque liaison est réversible et limitée à deux niveaux. Les repères bleus indiquent les rappels personnels ; les balises orange servent au treuil des rescapés.\n"
	for link: Dictionary in Routes.all_routes(model.get("continuation_phase", "dormant") != "dormant"):
		text += "%s%s\n" % ["EN COURS · " if str(link["id"]) == str(model.get("traversal_id", "")) else "", str(link["title"])]
	text += "Espace verrouille le descendeur ; relâcher les touches freine. Reposez-vous assuré avant de remonter. Une reprise charge un palier stable, jamais le milieu d’une corde ou d’un escalier.\n"
	text += "\nTRANSMISSIONS REÇUES · DERNIERS ÉCHANGES\n"
	var history: Array = model["transmissions"]
	if history.is_empty():
		text += "Aucune transmission enregistrée dans ce point de reprise."
	else:
		for index in range(maxi(0, history.size() - 3), history.size()):
			text += _transmission_text(history[index]) + "\n"
		text += "L’onglet Transmissions présente tout l’historique conservé."
	return text


static func _survivors_text(survivors: Array[Dictionary]) -> String:
	var text: String = "Une personne portée ou au treuil attend encore la confirmation du poste médical.\n\n"
	for row: Dictionary in survivors:
		text += "%s\n%s · ÉTAGE %d\n%s\n%s\n\n" % [str(row["name"]).to_upper(), row["location"], row["floor"], row["status"], row["detail"]]
	text += "Ana, Samuel et Nora restent au poste du toit après leur réception. Léa et Idris restent au refuge 25 après leur accueil ; une escorte interrompue les remet à l’abri dans la cabine du 24. Aucun transfert en cours n’est restauré à mi-course."
	return text


static func _clues_text(evidence: Array[Dictionary]) -> String:
	var text: String = "Les constats recueillis sont conservés tels qu’ils ont été trouvés. Leur interprétation reste ouverte.\n\n"
	for record: Dictionary in evidence:
		text += "ÉTAGE %d · %s\n%s\n%s\n\n" % [record["floor"], "RÉCUPÉRÉ" if record["collected"] else "À EXAMINER", record["title"], record["text"]]
	return text


static func _transmissions_text(transmissions: Array[Dictionary]) -> String:
	var text: String = "TRANSMISSIONS REÇUES\nLes %d derniers échanges au maximum sont conservés, dans l’ordre de réception. Les horodatages indiquent le temps de mission.\n\n" % MAX_TRANSMISSIONS
	if transmissions.is_empty():
		return text + "Aucune transmission enregistrée dans ce point de reprise."
	for record: Dictionary in transmissions:
		text += _transmission_text(record) + "\n"
	return text


static func _transmission_text(record: Dictionary) -> String:
	return "[%s] %s\n%s\n" % [format_time(record["elapsed"]), record["speaker"], record["message"]]


static func _structural_situation(phase: String) -> Dictionary:
	if phase == "aftermath":
		return {"title": "APRÈS L’IMPACT", "text": "Hespérie reste appuyée contre Aube. Le passage Est du 28 est condamné : emprunter le détour intérieur. Le noyau, le treuil et le poste d’Aube restent opérationnels. Bravo ne répond plus ; son sort n’est pas confirmé."}
	if phase in ["warning", "quake", "collapse", "impact", "alert", "shaking", "falling"]:
		return {"title": "RÉPLIQUE EN COURS", "text": "Éloignez-vous des vitres et restez près du noyau. Le treuil et les passages intérieurs tiennent. Le point sûr précédant la secousse reste la référence jusqu’à la stabilisation."}
	return {"title": "DEUX TOURS DEBOUT", "text": "Alpha intervient sur Aube ; Bravo vérifie des signaux dans Hespérie. Après la réception d’Ana au 30, rejoindre la baie Est du 29 pour établir le contact visuel. Les hélicoptères attendent une accalmie."}


static func _floor_label(value: int) -> String:
	return "Toit" if value == 31 else "Étage %d" % value


static func _number(data: Dictionary, key: String, fallback: float, minimum: float, maximum: float) -> float:
	var value: Variant = data.get(key, fallback)
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(value)):
		return fallback
	return clampf(float(value), minimum, maximum)


static func _string(value: Variant, limit: int) -> String:
	return value.left(limit) if value is String else ""


static func _ids(value: Variant, allowed: Array) -> Array[String]:
	var result: Array[String] = []
	if value is Array:
		for item: Variant in value:
			if item is String and item in allowed and item not in result:
				result.append(item)
	return result


static func _transmissions(value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not value is Array:
		return result
	for item: Variant in value:
		if not item is Dictionary:
			continue
		var speaker: String = _string(item.get("speaker", ""), 120)
		var message: String = _string(item.get("message", ""), 1200)
		var time: Variant = item.get("elapsed", -1.0)
		if speaker.strip_edges().is_empty() or message.strip_edges().is_empty() or typeof(time) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(time)) or float(time) < 0.0:
			continue
		result.append({"speaker": speaker, "message": message, "elapsed": minf(float(time), 315360000.0)})
		if result.size() > MAX_TRANSMISSIONS:
			result.pop_front()
	return result
