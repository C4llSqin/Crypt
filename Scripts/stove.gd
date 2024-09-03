extends flavor

var phase = 0
var cooked_paper = null

func get_flavor() -> String:
	return "A functional stove"

func _on_body_entered(body: Node3D) -> void:
	if not body.has_method("get_tags"): return
	var tags = body.get_tags()
	if tags["type"] == "pan" and phase == 0:
		body.freeze = true
		body.global_position = $attachment_0.global_position
		body.global_rotation = $attachment_0.global_rotation
		phase = 1
	elif tags["type"] == "paper" and "plaintext" not in tags and phase == 1:
		body.freeze = true
		body.global_position = $attachment_1.global_position
		body.global_rotation = $attachment_1.global_rotation
		phase = 2
		cooked_paper = body
		$cook_timer.start()

func _on_cook_timer_timeout() -> void:
	cooked_paper.freeze = false
	var plain = cooked_paper.get_text()
	cooked_paper.tags["plaintext"] = plain
	cooked_paper.set_text(str(plain.hash()))
	phase = 1
	cooked_paper.global_position = $attachment_1.global_position + Vector3(0, 0, -1)

func _on_magnet_body_exited(body: Node3D) -> void:
	_on_body_entered(body) #physics doesn't like very small paper sized objects
