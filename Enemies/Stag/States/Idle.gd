extends AbstractState

func _ready() -> void:
	# you will only transition to Idle explicitly
	RELATIVE_TRANSITION_CHANCE = 0

var turn_counter := 0
export var max_conseq_turns := 1

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	if first_time_entering:
		if randi() % 3 == 0:
			parent.play_animation("idle_short")
			yield(parent.sprite, "animation_finished")
		elif randi() % 5 == 0:
			parent.play_animation("idle")
			yield(parent.sprite, "animation_finished")
		
		var direction_to_player = GameStatus.CURRENT_PLAYER.global_position.direction_to(parent.global_position)
		var angle_deg = parent.normalize_angle(rad2deg(direction_to_player.angle()) + 90 - parent.sprite_rotation)
		
		if turn_counter >= max_conseq_turns:
			turn_counter = 0
			state_machine.call_deferred("transition_to_random_state")
			return
		turn_counter += 1
		
		if angle_deg > 60:
			state_machine.transition_deferred("TurnLeftFast")
		elif angle_deg < -60:
			state_machine.transition_deferred("TurnRightFast")
		elif angle_deg > 20:
			state_machine.transition_deferred("TurnLeft")
		elif angle_deg < -20:
			state_machine.transition_deferred("TurnRight")
		else:
			turn_counter = 0
			state_machine.call_deferred("transition_to_random_state")
#	parent.play_animation("idle", false)
