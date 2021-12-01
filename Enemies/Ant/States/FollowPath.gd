extends AbstractState

export var FOLLOW_ACCELERATION := 140000.0
export var STOP_DISTANCE := 30.0
# if this is wanted it should be set from outside
export var stop_when_player_near = false
export var PLAYER_DETECT_DISTANCE := 500.0


# should be a global position to make sure
var target_position: Vector2
var distance_to_player: float
var done = false

signal movement_completed

func process(delta: float, first_time_entering: bool):
	if first_time_entering:
		parent.animation_state.travel("Walk")
		done = false
	if not done:
		var distance_vec := (target_position - parent.global_position) as Vector2
		
		if distance_vec.length() < STOP_DISTANCE:
			state_machine.enabled = false
			parent.animation_state.travel("Idle")
			parent.animation_tree.set("parameters/Idle/blend_position", distance_vec)
			emit_signal("movement_completed")
			done = true
			return
			
		if stop_when_player_near:
			distance_to_player = parent.global_position.distance_to(GameStatus.CURRENT_PLAYER.global_position)
			if distance_to_player < PLAYER_DETECT_DISTANCE:
				parent.animation_state.travel("Idle")
				parent.animation_tree.set("parameters/Idle/blend_position", distance_vec)
				emit_signal("movement_completed")
				done = true
				return
	
		parent.animation_state.travel("Walk")
		parent.animation_tree.set("parameters/Walk/blend_position", distance_vec)

		parent.add_acceleration(GameStatus.const_delta * FOLLOW_ACCELERATION * distance_vec.normalized())
