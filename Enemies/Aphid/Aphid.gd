extends Node2D
class_name Aphid

func _ready() -> void:
	set_monitor(true)

var monitor: bool = true setget set_monitor

func set_monitor(b: bool):
	monitor = b
	$Area.monitorable = b
	$Area.monitoring = b

signal health_boost
func death() -> void:
	emit_signal("health_boost")
	queue_free()
