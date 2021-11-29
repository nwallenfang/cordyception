extends AbstractState


export var MELEE_RANGE := 550.0

# question is: where will the check be whether melee attack makes sense?
# have it be in this script for now

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	if first_time_entering:
		var distance_to_player = GameStatus.CURRENT_PLAYER.global_position.distance_to(parent.global_position)
		print(distance_to_player)
		if distance_to_player > MELEE_RANGE:
			state_machine.transition_deferred("Idle")
			return
		# timing is important for the hitboxes
		yield(get_tree().create_timer(0.8), "timeout")
		parent.swipe_hitbox.set_deferred("monitoring", true) 
		parent.swipe_hitbox.set_deferred("monitorable", true) 
		parent.swipe_hitbox.set_deferred("visible", true) 
		parent.play_animation("melee_swipe")
		yield(parent.sprite, "animation_finished")
		parent.swipe_hitbox.set_deferred("monitoring", false) 
		parent.swipe_hitbox.set_deferred("monitorable", false) 
		parent.swipe_hitbox.set_deferred("visible", false) 
		state_machine.transition_deferred("Idle")
