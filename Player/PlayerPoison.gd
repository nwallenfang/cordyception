extends Node2D
class_name PlayerPoison

var active := false setget set_active
var target_direction := 0.0 setget set_direction
var local_coords: bool setget set_local_coords

func _ready() -> void:
	self.active = false
	self.local_coords = false

func set_active(new_state) -> void:
	active = new_state
	$PoisonFog.emitting = new_state
	$PoisonSpray.emitting = new_state
	if active:
		$Timer.start()
	else:
		$Timer.stop()

func set_direction(direction: float) -> void:
	target_direction = direction

func _process(delta: float) -> void:
	if active:
		var current_rotation = global_transform.get_rotation()
		rotate(target_direction - current_rotation)

func set_local_coords(local: bool) -> void:
	local_coords = local
	$PoisonFog.local_coords = local_coords
	$PoisonSpray.local_coords = local_coords

const POISON_FRAGMENT = preload("res://Player/PoisonFragment.tscn")
func _on_Timer_timeout() -> void:
	var fragment := POISON_FRAGMENT.instance() as PoisonFragment
	GameStatus.CURRENT_YSORT.add_child(fragment)
	fragment.global_position = global_position
	fragment.rotation = global_transform.get_rotation()

