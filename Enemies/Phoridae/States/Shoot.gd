extends AbstractState

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as Phoridae
	if first_time_entering:
		parent.projectile_spawner.spawn_projectile()
		parent.set_facing_direction(parent.global_position.direction_to(GameStatus.CURRENT_PLAYER.global_position))
		yield(get_tree().create_timer(1),"timeout")
		state_machine.transition_deferred("Idle")
