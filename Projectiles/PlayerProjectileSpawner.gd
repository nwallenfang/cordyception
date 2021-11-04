extends Node2D

const PlayerProjectile := preload("res://Projectiles/Projectile.tscn")

signal cooldown_not_ready

func try_creating_projectile(direction: float) -> void:
	if not $ProjectileCooldown.is_stopped(): # Timer still running
		# Projectile shooting skill is not ready to fire again
		emit_signal("cooldown_not_ready")  # TODO maybe add sound when this fires
		return
		
	# create projectile
	var projectile := PlayerProjectile.instance()
	var main = get_tree().current_scene
	main.add_child(projectile)
	projectile.direction = Vector2.UP.rotated(direction)
	projectile.global_position = self.global_position
	projectile.damage = PlayerStats.PROJECTILE_DAMAGE
	
	# start cooldown timer
	$ProjectileCooldown.start()
