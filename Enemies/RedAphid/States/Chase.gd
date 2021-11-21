extends AbstractState

export var min_chase_time := 2.0
export var max_chase_time := 5.0
export var CHASE_ACCELERATION := 500.0

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 1

func process(delta: float, first_time_entering: bool):
	parent = parent as RedAphid
	if first_time_entering:
		parent.set_ignite_area(true)
		var chase_timer := get_tree().create_timer(rand_range(min_chase_time, max_chase_time))
		yield(chase_timer, "timeout")
		if state_machine.state.name == "Chase":
			parent.set_ignite_area(false)
			state_machine.transition_deferred("Idle")
		return
	
	if parent.ignite_ready:
		state_machine.transition_deferred("Ignite")
	
	var line2d = parent.line2D
	var distance_vector := (line2d.points[1] - line2d.points[0]) as Vector2
	var direction_vector = distance_vector.normalized()
	
	parent.play_walk_animation(direction_vector)
	parent.add_acceleration(CHASE_ACCELERATION * direction_vector)
