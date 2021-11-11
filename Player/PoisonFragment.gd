extends Node2D
class_name PoisonFragment

var damage : int
var knockback : float

func _on_Timer_timeout() -> void:
	queue_free()

func _ready() -> void:
	damage = GameStatus.PLAYER_POISON_DAMAGE
	knockback = GameStatus.PLAYER_POISON_KNOCKBACK

func knockback_vector() -> Vector2:
	return Vector2.UP.rotated(rotation) * knockback
