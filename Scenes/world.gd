extends Node3D

var laptop_id = randi_range(0, 9999)
var modulos = [randi_range(2,9), randi_range(2,9), randi_range(2,9), randi_range(2,9)]
var safe_code = 0
var comms_octals = [randi_range(1,127), randi_range(1,250)]
const passwords = [
	"password",
	"fantasy_football_fan#01",
	"SHA1",
	"SHA256",
	"MD5",
	"salt&peper",
	"godotForLife",
	"thirdDimension"
]
var password = passwords[randi_range(0, len(passwords)-1)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	safe_code = (1000 * (laptop_id % modulos[0])) + (100 * (laptop_id % modulos[1])) + (10 * (laptop_id % modulos[2])) + (1 * (laptop_id % modulos[3]))
	$Room/safe.set_num(safe_code)
	$Room/Laptop.set_laptop_game_info(laptop_id, modulos, comms_octals)
	$Room/Couch.set_text("192.168.{a}.{b}".format({'a': comms_octals[0], 'b': comms_octals[1]}))
	$"Room/Door mat".set_text("The password for door is the hash of '%s'" % password)
	var key = randi_range(1, 25)
	$Room/first_clue.set_text($Room/Laptop.encode_ceasar("Couch", key) + ", " + str(key))
	$Room/key_card_reader.set_password(password)

func _on_table_adapter_exists() -> void:
	$Room/Laptop.attach_wifi_adapter()

func _on_laptop_safe_eligable() -> void:
	$Room/safe.set_elligable(true)

func _on_safe_correct_code() -> void:
	$safe_timer.start() # wait 1 sec for people to register that they got the code right

func _on_safe_timer_timeout() -> void: # after that one sec
	$Room/safe.backout()
	$Room/safe.hide()
	$Room/safe.position = Vector3(0, -100, 0)
	$Room/pan.show()
	$Room/pan.freeze = false

func _on_key_card_reader_correct_password() -> void:
	$Room/door.hide()
	$Room/door.position = Vector3(0, 100, 0)

func _on_laptop_request_print() -> void:
	var state = $Room/Printer.request_print($Room/Laptop.get_printer_text())
	if state: $Room/Laptop.set_print_err("[center][color=red]PAPER JAM")
	else: $Room/Laptop.set_print_err("[center][color=red]QUEUE FULL")

func _on_printer_printed() -> void:
	$Room/Laptop.set_print_err("")
