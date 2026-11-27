class_name FloorGenerator
extends RefCounted
## Pure, repeatable content selection for the playable six-floor vertical slice.
## Geometry and player progression consume these specifications separately.

const GENERATION_VERSION: int = 1
const FLOOR_NUMBERS: Array[int] = [30, 29, 28, 27, 26, 25]
const THEMES: Array[String] = ["restaurant", "hotel", "office", "nursery", "spa", "refuge"]
const NAMES: Array[String] = [
	"Le Belvédère — restaurant panoramique",
	"Les Suites de Nacre",
	"Bureaux et archives Pelagos",
	"Le Jardin des Marées — accueil enfants",
	"Les Bains Suspendus — spa et piscine",
	"Refuge technique A25"
]
const HAZARDS: Array[String] = ["none", "smoke", "water", "unstable"]
const ANOMALIES: Array[String] = ["none", "footsteps", "radio", "figure"]
const SURVIVOR_NAMES: Dictionary = {
	30: "Ana Rios",
	28: "Samuel Breton",
	26: "Nora Haddad"
}
const EVIDENCE: Dictionary = {
	29: {
		"title": "Chambre 2908",
		"text": "Le client a appelé trois fois pour un bruit de pas au plafond. La chambre au-dessus était vide. Réponse de la direction, datée de six jours avant le typhon : « Ne pas mentionner la tour Hespérie. »"
	},
	27: {
		"title": "Le dessin des deux tours",
		"text": "Alma, 10 ans, a dessiné deux tours reliées sous la mer. Sous le dessin : « La dame dit mon prénom dans les tuyaux, mais maman ne l'entend pas. » Le papier a été accroché avant l'alerte météo."
	},
	26: {
		"title": "Relevé SILLAGE 06",
		"text": "Fiche technique oubliée derrière la pompe du spa : « Transmission acoustique non prévue vers les étages occupés. Réponse détectée sans source active. Continuer les mesures. Eva Sorel. » La dernière mesure précède le séisme de onze heures."
	}
}


static func generate(seed_value: int) -> Array:
	var floors: Array = []
	for index in range(FLOOR_NUMBERS.size()):
		var number: int = FLOOR_NUMBERS[index]
		var layout_rng: RandomNumberGenerator = _rng_for(seed_value, number, "layout")
		var props_rng: RandomNumberGenerator = _rng_for(seed_value, number, "props")
		var hazard_rng: RandomNumberGenerator = _rng_for(seed_value, number, "hazard")
		var anomaly_rng: RandomNumberGenerator = _rng_for(seed_value, number, "anomaly")
		var hazard: String = "none"
		var anomaly: String = "none"
		# Floor 27 is a deliberate breath in the pacing. The refuge is never unsafe.
		if number == 29 or number == 28:
			var choices: Array[String] = ["none", "smoke", "unstable"]
			hazard = choices[hazard_rng.randi_range(0, choices.size() - 1)]
			if anomaly_rng.randf() < 0.72:
				anomaly = "footsteps" if number == 29 else "radio"
		elif number == 26:
			hazard = "water" if hazard_rng.randf() < 0.75 else "none"
			anomaly = "figure"

		var record: Dictionary = EVIDENCE.get(number, {})
		floors.append({
			"number": number,
			"theme": THEMES[index],
			"name": NAMES[index],
			"safe": number == 25,
			"hazard": hazard,
			"survivor": SURVIVOR_NAMES.has(number),
			"evidence": EVIDENCE.has(number),
			"supplies": number == 29 or number == 25,
			"anomaly": anomaly,
			"layout_variant": layout_rng.randi_range(0, 2),
			"prop_seed": int(props_rng.randi()),
			"survivor_name": str(SURVIVOR_NAMES.get(number, "")),
			"evidence_title": str(record.get("title", "")),
			"evidence_text": str(record.get("text", ""))
		})
	return floors


static func _rng_for(seed_value: int, floor_number: int, channel: String) -> RandomNumberGenerator:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	# The hash separates adjacent user seeds and isolates each content channel.
	# Replay compatibility is tied to GENERATION_VERSION and the Godot version.
	rng.seed = ("tower-descent:%d:%d:%s:v%d" % [seed_value, floor_number, channel, GENERATION_VERSION]).hash()
	return rng


static func validate(floors: Array) -> Array[String]:
	var errors: Array[String] = []
	if floors.size() != FLOOR_NUMBERS.size():
		errors.append("Expected exactly six playable floor specifications.")
		return errors
	var expected_types: Dictionary = {
		"number": TYPE_INT, "theme": TYPE_STRING, "name": TYPE_STRING,
		"safe": TYPE_BOOL, "hazard": TYPE_STRING, "survivor": TYPE_BOOL,
		"evidence": TYPE_BOOL, "supplies": TYPE_BOOL, "anomaly": TYPE_STRING,
		"layout_variant": TYPE_INT, "prop_seed": TYPE_INT,
		"survivor_name": TYPE_STRING, "evidence_title": TYPE_STRING,
		"evidence_text": TYPE_STRING
	}
	var hostile_streak: int = 0
	for index in range(floors.size()):
		if not floors[index] is Dictionary:
			errors.append("Floor entry %d is not a dictionary." % index)
			continue
		var floor_data: Dictionary = floors[index]
		var schema_valid: bool = true
		for field in expected_types:
			if not floor_data.has(field) or typeof(floor_data[field]) != expected_types[field]:
				errors.append("Floor entry %d has a missing or invalid field: %s." % [index, field])
				schema_valid = false
		if not schema_valid:
			continue
		var number: int = floor_data["number"]
		if number != FLOOR_NUMBERS[index]:
			errors.append("Floor order must be 30, 29, 28, 27, 26, 25.")
		if floor_data["theme"] != THEMES[index]:
			errors.append("Floor %d has an incompatible architectural theme." % number)
		if str(floor_data["name"]).is_empty():
			errors.append("Floor %d has no readable name." % number)
		if not HAZARDS.has(floor_data["hazard"]) or not ANOMALIES.has(floor_data["anomaly"]):
			errors.append("Floor %d contains an unknown hazard or anomaly." % number)
		if int(floor_data["layout_variant"]) < 0 or int(floor_data["layout_variant"]) > 2:
			errors.append("Floor %d has an invalid layout variant." % number)
		if int(floor_data["prop_seed"]) < 0:
			errors.append("Floor %d has a negative prop seed." % number)
		if bool(floor_data["survivor"]) != SURVIVOR_NAMES.has(number):
			errors.append("The rescue roster must remain on floors 30, 28 and 26.")
		if bool(floor_data["survivor"]) and str(floor_data["survivor_name"]).is_empty():
			errors.append("A survivor needs a stable identity.")
		if bool(floor_data["evidence"]) != EVIDENCE.has(number):
			errors.append("Evidence must remain on floors 29, 27 and 26.")
		if bool(floor_data["evidence"]) and (str(floor_data["evidence_title"]).is_empty() or str(floor_data["evidence_text"]).is_empty()):
			errors.append("An evidence record must include its title and text.")
		if bool(floor_data["supplies"]) != (number == 29 or number == 25):
			errors.append("Supply stops must remain on floors 29 and 25.")
		if bool(floor_data["safe"]) != (number == 25):
			errors.append("Only the maintenance refuge is tagged as the safe zone.")
		if (number == 30 or number == 27 or number == 25) and (floor_data["hazard"] != "none" or floor_data["anomaly"] != "none"):
			errors.append("Onboarding, the pacing break and the refuge must remain quiet.")
		if number == 26 and floor_data["anomaly"] != "figure":
			errors.append("The final visible anomaly must remain on floor 26.")
		if floor_data["hazard"] != "none" or floor_data["anomaly"] != "none":
			hostile_streak += 1
		else:
			hostile_streak = 0
		if hostile_streak > 2:
			errors.append("More than two hostile floors occur consecutively.")
	return errors
