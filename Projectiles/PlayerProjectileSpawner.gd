extends Node2D

const PlayerProjectile := preload("res://Projectiles/PlayerProjectile.tscn")

signal cooldown_not_ready

func try_creating_projectile(direction: float) -> void:
	if not $ProjectileCooldown.is_stopped(): # Timer still running
		# Projectile shooting skill is not ready to fire again
		$CooldownNotReadySound.play()
		emit_signal("cooldown_not_ready")
		return
		
	# create projectile
	var projectile := PlayerProjectile.instance()
	var ysort = GameStatus.CURRENT_YSORT
	ysort.add_child(projectile)
	
	projectile.direction = Vector2.UP.rotated(direction)
	projectile.global_position = self.global_position
	projectile.damage = GameStatus.PLAYER_PROJECTILE_DAMAGE
	projectile.knockback = GameStatus.PLAYER_PROJECTILE_KNOCKBACK
	projectile.get_node("Sprite").rotation = direction
	
	
	# start cooldown timer
	$ProjectileCooldown.start()
	GameStatus.CURRENT_UI.get_node("ProjectileCooldownUI").set_blend(0.0)

# refresh GUI
func _process(delta: float) -> void:
	var time_left = $ProjectileCooldown.time_left
	if time_left != 0.0:
		var blend = 1.0 - (time_left / $ProjectileCooldown.wait_time)
		GameStatus.CURRENT_UI.get_node("ProjectileCooldownUI").set_blend(blend)


func _on_ProjectileCooldown_timeout() -> void:
	GameStatus.CURRENT_UI.get_node("ProjectileCooldownUI").set_blend(1.0)
