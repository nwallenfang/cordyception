extends StateMachine
class_name AphidStateMachine

onready var label_was_visible = get_parent().get_node("StateLabel").visible

func start():
	enabled = true
	get_parent().get_node("StateLabel").visible = label_was_visible
	# stop all animations etc.

func stop():
	enabled = false
	get_parent().get_node("StateLabel").visible = false
	# stop all animations etc.
	transition_to("Idle")

func set_enabled(enable: bool):
	if enable:
		start()
	else:
		stop()

func process(delta: float) -> void:
	if not enabled:
		return
	var this_was_the_first_time = first_time_entering
	state.process(delta, first_time_entering)
	if this_was_the_first_time:
		# first_time_entering is set again in transition method
		first_time_entering = false
