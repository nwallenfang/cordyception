extends Node2D

func _on_TriggerArea_body_entered(body: Node) -> void:
	if body as Player == null:
		print("WARNING SOMETHING STRANGE COLLIDING WITH CHECKPOINT")
	
	# pass checkpoint name as "id"
	GameEvents.trigger_event_with_arg("checkpoint_collected", {"name":name, "position":$Position.global_position})
	
