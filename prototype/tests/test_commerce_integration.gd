extends SceneTree
## Same real mission interactions as the visual fixture, without screenshots.
## Full physical travel is independently exercised by test_commerce_routes.gd.
const Fixture = preload("res://tests/visual_commerce_preview.gd")
func _initialize() -> void:
	var fixture := Fixture.new()
	fixture.check_only = true
	root.add_child.call_deferred(fixture)
