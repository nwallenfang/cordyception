extends AbstractState

func _ready() -> void:
	# you will only transition to Idle explicitly
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	if first_time_entering:
		parent.play_animation("idle", false)
		state_machine.call_deferred("transition_to_random_state")
