extends AbstractState

func _ready() -> void:
	# you will only transition to Idle explicitly
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	if first_time_entering:
		var direction_to_player = GameStatus.CURRENT_PLAYER.global_position.direction_to(parent.global_position)
		var angle_deg = parent.normalize_angle(rad2deg(direction_to_player.angle()) + 90 - parent.sprite_rotation)
		
		if angle_deg > 60:
			state_machine.transition_deferred("TurnLeftFast")
		elif angle_deg < -60:
			state_machine.transition_deferred("TurnRightFast")
		elif angle_deg > 20:
			state_machine.transition_deferred("TurnLeft")
		elif angle_deg < -20:
			state_machine.transition_deferred("TurnRight")
		state_machine.call_deferred("transition_to_random_state")
#	parent.play_animation("idle", false)
