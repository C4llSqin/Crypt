extends Area3D

signal correct_code

var active = false
var player_instance = null
var cur_number = 0
var correct_number = -1

var elligable = false
var can_backout = true

func set_num(num: int):
	correct_number = num

func set_elligable(val: bool = true):
	elligable = val

func on_interact(player_ins) -> void:
	if can_backout == false: return
	player_ins.deactivate()
	$overlay.show()
	active = true
	$Camera3D.current = true
	player_instance = player_ins

func _input(event: InputEvent) -> void:
	if can_backout == false: return
	if event.is_action_pressed("escape") and active: backout()

func backout():
	active = false
	$overlay.hide()
	$Camera3D.current = false
	player_instance.activate()
	player_instance = null

func remove_num() -> void:
	var display = $overlay/digits
	cur_number = cur_number / 10
	display.text = "[center]%04d" % cur_number

func add_num(number: int) -> void:
	var display = $overlay/digits
	if cur_number > 1000: return
	cur_number = cur_number * 10 + number
	display.text = "[center]%04d" % cur_number

func validate() -> bool:
	if cur_number == correct_number and elligable:
		can_backout = false
		$overlay/digits.text = "[center][color=cyan]yup."
		emit_signal("correct_code")
		return true
	else: 
		$overlay/digits.text = "[center][color=red]nope."
		return false

func _on_button_9_pressed() -> void: add_num(9)
func _on_button_8_pressed() -> void: add_num(8)
func _on_button_7_pressed() -> void: add_num(7)
func _on_button_6_pressed() -> void: add_num(6)
func _on_button_5_pressed() -> void: add_num(5)
func _on_button_4_pressed() -> void: add_num(4)
func _on_button_3_pressed() -> void: add_num(1)
func _on_button_2_pressed() -> void: add_num(2)
func _on_button_1_pressed() -> void: add_num(3)
func _on_button_0_pressed() -> void: add_num(0)
func _on_button_clr_pressed() -> void: remove_num()
func _on_button_entr_pressed() -> void: validate()
