extends AbstractState

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0.0
	
func process(delta, first_time_entering):
	parent = parent as StagBeetle
	state_machine = state_machine as StagStateMachine

	if first_time_entering:
		parent.play_animation("turn_right")
		$Tween.interpolate_property(parent, "sprite_rotation", parent.sprite_rotation, parent.sprite_rotation - 60, .8)
		$Tween.start()
		yield(parent.sprite, "animation_finished")
		state_machine.transition_deferred("Idle")
