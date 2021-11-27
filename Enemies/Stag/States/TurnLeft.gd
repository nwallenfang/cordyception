extends AbstractState

func _ready() -> void:
	RELATIVE_TRANSITION_CHANCE = 0.0


func process(delta, first_time_entering):
	parent = parent as StagBeetle
	state_machine = state_machine as StagStateMachine
	print(parent.sprite_rotation)
	if first_time_entering:
		var start_rotation = 0
		parent.get_node("AnimatedSprite").play("turn_left")
		print("rotate from ", parent.sprite_rotation, " to ", parent.sprite_rotation + 20)
		$Tween.interpolate_property(parent, "sprite_rotation", parent.sprite_rotation, parent.sprite_rotation + 20, 1.0)
		$Tween.start()
	
	


func _on_Tween_tween_all_completed() -> void:
	state_machine.transition_deferred("Idle")
