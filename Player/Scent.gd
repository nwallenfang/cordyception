extends Node2D
class_name Scent

func _on_Timer_timeout() -> void:
	GameStatus.CURRENT_PLAYER.scent_trail.erase(self)
	queue_free()
