extends PhysicsMover
class_name RedAphid

onready var line2D := $Line2D as Line2D

export var move_speed := 50000.0
export(NodePath) var mother_path : NodePath setget set_mother_path
export var mother_radius := 10.0
var mother: Node2D = null
func set_mother_path(path: NodePath):
	mother_path = path
	mother = get_node(mother_path)

func _ready() -> void:
	set_mother_path(mother_path)
	set_ignite_area(false)
	set_roll_area(false)

func set_ignite_area(b: bool):
	$IgniteArea.monitorable = b
	$IgniteArea.monitoring = b

func set_roll_area(b: bool):
	$RollCollision.monitorable = b
	$RollCollision.monitoring = b

const SPEED_DUST = preload("res://Enemies/RedAphid/SpeedDust.tscn")
func create_speed_dust():
	var dust = SPEED_DUST.instance()
	GameStatus.CURRENT_YSORT.add_child(dust)
	dust.global_position = global_position
	dust.connect("animation_finished", dust, "queue_free")
	dust.playing = true

const EXPLOSION = preload("res://Enemies/RedAphid/Explision.tscn")
func create_expolision_and_die():
	var explosion = SPEED_DUST.instance()
	GameStatus.CURRENT_YSORT.add_child(explosion)
	explosion.global_position = global_position
	queue_free()

var facing_right := true

func set_facing_direction(direction: Vector2):
	if direction == Vector2.ZERO:
		return
	facing_right = direction.x >= 0

func play_walk_animation(direction: Vector2):
	set_facing_direction(direction)
	if direction == Vector2.ZERO:
		$AnimationPlayer.play("idle_right" if facing_right else "idle_left")
	else:
		$AnimationPlayer.play("walk_right" if facing_right else "walk_left")

func play_ignite():
	$AnimationPlayer.play("idle_right" if facing_right else "idle_left")
	$ExplosionPlayer.play("ignite")

func _process(delta: float) -> void:
	line2D.points[1] = $ScentRay.get_player_scent_position() - global_position
	$StateMachine.process(delta)
	accelerate_and_move(delta)

func play_start_roll():
	$SpinPlayer.play("spin_right" if facing_right else "spin_left")
	$AnimationPlayer.play("roll_in_right" if facing_right else "roll_in_left")

func play_speed_roll():
	create_speed_dust()
	$SpinPlayer.play("spin_right_fast" if facing_right else "spin_left_fast")

signal roll_stopped
func play_stop_roll():
	$SpinPlayer.play("spin_right" if facing_right else "spin_left")
	$AnimationPlayer.play("roll_out_right" if facing_right else "roll_out_left")
	yield($SpinPlayer,"animation_finished")
	yield($SpinPlayer,"animation_finished")
	$SpinPlayer.play("idle")
	emit_signal("roll_stopped")

func _on_RollCollision_body_entered(body: Node) -> void:
	create_expolision_and_die()

var ignite_ready := false
func _on_IgniteArea_body_entered(body: Node) -> void:
	ignite_ready = true
