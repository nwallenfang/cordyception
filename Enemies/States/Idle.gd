extends AbstractState


export var IDLE_TIME := 0.2

func _ready() -> void:
	# you will only transition to Idle explicitly
	RELATIVE_TRANSITION_CHANCE = 0


func _on_IdleTimer_timeout() -> void:
	state_machine.transition_to_random_different_state()
	$IdleTimer.stop()
	
	
func process(delta, first_time_entering):
	if first_time_entering:
		if parent.animation_state != null:
			var last_state:String = parent.animation_state.get_current_node()
			parent.animation_state.travel("Idle")
			# set idle blend position as last movement blend position
			var last_blend = parent.animation_tree.get("parameters/"+ last_state + "/blend_position")
			parent.animation_tree.set("parameters/Idle/blend_position", last_blend)

	if $IdleTimer.is_stopped():
		$IdleTimer.start(IDLE_TIME)
	pass
	
