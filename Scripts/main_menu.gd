extends Control

func _on_button_pressed() -> void:
	$overlay.hide()
	$Player.activate();
	#$Player/RigidBody3D/Camera3D.make_current()

func _on_world_game_end() -> void:
	$Player.deactivate()
	$win_screen.show()
