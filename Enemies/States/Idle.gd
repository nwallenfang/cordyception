extends AbstractState


export var IDLE_TIME := 0.2

func _ready() -> void:
	# you will only transition to Idle explicitly
	RELATIVE_TRANSITION_CHANCE = 0


func _on_IdleTimer_timeout() -> void:
	state_machine.transition_to_random_different_state()
	$IdleTimer.stop()
	
	
func process(delta, first_time_entering):
	if $IdleTimer.is_stopped():
		$IdleTimer.start(IDLE_TIME)
	pass
	
