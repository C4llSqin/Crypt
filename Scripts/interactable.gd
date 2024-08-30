class_name interactable

extends Area3D

func on_interact(player_instance) -> void:
	print(typeof(player_instance), typeof(player))
	player_instance.deactivate()
	$Camera3D.current = true
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
