extends AbstractState

export var follow_acc := 100000.0

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as RedAphid # Set To Parent Class

	if first_time_entering:
		state_machine.set_mother_behaviour()

	var distance = parent.global_position.distance_to(parent.mother.global_position)
	if distance < parent.mother_radius:
		parent.play_walk_animation(Vector2.ZERO)
	else:
		var direction = parent.global_position.direction_to(parent.mother.global_position)
		parent.play_walk_animation(direction)
		var acc = direction * follow_acc * delta
		parent.add_acceleration(acc)
