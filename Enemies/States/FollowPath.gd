extends AbstractState

export var FOLLOW_ACCELERATION := 2200.0
export var STOP_DISTANCE := 30.0

# should be a global position to make sure
var target_position: Vector2

signal movement_completed

func process(delta: float, first_time_entering: bool):
	var distance_vec := (target_position - parent.global_position) as Vector2
	
	if distance_vec.length() < STOP_DISTANCE:
		emit_signal("movement_completed")
		state_machine.transition_to("Idle")
		
	parent.add_acceleration(FOLLOW_ACCELERATION * distance_vec.normalized())
