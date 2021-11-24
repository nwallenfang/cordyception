extends AbstractState

export var FOLLOW_ACCELERATION := 140000.0
export var STOP_DISTANCE := 30.0

# should be a global position to make sure
var target_position: Vector2
var done = false
signal movement_completed
var first_time_following = true

func process(delta: float, first_time_entering: bool):
	if first_time_entering:
		parent.levitation_player.play("up")
		first_time_following = true
		done = false
	elif not done and not parent.levitation_player.is_playing():
		if first_time_following:
			parent.animation_player.play("fly_move")
			first_time_following = false
			
		var distance_vec := (target_position - parent.global_position) as Vector2
		
		if distance_vec.length() < STOP_DISTANCE:
			state_machine.enabled = false
			parent.animation_player.play("fly_idle")
			parent.set_facing_direction(distance_vec)
			emit_signal("movement_completed")
			done = true
			return
		parent.animation_player.play("fly_move")
	
		parent.add_acceleration(delta * FOLLOW_ACCELERATION * distance_vec.normalized())
