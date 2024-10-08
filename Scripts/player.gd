class_name player

extends CharacterBody3D

signal flavor_done

# movement
const SPEED = 5.0
const Sense = -0.4
var active = false

# holding
const throw_force = 2
const follow_force = 5
const object_distance = 2
const max_distance = 5.0
var heldObject: RigidBody3D = null

#typing logic
const time_per_char = 0.03
var typing_time = 0

func activate() -> void:
	active = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func deactivate() -> void:
	active = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func drop_held():
	if heldObject != null:
		heldObject.linear_velocity = Vector3(0, 0, 0)
		heldObject = null

func throw_held():
	if heldObject != null:
		var obj = heldObject
		heldObject = null
		obj.apply_central_impulse(-$Head.global_basis.z * throw_force)

func fus_ro_dah():
	if heldObject != null:
		var obj = heldObject
		heldObject = null
		obj.apply_central_impulse(-$Head.global_basis.z * 7 * 10)

func handle_holding():
	#print($Head.global_rotation)
	if heldObject != null:
		var targetPos = $Head.global_transform.origin + ($Head.global_basis * Vector3(0, 0, -object_distance)) # 2.5 units in front of camera
		var objectPos = heldObject.position # Held object position
		var final_point = (targetPos - objectPos ) * follow_force# Our desired position
		#print(targetPos, final_point)
		heldObject.linear_velocity = final_point
		
		# Drop the object if it's too far away from the camera
		if heldObject.global_position.distance_to($Head.global_position) > max_distance:
			drop_held()

func use_input():
	if heldObject != null:
		drop_held()
		return 
	var collision = null
	if $Head/InteractCast.is_colliding():
		collision = $Head/InteractCast.get_collider()
	if collision is RigidBody3D: 
		print("Object")
		heldObject = collision
	elif collision is Area3D:
		print("Area")
		if collision.has_method("on_interact"):
			print("Area - interactable")
			
			collision.on_interact(self)

func write_diolog(text: String):
	$flavor_text/fade_timer.stop() 
	$flavor_text.visible_characters = 0
	$flavor_text.text = "[center]" + text
	$flavor_text.visible_ratio = 0

func process_type(delta: float) -> void:
	if $flavor_text.visible_ratio == 1:
		typing_time = 0
		return
	typing_time += delta
	while typing_time > time_per_char:
		$flavor_text.visible_characters += 1
		if $flavor_text.visible_ratio == 1: 
			$flavor_text/fade_timer.start()
			emit_signal("flavor_done")
			return
		typing_time -= time_per_char

func _on_fade_timer_timeout() -> void:
	write_diolog("")

func _input(event: InputEvent) -> void:
	#print(typeof(event))
	if event is InputEventMouseMotion and active:
		rotate_y(deg_to_rad(event.relative.x * Sense))
		$Head.rotate_x(deg_to_rad(event.relative.y * Sense))
		$Head.rotation.x = clamp($Head.rotation.x, -PI/2, PI/2)
	elif event is InputEventKey and active:
		if event.is_action_pressed("use"):
			print("Use")
			use_input()
		if event.is_action_pressed("throw"):
			print("Throw")
			throw_held()
		if event.is_action_pressed("fus_ro_dah"):
			print("Fus ro Dah!")
			fus_ro_dah()

func _process(delta: float) -> void:
	handle_holding()
	process_type(delta)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	if not active: input_dir = Vector2(0, 0)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
