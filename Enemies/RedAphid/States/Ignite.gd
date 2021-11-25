extends AbstractState

export var CHASE_ACCELERATION := 80000.0

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as RedAphid

	if first_time_entering:
		parent.play_ignite()
	var distance_vector := (parent.scentray.get_player_scent_position_global() - parent.global_position) as Vector2
	var direction_vector = distance_vector.normalized()
	
	parent.play_walk_animation(direction_vector)
	parent.add_acceleration(GameStatus.const_delta * CHASE_ACCELERATION * direction_vector)
