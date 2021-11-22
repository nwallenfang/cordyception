extends AbstractState

export var wait_time := 2.0

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as AntEnemy

	if first_time_entering:
		var player_pos := GameStatus.CURRENT_PLAYER.global_position
		var direction := parent.global_position.direction_to(player_pos) as Vector2
		parent.animation_state.travel("Throw")
		parent.animation_tree.set("parameters/Throw/blend_position", direction)
		yield(get_tree().create_timer(wait_time), "timeout")
		state_machine.transition_deferred("Idle")
