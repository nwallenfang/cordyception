extends Node2D

func _process(delta: float) -> void:
	if GameStatus.AIMER_VISIBLE and GameStatus.USE_CROSSHAIR:
		visible = true
	else:
		visible = false
	if visible:
		global_position = get_global_mouse_position()
