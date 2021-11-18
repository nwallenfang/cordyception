extends Node2D

export var knockback := 30000.0 
export var SPEED := 200.0

onready var direction: Vector2 setget set_direction
onready var velocity := SPEED * direction

func set_direction(new_dir: Vector2):
	direction = new_dir
	velocity = SPEED * direction

func set_knockback(new_knockback: float):
	knockback = new_knockback

func knockback_vector() -> Vector2:
	return knockback * direction.normalized()

func _on_Hitbox_area_entered(area: Area2D) -> void:
	queue_free()
