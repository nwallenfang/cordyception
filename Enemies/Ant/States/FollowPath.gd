extends AbstractState

export var FOLLOW_ACCELERATION := 2200.0
export var STOP_DISTANCE := 30.0

# should be a global position to make sure
var target_position: Vector2
var done = false
signal movement_completed

func process(delta: float, first_time_entering: bool):
	if first_time_entering:
		parent.animation_state.travel("Walk")
		done = false
	if not done:
		var distance_vec := (target_position - parent.global_position) as Vector2
		
		if distance_vec.length() < STOP_DISTANCE:
			print("stop")
			emit_signal("movement_completed")
			done = true
		
		parent.animation_tree.set("parameters/Walk/blend_position", distance_vec)
		parent.add_acceleration(FOLLOW_ACCELERATION * distance_vec.normalized())
