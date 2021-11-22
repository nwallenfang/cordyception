extends AbstractState

export var FOLLOW_ACCELERATION := 2200.0
export var STOP_DISTANCE := 30.0

# should be a global position to make sure
var target_position: Vector2
var done = false
signal movement_completed

func process(delta: float, first_time_entering: bool):
	if first_time_entering:
		parent.animation_state.travel("Walk")
		done = false

	var distance = parent.global_position.distance_to(parent.mother.global_position)
	if distance < parent.mother_radius:
		parent.play_walk_animation(Vector2.ZERO)
	else:
		var direction = parent.global_position.direction_to(parent.mother.global_position)
		parent.play_walk_animation(direction)
		var acc = direction * parent.move_speed * delta
		parent.add_acceleration(acc)
		
		
	parent.animation_tree.set("parameters/Walk/blend_position", Vector2.ZERO)

#		if distance_vec.length() < STOP_DISTANCE:
#			emit_signal("movement_completed")
#			done = true
