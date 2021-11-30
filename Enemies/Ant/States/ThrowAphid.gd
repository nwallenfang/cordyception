extends AbstractState

export var wait_time := 1.0

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0

func process(delta, first_time_entering):
	parent = parent as AntEnemy

	if first_time_entering:
		var target_aphid : RedAphid = null
		var target_distance = 0.0
		for area in $AphidDetector.get_overlapping_areas():
			var aphid = area.get_parent()
			if !aphid.ready_to_throw:
				continue
			if target_aphid == null:
				target_aphid = aphid
				target_distance = aphid.global_position.distance_to(parent.throw_origin.global_position)
			else:
				if aphid.global_position.distance_to(parent.throw_origin.global_position) < target_distance:
					target_aphid = aphid
					target_distance = aphid.global_position.distance_to(parent.throw_origin.global_position)
		if target_aphid == null:
			back_to_idle()
			return
		target_aphid.throw_origin = parent.throw_origin
		target_aphid.get_node("StateMachine").transition_deferred("GetThrown")
		var player_pos := GameStatus.CURRENT_PLAYER.global_position
		var direction := parent.global_position.direction_to(player_pos) as Vector2
		parent.animation_tree.set("parameters/Throw/blend_position", direction)
		parent.animation_tree.set("parameters/ThrowStart/blend_position", direction)
		parent.animation_state.travel("ThrowStart")
		yield(target_aphid, "ready_to_launch")
		parent.animation_state.travel("Throw")
		yield(get_tree().create_timer(wait_time), "timeout")
		back_to_idle()
