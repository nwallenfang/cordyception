extends Node2D
class_name PoisonFragment

var damage : int

func _on_Timer_timeout() -> void:
	queue_free()

func _ready() -> void:
	damage = GameStatus.PLAYER_POISON_DAMAGE
