extends flavor

signal adapter_exists

var phase = false

func get_flavor() -> String:
	return "A Sturdy Table"

func _on_magnet_zone_body_entered(body: Node3D) -> void:
	var tags = {'type': 'brazil;'}
	if body.has_method("get_tags"): tags = body.get_tags()
	if tags["type"] == "adapter" and not phase:
		phase = true
		emit_signal("adapter_exists")
		body.position = Vector3(0,100, 0)
		body.hide()
		body.freeze = true
