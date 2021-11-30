extends AbstractState

const RED_APHID = preload("res://Enemies/RedAphid/RedAphid.tscn")

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	if first_time_entering:
		# maybe play a whistling sound
		parent.play_animation("shoot_rapid")
		# instance aphids
		yield(get_tree().create_timer(1.1), "timeout")
		spawn_red_aphid()
		yield(get_tree().create_timer(.5), "timeout")
		spawn_red_aphid()
		yield(parent.sprite, "animation_finished")
		back_to_idle()

func spawn_red_aphid():
	parent = parent as StagBeetle
	var aphid := RED_APHID.instance() as RedAphid
	GameStatus.CURRENT_YSORT.add_child(aphid)
	aphid.is_boss_aphid = true
	aphid.visible = false
	aphid.get_node("StateMachine").start_with_state("Roll")
	yield(get_tree().create_timer(.5), "timeout")
	aphid.visible = true
	aphid.global_position = parent.projectile_origin.global_position + Vector2(0, 5)

