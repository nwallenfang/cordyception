extends StateMachine
class_name RedAphidStateMachine

onready var label_was_visible = get_parent().get_node("StateLabel").visible

func start():
	enabled = true
	get_parent().get_node("StateLabel").visible = label_was_visible
	if get_parent().mother != null:
		set_mother_behaviour()
	else:
		set_attack_behaviour()


		
func stop():
	enabled = false
	get_parent().get_node("StateLabel").visible = false
#	get_parent().get_node("Body/Hitbox").set_deferred("monitoring", false)
#	get_parent().get_node("Body/Hitbox").set_deferred("monitorable", false)
#	get_parent().get_node("Body/Hurtbox").set_deferred("monitoring", false)
#	get_parent().get_node("Body/Hurtbox").set_deferred("monitorable", false)
	# stop all animations etc.
	transition_to("Idle")

func set_enabled(enable: bool):
	if enable:
		start()
	else:
		stop()


func set_mother_behaviour():
	$FollowMother.RELATIVE_TRANSITION_CHANCE = 1
	$Roll.RELATIVE_TRANSITION_CHANCE = 0
	$Chase.RELATIVE_TRANSITION_CHANCE = 0
	idle_transition_chance = build_absolute_transition_chances()

func set_attack_behaviour():
	$FollowMother.RELATIVE_TRANSITION_CHANCE = 0.0 if get_parent().is_full_attacker else 0.2
	$Roll.RELATIVE_TRANSITION_CHANCE = 0.5
	$Chase.RELATIVE_TRANSITION_CHANCE = 1
	idle_transition_chance = build_absolute_transition_chances()

func process(delta: float) -> void:
	if not enabled:
		return
	var this_was_the_first_time = first_time_entering
	state.process(delta, first_time_entering)
	if this_was_the_first_time:
		# first_time_entering is set again in transition method
		first_time_entering = false

