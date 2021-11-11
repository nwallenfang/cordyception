extends StateMachine

class_name AntEnemyStateMachine

# will be true for the first frame you are in a new state
var first_time_entering = true

# TODO this will be removed
onready var idle_transition_chance

var label_exists := false

func _ready() -> void:	
	previous_non_idle_state = State["Sprint"]
	
	idle_transition_chance = {
		"Idle": 0.0,
		"Chase": 0.44,
		"Shoot": 0.26,
		"Sprint": 0.33
	}
	
	label_exists = get_parent().has_node("StateLabel")
		
func stop():
	enabled = false
	# stop all animations etc.
	# stop Tween movement if currently sprinting
	$Sprint/SprintMovementTween.stop_all()

func transition_to(new_state_name):
	if label_exists:
		get_parent().get_node("StateLabel").text = new_state_name
	first_time_entering = true
	if state.name != "Idle":
		previous_non_idle_state = state
	state = State[new_state_name]
	
func transition_to_random_state():
	var new_state = get_random_next_state(idle_transition_chance)
	transition_to(new_state)




func get_random_next_state(transition_chances: Dictionary):
		# another day of being an idle enemy ant
	# who knows what the day may bring
	# maybe shoot some stuff
	# maybe even go for a little walk
	# let the dice decide
	var rand := randf()  # random seed
	var psum: float = 0.0 # sum of probabilities that were already checked in for loop
	
	# idea: if the random number between 0 and 1 is smaller than the 
	# states up to some point, enter the state
	# else go on. For this the state probabilities' sum has to be 1
	for new_state in State.keys():
		psum += transition_chances[new_state]
		if rand <= psum:
			return new_state
		# random seed doesn't fit new state, go next
	
	print("ERROR no random state was drawn with ", transition_chances)
	
func transition_to_random_different_state():
	# transition to a new state different from last non-idle state
	# copy idle transition chances
	var state_transition_chances = self.idle_transition_chance.duplicate()
	var prob_to_remove: float = state_transition_chances[previous_non_idle_state.name]
	var number_possible_states = 2  # could be calculated to generalize better
	
	state_transition_chances[self.previous_non_idle_state.name] = 0.0
	
	for state_name in State.keys():
		if state_name != "Idle":
			state_transition_chances[state_name] += prob_to_remove / number_possible_states

	transition_to(get_random_next_state(state_transition_chances))

func process(delta: float) -> void:
	if not enabled:
		return
	var this_was_the_first_time = first_time_entering
	state.process(delta, first_time_entering)
	if this_was_the_first_time:
		# first_time_entering is set again in transition method
		first_time_entering = false
