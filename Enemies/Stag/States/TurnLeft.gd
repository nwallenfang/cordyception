extends AbstractState

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0.0

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	state_machine = state_machine as StagStateMachine

	if first_time_entering:
		parent.play_animation("turn_left")
		$Tween.interpolate_property(parent, "sprite_rotation", parent.sprite_rotation, parent.sprite_rotation + 20, .65)
		$Tween.start()
		yield(parent.sprite, "animation_finished")
		back_to_idle()
