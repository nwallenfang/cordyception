extends SlideMover

const PlayerProjectile := preload("res://Projectiles/Projectile.tscn")

var aim_direction := 0.0

var mouse_movement_input := Vector2.ZERO


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
	
	#update_mouse()
	#update_aimer()
	
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
	
	var turn_done := clamp(speed, 0.0, turn_abs) * turn_sign
	aim_direction += turn_done
	
	$Aimer.rotation = aim_direction
	
	# TEST CURSOR
	#$TestCursor.global_position = get_global_mouse_position()
	

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

#func move_mouse_to_local():
#	var new_position := global_position + local_mouse_position
#	if get_global_mouse_position().distance_to(new_position) < 2:
#		return
#	block_mouse_event = true
#	get_viewport().warp_mouse(new_position)

#func update_mouse() -> void:
#	var global_mouse := get_global_mouse_position()
#	var expected_global:Vector2 = global_position + local_mouse_position - get_last_movement()
#	expected_global.x = int(expected_global.x)
#	expected_global.y = int(expected_global.y)
#	var difference := global_mouse - expected_global
#	local_mouse_position += difference
#	move_mouse_to_local()
#
#func update_aimer():
#	var global_mouse := get_global_mouse_position()
#	aim_direction = $Aimer.global_position.angle_to_point(global_mouse) + Vector2.UP.angle()
#	$Aimer.rotation = aim_direction
#	var distance_to_aimer := global_mouse.distance_to($Aimer.global_position)
#	if distance_to_aimer > MAX_MOUSE_DISTANCE:
#		var new_mouse := global_mouse.move_toward($Aimer.global_position, distance_to_aimer - MAX_MOUSE_DISTANCE)
#		local_mouse_position += new_mouse - global_mouse
#		move_mouse_to_local()

func spawn_projectile() -> void: 
	var projectile := PlayerProjectile.instance()
	var main = get_tree().current_scene
	main.add_child(projectile)
	var rot : float = aim_direction
	projectile.direction = Vector2.UP.rotated(aim_direction)
	projectile.global_position = self.global_position
