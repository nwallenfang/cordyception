extends AbstractState

export var IDLE_TIME := 0.5

func _ready() -> void:
	# you will only transition to Idle explicitly
	RELATIVE_TRANSITION_CHANCE = 0

var idle_timer : SceneTreeTimer

func process(delta, first_time_entering):
	parent = parent as Phoridae
	if parent.aggressive and not parent.flying:
		state_machine.transition_to("Transition")
		return
	if first_time_entering:
		if parent.flying:
			parent.animation_player.play("fly_idle")
		else:
			parent.animation_player.play("stand")
		idle_timer = get_tree().create_timer(IDLE_TIME * (1 + randi() % 3))
		
	yield(idle_timer, "timeout")
	if state_machine.state.name == "Idle":
		state_machine.call_deferred("transition_to_random_state")
