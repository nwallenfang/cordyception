extends PhysicsMover
class_name Aphid

export var move_speed := 30000.0
export(NodePath) var mother_path : NodePath setget set_mother_path
export var mother_radius := 10.0
var mother: Node2D = null
func set_mother_path(path: NodePath):
	if path != "":
		mother_path = path
		mother = get_node(mother_path)

func _ready() -> void:
	set_monitor(true)
	set_mother_path(mother_path)

var monitor: bool = true setget set_monitor

func set_monitor(b: bool):
	monitor = b
	$Area.monitorable = b
	$Area.monitoring = b

signal health_boost
func death() -> void:
	emit_signal("health_boost")
	queue_free()

var facing_right := true
func play_walk_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		$AnimationPlayer.play("idle_right" if facing_right else "idle_left")
	else:
		facing_right = direction.x >= 0
		$AnimationPlayer.play("walk_right" if facing_right else "walk_left")

func _process(delta: float) -> void:
	$StateMachine.process(delta)
	accelerate_and_move(delta)

func _on_Area_body_entered(body: Node) -> void:
	connect("health_boost", body as Player, "health_boost")
	$AnimationPlayer.play("death_right" if facing_right else "death_left")
