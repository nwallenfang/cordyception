extends AbstractState


export var MELEE_RANGE := 2650.0

# question is: where will the check be whether melee attack makes sense?
# have it be in this script for now

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	if first_time_entering:
		var distance_to_player = GameStatus.CURRENT_PLAYER.global_position.distance_to(parent.global_position)
		if distance_to_player > MELEE_RANGE:
			back_to_idle()
			return
		
		# TODO hitboxes!
		parent.play_animation("melee_default")
		$AnimationPlayer.play("phorid")
		yield(get_tree().create_timer(2.0), "timeout")
		parent.melee_hitbox.set_deferred("monitoring", true) 
		parent.melee_hitbox.set_deferred("monitorable", true) 
		parent.melee_hitbox.set_deferred("visible", true) 
		# normal melee attack is a bit boring so spawn some projectiles as well
		$PhoridaeProjectileSpawner.spawn_projectile_here(parent.mandible_point.global_position)
		$PhoridaeProjectileSpawner.spawn_projectile_here(parent.mandible_point.global_position)
		if randi() % 4 == 0:
			$PhoridaeProjectileSpawner.spawn_projectile_here(parent.mandible_point.global_position)
			$PhoridaeProjectileSpawner.spawn_projectile_here(parent.mandible_point.global_position)
		yield(parent.sprite, "animation_finished")
		parent.melee_hitbox.set_deferred("monitoring", false) 
		parent.melee_hitbox.set_deferred("monitorable", false) 
		parent.melee_hitbox.set_deferred("visible", false) 
		back_to_idle()
