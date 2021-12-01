extends Node2D
class_name Projectile
 
const FRIENDLY_COLOR := Color(38, 229, 10)
const ENEMY_COLOR := Color.brown

const IS_PIERCING := false  # whether or not to be destroyed when hitting something
export var SPEED := 450 setget set_speed
 
onready var direction: Vector2 setget set_direction
onready var damage: int setget set_damage
onready var knockback: float setget set_knockback
onready var velocity := SPEED * direction


func _ready():
	$AnimationPlayer.play("active")
	yield(get_tree().create_timer(3.0), "timeout")
	

func set_direction(new_dir: Vector2):
	direction = new_dir
	velocity = SPEED * direction
	
func set_damage(new_damage: int):
	damage = new_damage

func set_speed(new_speed):
	SPEED = new_speed
	velocity = SPEED * direction

func set_knockback(new_knockback: float):
	knockback = new_knockback

func knockback_vector() -> Vector2:
	return knockback * direction.normalized()

func _physics_process(delta: float) -> void:
	self.position += delta * velocity

func _on_Hitbox_area_entered(area: Area2D) -> void:	
	if not IS_PIERCING:
		# TODO if there will be many projectiles instantiated at once and there 
		# are performance problems, don't free them immediately
		# google Pooling instead
		self.velocity = Vector2.ZERO
		$AnimationPlayer.play("obstacle_collision") 

func fly_animation():
	$AnimationPlayer.play("fly")

func _on_Hitbox_body_entered(body: Node) -> void:
	# Projectile hit a wall
	self.velocity = Vector2.ZERO
	$AnimationPlayer.play("obstacle_collision")


func _on_FadeOut_tween_all_completed() -> void:
	call_deferred("queue_free")
