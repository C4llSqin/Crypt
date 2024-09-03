extends Area3D

signal safe_eligable
signal request_print

#interactable logic
var active = false
var player_instance = null

#game logic
var laptop_id = 0000
var chat_phase = false
var modulos = [1, 1, 1, 1]
var octals = [1, 1]
var inet = false

#typing logic
const time_per_char = 0.03
var typing_time = 0

func set_laptop_game_info(num: int, modulo, octal):
	#var lbl = $overlay/Label
	$overlay/Label.text = "Laptop: %04d" % num
	laptop_id = num
	modulos = modulo
	octals = octal

func on_interact(player_ins) -> void:
	#print(typeof(player_instance), typeof(player))
	player_ins.deactivate()
	$overlay.show()
	active = true
	$Camera.current = true
	player_instance = player_ins

func attach_wifi_adapter():
	inet = true
	$overlay/connection_status.show()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("escape") and active:
		active = false
		$overlay.hide()
		$Camera.current = false
		player_instance.activate()
		player_instance = null

func encode_ceasar(text: String, key: int):
	var buf = ""
	for letter in text:
		var encoded = letter.unicode_at(0)
		var base = 65
		if encoded >= 97:
			base = 97
		var new_letter = (((encoded - base) + key) % 26)
		if new_letter < 0:
			new_letter = 26 + new_letter
		var decoded = base + new_letter
		buf = buf + char(decoded)
	return buf

func write_term(text: String): 
	#$flavor_text/fade_timer.stop() 
	$overlay/chat/phase1/term.visible_characters = 0
	$overlay/chat/phase1/term.text = text
	$overlay/chat/phase1/term.visible_ratio = 0

func _on_connect_button_pressed() -> void:
	var octal = [int($overlay/chat/phase0/oct_one.text), int($overlay/chat/phase0/oct_two.text), int($overlay/chat/phase0/oct_three.text), int($overlay/chat/phase0/oct_four.text)]
	var expected = [192, 168, octals[0], octals[1]]
	var rand_id = randi_range(0,9999)
	var text = ""
	var fmts = {
			'ip': "{a}.{b}.{c}.{d}:{e}.".format({'a': octal[0], 'b': octal[1], 'c': octal[2], 'd': octal[3], 'e': randi_range(2000, 9900)}),
			'laptop id': rand_id,
			'sequnce': "{a} {b} {c} {d}".format({'a': modulos[0], 'b': modulos[1], 'c': modulos[2], 'd': modulos[3]}),
			'mod_0': modulos[0],
			'mod_1': modulos[1],
			'mod_2': modulos[2],
			'mod_3': modulos[3],
			'res_0': rand_id % modulos[0],
			'res_1': rand_id % modulos[1],
			'res_2': rand_id % modulos[2],
			'res_3': rand_id % modulos[3],
		} 
	fmts['res_all'] = (fmts['res_0'] * 1000) + (fmts['res_1'] * 100) + (fmts['res_2'] * 10) + fmts['res_3']
	if not inet:
		text = """[sys] trying to connect to {ip}...
[[color=red]err[/color]] failled to connect to {ip}, No network adapters found""".format(fmts)
	elif octal == expected:
		text = """[sys] trying to connect to {ip}...
[sys] connected, handshaking...
[sys] handshaking succeeded
[[color=cyan]oth[/color]] Ah hello, Im traped in a room like you.
[[color=yellow]you[/color]] What brings you here?
[[color=cyan]oth[/color]] I don't know, but a place like this in california costs 300,000$ a month so not the worst outcome.
[[color=yellow]you[/color]] Fair, do you have any clues?
[[color=cyan]oth[/color]] I know how to derive the key to the safe, in my search for the password for the door, i've transended to fourth dimension.
[[color=yellow]you[/color]] Alright let me here it.
[[color=cyan]oth[/color]] The passcode to the safe consists of 4 digits. each digit is derived by an modulo operation based on your laptop number.
[[color=cyan]oth[/color]] the sequnce is {sequnce}
[[color=cyan]oth[/color]] for instance if your laptop id is {laptop id} the key derives like this
[[color=cyan]oth[/color]] {laptop id} % {mod_0} = {res_0}
[[color=cyan]oth[/color]] {laptop id} % {mod_1} = {res_1}
[[color=cyan]oth[/color]] {laptop id} % {mod_2} = {res_2}
[[color=cyan]oth[/color]] {laptop id} % {mod_3} = {res_3}
[[color=cyan]oth[/color]] Thus the password to the safe would be {res_all}
[[color=cyan]oth[/color]] [i]I would recomend grabing a calculator[/i]
[[color=yellow]you[/color]] How did you figure it out?
[[color=cyan]oth[/color]] When you've ventured into the fourth dimension, like I have, trival matters like safe codes are infinitely insignificant
[[color=yellow]you[/color]] Wait if you've [i]mastered[/i] the fourth dimension, why not just leave?
[[color=cyan]oth[/color]] That's a good idea.
[[color=cyan]oth[/color]] eH0cp1IaLFQyA0miOtUXW1qSicZF6CvZ
[[color=red]err[/color]] connection lost, FOURTH_DIMENSION""".format(fmts)
		chat_phase = true
		emit_signal("safe_eligable")
	else:
		text = """[sys] trying to connect to {ip}...
[[color=red]err[/color]] failled to connect to {ip}, No connection could be made because the target machine actively refused it""".format(fmts)
	
	$overlay/chat/phase0.hide()
	$overlay/chat/phase1.show()
	
	write_term(text)

func process_type(delta: float) -> void:
	if $overlay/chat/phase1/term.visible_ratio == 1:
		typing_time = 0
		return
	typing_time += delta
	while typing_time > time_per_char:
		$overlay/chat/phase1/term.visible_characters += 1
		if $overlay/chat/phase1/term.visible_ratio == 1 and not chat_phase: 
			$overlay/chat/phase1/fail_timer.start()
			return
		typing_time -= time_per_char

func _on_fail_timer_timeout() -> void:
	$overlay/chat/phase1.hide()
	$overlay/chat/phase0.show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_type(delta)

func _on_printer_button_pressed() -> void:
	$overlay/printer.show()
	$overlay/caesar.hide()
	$overlay/chat.hide()

func _on_chat_button_pressed() -> void:
	$overlay/printer.hide()
	$overlay/caesar.hide()
	$overlay/chat.show()

func _on_ceasar_button_pressed() -> void:
	$overlay/printer.hide()
	$overlay/caesar.show()
	$overlay/chat.hide()

func _on_encode_pressed() -> void:
	$overlay/caesar/caesar_chipher_text.text = encode_ceasar($overlay/caesar/caesar_plain_text.text, int($overlay/caesar/key_input.text))

func _on_decode_pressed() -> void:
	$overlay/caesar/caesar_plain_text.text = encode_ceasar($overlay/caesar/caesar_chipher_text.text, -int($overlay/caesar/key_input.text))

func set_print_err(text):
	$overlay/printer/print_status.text = text

func get_printer_text() -> String:
	return $overlay/printer/print_input.text

func _on_print_button_pressed() -> void:
	emit_signal("request_print")
