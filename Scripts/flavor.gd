class_name flavor

extends Area3D

func get_flavor() -> String:
	return "[Un overriden]"

func on_interact(player_ins) -> void:
	player_ins.write_diolog(get_flavor())
