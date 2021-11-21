extends AbstractState

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as Node2D # Set To Parent Class

	if first_time_entering:
		#
		# CODE
		#
		state_machine.transition_deferred("Idle")

	#
	# CODE
	#
