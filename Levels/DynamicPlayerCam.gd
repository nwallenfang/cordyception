extends Node2D

var target : Node2D = null setget set_target
export var proportion := 0.5
export var max_from_player := 300.0

func set_target(new_target):
	target = new_target
	update_global_position()
	
func update_global_position():
	global_position = (1.0 - proportion) * GameStatus.CURRENT_PLAYER.global_position + proportion * target.global_position

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		if target != null:
			update_global_position()
