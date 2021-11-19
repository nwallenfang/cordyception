extends Node2D

export var MAX_HEALTH := 20 setget set_max_health
export var DAMAGE := 1

# TODO doesn't this affect every enemy then?
signal health_zero
signal health_changed

onready var health := MAX_HEALTH setget set_health

func set_health(new_health: int) -> void:
	var health_prev = health
	health = max(new_health, 0)
	if new_health != health_prev:
		get_parent().healthbar.health = health
		emit_signal("health_changed")
	if health <= 0:
		emit_signal("health_zero")
	

func set_max_health(new_max: int):
	MAX_HEALTH = new_max
	set_health(min(MAX_HEALTH, health))
	get_parent().healthbar.set_max(MAX_HEALTH)
