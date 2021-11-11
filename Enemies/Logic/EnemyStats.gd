extends Node2D

export var MAX_HEALTH := 20
export var DAMAGE := 1

# TODO doesn't this affect every enemy then?
signal health_zero
signal health_changed

onready var health := MAX_HEALTH setget set_health

func set_health(new_health: int) -> void:
	var health_prev = health
	health = max(new_health, 0)
	if new_health != health_prev:
		emit_signal("health_changed")
	if health <= 0:
		emit_signal("health_zero")
	

