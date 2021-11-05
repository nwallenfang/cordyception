tool
extends AnimatedSprite
class_name SingleHeartUI

export var alive := true setget set_alive

func set_alive(_alive: bool) -> void:
	alive = _alive
	animation = "Alive" if alive else "Dead"

func animate() -> void:
	if alive:
		animation = "AliveBlink"
		frame = 0

func _ready() -> void:
	frames = preload("res://UI/SingleHeartUI.tres")
