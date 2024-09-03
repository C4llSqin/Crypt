extends flavor

signal printed

var jammed = false
var jammed_text = ""
var actionable = true
var player_instance = null

var paper = preload("res://Scenes/Paper.tscn")

const actions = [
	"You dropkick the printer.",
	"You shake the printer.",
	"[font_size=23]You pull a brick out of the wall, and pretend to call the rival printer company for a new printer.",
	"You give the printer a cheer that it can do this.",
	"[font_size=23]You mutter that this printer is more of an inconvenience than being kidnaped."
]

func request_print(text: String) -> bool:
	var val = !jammed
	if val: 
		jammed_text = text
		jammed = true
	return val

func get_flavor():
	return actions[randi_range(0, 4)]

func does_it_work():
	if player_instance == null:
		print("Null protection active")
		return
	player_instance.disconnect("flavor_done", run_timer)
	if jammed: 
		player_instance.write_diolog("Surprisingly, it worked")
		var node = paper.instantiate()
		get_parent_node_3d().add_child(node)
		node.position = position + Vector3(1, 0, 0)
		node.set_text(jammed_text)
		emit_signal("printed")
		jammed = false
	else: 
		player_instance.write_diolog("Unsurprisingly, it didn't work")
	player_instance = null
	
	actionable = true

func run_timer():
	$Timer.start()

func on_interact(player_ins) -> void:
	if not actionable: return
	actionable = false
	player_instance = player_ins
	player_ins.connect("flavor_done", run_timer)
	player_ins.write_diolog(get_flavor())
