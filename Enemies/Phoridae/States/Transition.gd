extends AbstractState

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta: float, first_time_entering: bool):
	parent = parent as Phoridae
	if first_time_entering:
		parent.levitation_player.stop()
		if parent.aggressive:
			parent.set_facing_direction(parent.global_position.direction_to(GameStatus.CURRENT_PLAYER.global_position))
			parent.levitation_player.play("up")
			parent.animation_player.play("fly_idle")
			parent.flying = true
		else:
			parent.levitation_player.play("down")
			parent.animation_player.play("fly_idle")
			parent.flying = false
		state_machine.update_transition_chances()
		yield(parent.levitation_player, "animation_finished")
#		parent.healthbar.visible = parent.flying
		state_machine.transition_deferred("Idle")
