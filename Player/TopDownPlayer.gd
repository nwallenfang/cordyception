extends SlideMover

var aim_direction := 0.0
const MAX_MOUSE_DISTANCE := 50.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_custom_mouse_cursor(preload("res://Game Logic/invisible_cursor.png"))

func get_input_vector() -> Vector2:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	return input_vector

func _physics_process(delta: float) -> void:
	var input_vec = get_input_vector()
	accelerate_and_move(input_vec, delta)
	$TestCursor.global_position = get_global_mouse_position()
	set_aimer()

func set_aimer() -> void:
	var global_mouse := get_global_mouse_position()
	$Aimer.rotation = aim_direction
	aim_direction = $Aimer.global_position.angle_to_point(global_mouse) + Vector2.UP.angle()
	var distance_to_aimer := global_mouse.distance_to($Aimer.global_position)
	if distance_to_aimer > MAX_MOUSE_DISTANCE:
		var new_mouse := global_mouse.move_toward($Aimer.global_position, distance_to_aimer - MAX_MOUSE_DISTANCE)
		get_viewport().warp_mouse(new_mouse)


