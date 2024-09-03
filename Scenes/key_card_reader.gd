extends CSGBox3D

signal correct_password

var password = "-1"

func set_password(text: String):
	password = text

func _on_magnet_body_entered(body: Node3D) -> void:
	if not body.has_method("get_tags"): return
	var tags = body.get_tags()
	if not "plaintext" in tags: return
	body.position = Vector3(0, 100, 0)
	if tags["plaintext"] == password and password != "-1":
		$Label3D.text = "correct"
		emit_signal("correct_password")
	else:
		$Label3D.text = "nope."
		$reset_timer.start()

func _on_magnet_body_exited(body: Node3D) -> void:
	_on_magnet_body_entered(body)

func _on_reset_timer_timeout() -> void:
	$Label3D.text = "idle"
