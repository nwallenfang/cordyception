extends AbstractState

export var follow_acc_base := 100000.0
export var follow_acc_slow := 30000.0
var follow_acc: float = follow_acc_base
export var chance_to_get_distracted := 0.0015

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as RedAphid # Set To Parent Class

	if !is_instance_valid(parent.mother):
		parent.is_full_attacker = true
		state_machine.set_attack_behaviour()
		back_to_idle()
		return

	if randf() < chance_to_get_distracted:
		state_machine.transition_deferred("Distracted")
		return

	if parent.mother is AntEnemy:
		follow_acc = follow_acc_base if parent.mother.state_machine.enabled else follow_acc_slow

	if first_time_entering:
		state_machine.set_mother_behaviour()

	var distance = parent.global_position.distance_to(parent.mother.global_position)
	if distance < parent.mother_radius:
		parent.play_walk_animation(Vector2.ZERO)
	else:
		var direction = parent.global_position.direction_to(parent.mother.global_position)
		parent.play_walk_animation(direction)
		var acc = direction * follow_acc * delta
		parent.add_acceleration(acc)
