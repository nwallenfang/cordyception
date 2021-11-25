extends AbstractState

# distance where it's still prob. 0 of stopping the chase
# basically, the probability of stopping the chase increases by increasing this distance
const CHASE_BASE_DISTANCE := 150.0

func _ready():
	(self.STOP_CHASE_DENSITY as Curve).max_value = CHASE_BASE_DISTANCE

# randomly decide (depending on distance to player) whether it is time to
# stop chasing
export(Curve) var STOP_CHASE_DENSITY # probability density curve
func should_stop_chasing(distance: float) -> bool:
	# cap distance from 0 to CHASE_BASE_DISTANCE
	var distance_normalized = min(distance, CHASE_BASE_DISTANCE)
	var stop_chase_probability = max(STOP_CHASE_DENSITY.interpolate_baked(CHASE_BASE_DISTANCE - distance_normalized), 0)
	var random_decider = randf()
	return random_decider < stop_chase_probability

export var CHASE_ACCELERATION := 110000.0
var starting_point: Vector2
var full_length: float
var progress: float

	
func process(delta: float, first_time_entering: bool):	
	var line2d = parent.get_node("Line2D")
	var distance_vector := (line2d.points[1] - line2d.points[0]) as Vector2
	var direction_vector = distance_vector.normalized()
	var distance_to_player_scent = distance_vector.length()
	
	if should_stop_chasing(distance_to_player_scent):
		state_machine.transition_deferred("Idle")
		
	if first_time_entering:
		if parent.animation_state != null:
			parent.animation_state.travel("Walk")
			
	if parent.animation_tree != null:
		# set idle blend position as last movement blend position
		parent.animation_tree.set("parameters/Walk/blend_position", direction_vector)

	
	parent.add_acceleration(GameStatus.const_delta * CHASE_ACCELERATION * direction_vector)
