extends CharacterBody3D

# movement
const SPEED = 5.0
const Sense = -0.4
var active = false

# holding
const throw_force = 7.0
const follow_force = 5.0
const object_distance = 2.5
const max_distance = 5.0
var heldObject: RigidBody3D

func activate() -> void:
	active = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func deactivate() -> void:
	active = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _input(event: InputEvent) -> void:
	#print(typeof(event))
	if event is InputEventMouseMotion and active:
		rotate_y(deg_to_rad(event.relative.x * Sense))
		$Head.rotate_x(deg_to_rad(event.relative.y * Sense))
		$Head.rotation.x = clamp($Head.rotation.x, -PI/2, PI/2)
	else:
		if event.is_action("use"): 
			print("UseKey")
			use_input()
		
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

func use_input():
	var collision = null
	if $Head/InteractCast.is_colliding():
		collision = $Head/InteractCast.get_collider()
	if collision is RigidBody3D: print("Object")
	elif collision is Area3D: print("Area")

func handle_held_object() -> void: pass
	
