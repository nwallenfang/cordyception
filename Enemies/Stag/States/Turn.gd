extends AbstractState

export var IDLE_TIME_MIN := 0.3
export var IDLE_TIME_MAX := 0.8

func _ready() -> void:
	# you will only transition to Idle explicitly
	pass

var idle_timer : SceneTreeTimer

func process(delta, first_time_entering):
	if first_time_entering:
		# once this state is reached, decide if you want to turn left or right
		var direction_to_player = GameStatus.CURRENT_PLAYER.global_position.direction_to(parent.global_position)
		var angle_deg = rad2deg(deg2rad(rad2deg(direction_to_player.angle()) + 90 + parent.sprite_rotation))
		
		if angle_deg > 20:
			state_machine.transition_deferred("TurnLeft")			
		elif angle_deg < -20:
			state_machine.transition_deferred("TurnRight")
		else:
			# dont wanna turn right now
			state_machine.transition_deferred("Idle")
