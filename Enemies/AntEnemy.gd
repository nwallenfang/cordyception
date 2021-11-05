extends SlideMover


func _on_Hurtbox_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	# parent should either be a projectile, poison mist or another weapon
	if parent is Projectile:
		var projectile := parent as Projectile
		$EnemyStats.health -= projectile.damage
		add_velocity(projectile.knockback_vector())


func _on_EnemyStats_health_changed() -> void:
	$Healthbar.health = $EnemyStats.health


func _on_EnemyStats_health_zero() -> void:
	queue_free()

func _physics_process(delta: float) -> void:
	accelerate_and_move(delta)
