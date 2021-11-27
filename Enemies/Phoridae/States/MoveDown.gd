extends AbstractState

export var IDLE_TIME_MIN := 0.3
export var IDLE_TIME_MAX := 0.8

func _ready() -> void:
	# you will only transition to Idle explicitly
	RELATIVE_TRANSITION_CHANCE = 0

var idle_timer : SceneTreeTimer

func process(delta, first_time_entering):
	parent = parent as Phoridae
	if parent.aggressive and not parent.flying:
		state_machine.transition_deferred("Transition")
		return
	if parent.flying and not parent.aggressive:
		state_machine.transition_deferred("Transition")
		return
	if first_time_entering:
		if parent.flying:
			parent.animation_player.play("fly_idle")
		else:
			parent.animation_player.play("stand")
		idle_timer = get_tree().create_timer(rand_range(IDLE_TIME_MIN, IDLE_TIME_MAX) if state_machine.previous_non_idle_state.name != "Transition" else 0.1)
		
		yield(idle_timer, "timeout")
		if state_machine.state.name == "Idle":
			state_machine.call_deferred("transition_to_random_state")
