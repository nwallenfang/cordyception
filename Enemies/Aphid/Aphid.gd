extends Node2D
class_name Aphid

func _ready() -> void:
	$Area.monitorable = true
	$Area.monitoring = true

signal health_boost
func death() -> void:
	emit_signal("health_boost")
	queue_free()
