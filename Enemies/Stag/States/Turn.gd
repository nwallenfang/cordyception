extends AbstractState

func _ready() -> void:
	pass

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	if first_time_entering:
		# once this state is reached, decide if you want to turn left or right
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
		else:
			# dont wanna turn right now
			back_to_idle()
