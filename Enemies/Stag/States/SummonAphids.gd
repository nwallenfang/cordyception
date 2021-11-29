extends AbstractState


func process(delta, first_time_entering):
	if first_time_entering:
		# maybe play a whistling sound
		
		# instance aphids
		
		# transition them to GetThrown
		state_machine.transition_deferred("Idle")
