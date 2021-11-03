extends SlideMover

const PlayerProjectile := preload("res://Projectiles/Projectile.tscn")

var aim_direction := 0.0

var mouse_movement_input := Vector2.ZERO
const MIN_TURN := PI / 20


func _ready() -> void:
#	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
#	Input.set_custom_mouse_cursor(preload("res://Game Logic/invisible_cursor.png"))
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func get_input_vector() -> Vector2:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	return input_vector
	
func handle_nonmovement_input() -> void:
	if Input.is_action_just_pressed("player_shoot"):
		spawn_projectile()
	# hier dann später die ganzen anderen skills einfügen

func _physics_process(delta: float) -> void:
	var input_vec = get_input_vector()
	handle_nonmovement_input()
	accelerate_and_move(input_vec, delta)
	
	update_mouse()

func update_mouse():
	var mouse_movement := mouse_movement_input
	mouse_movement_input = Vector2.ZERO
	
	aim_direction = reset_radian_angle(aim_direction)
	var target_direction := reset_radian_angle(vector_to_angle(mouse_movement))
	var turn := target_direction - aim_direction
	if turn > PI:
		turn -= TAU
	elif turn < -PI:
		turn += TAU
	if abs(turn) > PI:
		print("Fatal ERROR")
	
	var speed := mouse_movement.length() / 100.0
	var turn_sign := sign(turn)
	var turn_abs := abs(turn)
	
	if turn_abs < MIN_TURN:
		return
	
	var turn_done := clamp(speed, 0.0, turn_abs) * turn_sign
	aim_direction += turn_done
	
	$Aimer.rotation = aim_direction

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement_input += event.relative

func reset_radian_angle(a: float) -> float:
	return Vector2.RIGHT.rotated(a).angle()

func vector_to_angle(vec: Vector2) -> float:
	if vec == Vector2.ZERO:
		vec = Vector2(0, -1)
	vec.y = -vec.y
	return vec.angle_to(Vector2.DOWN)

func spawn_projectile() -> void: 
	var projectile := PlayerProjectile.instance()
	var main = get_tree().current_scene
	main.add_child(projectile)
	var rot : float = aim_direction
	projectile.direction = Vector2.UP.rotated(aim_direction)
	projectile.global_position = self.global_position
