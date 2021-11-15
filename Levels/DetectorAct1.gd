extends Node2D

func _on_Zone_body_entered(body: Node) -> void:
	GameEvents.trigger_unique_event("dandelion_dialog")

