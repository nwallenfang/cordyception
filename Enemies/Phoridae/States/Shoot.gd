extends AbstractState

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as Phoridae
	if first_time_entering:
		parent.projectile_spawner.spawn_projectile()
		parent.set_facing_direction(parent.global_position.direction_to(GameStatus.CURRENT_PLAYER.global_position))
		var distance = parent.global_position.distance_to(GameStatus.CURRENT_PLAYER.global_position)
		if distance < parent.fly_sound_radius:
			parent.play_fly_sound_if_suitable()
		yield(get_tree().create_timer(1),"timeout")
		state_machine.transition_deferred("Idle")
