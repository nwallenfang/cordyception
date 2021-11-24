extends Node

class_name AbstractState

# edit this in the property editor if you want to
export var RELATIVE_TRANSITION_CHANCE: float = 1.0

onready var state_machine
onready var State: Dictionary  # {"Idle" -> IdleStateNode, ...}
onready var parent = get_parent().get_parent()

func back_to_idle() -> void:
	if state_machine.state.name == self.name and state_machine.enabled:
		state_machine.transition_deferred("Idle")

func _ready() -> void:
	state_machine = get_parent()
	State = state_machine.State  
	# TODO  print warning if not child of state machine
	
func process(delta: float, first_time_entering: bool) -> void:
	# implement this
	pass
