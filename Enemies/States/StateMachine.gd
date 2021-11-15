extends Node2D

class_name StateMachine

var enabled := false
# state dictionary (was an enum earlier)
export onready var State: Dictionary  # name -> AbstractState
# current state of the State machine, whenever the StateMachine's process gets called,
# this state's process method gets called
onready var state: AbstractState
export onready var previous_non_idle_state: AbstractState
# State label node
var label_exists := false
# will be true for the first frame you are in a new state
var first_time_entering = true

onready var idle_transition_chance: Dictionary  # (state name (str) -> probability of entering that state from Idle (float))


func build_state_dict() -> Dictionary:
	var state_list = {}
	var index := 0
	for child_state in get_children():
		var casted_state = child_state as AbstractState
		if casted_state == null:
			print("WARNING: child ", child_state, " is not a valid state (must extend Abstract State)")
			continue
			
		state_list[casted_state.name] = casted_state
	
	return state_list
	
func make_state_list_available():
	# to all children
	for child_state in get_children():
		if child_state is AbstractState:
			child_state.set("State", State)
			
			
func transition_to(new_state_name):
	if label_exists:
		get_parent().get_node("StateLabel").text = new_state_name
	first_time_entering = true
	if state.name != "Idle":
		previous_non_idle_state = state
	state = State[new_state_name]  # str -> StatNode
	
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
	# possibles state are those which are not IDLE, not the last state, and not impossible (0) to begin with
	# start at -2 due to IDLE and last state
	var number_possible_states = -2
	
	for state_name in State.keys():
		if state_transition_chances[state_name] != 0.0:
			number_possible_states += 1
	
	if number_possible_states < 0:
		print("ERROR, number of possible states to transition to < 0")
		
	state_transition_chances[self.previous_non_idle_state.name] = 0.0
	
	for state_name in State.keys():
		if state_name != "Idle" and state_transition_chances[state_name] != 0.0:
			state_transition_chances[state_name] += prob_to_remove / number_possible_states

	transition_to(get_random_next_state(state_transition_chances))
	
func build_absolute_transition_chances() -> Dictionary:
	# for ease of use the State Nodes only contain a relative probability
	# such as 1 or 0. Transfer these probabilities to actual ones so that their
	# sum is 1. This dictionary should not change 
	var relative_transition_chances: Dictionary = {}
	var relative_sum: float = 0.0
	
	for child in get_children():
		relative_transition_chances[child.name] = child.RELATIVE_TRANSITION_CHANCE
		relative_sum += child.RELATIVE_TRANSITION_CHANCE

	# make relative to absolute probabilities by dividing each value by the sum		
	for state_name in relative_transition_chances.keys():
		relative_transition_chances[state_name] /= relative_sum
		
	return relative_transition_chances
	
func _ready() -> void:
	State = build_state_dict()
	state = State[State.keys()[0]]  # make initial state random more or less
	previous_non_idle_state = State[State.keys()[0]]
	make_state_list_available()
	
	if GameStatus.AUTO_ENEMY_BEHAVIOR:  # should only be enabled for debugging
		enabled = true
		
	# for clean code assert that there is an Idle state as a child
	idle_transition_chance = build_absolute_transition_chances()
	
	previous_non_idle_state = State["Sprint"]
	label_exists = get_parent().has_node("StateLabel")
		
		
func stop() -> void:
	# overwrite this
	pass
	
func process(delta: float):
	# overwrite this
	pass
