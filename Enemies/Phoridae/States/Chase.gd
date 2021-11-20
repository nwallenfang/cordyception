extends AbstractState

# distance where it's still prob. 0 of stopping the chase
# basically, the probability of stopping the chase increases by increasing this distance
const CHASE_BASE_DISTANCE := 500.0

func _ready():
	(self.STOP_CHASE_DENSITY as Curve).max_value = CHASE_BASE_DISTANCE
	RELATIVE_TRANSITION_CHANCE = 0

# randomly decide (depending on distance to player) whether it is time to
# stop chasing
export(Curve) var STOP_CHASE_DENSITY # probability density curve
export var min_chase_time := 1.5
var chase_timer: SceneTreeTimer
func should_stop_chasing(distance: float) -> bool:
	if chase_timer.time_left >= 0.1:
		return false
	if not parent.aggressive:
		return true
	# cap distance from 0 to CHASE_BASE_DISTANCE
	var distance_normalized = min(distance, CHASE_BASE_DISTANCE) / CHASE_BASE_DISTANCE
	var stop_chase_probability = max(STOP_CHASE_DENSITY.interpolate_baked(1 - distance_normalized), 0)
	var random_decider = randf()
	return random_decider < stop_chase_probability

export var CHASE_ACCELERATION := 2200.0
var starting_point: Vector2
var full_length: float
var progress: float

func process(delta: float, first_time_entering: bool):
	if first_time_entering:
		chase_timer = get_tree().create_timer(min_chase_time)
	var line2d = parent.line2D
	var distance_vector := (line2d.points[1] - line2d.points[0]) as Vector2
	var direction_vector = distance_vector.normalized()
	var distance_to_player_scent = distance_vector.length()
	
	if should_stop_chasing(distance_to_player_scent):
		state_machine.transition_deferred("Idle")
		return
		
	if first_time_entering:
		parent.get_node("AnimationPlayer").play("fly_move")
	
	parent.set_facing_direction(direction_vector)
	parent.add_acceleration(CHASE_ACCELERATION * direction_vector)
