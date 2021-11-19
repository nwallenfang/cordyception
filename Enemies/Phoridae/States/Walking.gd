extends AbstractState

export var walk_time := 0.3

func _ready():
	RELATIVE_TRANSITION_CHANCE = 1

var direction_vector := Vector2.ZERO
var walk_timer : SceneTreeTimer

func process(delta: float, first_time_entering: bool):
	if first_time_entering:
		direction_vector = Vector2.UP.rotated(rand_range(-PI, PI))
		parent.get_node("AnimationPlayer").play("walk")
		walk_timer = get_tree().create_timer(1 + (randi() % 5) * walk_time)
	
	if parent.aggressive and not parent.flying:
		walk_timer = null
		state_machine.transition_to("Transition")
		return
	
	parent.set_facing_direction(direction_vector)
	parent.add_acceleration(direction_vector * parent.walk_speed)
	yield(walk_timer, "timeout")
	if state_machine.state.name == "Walk":
		state_machine.transition_to("Idle")
