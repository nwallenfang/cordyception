extends PhysicsMover
class_name Player

var aim_direction := 0.0
var input_vec := Vector2.ZERO
var last_delta : float

var facing := Vector2.RIGHT

var collective_mouse_movement_input := Vector2.ZERO
const MIN_TURN := PI / 16
const CONTROLLER_AIM_THRESHHOLD = 0.05

onready var scent_spawner = $ScentSpawner
onready var animation_state := $AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
onready var projectile_spawner := $ProjectileSpawner as PlayerProjectileSpawner
onready var head := $Sprite/Head as Node2D
onready var poison := $Sprite/Head/PlayerPoison as PlayerPoison

enum State {
	IDLE, WALK, DASH, SHOOT, ATTACK, POISON
}

const STATE_FROM_STRING = {
	"idle": State.IDLE,
	"walk": State.WALK,
	"dash": State.DASH,
	"shoot": State.SHOOT,
	"attack": State.ATTACK,
	"poison": State.POISON
}

var state = State.IDLE setget set_state

func _ready() -> void:
	$AnimationTree.active = true

# input functions
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

func _input(event: InputEvent) -> void:
	# browsers only allow mouse capture after the user has interacted with the 
	# game, so the mouse mode has to be set in _input
	# see https://docs.godotengine.org/en/stable/getting_started/workflow/export/exporting_for_web.html#full-screen-and-mouse-capture
	if not Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		collective_mouse_movement_input += event.relative

func state_idle() -> void:
	if Input.is_action_just_pressed("player_dash"):
		set_state_and_match(State.DASH)
		return
	if Input.is_action_just_pressed("player_shoot"):
		set_state_and_match(State.SHOOT)
		return
	if Input.is_action_just_pressed("player_attack"):
		set_state_and_match(State.ATTACK)
		return
	if Input.is_action_pressed("player_poison"):
		set_state_and_match(State.POISON)
		return
	if input_vec != Vector2.ZERO:
		set_state_and_match(State.WALK)
		return
	animation_state.travel("Idle")
	accelerate_and_move(last_delta)

func state_walk() -> void:
	if Input.is_action_just_pressed("player_dash"):
		set_state_and_match(State.DASH)
		return
	if Input.is_action_just_pressed("player_shoot"):
		set_state_and_match(State.SHOOT)
		return
	if Input.is_action_just_pressed("player_attack"):
		set_state_and_match(State.ATTACK)
		return
	if Input.is_action_pressed("player_poison"):
		set_state_and_match(State.POISON)
		return
	if input_vec == Vector2.ZERO:
		set_state_and_match(State.IDLE)
		return
	animation_state.travel("Walk")
	accelerate_and_move(last_delta, input_vec)

func state_dash() -> void:
	var dash_duration: float = $AnimationPlayer.get_animation("dash_left").length

	if Input.is_action_just_pressed("player_dash"):
		# easiest way for me to play this sound
		if self.state == State.DASH and not $DashStuff/DashCooldown.is_stopped():
			$DashStuff/CooldownNotReadySound.play()

	if animation_state.get_current_node() != "Dash" and $DashStuff/DashCooldown.is_stopped():
		add_acceleration(GameStatus.PLAYER_DASH_ACC * input_vec)
		$AnimationTree.set("parameters/Dash/blend_position", input_vec)
		animation_state.travel("Dash")
		$DashStuff/DashParticles.emitting = true
		$Hurtbox/InvincibilityTimer.start(dash_duration)
		$DashStuff/DashCooldown.start()
		var dash_timer := $DashStuff/DashFrameTimer as Timer
		dash_timer.start(0.1)
	accelerate_and_move(last_delta, input_vec)

const DASH_FRAME := preload("res://Player/DashFrame.tscn")
func add_dash_frame() -> void:
	var dash_frame := DASH_FRAME.instance() as Sprite
	get_parent().add_child(dash_frame)
	dash_frame.texture = $Sprite.texture
	dash_frame.global_position = $Sprite.global_position
	dash_frame.rotation = $Sprite.rotation

func state_shoot() -> void:
	if animation_state.get_current_node() != "Shoot":
		var success := projectile_spawner.try_creating_projectile(aim_direction)
		if success:
			animation_state.travel("Shoot")
			$AnimationTree.set("parameters/Shoot/blend_position", Vector2.UP.rotated(aim_direction))
		else:
			set_state(State.IDLE)
	accelerate_and_move(last_delta)

func state_attack() -> void:
	if animation_state.get_current_node() != "Attack":
		$AnimationTree.set("parameters/Attack/blend_position", Vector2.UP.rotated(aim_direction))
		animation_state.travel("Attack")
	accelerate_and_move(last_delta, input_vec)

func state_poison() -> void:
	if !Input.is_action_pressed("player_poison"):
		poison.active = false
		set_state_and_match(State.IDLE)
		return
	if !poison.active:
		poison.active = true
	poison.target_direction = aim_direction
	update_animation_facing(Vector2.UP.rotated(aim_direction))
	animation_state.travel("Walk")
	accelerate_and_move(last_delta, input_vec)

func match_state():
	match state:
		State.IDLE:
			state_idle()
		State.WALK:
			state_walk()
		State.DASH:
			state_dash()
		State.SHOOT:
			state_shoot()
		State.ATTACK:
			state_attack()
		State.POISON:
			state_poison()

func set_state(new_state) -> void:
	state = new_state

func set_state_and_match(new_state) -> void:
	if new_state is String:
		set_state_string(new_state)
	else:
		state = new_state
	match_state()

func set_state_string(new_state: String) -> void:
	state = STATE_FROM_STRING[new_state]

func _physics_process(delta: float) -> void:
	last_delta = delta
	input_vec = get_input_vector()
	update_animation_facing(input_vec)
	update_aim()
	match_state()

# update the direction values for the animation tree
func update_animation_facing(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		facing = direction
		$AnimationTree.set("parameters/Idle/blend_position", facing)
		$AnimationTree.set("parameters/Walk/blend_position", facing)

func update_aim() -> void:
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
		add_acceleration(projectile.knockback_vector())
	
	var ant_enemy := area.get_parent() as AntEnemy
	if projectile:
		add_acceleration(projectile.knockback_vector())	
	
	$Hurtbox/InvincibilityTimer.start()
	$InvincibilityPlayer.play("start")


func _on_InvincibilityTimer_timeout() -> void:
	$InvincibilityPlayer.play("stop")
