extends Path2D
class_name AphidPath

onready var follow := $PathFollow2D as PathFollow2D

export(bool) var reversed := false
export(float, 0, 10) var min_wait := 0.8
export(float, 0, 10) var max_wait := 3.0
export(float, 0, 1) var min_travel := 0.2
export(float, 0, 1) var max_travel := 0.5
export(float, 0, 0.5) var border := 0.25
export var speed := 50.0
var animation_to_right := true

func _ready() -> void:
	$Timer.start(rand_range(min_wait, max_wait))

func _on_Timer_timeout() -> void:
	var old_position :float = follow.unit_offset
	var direction : float = (randi() % 2) * 2 - 1  # random get -1 or 1
	if old_position < border:
		direction = 1
	if old_position > 1.0 - border:
		direction = -1
	var distance := rand_range(min_travel, max_travel) * direction
	var target_position := clamp(old_position + distance, 0, 1)
	var actual_distance : float = abs((target_position - old_position) * curve.get_baked_length())
	$Tween.interpolate_property(follow, "unit_offset", old_position, target_position, actual_distance / speed, Tween.TRANS_LINEAR)
	$Tween.start()

func _on_Tween_tween_all_completed() -> void:
	$Timer.stop()
	$Timer.start(rand_range(min_wait, max_wait))
