extends SlideMover
class_name Player

var aim_direction := 0.0

var collective_mouse_movement_input := Vector2.ZERO
const MIN_TURN := PI / 16
const CONTROLLER_AIM_THRESHHOLD = 0.05

onready var scent_spawner = $ScentSpawner

func get_input_vector() -> Vector2:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	input_vector = input_vector.normalized()
	return input_vector

func get_controller_aim_vector() -> Vector2:
	var aim_vector := Vector2.ZERO
	aim_vector.x = Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left")
	aim_vector.y = Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	return aim_vector

func handle_nonmovement_input() -> void:
	if Input.is_action_just_pressed("player_shoot"):
		$ProjectileSpawner.try_creating_projectile(aim_direction)
	# hier dann später die ganzen anderen skills einfügen

func _physics_process(delta: float) -> void:
	var input_vec = get_input_vector()
	handle_nonmovement_input()
	accelerate_and_move(delta, input_vec)
	
	update_mouse_aim()
	var controller_aim := get_controller_aim_vector()
	if controller_aim.length() > CONTROLLER_AIM_THRESHHOLD:
		aim_direction = vector_to_angle(controller_aim)
	$Aimer.rotation = aim_direction

# update aimer arrow to mouse input
func update_mouse_aim():
	var mouse_movement := collective_mouse_movement_input
	collective_mouse_movement_input = Vector2.ZERO
	
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

func _input(event: InputEvent) -> void:
	# browsers only allow mouse capture after the user has interacted with the 
	# game, so the mouse mode has to be set in _input
	# see https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_for_web.html#full-screen-and-mouse-capture
	if not Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		collective_mouse_movement_input += event.relative


# vector angle calculation functions

func reset_radian_angle(a: float) -> float:
	return Vector2.RIGHT.rotated(a).angle()

func vector_to_angle(vec: Vector2) -> float:
	if vec == Vector2.ZERO:
		vec = Vector2(0, -1)
	vec.y = -vec.y
	return vec.angle_to(Vector2.DOWN)

# on hit
func _on_Hurtbox_area_entered(area: Area2D) -> void:
	if not $Hurtbox/InvincibilityTimer.is_stopped():
		return
		
	GameStatus.CURRENT_HEALTH -= 1
	var projectile := area.get_parent() as Projectile
	if projectile:
		add_velocity(projectile.knockback_vector())
	$Hurtbox/InvincibilityTimer.start()
	$InvincibilityPlayer.play("start")


func _on_InvincibilityTimer_timeout() -> void:
	$InvincibilityPlayer.play("stop")
