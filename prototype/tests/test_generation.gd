extends SceneTree
## Run: godot --headless --path prototype --script tests/test_generation.gd

const Generator = preload("res://scripts/floor_generator.gd")
var failures: Array[String] = []
var checks: int = 0


func _initialize() -> void:
	var signatures: Dictionary = {}
	var layouts: Dictionary = {}
	var hazards: Dictionary = {}
	var anomalies: Dictionary = {}
	for seed_value in range(200):
		var first: Array = Generator.generate(seed_value)
		var second: Array = Generator.generate(seed_value)
		_check(first == second, "Seed %d did not reproduce the same floor data." % seed_value)
		_check(Generator.validate(first).is_empty(), "Seed %d violates an invariant: %s" % [seed_value, str(Generator.validate(first))])
		# Unrelated random draws must never affect level generation.
		seed(seed_value + 91283)
		for _draw in range(7):
			randi()
		_check(first == Generator.generate(seed_value), "Global RNG leaked into seed %d." % seed_value)
		signatures[JSON.stringify(first)] = true
		for floor_data in first:
			layouts[floor_data["layout_variant"]] = true
			hazards[floor_data["hazard"]] = true
			anomalies[floor_data["anomaly"]] = true
		# Editing one generated result cannot mutate future runs or shared constants.
		first[0]["survivor_name"] = "MUTATED TEST VALUE"
		_check(Generator.generate(seed_value) == second, "Generated data leaked mutable state for seed %d." % seed_value)

	_check(signatures.size() == 200, "All 200 tested seeds must yield distinct complete specifications.")
	_check(layouts.size() == 3, "The seed sweep did not exercise all three layout variants.")
	_check(hazards.size() == 4, "The seed sweep did not exercise all four hazard states.")
	_check(anomalies.size() == 4, "The seed sweep did not exercise all four anomaly states.")
	for edge_seed in [-2147483648, -1, 0, 2147483647, 9223372036854775807]:
		var edge_result: Array = Generator.generate(edge_seed)
		_check(Generator.validate(edge_result).is_empty(), "An edge-case integer seed failed validation.")
		_check(edge_result == Generator.generate(edge_seed), "An edge-case integer seed was not reproducible.")

	# The validator must reject broken input instead of silently trusting metadata.
	_check(not Generator.validate([]).is_empty(), "Empty levels were accepted.")
	var malformed: Array = Generator.generate(42)
	malformed[0] = "wrong type"
	_check(not Generator.validate(malformed).is_empty(), "A non-dictionary level was accepted.")
	malformed = Generator.generate(42)
	malformed[0].erase("number")
	_check(not Generator.validate(malformed).is_empty(), "A missing required field was accepted.")
	malformed = Generator.generate(42)
	malformed[5]["hazard"] = "smoke"
	_check(not Generator.validate(malformed).is_empty(), "An unsafe refuge was accepted.")
	malformed = Generator.generate(42)
	malformed[2]["survivor"] = false
	_check(not Generator.validate(malformed).is_empty(), "A missing required survivor was accepted.")
	malformed = Generator.generate(42)
	for index in [1, 2, 3]:
		malformed[index]["hazard"] = "smoke"
	_check(not Generator.validate(malformed).is_empty(), "Three hostile floors in a row were accepted.")

	if failures.is_empty():
		print("PASS floor generation: %d checks, 200 seeds, all variants covered; determinism, isolation and negative validation passed." % checks)
		quit(0)
	else:
		for failure in failures:
			push_error(failure)
		print("FAIL floor generation: %d failures / %d checks." % [failures.size(), checks])
		quit(1)


func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures.append(message)
