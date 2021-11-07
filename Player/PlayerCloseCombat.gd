extends Node2D
class_name PlayerCloseCombat

onready var damage := GameStatus.PLAYER_CLOSECOMBAT_DAMAGE
onready var knockback := GameStatus.PLAYER_CLOSECOMBAT_KNOCKBACK
onready var hitbox := $Hitbox as Area2D

func _ready() -> void:
	$Polygon2D.visible = false
	hitbox.monitoring = false
	hitbox.monitorable = false

func strike_on() -> void:
	damage = GameStatus.PLAYER_CLOSECOMBAT_DAMAGE
	knockback = GameStatus.PLAYER_CLOSECOMBAT_KNOCKBACK
	$Polygon2D.visible = true
	hitbox.monitoring = true
	hitbox.monitorable = true

func strike_off() -> void:
	$Polygon2D.visible = false
	hitbox.monitoring = false
	hitbox.monitorable = false

func knockback_vector() -> Vector2:
	return Vector2.UP.rotated(get_global_transform().get_rotation()) * knockback
