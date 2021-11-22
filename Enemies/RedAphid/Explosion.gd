extends Node2D
class_name Explosion

export var knockback := 80000.0
export var knockback_radius := 550.0

func knockback_vector() -> Vector2:
	var distance := global_position.distance_to(GameStatus.CURRENT_PLAYER.global_position)
	var distance_normalized := clamp(1.0 - (distance / knockback_radius), 0.0, 1.0)
	return global_position.direction_to(GameStatus.CURRENT_PLAYER.global_position) * (knockback * distance_normalized)
