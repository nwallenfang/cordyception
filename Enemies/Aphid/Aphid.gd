extends Area2D
class_name Aphid

func _ready() -> void:
	monitorable = true
	monitoring = true

signal health_boost
func death() -> void:
	emit_signal("health_boost")
	queue_free()
