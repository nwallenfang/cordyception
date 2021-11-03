extends SlideMover

const PlayerProjectile := preload("res://Projectiles/Projectile.tscn")

var aim_direction := 0.0
onready var last_global_mouse := get_global_mouse_position()
const AIM_THRESHHOLD := 0.1

func _ready() -> void:
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_custom_mouse_cursor(preload("res://Game Logic/invisible_cursor.png"))

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
	$TestCursor.global_position = get_global_mouse_position()
#	aim_direction = $Aimer.global_position.angle_to_point(get_global_mouse_position()) + Vector2.UP.angle()
#	$Aimer.rotation = aim_direction
	set_aimer(delta)

func set_aimer(delta: float) -> void:
	var global_mouse := get_global_mouse_position()
	var mouse_diff := last_global_mouse - global_mouse
	last_global_mouse = global_mouse
	var mouse_movement := delta * mouse_diff.length()
	if mouse_movement > 0:
		$Aimer.rotation = mouse_diff.angle() + Vector2.UP.angle()

func spawn_projectile() -> void: 
	var projectile := PlayerProjectile.instance()
	var main = get_tree().current_scene
	main.add_child(projectile)
	var rot : float = $Aimer.rotation
	projectile.direction = Vector2(cos(rot - PI/2), sin(rot - PI/2))
	projectile.global_position = self.global_position
	
