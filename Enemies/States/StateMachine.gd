extends Node2D

class_name StateMachine

var enabled := false
# state dictionary (was an enum earlier)
export onready var State: Dictionary  # name -> AbstractState
onready var state: AbstractState
export onready var previous_non_idle_state: AbstractState

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
	# to all children, doesn't work yet....
	for child_state in get_children():
		if child_state is AbstractState:
			child_state.set("State", State)
	
func build_absolute_transition_chances() -> Dictionary:
	# for ease of use the State Nodes only contain a relative probability
	# such as 1 or 0. Transfer these probabilities to actual ones so that their
	# sum is 1. This dictionary should not change 
	
	# TODO
	return {}

func stop() -> void:
	# overwrite this
	pass
	
func _ready() -> void:
	State = build_state_dict()
	state = State[State.keys()[0]]  # make initial state random more or less
	previous_non_idle_state = State[State.keys()[0]]
	make_state_list_available()
	
	if GameStatus.AUTO_ENEMY_BEHAVIOR:  # should only be enabled for debugging
		enabled = true
