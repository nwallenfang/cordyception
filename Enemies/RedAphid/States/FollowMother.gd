extends AbstractState

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as RedAphid # Set To Parent Class

	if first_time_entering:
		#
		# CODE
		#
		pass
		# state_machine.transition_deferred("Idle")

	var distance = parent.global_position.distance_to(parent.mother.global_position)
	if distance < parent.mother_radius:
		parent.play_walk_animation(Vector2.ZERO)
	else:
		var direction = parent.global_position.direction_to(parent.mother.global_position)
		parent.play_walk_animation(direction)
		var acc = direction * parent.move_speed * delta
		parent.add_acceleration(acc)
