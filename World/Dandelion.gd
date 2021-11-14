extends StaticBody2D

export var OFFSET_SCALE := 0.7

func _ready() -> void:
	$Sprite.material.set("shader_param/offset", (global_position.x / 100.0) * OFFSET_SCALE)
