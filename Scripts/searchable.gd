extends Area3D

@export_category("Searchable")
@export var search_name = "BLANK"
@export var hide_self = false
@export var result_text = "You found..."
@export var is_paper = true
@export var depsoit_vec = Vector3(0, 1, 0)

var searched = false
var player_instance = null

func _ready() -> void:
	var text_box_timer = Timer.new()
	text_box_timer.name = "text_box_timer"
	text_box_timer.wait_time = 2
	add_child(text_box_timer)
	$text_box_timer.one_shot = true
	$text_box_timer.connect("timeout", search_result)

func set_text(text: String):
	#if is_paper:
	$held_itm.set_text(text)

func on_interact(player_ins) -> void:
	if searched: return
	searched = true
	player_instance = player_ins
	player_instance.write_diolog("You search the " + search_name)
	player_instance.connect("flavor_done", run_timer)
	
func run_timer():
	$text_box_timer.start()

func search_result():
	player_instance.write_diolog(result_text)
	$held_itm.show()
	$held_itm.freeze = false
	$held_itm.position = position + depsoit_vec
	var node = $held_itm
	remove_child(node)
	get_parent().add_child(node)
	player_instance.disconnect("flavor_done", run_timer)
	player_instance = null
