extends AbstractState

export var distracted_walk_speed := 20000.0
export var max_dist_to_mother := 450.0
func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

var walk_direction := Vector2.ZERO

func null_check():
	return is_instance_valid(parent.mother)

func process(delta, first_time_entering):
	parent = parent as RedAphid

	if first_time_entering:
		var stand_time := rand_range(.7, 1.9)
		var turn := randi() % 2 == 0
		var walk_time := 0.0 if !turn else rand_range(.5, 1.5) * (randi() % 2)
		
		var direction_to_mother := parent.global_position.direction_to(parent.mother.global_position) as Vector2
		var new_direction := direction_to_mother.rotated(deg2rad(180 + rand_range(-90, 90)))
		
		if turn:
			parent.set_facing_direction(new_direction)
		yield(get_tree().create_timer(stand_time), "timeout")
		if not null_check():
			return
		if parent.global_position.distance_to(parent.mother.global_position) > max_dist_to_mother:
			walk_time = 0
		walk_direction = new_direction
		yield(get_tree().create_timer(walk_time), "timeout")
		if not null_check():
			return
		if walk_time != 0:
			var second_stand_time = rand_range(.3, 1.5)
			walk_direction = Vector2.ZERO
			yield(get_tree().create_timer(second_stand_time), "timeout")
		back_to_idle()

	parent.add_acceleration(walk_direction * GameStatus.const_delta * distracted_walk_speed)
	parent.play_walk_animation(walk_direction)

