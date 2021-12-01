extends AbstractState

const CHASE_BASE_DISTANCE := 150.0

func _ready():
	RELATIVE_TRANSITION_CHANCE = 1.0

export var CHASE_ACCELERATION := 90000.0

var angle_offset: float

func process(delta: float, first_time_entering: bool):
	parent = parent as AntEnemy
	if first_time_entering:
		angle_offset = rand_range(45, 85)
		angle_offset *= 1 if randi() % 2 == 0 else -1
		var chase_time := rand_range(1.0, 2.5)
		yield(get_tree().create_timer(chase_time), "timeout")
		back_to_idle()
		return

	if parent.get_node("ScentRay").is_total_colliding:
		back_to_idle()
		return
	var direction_vector = parent.global_position.direction_to(GameStatus.CURRENT_PLAYER.global_position).rotated(deg2rad(angle_offset))
	
	parent.animation_state.travel("Walk")
			
	if parent.animation_tree != null:
		# set idle blend position as last movement blend position
		parent.animation_tree.set("parameters/Walk/blend_position", direction_vector)
		parent.update_shadow(direction_vector)

	
	parent.add_acceleration(GameStatus.const_delta * CHASE_ACCELERATION * direction_vector)
