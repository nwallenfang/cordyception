extends Node2D
class_name PhoridaeProjectile

export var knockback := 50000.0 
export var speed := 320.0
export var homing := 20.0
export var soft_collision_speed := 50.0

onready var direction: Vector2
onready var velocity := speed * direction
onready var player = GameStatus.CURRENT_PLAYER

func set_direction_and_velocity(new_dir: Vector2):
	direction = new_dir.normalized()
	velocity = speed * direction

func knockback_vector() -> Vector2:
	return knockback * direction.normalized()

func _on_Hitbox_area_entered(area: Area2D) -> void:
	if area.name == "Hurtbox":
		# Projectile hit a player
		# don't destroy projectile if player is dashing
		var player_object = area.get_parent()
		if player_object.state == player_object.State.DASH:
			return
	queue_free()

func _physics_process(delta):
	for area in $SoftCollision.get_overlapping_areas():
		velocity += area.global_position.direction_to(global_position) * soft_collision_speed
	set_direction_and_velocity(velocity + homing * global_position.direction_to(player.global_position))
	global_position += velocity * delta

func start() -> void:
	set_direction_and_velocity(global_position.direction_to(player.global_position))
	$Lifetime.start()

func _on_Lifetime_timeout():
	$FadePlayer.play("fade")
