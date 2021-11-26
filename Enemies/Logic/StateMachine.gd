extends Node2D

class_name StateMachine

export var print_random_calculation := false

var enabled := false setget set_enabled
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

export var ALLOW_SAME_STATE_IN_A_ROW := true

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
	if ALLOW_SAME_STATE_IN_A_ROW:
		var new_state = _get_random_next_state(idle_transition_chance)
		transition_to(new_state)
	else:
		_transition_to_random_different_state()

signal transition_to_idle
func transition_deferred(new_state_name: String) -> void:
	call_deferred("transition_to", new_state_name)
	if new_state_name == "Idle":
		emit_signal("transition_to_idle")

signal state_once_executed
func execute_state_once(state_name: String) -> void:
	var currently_enabled := enabled
	var prev_state_name = state.name
	if !currently_enabled:
		set_enabled(true)
	first_time_entering = true
	transition_deferred(state_name)
	yield(self, "transition_to_idle")
	if !currently_enabled:
		set_enabled(false)
	transition_deferred(prev_state_name)
	emit_signal("state_once_executed")

func _get_random_next_state(transition_chances: Dictionary):
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
#			if print_random_calculation:
#				print(transition_chances)
#				print(str(rand) + " -> " + new_state)
			return new_state
		# random seed doesn't fit new state, go next
	
	print("ERROR no random state was drawn with ", transition_chances)
	
func _transition_to_random_different_state():
	# transition to a new state different from last non-idle state
	# copy idle transition chances
	var state_transition_chances = self.idle_transition_chance.duplicate(true)
	var prob_to_remove: float = state_transition_chances[previous_non_idle_state.name]
	# possibles state are those which not the last state, and not impossible (0) to begin with
	# note that idle is already accounted for since it's probability 0
	var number_possible_states = -1
	
	for state_name in State.keys():
		if state_transition_chances[state_name] != 0.0:
			number_possible_states += 1
	
	if number_possible_states <= 0:
		print("ERROR, number of possible states to transition to <= 0 (Better allow same state in a row)")
		
	state_transition_chances[self.previous_non_idle_state.name] = 0.0
	
	for state_name in State.keys():
		if state_name != "Idle" and state_transition_chances[state_name] != 0.0:
			state_transition_chances[state_name] += prob_to_remove / number_possible_states

	transition_to(_get_random_next_state(state_transition_chances))
	
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


func find_initial_state_and_prev():
	# initial state and previous state should at least make sense for the 
	# transition chances
	var first_possible_state := ""
	var second_possible_state := ""
	for name in idle_transition_chance.keys():
		if idle_transition_chance[name] > 0.0:
			if first_possible_state.empty():
				first_possible_state = name
			elif second_possible_state.empty():
				second_possible_state = name
			else:
				break
	if first_possible_state.empty():
		print("WARNING: find_initial_state_and_prev(): Not enough possible states!!")
	
	state = State["Idle"] # first state should be Idle
	if not first_possible_state.empty():
		# if previous state can NOT be set, it is expected that reaching same state
		# twice in a row is no problem (see ALLOW_.....)
		previous_non_idle_state = State[first_possible_state]

func _ready() -> void:
	State = build_state_dict()
	make_state_list_available()
	
	if GameStatus.AUTO_ENEMY_BEHAVIOR:  # should only be enabled for debugging
		enabled = true
		
	# TODO for cleaner code assert that there is an Idle state as a child
	idle_transition_chance = build_absolute_transition_chances()
	find_initial_state_and_prev()
	label_exists = get_parent().has_node("StateLabel")
		

func set_behavior_to(probabilities: Dictionary):
	# first set probability property in child state
	for child_state in get_children():
		child_state.RELATIVE_TRANSITION_CHANCE = 0.0
	for state_name in probabilities.keys():
		var _state = get_node(state_name)
		if _state != null:
			_state.RELATIVE_TRANSITION_CHANCE = probabilities[state_name]
		else:
			print("behavior WARN: state ", state_name, " doesn't exist!")

	# second force transition chance recalculation
	idle_transition_chance = build_absolute_transition_chances()
	#$StateMachine.find_initial_state_and_prev()

func stop() -> void:
	# overwrite this
	pass
	
func process(delta: float):
	# overwrite this
	pass
	
func set_enabled(enable: bool):
	# overwrite this in subclass
	pass
