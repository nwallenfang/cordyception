extends AbstractState


export var MELEE_RANGE := 550.0

# question is: where will the check be whether melee attack makes sense?
# have it be in this script for now

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	if first_time_entering:
		var distance_to_player = GameStatus.CURRENT_PLAYER.global_position.distance_to(parent.global_position)
		if distance_to_player > MELEE_RANGE:
			state_machine.transition_deferred("Idle")
			return
		
		# TODO hitboxes!
		parent.play_animation("melee_default")
		yield(get_tree().create_timer(1.7), "timeout")
		parent.melee_hitbox.set_deferred("monitoring", true) 
		parent.melee_hitbox.set_deferred("monitorable", true) 
		parent.melee_hitbox.set_deferred("visible", true) 
		# normal melee attack is a bit boring so spawn some projectiles as well
		$PhoridaeProjectileSpawner.spawn_projectile_here(parent.projectile_origin.global_position)
		$PhoridaeProjectileSpawner.spawn_projectile_here(parent.projectile_origin.global_position)
		yield(parent.sprite, "animation_finished")
		state_machine.transition_deferred("Idle")
		parent.melee_hitbox.set_deferred("monitoring", false) 
		parent.melee_hitbox.set_deferred("monitorable", false) 
		parent.melee_hitbox.set_deferred("visible", false) 
