extends StateMachine

class_name PhoridaeStateMachine

onready var label_was_visible = get_parent().get_node("StateLabel").visible


func _ready() -> void:
	enabled = false

func start():
	enabled = true
	get_parent().get_node("StateLabel").visible = label_was_visible
	get_parent().get_node("Body/Hitbox").set_deferred("monitoring", true)
	get_parent().get_node("Body/Hitbox").set_deferred("monitorable", true)
	get_parent().get_node("Body/Hurtbox").set_deferred("monitoring", true)
	get_parent().get_node("Body/Hurtbox").set_deferred("monitorable", true)

	# stop all animations etc.


		
func stop():
	enabled = false
	get_parent().get_node("StateLabel").visible = false
	get_parent().get_node("Body/Hitbox").set_deferred("monitoring", false)
	get_parent().get_node("Body/Hitbox").set_deferred("monitorable", false)
	get_parent().get_node("Body/Hurtbox").set_deferred("monitoring", false)
	get_parent().get_node("Body/Hurtbox").set_deferred("monitorable", false)
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

func update_transition_chances() -> void:
	if get_parent().flying:
		$Walking.RELATIVE_TRANSITION_CHANCE = 0
		$Chase.RELATIVE_TRANSITION_CHANCE = 1.5
		$Shoot.RELATIVE_TRANSITION_CHANCE = 1
	else:
		$Walking.RELATIVE_TRANSITION_CHANCE = 1
		$Chase.RELATIVE_TRANSITION_CHANCE = 0
		$Shoot.RELATIVE_TRANSITION_CHANCE = 0
	idle_transition_chance = build_absolute_transition_chances()
