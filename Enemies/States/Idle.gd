extends AbstractState


export var IDLE_TIME := 0.2

func _ready() -> void:
	# you will only transition to Idle explicitly
	RELATIVE_TRANSITION_CHANCE = 0

	
func process(delta, first_time_entering):
	if first_time_entering:
		state_machine.transition_to_random_state()

	
	
