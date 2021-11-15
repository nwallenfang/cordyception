extends StateMachine

class_name AntEnemyStateMachine

		
func stop():
	enabled = false
	# stop all animations etc.
	# stop Tween movement if currently sprinting
	$Sprint/SprintMovementTween.stop_all()
	transition_to("Idle")


func process(delta: float) -> void:
	if not enabled:
		return
	var this_was_the_first_time = first_time_entering
	state.process(delta, first_time_entering)
	if this_was_the_first_time:
		# first_time_entering is set again in transition method
		first_time_entering = false
