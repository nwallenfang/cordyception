extends AbstractState

const RED_APHID = preload("res://Enemies/RedAphid/RedAphid.tscn")

var list_of_aphids := []
export var max_aphids := 2

func get_aphid_list_count() -> int:
	for aph in list_of_aphids:
		if not is_instance_valid(aph) or aph == null:
			list_of_aphids.erase(aph)
	return list_of_aphids.size()

func process(delta, first_time_entering):
	parent = parent as StagBeetle
	if first_time_entering:
		if get_aphid_list_count() >= max_aphids:
			back_to_idle()
			return
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
	list_of_aphids.append(aphid)
	GameStatus.CURRENT_YSORT.add_child(aphid)
	aphid.is_boss_aphid = true
	aphid.visible = false
	aphid.get_node("StateMachine").start_with_state("Roll")
	yield(get_tree().create_timer(.5), "timeout")
	aphid.visible = true
	aphid.global_position = parent.projectile_origin.global_position + Vector2(0, 5)

