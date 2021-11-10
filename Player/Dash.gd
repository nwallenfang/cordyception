extends Node2D

# refresh GUI
func _process(delta: float) -> void:
	var time_left = $DashCooldown.time_left
	if time_left != 0.0:
		var blend = 1.0 - (time_left / $DashCooldown.wait_time)
		GameStatus.CURRENT_UI.get_node("DashCooldownUI").set_blend(blend)
