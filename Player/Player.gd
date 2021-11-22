extends PhysicsMover
class_name Player

var aim_direction := 0.0
var input_vec := Vector2.ZERO
var last_delta : float

export var invinc_time := 0.8

var facing := Vector2.RIGHT

var collective_mouse_movement_input := Vector2.ZERO
const MIN_TURN := PI / 16
const CONTROLLER_AIM_THRESHHOLD = 0.05

onready var scent_spawner = $ScentSpawner
onready var animation_state := $AnimationTree.get("parameters/playback") as AnimationNodeStateMachinePlayback
onready var projectile_spawner := $Head/ProjectileSpawner as PlayerProjectileSpawner
onready var head := $Head as Node2D
onready var anchor := $Anchor as Node2D
onready var poison := $Head/PlayerPoison as PlayerPoison
onready var dash_stuff := $DashStuff as DashStuff
onready var script_player := $ScriptPlayer as AnimationPlayer
onready var heal_player := $HealPlayer as AnimationPlayer
onready var aimer := $Aimer as Node2D

signal follow_completed

enum State {
	IDLE, WALK, DASH, SHOOT, POISON, FOLLOW
}

const STATE_FROM_STRING = {
	"idle": State.IDLE,
	"walk": State.WALK,
	"dash": State.DASH,
	"shoot": State.SHOOT,
	"poison": State.POISON,
	"follow": State.FOLLOW
}

var state = State.IDLE setget set_state
var state_blocked: bool = false
var state_first_frame: bool = false

func _ready() -> void:
	$AnimationTree.active = true
	$HealParticles.emitting = false
	dash_stuff.connect("add_dash_frame", self, "add_dash_frame")
	
func reset():
	GameStatus.CURRENT_HEALTH = GameStatus.PLAYER_MAX_HEALTH

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
	# mouse capture now in Game Status
	if event is InputEventMouseMotion:
		collective_mouse_movement_input += event.relative

# will be used in state_follow()
var target_position: Vector2
func follow_path(target_pos: Vector2):
	target_position = target_pos
	state_blocked = true
	set_state(State.FOLLOW)
	animation_state.travel("Walk")
	

func state_idle() -> void:
	animation_state.travel("Idle")
	state_blocked = false
	accelerate_and_move(last_delta)

func state_walk() -> void:
	animation_state.travel("Walk")
	state_blocked = false
	accelerate_and_move(last_delta, input_vec)

export var STOP_DISTANCE := 25.0
func state_follow() -> void:
	if state_first_frame:
		animation_state.travel("Walk")
		state_blocked = true
	
	var distance_vec := (target_position - self.global_position) as Vector2
	$AnimationTree.set("parameters/Walk/blend_position", distance_vec)
	
	# stop condition	
	if distance_vec.length() < STOP_DISTANCE:
		# set idle position to same as follow so it looks nicer after moving
		$AnimationTree.set("parameters/Idle/blend_position", distance_vec)
		emit_signal("follow_completed")
		set_state(State.IDLE)
		
	accelerate_and_move(last_delta, distance_vec.normalized())

func state_dash() -> void:
	if not state_first_frame and Input.is_action_just_pressed("player_dash"):
		# player trying to dash while still dash is alreayd active
		GameStatus.CURRENT_UI.cooldown_not_ready()
		
	if state_first_frame:
		add_acceleration(GameStatus.PLAYER_DASH_ACC * input_vec)
		script_player.play("dash")
		var dash_duration: float = script_player.get_animation("dash").length
		$Hurtbox/InvincibilityTimer.start(dash_duration)
		dash_stuff.start_dash_effects()
		$Sounds/Dash.play()
		state_blocked = true
	accelerate_and_move(last_delta, input_vec)

const DASH_FRAME := preload("res://Player/DashFrame.tscn")
func add_dash_frame() -> void:
	var dash_frame := DASH_FRAME.instance() as Sprite
	get_parent().add_child(dash_frame)
	dash_frame.texture = $Sprite.texture
	dash_frame.hframes = $Sprite.hframes
	dash_frame.frame = $Sprite.frame
	dash_frame.global_position = $Sprite.global_position
	dash_frame.rotation = $Sprite.rotation

func shoot() -> void:
	projectile_spawner.try_creating_projectile(aim_direction)

func state_shoot() -> void:
	if state_first_frame:
		script_player.play("shoot")
		animation_state.travel("Shoot")
		state_blocked = true
	$AnimationTree.set("parameters/Shoot/blend_position", Vector2.UP.rotated(aim_direction))
	accelerate_and_move(last_delta)

func state_poison() -> void:
	var sound_is_over = (not state_first_frame) and (not $Sounds/PoisonCloud.playing)
	if !Input.is_action_pressed("player_poison") or sound_is_over:
		poison.active = false
		set_state(State.IDLE)
		$Sounds/PoisonCloud.stop()
		GameStatus.emit_signal("stop_spray")
		return
	if state_first_frame:
		$Sounds/PoisonCloud.play()
		poison.active = true
		state_blocked = true
	poison.target_direction = aim_direction
	update_animation_facing(Vector2.UP.rotated(aim_direction))
	animation_state.travel("Walk" if input_vec != Vector2.ZERO else "Idle")
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
		State.POISON:
			state_poison()
		State.FOLLOW:
			state_follow()

func set_state(new_state) -> void:
	if new_state != state:
		state_first_frame = true
	state = new_state

func set_state_string(new_state: String) -> void:
	set_state(STATE_FROM_STRING[new_state])

func evaluate_action_input() -> void:
	if Input.is_action_just_pressed("player_dash") and GameStatus.DASH_ENABLED:
		if dash_stuff.is_cooldown_ready():
			set_state(State.DASH)
			return
		else:
			GameStatus.CURRENT_UI.cooldown_not_ready()
	if Input.is_action_just_pressed("player_shoot") and GameStatus.SHOOT_ENABLED:
		if projectile_spawner.is_cooldown_ready():
			set_state(State.SHOOT)
			return
		else:
			GameStatus.CURRENT_UI.cooldown_not_ready()
	if Input.is_action_just_pressed("player_poison") and GameStatus.SPRAY_ENABLED:
		GameStatus.emit_signal("start_spray")
		set_state(State.POISON)
		return
	if input_vec != Vector2.ZERO and GameStatus.MOVE_ENABLED:
		set_state(State.WALK)
		return
	else:
		set_state(State.IDLE)
		return

func _physics_process(delta: float) -> void:
	last_delta = delta
	input_vec = get_input_vector()
	update_animation_facing(input_vec)
	update_aim()
	state_first_frame = false
	if !state_blocked:
		evaluate_action_input()
	match_state()

# update the direction values for the animation tree
func update_animation_facing(direction: Vector2) -> void:
	if direction != Vector2.ZERO and GameStatus.MOVE_ENABLED:
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

# gain 1 HP
func health_boost():
	GameStatus.CURRENT_HEALTH += 1
	heal_player.play("heal")

# on hit
func _on_Hurtbox_area_entered(area: Area2D) -> void:
	if not $Hurtbox/InvincibilityTimer.is_stopped():
		return

	var projectile := area.get_parent() as Projectile
	if projectile:
		add_acceleration(projectile.knockback_vector())
	
	var ant_enemy := area.get_parent() as AntEnemy
	if ant_enemy:
		add_acceleration(ant_enemy.anchor.global_position.direction_to(anchor.global_position) * GameStatus.ENEMY_KNOCKBACK)
	
	var thorn := area.get_parent() as Thorn
	if thorn:
		add_acceleration(thorn.knockback_vector())
	
	var phorid_projectile := area.get_parent() as PhoridaeProjectile
	if phorid_projectile:
		add_acceleration(phorid_projectile.knockback_vector())
	
	var phorid := area.get_parent().get_parent() as Phoridae
	if phorid:
		add_acceleration(phorid.body.global_position.direction_to(anchor.global_position) * GameStatus.ENEMY_KNOCKBACK)
	
	var explosion := area.get_parent() as Explosion
	if explosion:
		add_acceleration(explosion.knockback_vector())
		if area.name == "Knockback":
			return
	
	$Sounds/TakeHit.play()
	GameStatus.CURRENT_HEALTH -= 1
	$Hurtbox/InvincibilityTimer.start(invinc_time)
	$InvincibilityPlayer.play("start")


func _on_InvincibilityTimer_timeout() -> void:
	$InvincibilityPlayer.play("stop")
	$Hurtbox.monitoring = false
	$Hurtbox.set_deferred("monitoring", true)
