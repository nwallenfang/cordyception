extends Node2D
# test
class_name DashStuff

signal add_dash_frame

# refresh GUI
func _process(delta: float) -> void:
	var time_left = $DashCooldown.time_left
	if time_left != 0.0:
		var blend = 1.0 - (time_left / $DashCooldown.wait_time)
		GameStatus.CURRENT_UI.get_node("DashCooldownUI").set_blend(blend)

func is_cooldown_ready() -> bool:
	return $DashCooldown.is_stopped()

func start_dash_effects() -> void:
	$DashParticles.emitting = true
	$DashFrameTimer.start(0.1)
	$DashCooldown.start()

func stop_dash_effects() -> void:
	$DashParticles.emitting = false
	$DashFrameTimer.stop()


func _on_DashFrameTimer_timeout() -> void:
	emit_signal("add_dash_frame")
